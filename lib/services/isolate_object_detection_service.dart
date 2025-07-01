import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/recipe_image.dart';
import 'object_detection_service.dart';
import '../custom/tflite_flutter_locator.dart';
import '../custom/list_shape_extension.dart';

/// Message types for communication between isolate and main thread
enum IsolateMessageType {
  initialize,
  detect,
  result,
  error,
}

/// Message structure for communication between isolate and main thread
class IsolateMessage {
  final IsolateMessageType type;
  final dynamic data;

  IsolateMessage(this.type, this.data);

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'data': data,
    };
  }

  factory IsolateMessage.fromJson(Map<String, dynamic> json) {
    return IsolateMessage(
      IsolateMessageType.values[json['type']],
      json['data'],
    );
  }

  String serialize() {
    return jsonEncode(toJson());
  }

  static IsolateMessage deserialize(String data) {
    return IsolateMessage.fromJson(jsonDecode(data));
  }
}

/// Implementation of the object detection service using an isolate
class IsolateObjectDetectionService implements ObjectDetectionService {
  static const String _modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const String _labelsPath = 'assets/models/ssd_mobilenet_labels.txt';

  Isolate? _isolate;
  ReceivePort? _receivePort;
  Stream<dynamic>? _receiveStream;
  SendPort? _sendPort;
  Completer<void>? _initCompleter;
  final Map<String, Completer<List<DetectedObject>>> _detectCompleters = {};
  bool _isInitialized = false;
  bool _initializationFailed = false;

  // Check if we're running in a test environment
  bool _isInTestEnvironment() {
    try {
      return const bool.fromEnvironment('FLUTTER_TEST');
    } catch (e) {
      return true; // If there's an exception, assume we're in a test
    }
  }

