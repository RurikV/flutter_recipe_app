import '../../../data/models/recipe_image.dart' as model;

/// Base class for object detection services
abstract class ObjectDetectionService {
  /// Initialize the object detection service
  Future<void> initialize();

  /// Detect objects in an image
  Future<List<ServiceDetectedObject>> detectObjects(model.RecipeImage image);

  /// Check if the service is initialized
  bool get isInitialized;
}

/// Represents an object detected in an image by the service
class ServiceDetectedObject {
  final String label;
  final double confidence;
  final Rect boundingBox;

  ServiceDetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() {
    return 'ServiceDetectedObject(label: $label, confidence: ${confidence.toStringAsFixed(2)}, boundingBox: $boundingBox)';
  }

  /// Convert to a model.DetectedObject
  model.DetectedObject toModelDetectedObject() {
    return model.DetectedObject(
      label: label,
      confidence: confidence,
      boundingBox: {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
    );
  }

  /// Create from a model.DetectedObject
  factory ServiceDetectedObject.fromModelDetectedObject(model.DetectedObject obj) {
    final Map<String, double> box = obj.boundingBox ?? {'left': 0, 'top': 0, 'right': 0, 'bottom': 0};
    return ServiceDetectedObject(
      label: obj.label,
      confidence: obj.confidence,
      boundingBox: Rect(
        left: box['left'] ?? 0,
        top: box['top'] ?? 0,
        right: box['right'] ?? 0,
        bottom: box['bottom'] ?? 0,
      ),
    );
  }
}

/// Represents a bounding box for a detected object
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;

  @override
  String toString() {
    return 'Rect(left: ${left.toStringAsFixed(2)}, top: ${top.toStringAsFixed(2)}, right: ${right.toStringAsFixed(2)}, bottom: ${bottom.toStringAsFixed(2)})';
  }
}
