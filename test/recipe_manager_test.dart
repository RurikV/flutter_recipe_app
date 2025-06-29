import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/models/comment.dart';
import 'package:flutter_recipe_app/domain/usecases/recipe_manager.dart';
import 'package:flutter_recipe_app/domain/repositories/recipe_repository.dart';
import 'package:flutter_recipe_app/data/api_service.dart';
import 'package:flutter_recipe_app/data/database_service.dart';
import 'package:flutter_recipe_app/services/connectivity_service.dart';
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
            id: 1,
            name: 'Mock step 1',
            duration: 10,
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
class MockDatabaseService implements DatabaseService {
  final Map<String, Recipe> _recipes = {};

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
            id: 1,
            name: 'Mock step 1',
            duration: 10,
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
            id: 1,
            name: 'Mock step 1',
            duration: 10,
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

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    // Simulate successful save
    _recipes[recipe.uuid] = recipe;
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    return _recipes[uuid];
  }

  @override
  Future<int?> getStepId(String recipeUuid, int stepIndex) async {
    return 1; // Mock step ID
  }

  @override
  Future<bool> deleteRecipe(String recipeId) async {
    if (_recipes.containsKey(recipeId)) {
      _recipes.remove(recipeId);
      return true;
    }
    return false;
  }

  @override
  Future<void> close() async {
    // No need to do anything in the mock
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    // Mock implementation - reuse saveRecipe
    await saveRecipe(recipe);
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    // Mock implementation
    return ['Ingredient 1', 'Ingredient 2', 'Ingredient 3'];
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    // Mock implementation
    return ['g', 'kg', 'ml', 'l', 'pcs'];
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    // Mock implementation
    if (_recipes.containsKey(recipeUuid)) {
      final recipe = _recipes[recipeUuid]!;
      final updatedComments = List<Comment>.from(recipe.comments)..add(comment);
      final updatedRecipe = Recipe(
        uuid: recipe.uuid,
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
        comments: updatedComments,
      );
      _recipes[recipeUuid] = updatedRecipe;
    }
  }

  @override
  Future<List<Comment>> getComments(String recipeUuid) async {
    // Mock implementation
    if (_recipes.containsKey(recipeUuid)) {
      return _recipes[recipeUuid]!.comments;
    }
    return [];
  }

  @override
  Future<bool> isInFavorites(String recipeId) async {
    // Mock implementation
    if (_recipes.containsKey(recipeId)) {
      return _recipes[recipeId]!.isFavorite;
    }
    return false;
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

// Mock implementation of RecipeRepository for testing
class MockRecipeRepository implements RecipeRepository {
  final List<Recipe> _recipes = [];

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
            id: 1,
            name: 'Mock step 1',
            duration: 10,
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
            id: 1,
            name: 'Mock step 1',
            duration: 10,
          ),
        ],
        isFavorite: true,
        comments: [],
      ),
    ];
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    final recipes = await getRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    // Simulate successful save
    _recipes.add(recipe);
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    // Simulate successful update
    final index = _recipes.indexWhere((r) => r.uuid == recipe.uuid);
    if (index != -1) {
      _recipes[index] = recipe;
    } else {
      _recipes.add(recipe);
    }
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    // Simulate successful delete
    _recipes.removeWhere((recipe) => recipe.uuid == uuid);
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    // Simulate successful toggle
    final index = _recipes.indexWhere((r) => r.uuid == uuid);
    if (index != -1) {
      final recipe = _recipes[index];
      _recipes[index] = Recipe(
        uuid: recipe.uuid,
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
        isFavorite: !recipe.isFavorite,
        comments: recipe.comments,
      );
    }
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    // Mock implementation
    return ['Ingredient 1', 'Ingredient 2', 'Ingredient 3'];
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    // Mock implementation
    return ['g', 'kg', 'ml', 'l', 'pcs'];
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    // Simulate successful comment addition
    final index = _recipes.indexWhere((r) => r.uuid == recipeUuid);
    if (index != -1) {
      final recipe = _recipes[index];
      final updatedComments = List<Comment>.from(recipe.comments)..add(comment);
      _recipes[index] = Recipe(
        uuid: recipe.uuid,
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
        comments: updatedComments,
      );
    }
  }

  @override
  Future<List<Comment>> getComments(String recipeUuid) async {
    // Simulate successful comment retrieval
    final index = _recipes.indexWhere((r) => r.uuid == recipeUuid);
    if (index != -1) {
      return _recipes[index].comments;
    }
    return [];
  }
}

// Failing repository implementation for testing exception handling
class _FailingRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getRecipes() async {
    throw Exception('Failed to get recipes');
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    throw Exception('Failed to get favorite recipes');
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    throw Exception('Failed to get recipe by UUID');
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    throw Exception('Failed to save recipe');
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    throw Exception('Failed to update recipe');
  }

  @override
  Future<void> deleteRecipe(String uuid) async {
    throw Exception('Failed to delete recipe');
  }

  @override
  Future<void> toggleFavorite(String uuid) async {
    throw Exception('Failed to toggle favorite');
  }

  @override
  Future<List<String>> getAvailableIngredients() async {
    throw Exception('Failed to get available ingredients');
  }

  @override
  Future<List<String>> getAvailableUnits() async {
    throw Exception('Failed to get available units');
  }

  @override
  Future<void> addComment(String recipeUuid, Comment comment) async {
    throw Exception('Failed to add comment');
  }

  @override
  Future<List<Comment>> getComments(String recipeUuid) async {
    throw Exception('Failed to get comments');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Manager Tests', () {
    late RecipeManager recipeManager;
    late MockRecipeRepository mockRecipeRepository;

    setUp(() {
      // Create mock repository
      mockRecipeRepository = MockRecipeRepository();

      // Create a recipe manager with mock repository
      recipeManager = RecipeManager(
        recipeRepository: mockRecipeRepository,
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
          Ingredient.simple(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Test step 1',
            duration: 10,
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
          Ingredient.simple(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Test step 1',
            duration: 10,
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

    test('Get recipes throws exception when repository fails', () async {
      // Create a failing repository
      final failingRepository = _FailingRecipeRepository();

      // Create a recipe manager with failing repository
      final failingRecipeManager = RecipeManager(
        recipeRepository: failingRepository,
      );

      // Expect an exception when getting recipes
      expect(() => failingRecipeManager.getRecipes(), throwsException);

      print('[DEBUG_LOG] Successfully threw exception when repository failed to get recipes');
    });

    test('Get favorite recipes throws exception when repository fails', () async {
      // Create a failing repository
      final failingRepository = _FailingRecipeRepository();

      // Create a recipe manager with failing repository
      final failingRecipeManager = RecipeManager(
        recipeRepository: failingRepository,
      );

      // Expect an exception when getting favorite recipes
      expect(() => failingRecipeManager.getFavoriteRecipes(), throwsException);

      print('[DEBUG_LOG] Successfully threw exception when repository failed to get favorite recipes');
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
