import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/tflite_flutter_locator.dart';
import '../custom/list_shape_extension.dart';
import 'package:image/image.dart' as img;
import '../models/recipe_image.dart';

class SSDObjectDetectionService {
  static const String _modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const String _labelsPath = 'assets/models/ssd_mobilenet_labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _initializationFailed = false;

  // Check if we're running in a test environment
  bool _isInTestEnvironment() {
    try {
      return const bool.fromEnvironment('FLUTTER_TEST');
    } catch (e) {
      return true; // If there's an exception, assume we're in a test
    }
  }

  // Initialize the TensorFlow Lite interpreter
  Future<void> initialize() async {
    // Skip initialization if it has already failed or if we're in a test environment
    if (_initializationFailed || _isInTestEnvironment()) {
      _initializationFailed = true;
      debugPrint('Skipping TensorFlow Lite initialization in test environment');
      return;
    }

    try {
      // Load the model
      final interpreterOptions = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: interpreterOptions,
      );

      // Load the labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData.split('\n');

      debugPrint('TensorFlow Lite SSD model loaded successfully');
    } catch (e) {
      debugPrint('Error initializing TensorFlow Lite SSD model: $e');
      _initializationFailed = true;
    }
  }

  // Detect objects in an image
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    // Return empty results if initialization has failed
    if (_initializationFailed) {
      return [];
    }

    // Try to initialize if not already done
    if (_interpreter == null || _labels == null) {
      await initialize();
      if (_interpreter == null || _labels == null || _initializationFailed) {
        return [];
      }
    }

    try {
      // Load and preprocess the image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) return [];

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
      // Output format for SSD MobileNet:
      // [1, 10, 4] - bounding boxes (top, left, bottom, right)
      // [1, 10] - class indices
      // [1, 10] - confidence scores
      // [1] - number of detections
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
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // Process results
      final List<DetectedObject> detectedObjects = [];
      final numDetected = numDetections[0].toInt();

      for (int i = 0; i < numDetected && i < maxResults; i++) {
        final score = outputScores[0][i];
        final classIndex = outputClasses[0][i].toInt();

        // Skip if score is too low or class index is invalid
        if (score < 0.5 || classIndex >= _labels!.length) continue;

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

        detectedObjects.add(DetectedObject(
          label: _labels![classIndex],
          confidence: score,
          boundingBox: boundingBox,
        ));
      }

      // Sort by confidence score in descending order
      detectedObjects.sort((a, b) => b.confidence.compareTo(a.confidence));

      // Take only the top results
      return detectedObjects.take(maxResults).toList();
    } catch (e) {
      debugPrint('Error detecting objects with SSD model: $e');
      return [];
    }
  }

  // Convert image to input format for SSD MobileNet
  Float32List _imageToByteList(img.Image image) {
    final inputSize = 300;
    final result = Float32List(1 * inputSize * inputSize * 3);
    var index = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        // Normalize pixel values to [-1, 1]
        result[index++] = (pixel.r / 127.5) - 1.0;
        result[index++] = (pixel.g / 127.5) - 1.0;
        result[index++] = (pixel.b / 127.5) - 1.0;
      }
    }

    return result;
  }

  // Dispose of resources
  void dispose() {
    _interpreter?.close();
  }
}