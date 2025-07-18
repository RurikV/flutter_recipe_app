import 'ingredient.dart';
import 'recipe_step.dart';
import 'comment.dart';
import 'recipe_image.dart';
import 'dart:convert';

class Recipe {
  final String uuid;
  final String name;
  final List<RecipeImage> images; // List of recipe images with detected objects
  final String mainImage; // Main image URL for backward compatibility
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
    dynamic images,
    this.mainImage = '',
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
  }) : images = _processImages(images);

  // Helper method to process images parameter which could be a String, List<RecipeImage>, or null
  static List<RecipeImage> _processImages(dynamic images) {
    if (images == null) {
      return [];
    } else if (images is String) {
      // Check if the string is a URL (starts with http:// or https://)
      if (images.startsWith('http://') || images.startsWith('https://')) {
        // If it's a URL, treat it as a single image URL
        return [RecipeImage(path: images)];
      }

      // If it's not a URL, try to parse it as JSON
      try {
        final List<dynamic> decodedList = jsonDecode(images);
        return decodedList
            .map((item) => RecipeImage.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // If parsing fails, treat it as a single image URL
        return [RecipeImage(path: images)];
      }
    } else if (images is List<RecipeImage>) {
      return images;
    } else if (images is List) {
      // If it's a list but not List<RecipeImage>, try to convert each item
      return images.map((item) {
        if (item is RecipeImage) {
          return item;
        } else if (item is Map<String, dynamic>) {
          return RecipeImage.fromJson(item);
        } else {
          return RecipeImage(path: item.toString());
        }
      }).toList();
    }
    // Default fallback
    return [];
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print('[DEBUG_LOG] Recipe.fromJson: Starting to parse recipe JSON');
    print('[DEBUG_LOG] Recipe.fromJson: JSON keys: ${json.keys.toList()}');
    print('[DEBUG_LOG] Recipe.fromJson: Recipe name: ${json['name']}');
    print('[DEBUG_LOG] Recipe.fromJson: Recipe ID: ${json['id']}');

    // Handle the API response structure which uses 'id' instead of 'uuid'
    // and 'photo' instead of 'images'
    final String imageUrl = (json['images'] ?? json['photo'] ?? 'https://placehold.co/400x300/png?text=No+Image') as String;
    String validImageUrl = imageUrl;

    // Validate and sanitize image URL
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      validImageUrl = 'https://placehold.co/400x300/png?text=No+Image';
    } else if (imageUrl.contains('example.com') || imageUrl.contains('placeholder.com')) {
      // Replace known problematic placeholder URLs
      validImageUrl = 'https://placehold.co/400x300/png?text=No+Image';
    }

    return Recipe(
      uuid: (json['uuid'] ?? json['id']?.toString() ?? '0') as String,
      name: json['name'] as String,
      images: validImageUrl,
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
          ? (() {
              print('[DEBUG_LOG] Recipe.fromJson: Found "ingredients" field');
              final ingredientsList = json['ingredients'] as List;
              print('[DEBUG_LOG] Recipe.fromJson: Ingredients count: ${ingredientsList.length}');
              return List<Ingredient>.from(
                ingredientsList.map(
                  (x) => Ingredient.fromJson(x as Map<String, dynamic>),
                ),
              );
            })()
          : json['recipeIngredients'] != null
              ? (() {
                  print('[DEBUG_LOG] Recipe.fromJson: Found "recipeIngredients" field');
                  final recipeIngredientsList = json['recipeIngredients'] as List;
                  print('[DEBUG_LOG] Recipe.fromJson: RecipeIngredients count: ${recipeIngredientsList.length}');

                  final parsedIngredients = List<Ingredient>.from(
                    recipeIngredientsList.map(
                      (x) {
                        print('[DEBUG_LOG] Recipe.fromJson: Processing ingredient: $x');

                        // Extract ingredient from recipeIngredient
                        final ingredientData = x['ingredient'] as Map<String, dynamic>?;
                        final count = x['count']?.toString() ?? '';

                        print('[DEBUG_LOG] Recipe.fromJson: Ingredient data: $ingredientData');
                        print('[DEBUG_LOG] Recipe.fromJson: Count: $count');

                        if (ingredientData != null) {
                          // Create ingredient with data from the relationship
                          // Determine which form of the measure unit to use based on the count
                          String unitForm = '';
                          if (ingredientData['measureUnit'] != null) {
                            final measureUnit = ingredientData['measureUnit'] as Map<String, dynamic>;
                            final countNum = int.tryParse(count) ?? 0;

                            print('[DEBUG_LOG] Recipe.fromJson: MeasureUnit: $measureUnit');
                            print('[DEBUG_LOG] Recipe.fromJson: Count number: $countNum');

                            if (countNum == 1) {
                              unitForm = measureUnit['one'] as String? ?? '';
                            } else if (countNum >= 2 && countNum <= 4) {
                              unitForm = measureUnit['few'] as String? ?? '';
                            } else {
                              unitForm = measureUnit['many'] as String? ?? '';
                            }

                            print('[DEBUG_LOG] Recipe.fromJson: Selected unit form: $unitForm');
                          }

                          final ingredient = Ingredient.simple(
                            name: ingredientData['name'] as String? ?? '',
                            quantity: count,
                            unit: unitForm,
                          );

                          print('[DEBUG_LOG] Recipe.fromJson: Created ingredient: ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}');
                          return ingredient;
                        } else {
                          print('[DEBUG_LOG] Recipe.fromJson: ⚠️ Ingredient data is null!');
                          // Fallback if ingredient data is missing
                          return Ingredient.simple(name: '', quantity: '', unit: '');
                        }
                      },
                    ),
                  );

                  print('[DEBUG_LOG] Recipe.fromJson: Parsed ${parsedIngredients.length} ingredients');
                  return parsedIngredients;
                })()
              : json['recipeIngredientLinks'] != null
                  ? List<Ingredient>.from(
                      (json['recipeIngredientLinks'] as List).map(
                        (x) {
                          // Extract ingredient from recipeIngredientLink
                          final ingredientData = x['ingredient'] as Map<String, dynamic>?;
                          final count = x['count']?.toString() ?? '';

                          if (ingredientData != null) {
                            // Create ingredient with data from the relationship
                            // Determine which form of the measure unit to use based on the count
                            String unitForm = '';
                            if (ingredientData['measureUnit'] != null) {
                              final measureUnit = ingredientData['measureUnit'] as Map<String, dynamic>;
                              final countNum = int.tryParse(count) ?? 0;

                              if (countNum == 1) {
                                unitForm = measureUnit['one'] as String? ?? '';
                              } else if (countNum >= 2 && countNum <= 4) {
                                unitForm = measureUnit['few'] as String? ?? '';
                              } else {
                                unitForm = measureUnit['many'] as String? ?? '';
                              }
                            }

                            return Ingredient.simple(
                              name: ingredientData['name'] as String? ?? '',
                              quantity: count,
                              unit: unitForm,
                            );
                          } else {
                            // Fallback if ingredient data is missing
                            return Ingredient.simple(name: '', quantity: '', unit: '');
                          }
                        },
                      ),
                    )
                  : (() {
                      print('[DEBUG_LOG] Recipe.fromJson: ⚠️ No ingredients found in any expected field!');
                      return <Ingredient>[];
                    })(),
      // Handle steps from different API structures
      steps: json['steps'] != null
          ? (() {
              print('[DEBUG_LOG] Recipe.fromJson: Found "steps" field');
              final stepsList = json['steps'] as List;
              print('[DEBUG_LOG] Recipe.fromJson: Steps count: ${stepsList.length}');
              return List<RecipeStep>.from(
                stepsList.map(
                  (x) => RecipeStep.fromJson(x as Map<String, dynamic>),
                ),
              );
            })()
          : json['recipesteplink'] != null
              ? (() {
                  print('[DEBUG_LOG] Recipe.fromJson: Found "recipesteplink" field');
                  final stepsList = json['recipesteplink'] as List;
                  print('[DEBUG_LOG] Recipe.fromJson: RecipeStepLink count: ${stepsList.length}');
                  return List<RecipeStep>.from(
                    stepsList.map(
                      (x) => RecipeStep.fromJson(x as Map<String, dynamic>),
                    ),
                  );
                })()
              : json['recipeStepLinks'] != null
                  ? (() {
                      print('[DEBUG_LOG] Recipe.fromJson: Found "recipeStepLinks" field');
                      final recipeStepLinksList = json['recipeStepLinks'] as List;
                      print('[DEBUG_LOG] Recipe.fromJson: RecipeStepLinks count: ${recipeStepLinksList.length}');

                      final parsedSteps = List<RecipeStep>.from(
                        recipeStepLinksList.map(
                          (x) {
                            print('[DEBUG_LOG] Recipe.fromJson: Processing step: $x');

                            // Extract step from recipeStepLink
                            final stepData = x['step'] as Map<String, dynamic>?;
                            final number = x['number']?.toString() ?? '';

                            print('[DEBUG_LOG] Recipe.fromJson: Step data: $stepData');
                            print('[DEBUG_LOG] Recipe.fromJson: Step number: $number');

                            if (stepData != null) {
                              // Create step with data from the relationship
                              final step = RecipeStep(
                                id: 0,
                                name: stepData['name'] as String? ?? '',
                                duration: stepData['duration'] is int 
                                    ? stepData['duration'] as int
                                    : int.tryParse((stepData['duration'] ?? '0') as String) ?? 0,
                              );

                              print('[DEBUG_LOG] Recipe.fromJson: Created step: ${step.name} (${step.duration} min)');
                              return step;
                            } else {
                              print('[DEBUG_LOG] Recipe.fromJson: ⚠️ Step data is null!');
                              // Fallback if step data is missing
                              return RecipeStep(id: 0, name: '', duration: 0);
                            }
                          },
                        ),
                      );

                      print('[DEBUG_LOG] Recipe.fromJson: Parsed ${parsedSteps.length} steps');
                      return parsedSteps;
                    })()
                  : (() {
                      print('[DEBUG_LOG] Recipe.fromJson: ⚠️ No steps found in any expected field!');
                      return <RecipeStep>[];
                    })(),
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
    // Convert the list of RecipeImage objects to a JSON string
    final String imagesJson = RecipeImage.encodeList(images);

    return {
      'uuid': uuid,
      'name': name,
      'images': imagesJson,
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
    dynamic images,
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