  // Load the labels from the assets
  Future<List<String>> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelsPath);
      return labelsData.split('\n');
    } catch (e) {
      debugPrint('Error loading labels: $e');
      return [];
    }
  }

  // Load the model file from assets
  Future<Uint8List> _loadModelFile() async {
    try {
      final modelData = await rootBundle.load(_modelPath);
      return modelData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading model file: $e');
      return Uint8List(0);
    }
  }

  @override
  Future<void> initialize() async {
    // Skip initialization if it has already been initialized or failed
    if (_isInitialized || _initializationFailed) {
      return;
    }

    // Skip initialization if we're in a test environment
    if (_isInTestEnvironment()) {
      _initializationFailed = true;
      debugPrint('Skipping TensorFlow Lite initialization in test environment');
      return;
    }

    _initCompleter = Completer<void>();

    try {
      // Load the labels and model file in the main isolate
      final labels = await _loadLabels();
      final modelBytes = await _loadModelFile();

      // Create a receive port for communication with the isolate
      _receivePort = ReceivePort();

      // Spawn the isolate
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _receivePort!.sendPort,
      );

      // Convert to broadcast stream so it can have multiple listeners
      _receiveStream = _receivePort!.asBroadcastStream();

      // Listen for messages from the isolate
      _receiveStream!.listen(_handleIsolateMessage);

      // Wait for the isolate to send its SendPort
      await _waitForSendPort();

      // Send initialization message to the isolate with the labels and model bytes
      final message = IsolateMessage(
        IsolateMessageType.initialize, 
        {
          'labels': labels,
          'modelBytes': modelBytes,
        }
      );
      _sendPort!.send(message.serialize());

      // Wait for initialization to complete
      await _initCompleter!.future;
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing isolate: $e');
      _initializationFailed = true;
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.completeError(e);
      }
    }
  }

  Future<void> _waitForSendPort() async {
    final completer = Completer<void>();

    // Create a subscription to listen for the SendPort
    late StreamSubscription subscription;
    subscription = _receiveStream!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
        subscription.cancel();
      }
    });

    return completer.future;
  }

  void _handleIsolateMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      return;
    }

    if (message is String) {
      final isolateMessage = IsolateMessage.deserialize(message);

      switch (isolateMessage.type) {
        case IsolateMessageType.result:
          final String requestId = isolateMessage.data['requestId'];
          final List<dynamic> detectedObjectsJson = isolateMessage.data['detectedObjects'];

          // Convert JSON to DetectedObject list
          final List<DetectedObject> detectedObjects = detectedObjectsJson
              .map((json) => DetectedObject.fromJson(json))
              .toList();

          // Complete the completer for this request
          _detectCompleters[requestId]?.complete(detectedObjects);
          _detectCompleters.remove(requestId);
          break;

        case IsolateMessageType.error:
          final String requestId = isolateMessage.data['requestId'];
          final String errorMessage = isolateMessage.data['error'];

          // Complete the completer with an error
          _detectCompleters[requestId]?.completeError(Exception(errorMessage));
          _detectCompleters.remove(requestId);
          break;

        case IsolateMessageType.initialize:
          if (isolateMessage.data['success'] == true) {
            if (_initCompleter != null && !_initCompleter!.isCompleted) {
              _initCompleter!.complete();
            }
          } else {
            _initializationFailed = true;
            if (_initCompleter != null && !_initCompleter!.isCompleted) {
              _initCompleter!.completeError(Exception(isolateMessage.data['error']));
            }
          }
          break;

        default:
          debugPrint('Unknown message type: ${isolateMessage.type}');
      }
    }
  }

  @override
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    // Return empty results if initialization has failed
    if (_initializationFailed) {
      return [];
    }

    // Try to initialize if not already done
    if (!_isInitialized) {
      await initialize();
      if (_initializationFailed) {
        return [];
      }
    }

    try {
      // Generate a unique request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a completer for this request
      final completer = Completer<List<DetectedObject>>();
      _detectCompleters[requestId] = completer;

      // Read the image file as bytes
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Send the detection request to the isolate
      final message = IsolateMessage(
        IsolateMessageType.detect,
        {
          'requestId': requestId,
          'imagePath': imagePath,
          'imageBytes': imageBytes,
          'maxResults': maxResults,
        },
      );

      _sendPort!.send(message.serialize());

      // Wait for the result
      return await completer.future;
    } catch (e) {
      debugPrint('Error detecting objects: $e');
      return [];
    }
  }

  @override
  void dispose() {
    // Kill the isolate
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    // Close the receive port
    _receivePort?.close();
    _receivePort = null;

    // Clear the receive stream
    _receiveStream = null;

    // Clear the send port
    _sendPort = null;

    // Clear the completers
    _initCompleter = null;
    _detectCompleters.clear();

    _isInitialized = false;
  }

  // Entry point for the isolate
  static void _isolateEntryPoint(SendPort mainSendPort) async {
    // Do not initialize WidgetsFlutterBinding in the isolate as it causes UI-related errors
    // We'll pass the necessary data from the main isolate instead

    // Create a receive port for receiving messages from the main isolate
    final receivePort = ReceivePort();

    // Send the send port to the main isolate
    mainSendPort.send(receivePort.sendPort);

    Interpreter? interpreter;
    List<String>? labels;
    bool isInitialized = false;

    // Listen for messages from the main isolate
    receivePort.listen((message) async {
      if (message is String) {
        final isolateMessage = IsolateMessage.deserialize(message);

        switch (isolateMessage.type) {
          case IsolateMessageType.initialize:
            try {
              // Get the labels and model bytes passed from the main isolate
              labels = List<String>.from(isolateMessage.data['labels'] ?? []);

              // Convert List<dynamic> to Uint8List
              final modelBytesList = isolateMessage.data['modelBytes'] as List<dynamic>;
              final modelBytes = Uint8List.fromList(modelBytesList.cast<int>());

              // Create the interpreter from the model bytes
              final interpreterOptions = InterpreterOptions();
              interpreter = Interpreter.fromBuffer(
                modelBytes,
                options: interpreterOptions,
              );

              isInitialized = true;

              // Send success message back to main isolate
              final resultMessage = IsolateMessage(
                IsolateMessageType.initialize,
                {'success': true},
              );
              mainSendPort.send(resultMessage.serialize());
            } catch (e) {
              // Send error message back to main isolate
              final errorMessage = IsolateMessage(
                IsolateMessageType.initialize,
                {'success': false, 'error': e.toString()},
              );
              mainSendPort.send(errorMessage.serialize());
            }
            break;

          case IsolateMessageType.detect:
            final requestId = isolateMessage.data['requestId'];
            final imagePath = isolateMessage.data['imagePath'];
            // Convert List<dynamic> to Uint8List
            final imageBytesList = isolateMessage.data['imageBytes'] as List<dynamic>;
            final Uint8List imageBytes = Uint8List.fromList(imageBytesList.cast<int>());
            final int maxResults = isolateMessage.data['maxResults'];

            try {
              if (!isInitialized || interpreter == null || labels == null) {
                throw Exception('Object detection service not initialized');
              }

              // Decode the image
              final image = img.decodeImage(imageBytes);
              if (image == null) {
                throw Exception('Failed to decode image');
              }

              // Get the original image dimensions
              final imageHeight = image.height;
              final imageWidth = image.width;

              // Resize the image to 300x300 (SSD MobileNet input size)
              final resizedImage = img.copyResize(
                image,
                width: 300,
                height: 300,
              );

              // Convert the image to a Float32List
              final inputImageData = _imageToByteList(resizedImage);

              // Prepare output tensors
              final outputLocations = List<double>.filled(1 * 10 * 4, 0.0).reshape<double>([1, 10, 4]);
              final outputClasses = List<double>.filled(1 * 10, 0.0).reshape<double>([1, 10]);
              final outputScores = List<double>.filled(1 * 10, 0.0).reshape<double>([1, 10]);
              final numDetections = List<double>.filled(1, 0.0).reshape<double>([1]);

              // Define inputs and outputs
              final inputs = [inputImageData];
              final outputs = <int, Object>{
                0: outputLocations,
                1: outputClasses,
                2: outputScores,
                3: numDetections,
              };

              // Run inference
              interpreter!.runForMultipleInputs(inputs, outputs);

              // Process results
              final List<Map<String, dynamic>> detectedObjectsJson = [];
              final numDetected = numDetections[0].toInt();

              for (int i = 0; i < numDetected && i < maxResults; i++) {
                final score = outputScores[0][i];
                final classIndex = outputClasses[0][i].toInt();

                // Skip if score is too low or class index is invalid
                if (score < 0.5 || classIndex >= labels!.length) continue;

                // Get bounding box coordinates (normalized)
                final top = outputLocations[0][i][0];
                final left = outputLocations[0][i][1];
                final bottom = outputLocations[0][i][2];
                final right = outputLocations[0][i][3];

                // Convert normalized coordinates to actual pixel values
                final boundingBox = <String, double>{
                  'top': top * imageHeight,
                  'left': left * imageWidth,
                  'bottom': bottom * imageHeight,
                  'right': right * imageWidth,
                };

                detectedObjectsJson.add({
                  'label': labels![classIndex],
                  'confidence': score,
                  'boundingBox': boundingBox,
                });
              }

              // Sort by confidence score in descending order
              detectedObjectsJson.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

              // Take only the top results
              final topResults = detectedObjectsJson.take(maxResults).toList();

              // Send the results back to the main isolate
              final resultMessage = IsolateMessage(
                IsolateMessageType.result,
                {
                  'requestId': requestId,
                  'detectedObjects': topResults,
                },
              );
              mainSendPort.send(resultMessage.serialize());
            } catch (e) {
              // Send error message back to main isolate
              final errorMessage = IsolateMessage(
                IsolateMessageType.error,
                {
                  'requestId': requestId,
                  'error': e.toString(),
                },
              );
              mainSendPort.send(errorMessage.serialize());
            }
            break;

          default:
            print('Unknown message type: ${isolateMessage.type}');
        }
      }
    });
  }

  // Convert image to input format for SSD MobileNet
  static List _imageToByteList(img.Image image) {
    final inputSize = 300;
    final result = Uint8List(1 * inputSize * inputSize * 3);
    var index = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        // Use uint8 values (0-255) directly, converting num to int
        result[index++] = pixel.r.toInt();
        result[index++] = pixel.g.toInt();
        result[index++] = pixel.b.toInt();
      }
    }

    // Reshape the flat array to 4D tensor with shape [1, height, width, channels]
    return result.reshape<int>([1, inputSize, inputSize, 3]);
  }
}
