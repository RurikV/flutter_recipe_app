import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_master/data/database/app_database.dart' as db;
import 'package:recipe_master/services/classification/object_detection_service.dart';
import 'package:recipe_master/services/api/api_service.dart';
import 'package:recipe_master/services/database/database_service.dart';
import 'package:recipe_master/data/models/recipe.dart' as app_model;
import 'package:recipe_master/data/models/comment.dart' as app_model;
import 'package:recipe_master/data/models/ingredient.dart' as app_model;
import 'package:recipe_master/data/models/recipe_image.dart' as model;
import 'package:recipe_master/data/entities/recipe.dart';
import 'package:recipe_master/data/entities/comment.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/data/usecases/recipe_manager_impl.dart';
import 'package:recipe_master/data/repositories/recipe_repository.dart';

final GetIt testGetIt = GetIt.instance;

// Mock implementation of ObjectDetectionService for testing
class MockObjectDetectionService implements ObjectDetectionService {
  @override
  Future<void> initialize() async {
    // Do nothing for testing
  }

  @override
  Future<List<ServiceDetectedObject>> detectObjects(model.RecipeImage image) async {
    // Return empty list for testing
    return <ServiceDetectedObject>[];
  }

  @override
  bool get isInitialized => true;
}

// Mock implementation of ApiService for testing
class MockApiService implements ApiService {
  List<Map<String, dynamic>> createdSteps = [];
  List<Map<String, dynamic>> createdStepLinks = [];
  List<Map<String, dynamic>> createdIngredients = [];

  // Additional methods not in the interface
  Future<List<app_model.Recipe>> getRecipes() async {
    // Return an empty list - we'll use the Redux store for test data
    return [];
  }

