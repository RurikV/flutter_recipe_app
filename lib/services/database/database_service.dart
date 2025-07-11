import '../../../data/models/recipe.dart';
import '../../../data/models/comment.dart';

/// Interface for database-related operations
abstract class DatabaseService {
  /// Get all recipes with their related data
  Future<List<Recipe>> getAllRecipes();

  /// Get favorite recipes with their related data
  Future<List<Recipe>> getFavoriteRecipes();

  /// Check if a recipe is in favorites
  Future<bool> isInFavorites(String recipeId);

  /// Get a recipe by UUID with all related data
  Future<Recipe?> getRecipeByUuid(String uuid);

  /// Save a recipe with all its related data
  Future<void> saveRecipe(Recipe recipe);

  /// Update a recipe with all its related data
  Future<void> updateRecipe(Recipe recipe);

  /// Delete a recipe by UUID
  Future<void> deleteRecipe(String uuid);

  /// Toggle favorite status for a recipe
  Future<void> toggleFavorite(String uuid);

  /// Add a comment to a recipe
  Future<void> addComment(String recipeUuid, Comment comment);

  /// Get comments for a recipe
  Future<List<Comment>> getComments(String recipeUuid);

  /// Get available ingredients
  Future<List<String>> getAvailableIngredients();

  /// Get available units of measurement
  Future<List<String>> getAvailableUnits();
}
