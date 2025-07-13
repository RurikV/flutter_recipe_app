import '../../../data/models/recipe.dart';

/// Interface for API-related operations
abstract class ApiService {
  /// Get all recipes (basic data only)
  Future<List<dynamic>> getRecipesData();

  /// Get a recipe by ID (basic data only)
  Future<Map<String, dynamic>> getRecipeData(String id);

  /// Get all ingredients
  Future<List<dynamic>> getIngredientsData();

  /// Get all measure units
  Future<List<dynamic>> getMeasureUnitsData();

  /// Get all recipe ingredients
  Future<List<dynamic>> getRecipeIngredientsData();

  /// Get all recipe steps
  Future<List<dynamic>> getRecipeStepsData();

  /// Get all recipe step links
  Future<List<dynamic>> getRecipeStepLinksData();

  /// Get all comments for a recipe
  Future<List<dynamic>> getCommentsForRecipe(String recipeId);

  /// Add a comment to a recipe
  Future<Map<String, dynamic>> addComment(String recipeId, String authorName, String text);

  /// Create a new recipe
  Future<Map<String, dynamic>> createRecipe(Recipe recipe);

  /// Update an existing recipe
  Future<Map<String, dynamic>> updateRecipe(String id, Recipe recipe);

  /// Delete a recipe
  Future<void> deleteRecipe(String id);

  /// Create recipe data
  Future<Map<String, dynamic>> createRecipeData(Map<String, dynamic> recipeData);

  /// Create ingredient data
  Future<Map<String, dynamic>> createIngredientData(Map<String, dynamic> ingredientData);

  /// Create recipe ingredient data
  Future<Map<String, dynamic>> createRecipeIngredientData(Map<String, dynamic> recipeIngredientData);

  /// Create recipe step data
  Future<Map<String, dynamic>> createRecipeStepData(Map<String, dynamic> stepData);

  /// Create recipe step link data
  Future<Map<String, dynamic>> createRecipeStepLinkData(Map<String, dynamic> stepLinkData);

  /// Update recipe data
  Future<Map<String, dynamic>> updateRecipeData(String id, Map<String, dynamic> recipeData);

  /// Delete recipe data
  Future<void> deleteRecipeData(String id);

  /// Add comment data
  Future<Map<String, dynamic>> addCommentData(String recipeId, Map<String, dynamic> commentData);

  /// Get comments data
  Future<List<dynamic>> getCommentsData(String recipeId);
}