  // Additional methods not in the interface
  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    // Simulate successful toggle
    return true;
  }

  // Additional methods not in the interface
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    // Simulate successful update
    return true;
  }

  @override
  Future<List<dynamic>> getRecipesData() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getRecipeData(String id) async {
    return {};
  }

  @override
  Future<List<dynamic>> getIngredientsData() async {
    return [];
  }

  @override
  Future<List<dynamic>> getMeasureUnitsData() async {
    return [];
  }

  @override
  Future<List<dynamic>> getRecipeIngredientsData() async {
    return [];
  }

  @override
  Future<List<dynamic>> getRecipeStepsData() async {
    return [];
  }

  @override
  Future<List<dynamic>> getRecipeStepLinksData() async {
    return [];
  }

  @override
  Future<List<dynamic>> getCommentsForRecipe(String recipeId) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> addComment(String recipeId, String authorName, String text) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> createRecipe(app_model.Recipe recipe) async {
    // Simulate the new approach to recipe creation:
    // 1. Create the recipe with basic information
    // 2. Create recipe ingredients
    // 3. Create recipe steps and link them to the recipe

    // Create a simplified JSON directly
    final simplifiedJson = {
      'name': recipe.name,
      'duration': int.tryParse(recipe.duration.split(' ').first) ?? 0,
      'photo': recipe.images,
    };

    print('[DEBUG_LOG] MockApiService: Creating recipe with basic info: $simplifiedJson');

    // Simulate creating recipe ingredients
    for (var ingredient in recipe.ingredients) {
      final ingredientJson = {
        'count': int.tryParse(ingredient.quantity) ?? 0,
        'ingredient': {'id': ingredient.id},
        'recipe': {'id': 999} // Mock recipe ID
      };
      createdIngredients.add(ingredientJson);
      print('[DEBUG_LOG] MockApiService: Creating recipe ingredient: $ingredientJson');
    }

    // Simulate creating recipe steps and linking them to the recipe
    for (var i = 0; i < recipe.steps.length; i++) {
      final step = recipe.steps[i];

      // Create step
      final stepJson = {
        'name': step.name,
        'duration': step.duration,
      };
      createdSteps.add(stepJson);
      print('[DEBUG_LOG] MockApiService: Creating recipe step: $stepJson');

      // Link step to recipe
      final stepLinkJson = {
        'number': i + 1,
        'recipe': {'id': 999}, // Mock recipe ID
        'step': {'id': step.id}
      };
      createdStepLinks.add(stepLinkJson);
      print('[DEBUG_LOG] MockApiService: Creating recipe step link: $stepLinkJson');
    }

    // Simulate successful recipe creation by returning a Map<String, dynamic>
    // that contains the recipe data
    return {
      'id': 'mock-uuid-${DateTime.now().millisecondsSinceEpoch}',
      'name': recipe.name,
      'photo': recipe.images,
      'description': recipe.description,
      'instructions': recipe.instructions,
      'difficulty': recipe.difficulty,
      'duration': recipe.duration,
      'rating': recipe.rating,
      'tags': recipe.tags.map((tag) => {'name': tag}).toList(),
      'ingredients': recipe.ingredients.map((ingredient) => {
        'name': ingredient.name,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit,
      }).toList(),
      'steps': recipe.steps.map((step) => {
        'id': step.id,
        'name': step.name,
        'duration': step.duration,
      }).toList(),
      'isFavorite': recipe.isFavorite,
      'comments': recipe.comments.map((comment) => {
        'text': comment.text,
        'author': comment.authorName,
        'date': comment.date,
      }).toList(),
    };
  }

  @override
  Future<Map<String, dynamic>> updateRecipe(String id, app_model.Recipe recipe) async {
    return {};
  }

  @override
  Future<void> deleteRecipe(String id) async {
    // Do nothing
  }

  @override
  Future<Map<String, dynamic>> createRecipeData(Map<String, dynamic> recipeData) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> createIngredientData(Map<String, dynamic> ingredientData) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> createRecipeIngredientData(Map<String, dynamic> recipeIngredientData) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> createRecipeStepData(Map<String, dynamic> stepData) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> createRecipeStepLinkData(Map<String, dynamic> stepLinkData) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateRecipeData(String id, Map<String, dynamic> recipeData) async {
    return {};
  }

  @override
  Future<void> deleteRecipeData(String id) async {
    // Do nothing
  }

  @override
  Future<Map<String, dynamic>> addCommentData(String recipeId, Map<String, dynamic> commentData) async {
    return {};
  }

  @override
  Future<List<dynamic>> getCommentsData(String recipeId) async {
    return [];
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
  Future<void> deleteRecipe(String recipeId) async {
    // Do nothing
  }

  @override
  Future<bool> isInFavorites(String recipeId) async {
    // Do nothing
    return false;
  }

  // This method is not in the DatabaseService interface
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

  // This method is not in the DatabaseService interface
  Future<List<app_model.Ingredient>> getAllIngredients() async {
    // Return an empty list for testing
    return [];
  }

  // This method is not in the DatabaseService interface
  Future<void> close() async {
    // Do nothing
  }

  // This method is not in the DatabaseService interface
  Future<void> clearDatabase() async {
    // Do nothing for testing
  }

  // This method is not in the DatabaseService interface
  Future<void> updateFavoritesOrder(List<String> recipeIds) async {
    // Do nothing for testing
  }

  // This method is not in the DatabaseService interface
  Future<void> updateStepCompletion(String recipeId, int stepId, bool isCompleted) async {
    // Do nothing for testing
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
  if (testGetIt.isRegistered<db.AppDatabase>()) {
    testGetIt.unregister<db.AppDatabase>();
  }

  if (testGetIt.isRegistered<ObjectDetectionService>()) {
    testGetIt.unregister<ObjectDetectionService>();
  }

  if (testGetIt.isRegistered<ApiService>()) {
    testGetIt.unregister<ApiService>();
  }

  if (testGetIt.isRegistered<DatabaseService>()) {
    testGetIt.unregister<DatabaseService>();
  }

  if (testGetIt.isRegistered<RecipeManager>()) {
    testGetIt.unregister<RecipeManager>();
  }

  // Register the AppDatabase
  final appDatabase = db.AppDatabase();
  testGetIt.registerSingleton<db.AppDatabase>(appDatabase);

  // Register the ObjectDetectionService with a mock implementation for tests
  testGetIt.registerSingleton<ObjectDetectionService>(
    MockObjectDetectionService(),
  );

  // Register mock implementations of ApiService and DatabaseService
  testGetIt.registerSingleton<ApiService>(MockApiService());
  testGetIt.registerSingleton<DatabaseService>(MockDatabaseService());

  // Register a RecipeManager with a mock RecipeRepository
  testGetIt.registerSingleton<RecipeManager>(
    RecipeManagerImpl(recipeRepository: MockRecipeRepository()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Locator Tests', () {
    test('Initialize test service locator', () {
      // Initialize the service locator
      initializeTestServiceLocator();

      // Verify that the service locator has been initialized
      expect(testGetIt.isRegistered<db.AppDatabase>(), isTrue);
      expect(testGetIt.isRegistered<ObjectDetectionService>(), isTrue);
    });
  });
}
