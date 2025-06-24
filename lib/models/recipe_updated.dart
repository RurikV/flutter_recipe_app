import 'package:json_annotation/json_annotation.dart';
import 'ingredient.dart';
import 'recipe_step.dart';
import 'comment.dart';
import 'recipe_ingredient.dart';
import 'recipe_step_link.dart';
import 'recipe_image.dart';

part 'recipe_updated.g.dart';

@JsonSerializable(explicitToJson: true)
class Recipe {
  final int id;
  final String uuid; // For backward compatibility
  final String name;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<RecipeImage> recipeImages; // New field for multiple images with detected objects

  @JsonKey(name: 'photo')
  final String images; // For backward compatibility - will store JSON string of recipeImages

  final String description;
  final String instructions;
  final int difficulty;

  @JsonKey(name: 'duration')
  final int durationMinutes;

  final String durationStr; // For backward compatibility
  final int rating;
  final List<String> tags;

  @JsonKey(name: 'recipeIngredients')
  final List<RecipeIngredient>? recipeIngredients;

  @JsonKey(name: 'recipeStepLinks')
  final List<RecipeStepLink>? stepLinks;

  final List<Ingredient> ingredients; // For backward compatibility
  final List<RecipeStep> steps; // For backward compatibility

  final bool isFavorite;
  final List<Comment> comments;

  Recipe({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.images,
    List<RecipeImage>? recipeImages,
    required this.description,
    required this.instructions,
    required this.difficulty,
    required this.durationStr,
    this.durationMinutes = 0,
    required this.rating,
    required this.tags,
    this.ingredients = const [],
    this.steps = const [],
    this.recipeIngredients,
    this.stepLinks,
    this.isFavorite = false,
    this.comments = const [],
  }) : recipeImages = recipeImages ?? _parseRecipeImages(images);

  // Helper method to parse recipe images from a string
  static List<RecipeImage> _parseRecipeImages(String imagesStr) {
    if (imagesStr.isEmpty) {
      return [];
    }

    // Check if it's a JSON string of RecipeImage objects
    try {
      return RecipeImage.decodeList(imagesStr);
    } catch (e) {
      // If it's not a valid JSON string, treat it as a single image URL
      final validUrl = _getValidImageUrl(imagesStr);
      return [RecipeImage(path: validUrl)];
    }
  }

