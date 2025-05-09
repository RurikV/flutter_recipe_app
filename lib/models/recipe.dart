import 'dart:convert';

class Recipe {
  final String uuid;
  final String name;
  final String images;
  final String description;
  final String instructions;
  final int difficulty;
  final int rating;
  final List<String> tags;

  Recipe({
    required this.uuid,
    required this.name,
    required this.images,
    required this.description,
    required this.instructions,
    required this.difficulty,
    required this.rating,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      images: json['images'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      difficulty: json['difficulty'] as int,
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
      'rating': rating,
      'tags': tags,
    };
  }
}