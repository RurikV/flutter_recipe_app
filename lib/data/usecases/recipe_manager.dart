import '../models/recipe.dart';
import '../models/comment.dart';

/// Interface for recipe management operations
abstract class RecipeManager {
  /// Get all recipes
  Future<List<Recipe>> getRecipes();

  /// Get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes();

  /// Get recipe by UUID with detailed information
  Future<Recipe?> getRecipeByUuid(String uuid);

  /// Get available ingredients
  Future<List<String>> getIngredients();

  /// Get available units of measurement
  Future<List<String>> getUnits();

  /// Save a new recipe
  Future<bool> saveRecipe(Recipe recipe);

  /// Toggle favorite status for a recipe
  Future<bool> toggleFavorite(String recipeId);

  /// Add a comment to a recipe
  Future<bool> addComment(String recipeId, Comment comment);

  /// Update step completion status
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted);

}
