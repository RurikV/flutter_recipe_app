import 'dart:convert';

class RecipeImage {
  final String path;
  final List<DetectedObject> detectedObjects;

  RecipeImage({
    required this.path,
    this.detectedObjects = const [],
  });

  factory RecipeImage.fromJson(Map<String, dynamic> json) {
    return RecipeImage(
      path: json['path'] as String,
      detectedObjects: json['detectedObjects'] != null
          ? List<DetectedObject>.from(
              (json['detectedObjects'] as List).map(
                (x) => DetectedObject.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'detectedObjects': detectedObjects.map((e) => e.toJson()).toList(),
    };
  }

  // Creates a copy of the recipe image with the given fields replaced with the new values
  RecipeImage copyWith({
    String? path,
    List<DetectedObject>? detectedObjects,
  }) {
    return RecipeImage(
      path: path ?? this.path,
      detectedObjects: detectedObjects ?? this.detectedObjects,
    );
  }

  // Convert to and from a JSON string for storage in the database
  static String encodeList(List<RecipeImage> images) {
    return jsonEncode(images.map((image) => image.toJson()).toList());
  }

  static List<RecipeImage> decodeList(String encodedImages) {
    if (encodedImages.isEmpty) return [];
    
    try {
      final List<dynamic> decodedList = jsonDecode(encodedImages);
      return decodedList
          .map((item) => RecipeImage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If decoding fails, return an empty list
      return [];
    }
  }
}

class DetectedObject {
  final String label;
  final double confidence;
  final Map<String, double>? boundingBox;

  DetectedObject({
    required this.label,
    required this.confidence,
    this.boundingBox,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
      boundingBox: json['boundingBox'] != null
          ? Map<String, double>.from(json['boundingBox'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'boundingBox': boundingBox,
    };
  }
}