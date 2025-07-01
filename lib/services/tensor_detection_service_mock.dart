import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/recipe_image.dart';
import 'object_detection_service.dart';

/// A mock implementation of the object detection service
/// This implementation doesn't use TensorFlow Lite to avoid platform-specific issues
class TensorDetectionServiceMock implements ObjectDetectionService {
  bool _initialized = false;
  List<String> _mockLabels = [
    'apple', 'banana', 'orange', 'strawberry', 'blueberry',
    'carrot', 'broccoli', 'potato', 'tomato', 'onion',
    'chicken', 'beef', 'pork', 'fish', 'shrimp',
    'pasta', 'rice', 'bread', 'cake', 'cookie'
  ];

  // Initialize the service
  @override
  Future<void> initialize() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
    _initialized = true;
    debugPrint('Mock object detection service initialized');
  }

  // Detect objects in an image
  @override
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    // Initialize if not already done
    if (!_initialized) {
      await initialize();
    }

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Generate mock detection results
      final List<DetectedObject> detectedObjects = [];
      
      // Use the image to generate some variation in the results
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      
      // If we can't decode the image, return some default mock results
      if (image == null) {
        return _generateDefaultMockResults(maxResults);
      }
      
      // Use image properties to generate some variation in the results
      final int seed = image.width * image.height % _mockLabels.length;
      
      // Generate mock results based on the image
      for (int i = 0; i < maxResults && i < _mockLabels.length; i++) {
        final index = (seed + i) % _mockLabels.length;
        // Generate a confidence score that decreases with each item
        final confidence = 0.95 - (i * 0.1);
        
        detectedObjects.add(DetectedObject(
          label: _mockLabels[index],
          confidence: confidence > 0.1 ? confidence : 0.1,
        ));
      }

      return detectedObjects;
    } catch (e) {
      debugPrint('Error in mock object detection: $e');
      // Return default mock results in case of error
      return _generateDefaultMockResults(maxResults);
    }
  }
  
  // Generate default mock results
  List<DetectedObject> _generateDefaultMockResults(int maxResults) {
    final List<DetectedObject> detectedObjects = [];
    
    for (int i = 0; i < maxResults && i < 3; i++) {
      detectedObjects.add(DetectedObject(
        label: 'Mock Object ${i + 1}',
        confidence: 0.95 - (i * 0.1),
      ));
    }
    
    return detectedObjects;
  }

  // Dispose of resources
  @override
  void dispose() {
    // No resources to dispose in the mock implementation
    debugPrint('Mock object detection service disposed');
  }
}