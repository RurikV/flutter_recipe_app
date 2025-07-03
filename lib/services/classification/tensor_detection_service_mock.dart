import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/recipe_image.dart';
import 'object_detection_service.dart';

/// A mock implementation of the tensor detection service for testing
class TensorDetectionServiceMock implements ObjectDetectionService {
  bool _isInitialized = false;
  final List<String> _mockLabels = [
    'test_apple', 'test_banana', 'test_orange', 'test_strawberry', 'test_blueberry',
    'test_carrot', 'test_broccoli', 'test_potato', 'test_tomato', 'test_onion',
    'test_chicken', 'test_beef', 'test_pork', 'test_fish', 'test_shrimp',
    'test_pasta', 'test_rice', 'test_bread', 'test_cake', 'test_cookie'
  ];
  final Random _random = Random(42); // Fixed seed for reproducible results in tests

  @override
  Future<void> initialize() async {
    // Fast initialization for tests
    await Future.delayed(const Duration(milliseconds: 10));
    _isInitialized = true;
    debugPrint('Mock tensor detection service initialized');
  }

  @override
  Future<List<DetectedObject>> detectObjects(RecipeImage image) async {
    // Initialize if not already done
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Fast processing for tests
      await Future.delayed(const Duration(milliseconds: 10));

      // Generate mock detection results
      final List<DetectedObject> detectedObjects = [];

      // Generate a deterministic seed based on the image path
      final int seed = image.path.hashCode % _mockLabels.length;

      // Generate 2-4 mock detections
      final int numDetections = 2 + _random.nextInt(3);

      for (int i = 0; i < numDetections; i++) {
        // Pick a label based on the seed
        final int labelIndex = (seed + i) % _mockLabels.length;
        final String label = _mockLabels[labelIndex];
        
        // Generate confidence score that decreases with each detection
        final double confidence = 0.9 - (i * 0.1);
        if (confidence < 0.5) continue; // Skip low confidence detections
        
        // Generate bounding box
        final double left = 0.1 + (_random.nextDouble() * 0.6);
        final double top = 0.1 + (_random.nextDouble() * 0.6);
        final double width = 0.1 + (_random.nextDouble() * 0.2);
        final double height = 0.1 + (_random.nextDouble() * 0.2);
        
        detectedObjects.add(DetectedObject(
          label: label,
          confidence: confidence,
          boundingBox: Rect(
            left: left,
            top: top,
            right: left + width,
            bottom: top + height,
          ),
        ));
      }

      // Sort by confidence score in descending order
      detectedObjects.sort((a, b) => b.confidence.compareTo(a.confidence));
      
      return detectedObjects;
    } catch (e) {
      debugPrint('Error in mock tensor detection: $e');
      return [];
    }
  }

  @override
  bool get isInitialized => _isInitialized;
}