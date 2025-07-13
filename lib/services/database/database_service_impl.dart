import '../../../data/models/recipe.dart' as app_model;
import '../../../data/models/comment.dart' as app_model;
import 'database_service.dart';

/// Stub implementation of the DatabaseService interface
/// Local database has been removed for performance optimization.
/// App now uses API with caching instead of local database.
class DatabaseServiceImpl implements DatabaseService {

  /// Constructor - no database dependency needed for stub implementation
  DatabaseServiceImpl();

  @override
  Future<List<app_model.Recipe>> getAllRecipes() async {
    // Stub implementation - return empty list
    // App now uses API with caching instead of local database
    return [];
  }

  @override
  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    // Stub implementation - return empty list
    // App now uses API with caching instead of local database
    return [];
  }

  @override
  Future<bool> isInFavorites(String recipeId) async {
    // Stub implementation - return false
    // App now uses API with caching instead of local database
    return false;
  }

  @override
  Future<app_model.Recipe?> getRecipeByUuid(String uuid) async {
    // Stub implementation - return null
    // App now uses API with caching instead of local database
    return null;
  }

  @override
  Future<void> saveRecipe(app_model.Recipe recipe) async {
    // Stub implementation - no-op
    // App now uses API with caching instead of local database
  }

  @override
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    // Stub implementation - no-op
    // App now uses API with caching instead of local database
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    // Stub implementation - no-op
    // App now uses API with caching instead of local database
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    // Stub implementation - no-op
    // App now uses API with caching instead of local database
  }

  @override
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Stub implementation - no-op
    // App now uses API with caching instead of local database
  }

  @override
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Stub implementation - return empty list
    // App now uses API with caching instead of local database
    return [];
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    // Stub implementation - return empty list
    // App now uses API with caching instead of local database
    return [];
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    // Stub implementation - return empty list
    // App now uses API with caching instead of local database
    return [];
  }
}
