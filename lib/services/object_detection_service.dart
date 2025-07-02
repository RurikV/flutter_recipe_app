import '../models/recipe_image.dart';

/// Abstract base class for object detection services
abstract class ObjectDetectionService {
  /// Initialize the object detection service
  Future<void> initialize();

  /// Detect objects in an image
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5});

  /// Dispose of resources
  void dispose();
}

/// Factory for creating the appropriate object detection service based on the platform
class ObjectDetectionServiceFactory {
  static ObjectDetectionService create() {
    // Use conditional imports to create the appropriate implementation
    // This will be handled by the service_locator
    throw UnimplementedError('Use service_locator to get the appropriate implementation');
  }
}