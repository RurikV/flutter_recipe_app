import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';

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
  final List<Ingredient> ingredients; // New field for ingredients
  final List<RecipeStep> steps; // New field for recipe steps

  Recipe({
    required this.uuid,
    required this.name,
    required this.images,
    required this.description,
    required this.instructions,
    required this.difficulty,
    required this.duration,
    required this.rating,
    required this.tags,
    this.ingredients = const [],
    this.steps = const [],
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
      duration: json['duration'] as String,
      rating: json['rating'] as int,
      tags: List<String>.from(json['tags']),
      ingredients: json['ingredients'] != null
          ? List<Ingredient>.from(
              (json['ingredients'] as List).map(
                (x) => Ingredient.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      steps: json['steps'] != null
          ? List<RecipeStep>.from(
              (json['steps'] as List).map(
                (x) => RecipeStep.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
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
      'duration': duration,
      'rating': rating,
      'tags': tags,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }
}
