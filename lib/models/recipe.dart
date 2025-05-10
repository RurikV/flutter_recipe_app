import 'dart:convert';

class Recipe {
  final String uuid;
  final String name;
  final String images; // This should ideally be a single image URL string
  final String description;
  final String instructions;
  final int difficulty; // Will be removed from the card display
  final String duration; // New field for cooking time
  final int rating;     // Will be removed from the card display
  final List<String> tags; // Will be removed from the card display

  Recipe({
    required this.uuid,
    required this.name,
    required this.images,
    required this.description,
    required this.instructions,
    required this.difficulty,
    required this.duration, // Add to constructor
    required this.rating,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      // Assuming 'images' in your JSON is a single URL string.
      // If it's a list, you might need to adjust how you pick an image.
      images: json['images'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      difficulty: json['difficulty'] as int,
      duration: json['duration'] as String, // Parse duration
      rating: json['rating'] as int,
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'images': images,
      'description': description,
      'instructions': instructions,
      'difficulty': difficulty,
      'duration': duration, // Add to JSON
      'rating': rating,
      'tags': tags,
    };
  }
}