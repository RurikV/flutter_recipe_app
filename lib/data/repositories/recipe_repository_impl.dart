import '../../domain/repositories/recipe_repository.dart';
import '../../models/recipe.dart';
import '../../models/comment.dart';
import '../api_service.dart';
import '../database_service.dart';
import '../../services/connectivity_service.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;

  RecipeRepositoryImpl({
    ApiService? apiService,
    DatabaseService? databaseService,
    ConnectivityService? connectivityService,
  })  : _apiService = apiService ?? ApiService(),
        _databaseService = databaseService ?? DatabaseService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      // Always try to get recipes from the API first
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // Get recipes from the API
          final recipes = await _apiService.getRecipes();

          // Save recipes to the local database
          for (var recipe in recipes) {
            await _databaseService.saveRecipe(recipe);
          }

          return recipes;
        } catch (apiError) {
          // If API call fails, try to get recipes from the local database
          final dbRecipes = await _databaseService.getAllRecipes();
          if (dbRecipes.isNotEmpty) {
            return dbRecipes;
          }
          // If database is empty, rethrow the API error
          throw apiError;
        }
      } else {
        // If no internet connection, get recipes from the local database
        final dbRecipes = await _databaseService.getAllRecipes();
        return dbRecipes;
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('Failed to get recipes: $e');
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      return await _databaseService.getFavoriteRecipes();
    } catch (e) {
      throw Exception('Failed to get favorite recipes: $e');
    }
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    try {
      return await _databaseService.getRecipeByUuid(uuid);
    } catch (e) {
      throw Exception('Failed to get recipe by UUID: $e');
    }
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      await _databaseService.saveRecipe(recipe);
      
      // If connected, also save to API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          await _apiService.saveRecipe(recipe);
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
          await _apiService.updateRecipe(recipe);
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
      await _databaseService.deleteRecipe(uuid);
      
      // If connected, also delete from API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          await _apiService.deleteRecipe(uuid);
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
      await _databaseService.toggleFavorite(uuid);
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
          return await _apiService.getAvailableIngredients();
        } catch (e) {
          // API call failed, use local data
          return await _databaseService.getAvailableIngredients();
        }
      } else {
        // No internet connection, use local data
        return await _databaseService.getAvailableIngredients();
      }
    } catch (e) {
      throw Exception('Failed to get available ingredients: $e');
    }
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        try {
          return await _apiService.getAvailableUnits();
        } catch (e) {
          // API call failed, use local data
          return await _databaseService.getAvailableUnits();
        }
      } else {
        // No internet connection, use local data
        return await _databaseService.getAvailableUnits();
      }
    } catch (e) {
      throw Exception('Failed to get available units: $e');
    }
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    try {
      await _databaseService.addComment(recipeUuid, comment);
      
      // If connected, also add to API
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        try {
          await _apiService.addComment(recipeUuid, comment);
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
          final comments = await _apiService.getComments(recipeUuid);
          
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