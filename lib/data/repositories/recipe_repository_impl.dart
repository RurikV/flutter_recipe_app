import 'recipe_repository.dart';
import '../models/recipe.dart' as model;
import '../models/comment.dart' as model;
import '../../services/api/api_service.dart';
import '../../services/database/database_service.dart';
import '../../services/connectivity/connectivity_service.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;

  // In-memory cache for recipes
  final List<model.Recipe> _cachedRecipes = [];
  final List<model.Recipe> _cachedFavoriteRecipes = [];

  RecipeRepositoryImpl({
    required ApiService apiService,
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _databaseService = databaseService,
        _connectivityService = connectivityService;

  @override
  Future<List<model.Recipe>> getRecipes() async {
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
          final List<model.Recipe> recipes = [];
          for (final recipeData in recipesData) {
            final recipeId = recipeData['id'].toString();
            if (ingredientsByRecipeId.containsKey(recipeId)) {
              recipeData['recipeIngredients'] = ingredientsByRecipeId[recipeId];
            }
            if (stepsByRecipeId.containsKey(recipeId)) {
              recipeData['recipeStepLinks'] = stepsByRecipeId[recipeId];
            }
            recipes.add(model.Recipe.fromJson(recipeData));
          }

          // Save recipes to the in-memory cache, preserving favorite status
          // Create a map of existing favorite statuses before clearing cache
          final Map<String, bool> existingFavoriteStatuses = {};
          for (final cachedRecipe in _cachedRecipes) {
            existingFavoriteStatuses[cachedRecipe.uuid] = cachedRecipe.isFavorite;
          }

          // Apply existing favorite statuses to new recipes
          final List<model.Recipe> recipesWithFavorites = recipes.map((recipe) {
            final existingFavoriteStatus = existingFavoriteStatuses[recipe.uuid];
            if (existingFavoriteStatus != null && existingFavoriteStatus) {
              return recipe.copyWith(isFavorite: true);
            }
            return recipe;
          }).toList();

          _cachedRecipes.clear();
          _cachedRecipes.addAll(recipesWithFavorites);

          // Update the favorites cache to stay in sync
          _cachedFavoriteRecipes.clear();
          _cachedFavoriteRecipes.addAll(recipesWithFavorites.where((recipe) => recipe.isFavorite));

          // Return the recipes directly (no mapping needed)
          return recipesWithFavorites;
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
  Future<List<model.Recipe>> getFavoriteRecipes() async {
    try {
      // Return recipes from the in-memory cache that are marked as favorites
      return _cachedRecipes
          .where((recipe) => recipe.isFavorite)
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite recipes: $e');
    }
  }

  @override
  Future<model.Recipe?> getRecipeByUuid(String uuid) async {
    print('[DEBUG_LOG] RecipeRepositoryImpl: getRecipeByUuid called with UUID: $uuid');

    try {
      print('[DEBUG_LOG] RecipeRepositoryImpl: Checking in-memory cache for recipe $uuid');
      print('[DEBUG_LOG] RecipeRepositoryImpl: Cache contains ${_cachedRecipes.length} recipes');

      // First try to get from in-memory cache
      final cachedRecipe = _cachedRecipes.firstWhere(
        (recipe) => recipe.uuid == uuid,
        orElse: () => throw Exception('Recipe not found in cache'),
      );

      print('[DEBUG_LOG] RecipeRepositoryImpl: Found recipe in cache:');
      print('[DEBUG_LOG] - UUID: ${cachedRecipe.uuid}');
      print('[DEBUG_LOG] - Name: ${cachedRecipe.name}');
      print('[DEBUG_LOG] - Ingredients count: ${cachedRecipe.ingredients.length}');
      print('[DEBUG_LOG] - Steps count: ${cachedRecipe.steps.length}');

      // Check if the cached recipe has complete data (ingredients and steps)
      if (cachedRecipe.ingredients.isNotEmpty && cachedRecipe.steps.isNotEmpty) {
        print('[DEBUG_LOG] RecipeRepositoryImpl: Cached recipe has complete data, returning it');
        return cachedRecipe;
      } else {
        print('[DEBUG_LOG] RecipeRepositoryImpl: Cached recipe is incomplete, fetching from API...');
        // Throw exception to trigger API fetch
        throw Exception('Cached recipe is incomplete');
      }
    } catch (cacheError) {
      print('[DEBUG_LOG] RecipeRepositoryImpl: Recipe not found in cache: $cacheError');

      // If not found locally and connected, try to get from API
      print('[DEBUG_LOG] RecipeRepositoryImpl: Checking connectivity...');
      final isConnected = await _connectivityService.isConnected();
      print('[DEBUG_LOG] RecipeRepositoryImpl: Connected: $isConnected');

      if (isConnected) {
        try {
          print('[DEBUG_LOG] RecipeRepositoryImpl: Calling API service to get recipe data for UUID: $uuid');

          // Get complete recipe data from the optimized API endpoint
          // The API now returns complete recipe data with ingredients and steps
          final recipeData = await _apiService.getRecipeData(uuid);

          print('[DEBUG_LOG] RecipeRepositoryImpl: API returned recipe data:');
          print('[DEBUG_LOG] - Raw API response keys: ${recipeData.keys.toList()}');
          print('[DEBUG_LOG] - Recipe name: ${recipeData['name']}');
          print('[DEBUG_LOG] - Recipe duration: ${recipeData['duration']}');
          print('[DEBUG_LOG] - Has recipeIngredients: ${recipeData.containsKey('recipeIngredients')}');
          print('[DEBUG_LOG] - Has recipeStepLinks: ${recipeData.containsKey('recipeStepLinks')}');

          if (recipeData.containsKey('recipeIngredients')) {
            final ingredients = recipeData['recipeIngredients'] as List?;
            print('[DEBUG_LOG] - Ingredients count from API: ${ingredients?.length ?? 0}');
            if (ingredients != null && ingredients.isNotEmpty) {
              print('[DEBUG_LOG] - First ingredient from API: ${ingredients[0]}');
            }
          }

          if (recipeData.containsKey('recipeStepLinks')) {
            final steps = recipeData['recipeStepLinks'] as List?;
            print('[DEBUG_LOG] - Steps count from API: ${steps?.length ?? 0}');
            if (steps != null && steps.isNotEmpty) {
              print('[DEBUG_LOG] - First step from API: ${steps[0]}');
            }
          }

          print('[DEBUG_LOG] RecipeRepositoryImpl: Parsing API data with Recipe.fromJson...');

          // Create the recipe object using data model
          final dataRecipe = model.Recipe.fromJson(recipeData);

          print('[DEBUG_LOG] RecipeRepositoryImpl: Recipe parsed successfully:');
          print('[DEBUG_LOG] - Parsed UUID: ${dataRecipe.uuid}');
          print('[DEBUG_LOG] - Parsed name: ${dataRecipe.name}');
          print('[DEBUG_LOG] - Parsed ingredients count: ${dataRecipe.ingredients.length}');
          print('[DEBUG_LOG] - Parsed steps count: ${dataRecipe.steps.length}');

          if (dataRecipe.ingredients.isNotEmpty) {
            print('[DEBUG_LOG] RecipeRepositoryImpl: Parsed ingredients:');
            for (int i = 0; i < dataRecipe.ingredients.length; i++) {
              final ingredient = dataRecipe.ingredients[i];
              print('[DEBUG_LOG]   ${i + 1}. ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}');
            }
          } else {
            print('[DEBUG_LOG] RecipeRepositoryImpl: ⚠️ NO INGREDIENTS after parsing!');
          }

          if (dataRecipe.steps.isNotEmpty) {
            print('[DEBUG_LOG] RecipeRepositoryImpl: Parsed steps:');
            for (int i = 0; i < dataRecipe.steps.length; i++) {
              final step = dataRecipe.steps[i];
              print('[DEBUG_LOG]   ${i + 1}. ${step.name} (${step.duration} min)');
            }
          } else {
            print('[DEBUG_LOG] RecipeRepositoryImpl: ⚠️ NO STEPS after parsing!');
          }

          print('[DEBUG_LOG] RecipeRepositoryImpl: Saving recipe to local database...');
          // Save to local database
          await _databaseService.saveRecipe(dataRecipe);
          print('[DEBUG_LOG] RecipeRepositoryImpl: Recipe saved to local database');

          print('[DEBUG_LOG] RecipeRepositoryImpl: Updating in-memory cache with complete recipe data...');
          // Update in-memory cache with complete recipe data
          final index = _cachedRecipes.indexWhere((r) => r.uuid == dataRecipe.uuid);
          if (index >= 0) {
            _cachedRecipes[index] = dataRecipe;
            print('[DEBUG_LOG] RecipeRepositoryImpl: Updated existing recipe in cache');
          } else {
            _cachedRecipes.add(dataRecipe);
            print('[DEBUG_LOG] RecipeRepositoryImpl: Added new recipe to cache');
          }

          return dataRecipe;
        } catch (e) {
          print('[DEBUG_LOG] RecipeRepositoryImpl: ❌ Failed to get recipe from API: $e');
          print('[DEBUG_LOG] RecipeRepositoryImpl: API error stack trace: ${StackTrace.current}');
          return null;
        }
      }

      print('[DEBUG_LOG] RecipeRepositoryImpl: No connectivity, returning null');
      return null;
    }
  }

  @override
  Future<void> saveRecipe(model.Recipe recipe) async {
    try {
      // Use the model directly for cache
      final dataRecipe = recipe;

      // Update in-memory cache
      final index = _cachedRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (index >= 0) {
        _cachedRecipes[index] = dataRecipe;
      } else {
        _cachedRecipes.add(dataRecipe);
      }

      // Update favorites cache if needed
      if (recipe.isFavorite) {
        final favoriteIndex = _cachedFavoriteRecipes.indexWhere((r) => r.uuid == recipe.uuid);
        if (favoriteIndex >= 0) {
          _cachedFavoriteRecipes[favoriteIndex] = dataRecipe;
        } else {
          _cachedFavoriteRecipes.add(dataRecipe);
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
  Future<void> updateRecipe(model.Recipe recipe) async {
    try {
      // Use the model directly for database
      await _databaseService.updateRecipe(recipe);

      // Update in-memory cache
      final index = _cachedRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (index >= 0) {
        _cachedRecipes[index] = recipe;
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
        final model.Recipe updatedRecipe = recipe.copyWith(
          isFavorite: !recipe.isFavorite,
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
  Future<void> addComment(String recipeUuid, model.Comment comment) async {
    try {
      // Use the model directly for database
      final dataComment = comment;

      // Save comment to local database
      await _databaseService.addComment(recipeUuid, dataComment);

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
  Future<List<model.Comment>> getComments(String recipeUuid) async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get comments data from API
          final commentsData = await _apiService.getCommentsData(recipeUuid);

          // Convert to model Comment objects
          final List<model.Comment> comments = [];
          for (final commentData in commentsData) {
            comments.add(model.Comment.fromJson(commentData));
          }

          // Save comments to local database
          for (var comment in comments) {
            await _databaseService.addComment(recipeUuid, comment);
          }

          return comments;
        } catch (e) {
          // API call failed, use local data
          final dataComments = await _databaseService.getComments(recipeUuid);
          return dataComments;
        }
      } else {
        // No internet connection, use local data
        final dataComments = await _databaseService.getComments(recipeUuid);
        return dataComments;
      }
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }
}
