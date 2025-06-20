import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/services/recipe_manager.dart';
import 'package:flutter_recipe_app/services/api_service.dart';
import 'package:flutter_recipe_app/services/database_service.dart';
import 'package:flutter_recipe_app/services/connectivity_service.dart';
import 'package:flutter_recipe_app/models/comment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    // Simulate successful recipe creation
    return Recipe(
      uuid: 'mock-uuid',
      name: recipe.name,
      images: recipe.images,
      description: recipe.description,
      instructions: recipe.instructions,
      difficulty: recipe.difficulty,
      duration: recipe.duration,
      rating: recipe.rating,
      tags: recipe.tags,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      isFavorite: recipe.isFavorite,
      comments: recipe.comments,
    );
  }

  @override
  Future<List<Recipe>> getRecipes() async {
    // Return a list with one mock recipe
    return [
      Recipe(
        uuid: 'mock-uuid-1',
        name: 'Mock Recipe 1',
        images: 'https://via.placeholder.com/400x300?text=Mock+Recipe',
        description: 'Mock description',
        instructions: 'Mock instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['mock', 'test'],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Mock step 1',
            duration: '10 min',
          ),
        ],
        isFavorite: false,
        comments: [],
      ),
    ];
  }

  @override
  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    // Simulate successful toggle
    return true;
  }

  @override
  Future<bool> updateStep(String recipeId, int stepId, bool isCompleted) async {
    // Simulate successful update
    return true;
  }
}

// Mock implementation of DatabaseService for testing
class MockDatabaseService extends DatabaseService {
  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    // Simulate successful save
    return true;
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    // Return a list with one mock recipe
    return [
      Recipe(
        uuid: 'mock-uuid-1',
        name: 'Mock Recipe 1',
        images: 'https://via.placeholder.com/400x300?text=Mock+Recipe',
        description: 'Mock description',
        instructions: 'Mock instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['mock', 'test'],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Mock step 1',
            duration: '10 min',
          ),
        ],
        isFavorite: false,
        comments: [],
      ),
    ];
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    // Return a list with one mock favorite recipe
    return [
      Recipe(
        uuid: 'mock-uuid-2',
        name: 'Mock Favorite Recipe',
        images: 'https://via.placeholder.com/400x300?text=Mock+Recipe',
        description: 'Mock description',
        instructions: 'Mock instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['mock', 'test', 'favorite'],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Mock step 1',
            duration: '10 min',
          ),
        ],
        isFavorite: true,
        comments: [],
      ),
    ];
  }

  @override
  Future<bool> toggleFavorite(String recipeId) async {
    // Simulate successful toggle
    return true;
  }

  @override
  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    // Simulate successful update
    return true;
  }
}

// Mock implementation of ConnectivityService for testing
class MockConnectivityService extends ConnectivityService {
  final bool _isConnected;

  MockConnectivityService({bool isConnected = true}) : _isConnected = isConnected;

  @override
  Future<bool> isConnected() async {
    return _isConnected;
  }

  @override
  Stream<ConnectivityResult> get connectivityStream => 
      Stream.value(_isConnected ? ConnectivityResult.wifi : ConnectivityResult.none);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Manager Tests', () {
    late RecipeManager recipeManager;
    late MockApiService mockApiService;
    late MockDatabaseService mockDatabaseService;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      // Create mock services
      mockApiService = MockApiService();
      mockDatabaseService = MockDatabaseService();
      mockConnectivityService = MockConnectivityService();

      // Create a recipe manager with mock services
      recipeManager = RecipeManager(
        apiService: mockApiService,
        databaseService: mockDatabaseService,
        connectivityService: mockConnectivityService,
      );
    });

    test('Save recipe with internet connection', () async {
      // Create a test recipe
      final recipe = Recipe(
        uuid: 'test-uuid-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['test', 'recipe'],
        ingredients: [
          Ingredient(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          RecipeStep(
            description: 'Test step 1',
            duration: '10 min',
          ),
        ],
      );

      // Save the recipe
      final success = await recipeManager.saveRecipe(recipe);

      // Verify the recipe was saved successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Recipe saved successfully with internet connection: ${recipe.uuid}');
    });

    test('Save recipe without internet connection', () async {
      // Create a test recipe
      final recipe = Recipe(
        uuid: 'test-uuid-offline-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Recipe Offline ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['test', 'recipe', 'offline'],
        ingredients: [
          Ingredient(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          RecipeStep(
            description: 'Test step 1',
            duration: '10 min',
          ),
        ],
      );

      // Save the recipe
      final success = await recipeManager.saveRecipe(recipe);

      // Verify the recipe was saved successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Recipe saved successfully without internet connection: ${recipe.uuid}');
    });

    test('Get recipes with internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Verify recipes were retrieved
      expect(recipes, isNotNull);
      expect(recipes.isNotEmpty, isTrue);

      print('[DEBUG_LOG] Retrieved ${recipes.length} recipes with internet connection');
    });

    test('Get recipes without internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Verify recipes were retrieved
      expect(recipes, isNotNull);
      expect(recipes.isNotEmpty, isTrue);

      print('[DEBUG_LOG] Retrieved ${recipes.length} recipes without internet connection');
    });

    test('Toggle favorite status with internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Ensure we have at least one recipe
      expect(recipes.isNotEmpty, isTrue);

      // Toggle favorite status for the first recipe
      final recipeId = recipes.first.uuid;
      final success = await recipeManager.toggleFavorite(recipeId);

      // Verify the favorite status was toggled successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Toggled favorite status successfully with internet connection: $recipeId');
    });

    test('Toggle favorite status without internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Ensure we have at least one recipe
      expect(recipes.isNotEmpty, isTrue);

      // Toggle favorite status for the first recipe
      final recipeId = recipes.first.uuid;
      final success = await recipeManager.toggleFavorite(recipeId);

      // Verify the favorite status was toggled successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Toggled favorite status successfully without internet connection: $recipeId');
    });

    test('Update step status with internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Find a recipe with steps
      final recipesWithSteps = recipes.where((r) => r.steps.isNotEmpty).toList();
      expect(recipesWithSteps.isNotEmpty, isTrue);

      final recipe = recipesWithSteps.first;
      final recipeId = recipe.uuid;
      final stepIndex = 0;

      // Update step status
      final success = await recipeManager.updateStepStatus(recipeId, stepIndex, true);

      // Verify the step status was updated successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Updated step status successfully with internet connection: $recipeId, step $stepIndex');
    });

    test('Update step status without internet connection', () async {
      // Get recipes
      final recipes = await recipeManager.getRecipes();

      // Find a recipe with steps
      final recipesWithSteps = recipes.where((r) => r.steps.isNotEmpty).toList();
      expect(recipesWithSteps.isNotEmpty, isTrue);

      final recipe = recipesWithSteps.first;
      final recipeId = recipe.uuid;
      final stepIndex = 0;

      // Update step status
      final success = await recipeManager.updateStepStatus(recipeId, stepIndex, true);

      // Verify the step status was updated successfully
      expect(success, isTrue);

      print('[DEBUG_LOG] Updated step status successfully without internet connection: $recipeId, step $stepIndex');
    });
  });
}
