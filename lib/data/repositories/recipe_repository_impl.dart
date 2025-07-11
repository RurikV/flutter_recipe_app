import '../../domain/repositories/recipe_repository.dart';
import '../../models/recipe.dart';
import '../../models/comment.dart';
import '../../domain/services/api_service.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/connectivity_service.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;
  // Uncommented DatabaseService to fix build errors
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;

  // In-memory cache for recipes
  final List<Recipe> _cachedRecipes = [];
  final List<Recipe> _cachedFavoriteRecipes = [];

  RecipeRepositoryImpl({
    required ApiService apiService,
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _databaseService = databaseService,
        _connectivityService = connectivityService;

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      // Always try to get recipes from the API first
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get recipes from the API by combining data from multiple endpoints
          // Step 1: Get basic recipe data
          final recipesData = await _apiService.getRecipesData();

          // Step 2: Get all recipe ingredients
          final allRecipeIngredients = await _apiService.getRecipeIngredientsData();

          // Step 3: Get all ingredients
          final allIngredientDetails = await _apiService.getIngredientsData();

          // Step 4: Get all measure units
          final allMeasureUnits = await _apiService.getMeasureUnitsData();

          // Step 5: Get all recipe step links
          final allRecipeStepLinks = await _apiService.getRecipeStepLinksData();

          // Step 6: Get all recipe steps
          final allRecipeSteps = await _apiService.getRecipeStepsData();

          // Create a map of ingredient ID to ingredient details
          final Map<int, Map<String, dynamic>> ingredientDetailsById = {};
          for (final ingredient in allIngredientDetails) {
            if (ingredient['id'] != null) {
              ingredientDetailsById[ingredient['id'] as int] = ingredient;
            }
          }

          // Create a map of measure unit ID to measure unit details
          final Map<int, Map<String, dynamic>> measureUnitsById = {};
          for (final unit in allMeasureUnits) {
            if (unit['id'] != null) {
              measureUnitsById[unit['id'] as int] = unit;
            }
          }

          // Create a map of recipe ID to ingredients with full details
          final Map<String, List<dynamic>> ingredientsByRecipeId = {};
          for (final recipeIngredient in allRecipeIngredients) {
            if (recipeIngredient['recipe'] != null && recipeIngredient['recipe']['id'] != null) {
              final recipeId = recipeIngredient['recipe']['id'].toString();
              if (!ingredientsByRecipeId.containsKey(recipeId)) {
                ingredientsByRecipeId[recipeId] = [];
              }

              // Enhance recipe ingredient with full ingredient details and measure unit details
              if (recipeIngredient['ingredient'] != null && recipeIngredient['ingredient']['id'] != null) {
                final ingredientId = recipeIngredient['ingredient']['id'] as int;
                if (ingredientDetailsById.containsKey(ingredientId)) {
                  // Add full ingredient details
                  final ingredientDetails = ingredientDetailsById[ingredientId]!;
                  recipeIngredient['ingredient'] = ingredientDetails;

                  // Add full measure unit details if available
                  if (ingredientDetails['measureUnit'] != null && ingredientDetails['measureUnit']['id'] != null) {
                    final measureUnitId = ingredientDetails['measureUnit']['id'] as int;
                    if (measureUnitsById.containsKey(measureUnitId)) {
                      ingredientDetails['measureUnit'] = measureUnitsById[measureUnitId]!;
                    }
                  }
                }
              }

              ingredientsByRecipeId[recipeId]!.add(recipeIngredient);
            }
          }

          // Create a map of step ID to step details
          final Map<int, Map<String, dynamic>> stepDetailsById = {};
          for (final step in allRecipeSteps) {
            if (step['id'] != null) {
              stepDetailsById[step['id'] as int] = step;
            }
          }

          // Create a map of recipe ID to steps with full details
          final Map<String, List<dynamic>> stepsByRecipeId = {};
          for (final stepLink in allRecipeStepLinks) {
            if (stepLink['recipe'] != null && stepLink['recipe']['id'] != null) {
              final recipeId = stepLink['recipe']['id'].toString();
              if (!stepsByRecipeId.containsKey(recipeId)) {
                stepsByRecipeId[recipeId] = [];
              }

              // Enhance step link with full step details
              if (stepLink['step'] != null && stepLink['step']['id'] != null) {
                final stepId = stepLink['step']['id'] as int;
                if (stepDetailsById.containsKey(stepId)) {
                  // Add full step details
                  final stepDetails = stepDetailsById[stepId]!;
                  stepLink['step'] = stepDetails;
                }
              }

              stepsByRecipeId[recipeId]!.add(stepLink);
            }
          }

          // Sort step links by number for each recipe
          for (final recipeId in stepsByRecipeId.keys) {
            stepsByRecipeId[recipeId]!.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
          }

          // Add ingredients and steps to each recipe and parse
          final List<Recipe> recipes = [];
          for (final recipeData in recipesData) {
            final recipeId = recipeData['id'].toString();
            if (ingredientsByRecipeId.containsKey(recipeId)) {
              recipeData['recipeIngredients'] = ingredientsByRecipeId[recipeId];
            }
            if (stepsByRecipeId.containsKey(recipeId)) {
              recipeData['recipeStepLinks'] = stepsByRecipeId[recipeId];
            }
            recipes.add(Recipe.fromJson(recipeData));
          }

          // Save recipes to the in-memory cache
          _cachedRecipes.clear();
          _cachedRecipes.addAll(recipes);

          return recipes;
        } catch (apiError) {
          // If API call fails, try to get recipes from the in-memory cache
          if (_cachedRecipes.isNotEmpty) {
            return _cachedRecipes;
          }
          // If cache is empty, rethrow the API error
          rethrow;
        }
      } else {
        // If no internet connection, get recipes from the in-memory cache
        return _cachedRecipes;
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('Failed to get recipes: $e');
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      // Return recipes from the in-memory cache that are marked as favorites
      return _cachedRecipes.where((recipe) => recipe.isFavorite).toList();
    } catch (e) {
      throw Exception('Failed to get favorite recipes: $e');
    }
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    try {
      // First try to get from in-memory cache
      final cachedRecipe = _cachedRecipes.firstWhere(
        (recipe) => recipe.uuid == uuid,
        orElse: () => throw Exception('Recipe not found in cache'),
      );
      return cachedRecipe;
    } catch (cacheError) {

      // If not found locally and connected, try to get from API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          // Get recipe from API by combining data from multiple endpoints
          // Step 1: Get basic recipe data
          final recipeData = await _apiService.getRecipeData(uuid);

          // Step 2: Get all recipe ingredients
          final allRecipeIngredients = await _apiService.getRecipeIngredientsData();

          // Filter ingredients for this recipe
          final recipeIngredients = allRecipeIngredients.where((ingredient) {
            return ingredient['recipe'] != null && 
                   ingredient['recipe']['id'].toString() == uuid;
          }).toList();

          // Step 3: Get all ingredients
          final allIngredientDetails = await _apiService.getIngredientsData();

          // Create a map of ingredient ID to ingredient details
          final Map<int, Map<String, dynamic>> ingredientDetailsById = {};
          for (final ingredient in allIngredientDetails) {
            if (ingredient['id'] != null) {
              ingredientDetailsById[ingredient['id'] as int] = ingredient;
            }
          }

          // Step 4: Get all measure units
          final allMeasureUnits = await _apiService.getMeasureUnitsData();

          // Create a map of measure unit ID to measure unit details
          final Map<int, Map<String, dynamic>> measureUnitsById = {};
          for (final unit in allMeasureUnits) {
            if (unit['id'] != null) {
              measureUnitsById[unit['id'] as int] = unit;
            }
          }

          // Enhance recipe ingredients with full ingredient details and measure unit details
          for (final recipeIngredient in recipeIngredients) {
            if (recipeIngredient['ingredient'] != null && recipeIngredient['ingredient']['id'] != null) {
              final ingredientId = recipeIngredient['ingredient']['id'] as int;
              if (ingredientDetailsById.containsKey(ingredientId)) {
                // Add full ingredient details
                final ingredientDetails = ingredientDetailsById[ingredientId]!;
                recipeIngredient['ingredient'] = ingredientDetails;

                // Add full measure unit details if available
                if (ingredientDetails['measureUnit'] != null && ingredientDetails['measureUnit']['id'] != null) {
                  final measureUnitId = ingredientDetails['measureUnit']['id'] as int;
                  if (measureUnitsById.containsKey(measureUnitId)) {
                    ingredientDetails['measureUnit'] = measureUnitsById[measureUnitId]!;
                  }
                }
              }
            }
          }

          // Step 5: Get all recipe step links
          final allRecipeStepLinks = await _apiService.getRecipeStepLinksData();

          // Filter step links for this recipe
          final recipeStepLinks = allRecipeStepLinks.where((stepLink) {
            return stepLink['recipe'] != null && 
                   stepLink['recipe']['id'].toString() == uuid;
          }).toList();

          // Step 6: Get all recipe steps
          final allRecipeSteps = await _apiService.getRecipeStepsData();

          // Create a map of step ID to step details
          final Map<int, Map<String, dynamic>> stepDetailsById = {};
          for (final step in allRecipeSteps) {
            if (step['id'] != null) {
              stepDetailsById[step['id'] as int] = step;
            }
          }

          // Enhance step links with full step details
          for (final stepLink in recipeStepLinks) {
            if (stepLink['step'] != null && stepLink['step']['id'] != null) {
              final stepId = stepLink['step']['id'] as int;
              if (stepDetailsById.containsKey(stepId)) {
                // Add full step details
                final stepDetails = stepDetailsById[stepId]!;
                stepLink['step'] = stepDetails;
              }
            }
          }

          // Sort step links by number
          recipeStepLinks.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));

          // Add ingredients and steps to recipe data
          recipeData['recipeIngredients'] = recipeIngredients;
          recipeData['recipeStepLinks'] = recipeStepLinks;

          // Create the recipe object
          final recipe = Recipe.fromJson(recipeData);

          // Save to local database
          await _databaseService.saveRecipe(recipe);

          return recipe;
        } catch (e) {
          print('Failed to get recipe from API: $e');
          return null;
        }
      }

      return null;
    }
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      // Update in-memory cache
      final index = _cachedRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (index >= 0) {
        _cachedRecipes[index] = recipe;
      } else {
        _cachedRecipes.add(recipe);
      }

      // Update favorites cache if needed
      if (recipe.isFavorite) {
        final favoriteIndex = _cachedFavoriteRecipes.indexWhere((r) => r.uuid == recipe.uuid);
        if (favoriteIndex >= 0) {
          _cachedFavoriteRecipes[favoriteIndex] = recipe;
        } else {
          _cachedFavoriteRecipes.add(recipe);
        }
      } else {
        _cachedFavoriteRecipes.removeWhere((r) => r.uuid == recipe.uuid);
      }

      // If connected, also save to API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          // Prepare recipe data for API
          final recipeJson = recipe.toJson();
          recipeJson.remove('uuid');
          recipeJson.remove('description');
          recipeJson.remove('instructions');
          recipeJson.remove('difficulty');
          recipeJson.remove('rating');
          recipeJson.remove('tags');
          recipeJson.remove('ingredients');
          recipeJson.remove('steps');
          recipeJson.remove('isFavorite');

          // Set a default value for duration if it's empty or convert to integer
          if (recipeJson['duration'] == '') {
            recipeJson['duration'] = 0; // Use integer 0 instead of string
          } else {
            // Try to extract numeric value from duration string (e.g., "30 min" -> 30)
            final durationStr = recipeJson['duration'] as String;
            final numericValue = int.tryParse(durationStr.split(' ').first);
            if (numericValue != null) {
              recipeJson['duration'] = numericValue;
            } else {
              recipeJson['duration'] = 0; // Default to 0 if parsing fails
            }
          }

          // Rename 'images' to 'photo'
          if (recipeJson.containsKey('images')) {
            recipeJson['photo'] = recipeJson['images'];
            recipeJson.remove('images');
          }

          // Create a simplified JSON structure for the API
          final simplifiedJson = {
            'name': recipeJson['name'],
            'duration': recipeJson['duration'],
            'photo': recipeJson['photo'],
          };

          // Step 1: Create the recipe with basic information
          final createdRecipeData = await _apiService.createRecipeData(simplifiedJson);
          final recipeId = createdRecipeData['id'] as int;

          // Step 2: Create recipe ingredients
          for (var ingredient in recipe.ingredients) {
            try {
              int ingredientId = ingredient.id;

              // If ingredient has ID 0, we need to create it or find an existing one
              if (ingredientId == 0) {
                try {
                  // First, try to find an existing ingredient with the same name
                  final allIngredients = await _apiService.getIngredientsData();
                  dynamic existingIngredient;
                  try {
                    existingIngredient = allIngredients.firstWhere(
                      (ing) => ing['name'] == ingredient.name,
                    );
                  } catch (e) {
                    existingIngredient = null;
                  }

                  if (existingIngredient != null) {
                    // Use the existing ingredient's ID
                    ingredientId = existingIngredient['id'];
                  } else {
                    // Create a new ingredient
                    final newIngredientJson = {
                      'name': ingredient.name,
                      'caloriesForUnit': 0.0,
                      'measureUnit': {'id': 1} // Default measure unit ID
                    };

                    final createdIngredient = await _apiService.createIngredientData(newIngredientJson);
                    ingredientId = createdIngredient['id'];
                  }
                } catch (e) {
                  print('Error creating or finding ingredient: $e');
                  continue;
                }
              }

              // Now create the recipe ingredient with the valid ingredient ID
              final ingredientJson = {
                'count': int.tryParse(ingredient.quantity) ?? 0,
                'ingredient': {'id': ingredientId},
                'recipe': {'id': recipeId}
              };

              await _apiService.createRecipeIngredientData(ingredientJson);
            } catch (e) {
              // Log the error but continue with the next ingredient
              print('Error creating ingredient: $e');
            }
          }

          // Step 3: Create recipe steps
          for (var i = 0; i < recipe.steps.length; i++) {
            try {
              final step = recipe.steps[i];

              // If the step has a non-zero ID, assume it already exists
              if (step.id != 0) {
                // Just link the existing step to the recipe
                final stepLinkJson = {
                  'number': i + 1,
                  'recipe': {'id': recipeId},
                  'step': {'id': step.id}
                };

                await _apiService.createRecipeStepLinkData(stepLinkJson);
                continue;
              }

              // First create the step
              final stepJson = {
                'name': step.name,
                'duration': step.duration,
              };

              final createdStep = await _apiService.createRecipeStepData(stepJson);
              final stepId = createdStep['id'];

              // Then link the step to the recipe
              final stepLinkJson = {
                'number': i + 1,
                'recipe': {'id': recipeId},
                'step': {'id': stepId}
              };

              await _apiService.createRecipeStepLinkData(stepLinkJson);
            } catch (e) {
              // Log the error but continue with the next step
              print('Error creating step: $e');
            }
          }
        } catch (e) {
          // API save failed, but local save succeeded
          print('Warning: Failed to save recipe to API: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _databaseService.updateRecipe(recipe);

      // If connected, also update in API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          // Prepare recipe data for API
          final recipeData = recipe.toJson();
          await _apiService.updateRecipeData(recipe.uuid, recipeData);
        } catch (e) {
          // API update failed, but local update succeeded
          print('Warning: Failed to update recipe in API: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    try {
      // Delete from in-memory cache
      _cachedRecipes.removeWhere((r) => r.uuid == uuid);
      _cachedFavoriteRecipes.removeWhere((r) => r.uuid == uuid);

      // If connected, also delete from API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          await _apiService.deleteRecipeData(uuid);
        } catch (e) {
          // API delete failed, but local delete succeeded
          print('Warning: Failed to delete recipe from API: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    try {
      // Toggle favorite status in in-memory cache
      final index = _cachedRecipes.indexWhere((r) => r.uuid == uuid);
      if (index >= 0) {
        final recipe = _cachedRecipes[index];
        final updatedRecipe = Recipe(
          uuid: recipe.uuid,
          name: recipe.name,
          images: recipe.images,
          description: recipe.description,
          instructions: recipe.instructions,
          difficulty: recipe.difficulty,
          duration: recipe.duration,
          rating: recipe.rating,
          tags: recipe.tags,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
          isFavorite: !recipe.isFavorite,
          comments: recipe.comments,
        );
        _cachedRecipes[index] = updatedRecipe;

        // Update favorites cache
        if (updatedRecipe.isFavorite) {
          _cachedFavoriteRecipes.add(updatedRecipe);
        } else {
          _cachedFavoriteRecipes.removeWhere((r) => r.uuid == uuid);
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite status: $e');
    }
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get ingredients data from API
          final ingredientsData = await _apiService.getIngredientsData();

          // Extract ingredient names and deduplicate using a Set
          final Set<String> ingredientNamesSet = {};
          for (final ingredient in ingredientsData) {
            if (ingredient['name'] != null) {
              ingredientNamesSet.add(ingredient['name'] as String);
            }
          }

          return ingredientNamesSet.toList();
        } catch (e) {
          // API call failed, use in-memory cache
          return _getIngredientsFromCache();
        }
      } else {
        // No internet connection, use in-memory cache
        return _getIngredientsFromCache();
      }
    } catch (e) {
      throw Exception('Failed to get available ingredients: $e');
    }
  }

  // Helper method to extract ingredient names from in-memory cache
  List<String> _getIngredientsFromCache() {
    final Set<String> ingredientNames = {};
    for (final recipe in _cachedRecipes) {
      for (final ingredient in recipe.ingredients) {
        if (ingredient.name.isNotEmpty) {
          ingredientNames.add(ingredient.name);
        }
      }
    }
    return ingredientNames.toList();
  }

  // Helper method to extract unit names from in-memory cache
  List<String> _getUnitsFromCache() {
    final Set<String> unitNames = {};
    for (final recipe in _cachedRecipes) {
      for (final ingredient in recipe.ingredients) {
        if (ingredient.unit.isNotEmpty) {
          unitNames.add(ingredient.unit);
        }
      }
    }
    return unitNames.toList();
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get measure units data from API
          final unitsData = await _apiService.getMeasureUnitsData();

          // Extract unit names and deduplicate using a Set
          final Set<String> unitNamesSet = {};
          for (final unit in unitsData) {
            if (unit['name'] != null) {
              unitNamesSet.add(unit['name'] as String);
            }
          }

          return unitNamesSet.toList();
        } catch (e) {
          // API call failed, use in-memory cache
          return _getUnitsFromCache();
        }
      } else {
        // No internet connection, use in-memory cache
        return _getUnitsFromCache();
      }
    } catch (e) {
      throw Exception('Failed to get available units: $e');
    }
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    try {
      // Save comment to local database
      await _databaseService.addComment(recipeUuid, comment);

      // If connected, also add to API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          // Convert comment to JSON
          final commentData = comment.toJson();

          // Add comment to API
          await _apiService.addCommentData(recipeUuid, commentData);
        } catch (e) {
          // API add failed, but local add succeeded
          print('Warning: Failed to add comment to API: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<List<Comment>> getComments(String recipeUuid) async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get comments data from API
          final commentsData = await _apiService.getCommentsData(recipeUuid);

          // Convert to Comment objects
          final List<Comment> comments = [];
          for (final commentData in commentsData) {
            comments.add(Comment.fromJson(commentData));
          }

          // Save comments to local database
          for (var comment in comments) {
            await _databaseService.addComment(recipeUuid, comment);
          }

          return comments;
        } catch (e) {
          // API call failed, use local data
          return await _databaseService.getComments(recipeUuid);
        }
      } else {
        // No internet connection, use local data
        return await _databaseService.getComments(recipeUuid);
      }
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }
}
