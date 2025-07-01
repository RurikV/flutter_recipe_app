import 'package:flutter/material.dart';
import '../models/recipe_image.dart';
import 'object_detection_service.dart';

/// Web implementation of the object detection service
/// This implementation doesn't use TensorFlow Lite since it's not available on web
class WebObjectDetectionService implements ObjectDetectionService {
  // No need to track initialization state for web implementation

  @override
  Future<void> initialize() async {
    // No actual initialization needed for web
    debugPrint('Web object detection service initialized');
  }

  @override
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    // For web, we return a mock implementation with empty results
    // In a real application, you might want to use a web-compatible object detection service
    // or implement server-side detection
    debugPrint('Web object detection service: detectObjects called with $imagePath');

    // Return empty list as we can't perform object detection on web
    return [];

    // Alternatively, you could return mock data for testing:
    /*
    return [
      DetectedObject(
        label: 'Mock Object 1',
        confidence: 0.95,
        boundingBox: {
          'top': 10.0,
          'left': 10.0,
          'bottom': 100.0,
          'right': 100.0,
        },
      ),
      DetectedObject(
        label: 'Mock Object 2',
        confidence: 0.85,
        boundingBox: {
          'top': 50.0,
          'left': 50.0,
          'bottom': 150.0,
          'right': 150.0,
        },
      ),
    ];
    */
  }

  @override
  void dispose() {
    // No resources to dispose for web implementation
    debugPrint('Web object detection service disposed');
  }
}
