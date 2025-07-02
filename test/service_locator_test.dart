import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_recipe_app/data/database/app_database.dart';
import 'package:flutter_recipe_app/services/object_detection_service.dart';
import 'package:flutter_recipe_app/data/api/api_service.dart';
import 'package:flutter_recipe_app/data/database/database_service.dart';
import 'package:flutter_recipe_app/models/recipe.dart' as app_model;
import 'package:flutter_recipe_app/models/comment.dart' as app_model;
import 'package:flutter_recipe_app/models/ingredient.dart' as app_model;
import 'package:flutter_recipe_app/models/recipe_image.dart';
import 'package:flutter_recipe_app/domain/usecases/recipe_manager.dart';
import 'package:flutter_recipe_app/domain/repositories/recipe_repository.dart';

final GetIt getIt = GetIt.instance;

// Mock implementation of ObjectDetectionService for testing
class MockObjectDetectionService implements ObjectDetectionService {
  @override
  Future<void> initialize() async {
    // Do nothing
  }

  @override
  Future<List<DetectedObject>> detectObjects(String imagePath, {int maxResults = 5}) async {
    // Return empty list
    return [];
  }

  @override
  void dispose() {
    // Do nothing
  }
}

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  Future<List<app_model.Recipe>> getRecipes() async {
    // Return an empty list - we'll use the Redux store for test data
    return [];
  }

  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    // Simulate successful toggle
    return true;
  }

  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    // Simulate successful update
    return true;
  }
}

// Mock implementation of DatabaseService for testing
class MockDatabaseService implements DatabaseService {
  @override
  Future<List<app_model.Recipe>> getAllRecipes() async {
    // Return an empty list - we'll use the Redux store for test data
    return [];
  }

  @override
  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    // Return an empty list - we'll use the Redux store for test data
    return [];
  }

  @override
  Future<app_model.Recipe?> getRecipeByUuid(String uuid) async {
    // Return null - we'll use the Redux store for test data
    return null;
  }

  @override
  Future<void> saveRecipe(app_model.Recipe recipe) async {
    // Do nothing
  }

  @override
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    // Do nothing
  }

  @override
  Future<bool> deleteRecipe(String recipeId) async {
    // Do nothing
    return true;
  }

  Future<void> toggleFavoriteStatus(String uuid, bool isFavorite) async {
    // Do nothing
  }

  @override
  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    // Do nothing
    return true;
  }

  @override
  Future<bool> isInFavorites(String recipeId) async {
    // Do nothing
    return false;
  }

  @override
  Future<int?> getStepId(String recipeUuid, int stepIndex) async {
    // Do nothing
    return null;
  }

  @override
  Future<bool> toggleFavorite(String recipeId) async {
    // Do nothing
    return true;
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    // Do nothing
    return [];
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    // Do nothing
    return [];
  }

  @override
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Do nothing
  }

  @override
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Do nothing
    return [];
  }

  @override
  Future<List<app_model.Ingredient>> getAllIngredients() async {
    // Return an empty list for testing
    return [];
  }

  @override
  Future<void> close() async {
    // Do nothing
  }
}

// Mock implementation of RecipeRepository for testing
class MockRecipeRepository implements RecipeRepository {
  @override
  Future<List<app_model.Recipe>> getRecipes() async {
    // Return an empty list for testing
    return [];
  }

  @override
  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    // Return an empty list for testing
    return [];
  }

  @override
  Future<app_model.Recipe?> getRecipeByUuid(String uuid) async {
    // Return null for testing
    return null;
  }

  @override
  Future<void> saveRecipe(app_model.Recipe recipe) async {
    // Do nothing for testing
  }

  @override
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    // Do nothing for testing
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    // Do nothing for testing
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    // Do nothing for testing
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    // Return an empty list for testing
    return [];
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    // Return an empty list for testing
    return [];
  }

  @override
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Do nothing for testing
  }

  @override
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Return an empty list for testing
    return [];
  }
}

/// Initialize the service locator for tests
void initializeTestServiceLocator() {
  // Reset the service locator if it's already been initialized
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }

  if (getIt.isRegistered<ObjectDetectionService>()) {
    getIt.unregister<ObjectDetectionService>();
  }

  if (getIt.isRegistered<ApiService>()) {
    getIt.unregister<ApiService>();
  }

  if (getIt.isRegistered<DatabaseService>()) {
    getIt.unregister<DatabaseService>();
  }

  if (getIt.isRegistered<RecipeManager>()) {
    getIt.unregister<RecipeManager>();
  }

  // Register the AppDatabase
  final appDatabase = AppDatabase();
  getIt.registerSingleton<AppDatabase>(appDatabase);

  // Register the ObjectDetectionService with a mock implementation for tests
  getIt.registerSingleton<ObjectDetectionService>(
    MockObjectDetectionService(),
  );

  // Register mock implementations of ApiService and DatabaseService
  getIt.registerSingleton<ApiService>(MockApiService());
  getIt.registerSingleton<DatabaseService>(MockDatabaseService());

  // Register a RecipeManager with a mock RecipeRepository
  getIt.registerSingleton<RecipeManager>(
    RecipeManager(recipeRepository: MockRecipeRepository()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Locator Tests', () {
    test('Initialize test service locator', () {
      // Initialize the service locator
      initializeTestServiceLocator();

      // Verify that the service locator has been initialized
      expect(getIt.isRegistered<AppDatabase>(), isTrue);
      expect(getIt.isRegistered<ObjectDetectionService>(), isTrue);
    });
  });
}
