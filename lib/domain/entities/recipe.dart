import 'ingredient.dart';
import 'recipe_step.dart';
import 'comment.dart';

class Recipe {
  final String uuid;
  final String name;
  final String images;
  final String description;
  final String instructions;
  final int difficulty;
  final String duration;
  final int rating;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final bool isFavorite;
  final List<Comment> comments;

  Recipe({
    required this.uuid,
    required this.name,
    this.images = '',
    required this.description,
    required this.instructions,
    required this.difficulty,
    required this.duration,
    required this.rating,
    required this.tags,
    this.ingredients = const [],
    this.steps = const [],
    this.isFavorite = false,
    this.comments = const [],
  });



  Recipe copyWith({
    String? uuid,
    String? name,
    String? images,
    String? description,
    String? instructions,
    int? difficulty,
    String? duration,
    int? rating,
    List<String>? tags,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    bool? isFavorite,
    List<Comment>? comments,
  }) {
    return Recipe(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      images: images ?? this.images,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      comments: comments ?? this.comments,
    );
  }
}