  // Helper method to ensure image URL is valid
  static String _getValidImageUrl(String url) {
    // Check if the URL is a valid HTTP or HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Check if it's a file path (starts with /)
    if (url.startsWith('/')) {
      return url;
    }

    // If it's just a filename like "default.png", use a placeholder
    return 'https://placehold.co/400x300/png?text=No+Image';
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle the API response structure which uses 'id' instead of 'uuid'
    // and 'photo' instead of 'images'
    final id = json['id'] as int? ?? 0;
    final uuid = (json['uuid'] ?? id.toString()) as String;
    final name = json['name'] as String;

    // Process images - could be a string, a list of RecipeImage objects, or a JSON string
    String imagesStr = '';
    List<RecipeImage> recipeImages = [];

    if (json['images'] != null) {
      if (json['images'] is String) {
        imagesStr = json['images'] as String;
        recipeImages = _parseRecipeImages(imagesStr);
      } else if (json['images'] is List) {
        // If it's already a list, convert each item to a RecipeImage
        recipeImages = (json['images'] as List)
            .map((img) => img is Map<String, dynamic> 
                ? RecipeImage.fromJson(img) 
                : RecipeImage(path: _getValidImageUrl(img.toString())))
            .toList();
        // Convert the list to a JSON string for storage
        imagesStr = RecipeImage.encodeList(recipeImages);
      }
    } else if (json['photo'] != null) {
      // Handle legacy 'photo' field
      imagesStr = json['photo'] as String;
      recipeImages = _parseRecipeImages(imagesStr);
    } else {
      // Default placeholder
      imagesStr = 'https://placehold.co/400x300/png?text=No+Image';
      recipeImages = [RecipeImage(path: imagesStr)];
    }

    final description = (json['description'] ?? '') as String;
    final instructions = (json['instructions'] ?? '') as String;
    final difficulty = (json['difficulty'] ?? 0) as int;

    // Handle duration which could be an int or a String
    final durationMinutes = json['duration'] is int ? json['duration'] as int : 0;
    final durationStr = json['duration'] is int 
        ? (json['duration'] as int).toString() 
        : (json['duration'] ?? '0') as String;

    final rating = (json['rating'] ?? 0) as int;

    // Handle potentially missing tags
    final tags = json['tags'] != null 
        ? List<String>.from(json['tags']) 
        : <String>[];

    // Handle ingredients from different API structures
    List<Ingredient> ingredients = [];
    List<RecipeIngredient>? recipeIngredients;

    if (json['ingredients'] != null) {
      ingredients = List<Ingredient>.from(
        (json['ingredients'] as List).map(
          (x) {
            if (x is Map<String, dynamic>) {
              // Try to convert to the new Ingredient model
              try {
                return Ingredient.fromJson(x);
              } catch (e) {
                // If that fails, use the simple constructor
                return Ingredient.simple(
                  name: x['name'] as String? ?? '',
                  quantity: x['quantity'] as String? ?? '',
                  unit: x['unit'] as String? ?? '',
                );
              }
            } else {
              return Ingredient.simple(name: '', quantity: '', unit: '');
            }
          },
        ),
      );
    } else if (json['recipeIngredients'] != null) {
      // Parse recipeIngredients
      recipeIngredients = List<RecipeIngredient>.from(
        (json['recipeIngredients'] as List).map(
          (x) => RecipeIngredient.fromJson(x as Map<String, dynamic>),
        ),
      );

      // Also create simple ingredients for backward compatibility
      ingredients = List<Ingredient>.from(
        (json['recipeIngredients'] as List).map(
          (x) {
            final ingredientData = x['ingredient'] as Map<String, dynamic>?;
            final count = x['count']?.toString() ?? '';

            if (ingredientData != null) {
              return Ingredient.simple(
                name: ingredientData['name'] as String? ?? '',
                quantity: count,
                unit: ingredientData['measureUnit'] != null 
                    ? (ingredientData['measureUnit']['one'] as String? ?? '') 
                    : '',
              );
            } else {
              return Ingredient.simple(name: '', quantity: '', unit: '');
            }
          },
        ),
      );
    }

    // Handle steps from different API structures
    List<RecipeStep> steps = [];
    List<RecipeStepLink>? stepLinks;

    if (json['steps'] != null) {
      steps = List<RecipeStep>.from(
        (json['steps'] as List).map(
          (x) {
            if (x is Map<String, dynamic>) {
              // Try to convert to the new RecipeStep model
              try {
                return RecipeStep.fromJson(x);
              } catch (e) {
                // If that fails, use the simple constructor
                return RecipeStep(
                  id: 0,
                  name: x['description'] as String? ?? '',
                  duration: int.tryParse(x['duration'] as String? ?? '0') ?? 0,
                  isCompleted: x['isCompleted'] as bool? ?? false,
                );
              }
            } else {
              return RecipeStep(
                id: 0,
                name: '',
                duration: 0,
                isCompleted: false,
              );
            }
          },
        ),
      );
    } else if (json['recipeStepLinks'] != null) {
      // Parse stepLinks
      stepLinks = List<RecipeStepLink>.from(
        (json['recipeStepLinks'] as List).map(
          (x) => RecipeStepLink.fromJson(x as Map<String, dynamic>),
        ),
      );

      // Also create simple steps for backward compatibility
      steps = List<RecipeStep>.from(
        (json['recipeStepLinks'] as List).map(
          (x) {
            final stepData = x['step'] as Map<String, dynamic>?;

            if (stepData != null) {
              return RecipeStep(
                id: 0,
                name: stepData['name'] as String? ?? '',
                duration: stepData['duration'] is int 
                    ? stepData['duration'] as int
                    : int.tryParse(stepData['duration'] as String? ?? '0') ?? 0,
                isCompleted: false,
              );
            } else {
              return RecipeStep(
                id: 0,
                name: '',
                duration: 0,
                isCompleted: false,
              );
            }
          },
        ),
      );
    }

    final isFavorite = json['isFavorite'] as bool? ?? false;

    List<Comment> comments = [];
    if (json['comments'] != null) {
      comments = List<Comment>.from(
        (json['comments'] as List).map(
          (x) => Comment.fromJson(x as Map<String, dynamic>),
        ),
      );
    }

    return Recipe(
      id: id,
      uuid: uuid,
      name: name,
      images: imagesStr,
      recipeImages: recipeImages,
      description: description,
      instructions: instructions,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      durationStr: durationStr,
      rating: rating,
      tags: tags,
      ingredients: ingredients,
      steps: steps,
      recipeIngredients: recipeIngredients,
      stepLinks: stepLinks,
      isFavorite: isFavorite,
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$RecipeToJson(this);
    // Update the 'photo' field with the encoded recipeImages
    if (recipeImages.isNotEmpty) {
      json['photo'] = RecipeImage.encodeList(recipeImages);
    }
    return json;
  }

  // Creates a copy of the recipe with the given fields replaced with the new values
  Recipe copyWith({
    int? id,
    String? uuid,
    String? name,
    String? images,
    List<RecipeImage>? recipeImages,
    String? description,
    String? instructions,
    int? difficulty,
    int? durationMinutes,
    String? durationStr,
    int? rating,
    List<String>? tags,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    List<RecipeIngredient>? recipeIngredients,
    List<RecipeStepLink>? stepLinks,
    bool? isFavorite,
    List<Comment>? comments,
  }) {
    // If recipeImages is provided but images is not, encode recipeImages to images
    String updatedImages = images ?? this.images;
    List<RecipeImage> updatedRecipeImages = recipeImages ?? this.recipeImages;

    if (recipeImages != null && images == null) {
      updatedImages = RecipeImage.encodeList(updatedRecipeImages);
    }

    return Recipe(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      images: updatedImages,
      recipeImages: updatedRecipeImages,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationStr: durationStr ?? this.durationStr,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      recipeIngredients: recipeIngredients ?? this.recipeIngredients,
      stepLinks: stepLinks ?? this.stepLinks,
      isFavorite: isFavorite ?? this.isFavorite,
      comments: comments ?? this.comments,
    );
  }
}
