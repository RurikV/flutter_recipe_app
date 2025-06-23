import 'ingredient.dart';
import 'recipe_step.dart';
import 'comment.dart';

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
  final bool isFavorite; // Flag to mark recipe as favorite
  final List<Comment> comments; // List of comments for the recipe

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
    this.isFavorite = false,
    this.comments = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle the API response structure which uses 'id' instead of 'uuid'
    // and 'photo' instead of 'images'
    return Recipe(
      uuid: (json['uuid'] ?? json['id']?.toString() ?? '0') as String,
      name: json['name'] as String,
      // API uses 'photo' for image URL
      images: (json['images'] ?? json['photo'] ?? 'default.png') as String,
      // Provide default values for potentially missing fields
      description: (json['description'] ?? '') as String,
      instructions: (json['instructions'] ?? '') as String,
      difficulty: (json['difficulty'] ?? 0) as int,
      // Handle duration which could be an int or a String
      duration: json['duration'] is int 
          ? (json['duration'] as int).toString() 
          : (json['duration'] ?? '0') as String,
      rating: (json['rating'] ?? 0) as int,
      // Handle potentially missing tags
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      // Handle ingredients from different API structures
      ingredients: json['ingredients'] != null
          ? List<Ingredient>.from(
              (json['ingredients'] as List).map(
                (x) => Ingredient.fromJson(x as Map<String, dynamic>),
              ),
            )
          : json['recipeIngredients'] != null
              ? List<Ingredient>.from(
                  (json['recipeIngredients'] as List).map(
                    (x) {
                      // Extract ingredient from recipeIngredient
                      final ingredientData = x['ingredient'] as Map<String, dynamic>?;
                      final count = x['count']?.toString() ?? '';

                      if (ingredientData != null) {
                        // Create ingredient with data from the relationship
                        return Ingredient(
                          name: ingredientData['name'] as String? ?? '',
                          quantity: count,
                          unit: ingredientData['measureUnit'] != null 
                              ? (ingredientData['measureUnit']['one'] as String? ?? '') 
                              : '',
                        );
                      } else {
                        // Fallback if ingredient data is missing
                        return Ingredient(name: '', quantity: '', unit: '');
                      }
                    },
                  ),
                )
              : [],
      // Handle steps from different API structures
      steps: json['steps'] != null
          ? List<RecipeStep>.from(
              (json['steps'] as List).map(
                (x) => RecipeStep.fromJson(x as Map<String, dynamic>),
              ),
            )
          : json['recipesteplink'] != null
              ? List<RecipeStep>.from(
                  (json['recipesteplink'] as List).map(
                    (x) => RecipeStep.fromJson(x as Map<String, dynamic>),
                  ),
                )
              : json['recipeStepLinks'] != null
                  ? List<RecipeStep>.from(
                      (json['recipeStepLinks'] as List).map(
                        (x) {
                          // Extract step from recipeStepLink
                          final stepData = x['step'] as Map<String, dynamic>?;
                          final number = x['number']?.toString() ?? '';

                          if (stepData != null) {
                            // Create step with data from the relationship
                            return RecipeStep(
                              description: stepData['name'] as String? ?? '',
                              duration: stepData['duration'] is int 
                                  ? (stepData['duration'] as int).toString() 
                                  : (stepData['duration'] ?? '0') as String,
                            );
                          } else {
                            // Fallback if step data is missing
                            return RecipeStep(description: '', duration: '0');
                          }
                        },
                      ),
                    )
                  : [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      comments: json['comments'] != null
          ? List<Comment>.from(
              (json['comments'] as List).map(
                (x) => Comment.fromJson(x as Map<String, dynamic>),
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
      'isFavorite': isFavorite,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  // Creates a copy of the recipe with the given fields replaced with the new values
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
