import '../../models/recipe.dart';
import '../../models/comment.dart';

/// Repository interface for recipe-related operations
abstract class RecipeRepository {
  /// Get all recipes
  Future<List<Recipe>> getRecipes();
  
  /// Get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes();
  
  /// Get recipe by UUID
  Future<Recipe?> getRecipeByUuid(String uuid);
  
  /// Save recipe
  Future<void> saveRecipe(Recipe recipe);
  
  /// Update recipe
  Future<void> updateRecipe(Recipe recipe);
  
  /// Delete recipe
  Future<void> deleteRecipe(String uuid);
  
  /// Toggle favorite status
  Future<void> toggleFavorite(String uuid);
  
  /// Get available ingredients
  Future<List<String>> getAvailableIngredients();
  
  /// Get available units of measurement
  Future<List<String>> getAvailableUnits();
  
  /// Add comment to recipe
  Future<void> addComment(String recipeUuid, Comment comment);
  
  /// Get comments for recipe
  Future<List<Comment>> getComments(String recipeUuid);
}