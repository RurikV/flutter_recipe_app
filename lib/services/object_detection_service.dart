import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/recipe_image.dart';

// Helper functions to extract RGB values from a pixel
int getRed(int pixel) => (pixel >> 16) & 0xFF;
int getGreen(int pixel) => (pixel >> 8) & 0xFF;
int getBlue(int pixel) => pixel & 0xFF;

class ObjectDetectionService {
  static const String _modelPath = 'assets/models/mobilenet_v1_1.0_224_quant.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  // Initialize the TensorFlow Lite interpreter
  Future<void> initialize() async {
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

      debugPrint('TensorFlow Lite model loaded successfully');
    } catch (e) {
      debugPrint('Error initializing TensorFlow Lite: $e');
    }
  }

  // Detect objects in an image
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    if (_interpreter == null || _labels == null) {
      await initialize();
      if (_interpreter == null || _labels == null) {
        return [];
      }
    }

    try {
      // Load and preprocess the image
      final imageData = await _loadAndProcessImage(imagePath);
      if (imageData == null) return [];

      // Get output tensor shape
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape.reduce((a, b) => a * b);

      // Create output buffer
      final outputBuffer = Float32List(outputSize);

      // Run inference
      _interpreter!.run(Float32List.fromList(imageData), outputBuffer);

      // Find the top N results
      final List<DetectedObject> detectedObjects = [];

      // Create a list of (index, score) pairs
      final List<MapEntry<int, double>> indexedResults = [];
      for (int i = 0; i < outputBuffer.length; i++) {
        indexedResults.add(MapEntry(i, outputBuffer[i].toDouble()));
      }

      // Sort by score in descending order
      indexedResults.sort((a, b) => b.value.compareTo(a.value));

      // Take the top N results
      for (int i = 0; i < maxResults && i < indexedResults.length; i++) {
        final index = indexedResults[i].key;
        final score = indexedResults[i].value;

        if (index < _labels!.length) {
          detectedObjects.add(DetectedObject(
            label: _labels![index],
            confidence: score,
          ));
        }
      }

      return detectedObjects;
    } catch (e) {
      debugPrint('Error detecting objects: $e');
      return [];
    }
  }

  // Load and process the image for the model
  Future<List<double>?> _loadAndProcessImage(String imagePath) async {
    try {
      // Read the image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Decode the image
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) return null;

      // Resize the image to 224x224 (MobileNet input size)
      final resizedImage = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Convert the image to a list of pixel values
      final inputImageData = List<double>.filled(224 * 224 * 3, 0);

      int pixelIndex = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // Extract RGB values and normalize to [0, 1]
          // In image package 4.x, we need to use the r, g, b properties of the Pixel class
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          inputImageData[pixelIndex++] = r / 255.0;
          inputImageData[pixelIndex++] = g / 255.0;
          inputImageData[pixelIndex++] = b / 255.0;
        }
      }

      return inputImageData;
    } catch (e) {
      debugPrint('Error loading and processing image: $e');
      return null;
    }
  }

  // Dispose of resources
  void dispose() {
    _interpreter?.close();
  }
}
