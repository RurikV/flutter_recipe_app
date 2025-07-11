import 'recipe_repository.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../../services/api/api_service.dart';
import '../../services/database/database_service.dart';
import '../../services/connectivity/connectivity_service.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;
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
          final recipesData = await _apiService.getRecipesData();
          final allRecipeIngredients = await _apiService.getRecipeIngredientsData();
          final allIngredientDetails = await _apiService.getIngredientsData();
          final allMeasureUnits = await _apiService.getMeasureUnitsData();
          final allRecipeStepLinks = await _apiService.getRecipeStepLinksData();
          final allRecipeSteps = await _apiService.getRecipeStepsData();

          // Create maps for efficient lookup
          final Map<int, Map<String, dynamic>> ingredientDetailsById = {};
          for (final ingredient in allIngredientDetails) {
            if (ingredient['id'] != null) {
              ingredientDetailsById[ingredient['id'] as int] = ingredient;
            }
          }

          final Map<int, Map<String, dynamic>> measureUnitsById = {};
          for (final unit in allMeasureUnits) {
            if (unit['id'] != null) {
              measureUnitsById[unit['id'] as int] = unit;
            }
          }

          final Map<String, List<dynamic>> ingredientsByRecipeId = {};
          for (final recipeIngredient in allRecipeIngredients) {
            if (recipeIngredient['recipe'] != null && recipeIngredient['recipe']['id'] != null) {
              final recipeId = recipeIngredient['recipe']['id'].toString();
              if (!ingredientsByRecipeId.containsKey(recipeId)) {
                ingredientsByRecipeId[recipeId] = [];
              }

              if (recipeIngredient['ingredient'] != null && recipeIngredient['ingredient']['id'] != null) {
                final ingredientId = recipeIngredient['ingredient']['id'] as int;
                if (ingredientDetailsById.containsKey(ingredientId)) {
                  final ingredientDetails = ingredientDetailsById[ingredientId]!;
                  recipeIngredient['ingredient'] = ingredientDetails;

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

          final Map<int, Map<String, dynamic>> stepDetailsById = {};
          for (final step in allRecipeSteps) {
            if (step['id'] != null) {
              stepDetailsById[step['id'] as int] = step;
            }
          }

          final Map<String, List<dynamic>> stepsByRecipeId = {};
          for (final stepLink in allRecipeStepLinks) {
            if (stepLink['recipe'] != null && stepLink['recipe']['id'] != null) {
              final recipeId = stepLink['recipe']['id'].toString();
              if (!stepsByRecipeId.containsKey(recipeId)) {
                stepsByRecipeId[recipeId] = [];
              }

              if (stepLink['step'] != null && stepLink['step']['id'] != null) {
                final stepId = stepLink['step']['id'] as int;
                if (stepDetailsById.containsKey(stepId)) {
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

          // Save recipes to the in-memory cache, preserving favorite status
          final Map<String, bool> existingFavoriteStatuses = {};
          for (final cachedRecipe in _cachedRecipes) {
            existingFavoriteStatuses[cachedRecipe.uuid] = cachedRecipe.isFavorite;
          }

          // Apply existing favorite statuses to new recipes
          final List<Recipe> recipesWithFavorites = recipes.map((recipe) {
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

          return recipesWithFavorites;
        } catch (apiError) {
          // If API call fails, try to get recipes from the in-memory cache
          if (_cachedRecipes.isNotEmpty) {
            return _cachedRecipes;
          }
          rethrow;
        }
      } else {
        // If no internet connection, get recipes from the in-memory cache
        return _cachedRecipes;
      }
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
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
          final recipeData = await _apiService.getRecipeData(uuid);
          final recipe = Recipe.fromJson(recipeData);
          
          // Add to cache
          _cachedRecipes.add(recipe);
          
          return recipe;
        } catch (apiError) {
          throw Exception('Recipe not found: $apiError');
        }
      } else {
        throw Exception('Recipe not found in cache and no internet connection');
      }
    }
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      // Save to local database
      await _databaseService.saveRecipe(recipe);
      
      // Add to cache if not already present
      final existingIndex = _cachedRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (existingIndex >= 0) {
        _cachedRecipes[existingIndex] = recipe;
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
      }
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      // Update in local database
      await _databaseService.updateRecipe(recipe);
      
      // Update in cache
      final existingIndex = _cachedRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (existingIndex >= 0) {
        _cachedRecipes[existingIndex] = recipe;
      }
      
      // Update favorites cache
      final favoriteIndex = _cachedFavoriteRecipes.indexWhere((r) => r.uuid == recipe.uuid);
      if (recipe.isFavorite) {
        if (favoriteIndex >= 0) {
          _cachedFavoriteRecipes[favoriteIndex] = recipe;
        } else {
          _cachedFavoriteRecipes.add(recipe);
        }
      } else {
        if (favoriteIndex >= 0) {
          _cachedFavoriteRecipes.removeAt(favoriteIndex);
        }
      }
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    try {
      // Delete from local database
      await _databaseService.deleteRecipe(uuid);
      
      // Remove from cache
      _cachedRecipes.removeWhere((recipe) => recipe.uuid == uuid);
      _cachedFavoriteRecipes.removeWhere((recipe) => recipe.uuid == uuid);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    try {
      final recipeIndex = _cachedRecipes.indexWhere((recipe) => recipe.uuid == uuid);
      if (recipeIndex >= 0) {
        final recipe = _cachedRecipes[recipeIndex];
        final updatedRecipe = recipe.copyWith(isFavorite: !recipe.isFavorite);
        
        // Update in cache
        _cachedRecipes[recipeIndex] = updatedRecipe;
        
        // Update favorites cache
        if (updatedRecipe.isFavorite) {
          _cachedFavoriteRecipes.add(updatedRecipe);
        } else {
          _cachedFavoriteRecipes.removeWhere((r) => r.uuid == uuid);
        }
        
        // Update in database
        await _databaseService.updateRecipe(updatedRecipe);
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    try {
      return await _databaseService.getAvailableIngredients();
    } catch (e) {
      throw Exception('Failed to get available ingredients: $e');
    }
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    try {
      return await _databaseService.getAvailableUnits();
    } catch (e) {
      throw Exception('Failed to get available units: $e');
    }
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    try {
      await _databaseService.addComment(recipeUuid, comment);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<List<Comment>> getComments(String recipeUuid) async {
    try {
      return await _databaseService.getComments(recipeUuid);
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }
}