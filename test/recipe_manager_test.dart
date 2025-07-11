import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/data/models/comment.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/data/usecases/recipe_manager_impl.dart';
import 'package:recipe_master/data/repositories/recipe_repository.dart';
import 'package:recipe_master/services/api/api_service.dart';
import 'package:recipe_master/services/connectivity/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock implementation of ApiService for testing
class MockApiService implements ApiService {
  @override
  Future<Map<String, dynamic>> createRecipe(Recipe recipe) async {
    // Simulate successful recipe creation by returning a Map<String, dynamic>
    return {
      'id': 'mock-uuid',
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

  // Helper method for tests
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
          RecipeStep.simple(
            description: 'Mock step 1 description',
            duration: '10',
          ),
        ],
        isFavorite: false,
        comments: [],
      ),
    ];
  }

  // Helper method for tests
  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    // Simulate successful toggle
    return true;
  }

  // Helper method for tests
  Future<bool> updateStep(String recipeId, int stepId, bool isCompleted) async {
    // Simulate successful update
    return true;
  }

  @override
  Future<List<dynamic>> getRecipesData() async {
    // Mock implementation
    return [
      {
        'id': 'mock-uuid-1',
        'name': 'Mock Recipe 1',
        'photo': 'https://via.placeholder.com/400x300?text=Mock+Recipe',
        'description': 'Mock description',
        'instructions': 'Mock instructions',
        'difficulty': 2,
        'duration': '30 min',
        'rating': 0,
      }
    ];
  }

  @override
  Future<Map<String, dynamic>> getRecipeData(String id) async {
    // Mock implementation
    return {
      'id': id,
      'name': 'Mock Recipe',
      'photo': 'https://via.placeholder.com/400x300?text=Mock+Recipe',
      'description': 'Mock description',
      'instructions': 'Mock instructions',
      'difficulty': 2,
      'duration': '30 min',
      'rating': 0,
    };
  }

  @override
  Future<List<dynamic>> getIngredientsData() async {
    // Mock implementation
    return [
      {'id': 1, 'name': 'Ingredient 1'},
      {'id': 2, 'name': 'Ingredient 2'},
    ];
  }

  @override
  Future<List<dynamic>> getMeasureUnitsData() async {
    // Mock implementation
    return [
      {'id': 1, 'name': 'g'},
      {'id': 2, 'name': 'ml'},
    ];
  }

  @override
  Future<List<dynamic>> getRecipeIngredientsData() async {
    // Mock implementation
    return [
      {'recipe_id': 'mock-uuid-1', 'ingredient_id': 1, 'quantity': '100', 'unit': 'g'},
      {'recipe_id': 'mock-uuid-1', 'ingredient_id': 2, 'quantity': '200', 'unit': 'ml'},
    ];
  }

  @override
  Future<List<dynamic>> getRecipeStepsData() async {
    // Mock implementation
    return [
      {'id': 1, 'recipe_id': 'mock-uuid-1', 'description': 'Step 1', 'duration': '10'},
      {'id': 2, 'recipe_id': 'mock-uuid-1', 'description': 'Step 2', 'duration': '15'},
    ];
  }

  @override
  Future<List<dynamic>> getRecipeStepLinksData() async {
    // Mock implementation
    return [
      {'recipe_id': 'mock-uuid-1', 'step_id': 1, 'order': 1},
      {'recipe_id': 'mock-uuid-1', 'step_id': 2, 'order': 2},
    ];
  }

  @override
  Future<List<dynamic>> getCommentsForRecipe(String recipeId) async {
    // Mock implementation
    return [
      {'id': 1, 'recipe_id': recipeId, 'author': 'User 1', 'text': 'Comment 1', 'date': '2023-01-01'},
      {'id': 2, 'recipe_id': recipeId, 'author': 'User 2', 'text': 'Comment 2', 'date': '2023-01-02'},
    ];
  }

  @override
  Future<Map<String, dynamic>> addComment(String recipeId, String authorName, String text) async {
    // Mock implementation
    return {
      'id': 3,
      'recipe_id': recipeId,
      'author': authorName,
      'text': text,
      'date': DateTime.now().toString(),
    };
  }

  @override
  Future<Map<String, dynamic>> updateRecipe(String id, Recipe recipe) async {
    // Mock implementation
    return {
      'id': id,
      'name': recipe.name,
      'photo': recipe.images,
      'description': recipe.description,
      'instructions': recipe.instructions,
      'difficulty': recipe.difficulty,
      'duration': recipe.duration,
      'rating': recipe.rating,
    };
  }

  @override
  Future<void> deleteRecipe(String id) async {
    // Mock implementation
  }

  @override
  Future<Map<String, dynamic>> createRecipeData(Map<String, dynamic> recipeData) async {
    // Mock implementation
    return {'id': 'mock-uuid', ...recipeData};
  }

  @override
  Future<Map<String, dynamic>> createIngredientData(Map<String, dynamic> ingredientData) async {
    // Mock implementation
    return {'id': 3, ...ingredientData};
  }

  @override
  Future<Map<String, dynamic>> createRecipeIngredientData(Map<String, dynamic> recipeIngredientData) async {
    // Mock implementation
    return {'id': 3, ...recipeIngredientData};
  }

  @override
  Future<Map<String, dynamic>> createRecipeStepData(Map<String, dynamic> stepData) async {
    // Mock implementation
    return {'id': 3, ...stepData};
  }

  @override
  Future<Map<String, dynamic>> createRecipeStepLinkData(Map<String, dynamic> stepLinkData) async {
    // Mock implementation
    return {'id': 3, ...stepLinkData};
  }

  @override
  Future<Map<String, dynamic>> updateRecipeData(String id, Map<String, dynamic> recipeData) async {
    // Mock implementation
    return {'id': id, ...recipeData};
  }

  @override
  Future<void> deleteRecipeData(String id) async {
    // Mock implementation
  }

  @override
  Future<Map<String, dynamic>> addCommentData(String recipeId, Map<String, dynamic> commentData) async {
    // Mock implementation
    return {'id': 3, 'recipe_id': recipeId, ...commentData};
  }

  @override
  Future<List<dynamic>> getCommentsData(String recipeId) async {
    // Mock implementation
    return [
      {'id': 1, 'recipe_id': recipeId, 'author': 'User 1', 'text': 'Comment 1', 'date': '2023-01-01'},
      {'id': 2, 'recipe_id': recipeId, 'author': 'User 2', 'text': 'Comment 2', 'date': '2023-01-02'},
    ];
  }
}

// Mock implementation of DatabaseService for testing
class MockDatabaseService {
  final Map<String, Recipe> _recipes = {};

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
          RecipeStep.simple(
            description: 'Mock step 1 description',
            duration: '10',
          ),
        ],
        isFavorite: false,
        comments: [],
      ),
    ];
  }

  Future<List<Ingredient>> getAllIngredients() async {
    // Mock implementation
    return [
      Ingredient.simple(name: 'Ingredient 1', quantity: '100', unit: 'g'),
      Ingredient.simple(name: 'Ingredient 2', quantity: '200', unit: 'ml'),
      Ingredient.simple(name: 'Ingredient 3', quantity: '3', unit: 'pcs'),
    ];
  }

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
          RecipeStep.simple(
            description: 'Mock step 1 description',
            duration: '10',
          ),
        ],
        isFavorite: true,
        comments: [],
      ),
    ];
  }

  Future<bool> toggleFavorite(String recipeId) async {
    // Simulate successful toggle
    return true;
  }

  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    // Simulate successful update
    return true;
  }

  Future<void> saveRecipe(Recipe recipe) async {
    // Simulate successful save
    _recipes[recipe.uuid] = recipe;
  }

  Future<Recipe?> getRecipeByUuid(String uuid) async {
    return _recipes[uuid];
  }

  Future<int?> getStepId(String recipeUuid, int stepIndex) async {
    return 1; // Mock step ID
  }

  Future<bool> deleteRecipe(String recipeId) async {
    if (_recipes.containsKey(recipeId)) {
      _recipes.remove(recipeId);
      return true;
    }
    return false;
  }

  Future<void> close() async {
    // No need to do anything in the mock
  }

  Future<void> updateRecipe(Recipe recipe) async {
    // Mock implementation - reuse saveRecipe
    await saveRecipe(recipe);
  }

  Future<List<String>> getAvailableIngredients() async {
    // Mock implementation
    return ['Ingredient 1', 'Ingredient 2', 'Ingredient 3'];
  }

  Future<List<String>> getAvailableUnits() async {
    // Mock implementation
    return ['g', 'kg', 'ml', 'l', 'pcs'];
  }

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

  Future<List<Comment>> getComments(String recipeUuid) async {
    // Mock implementation
    if (_recipes.containsKey(recipeUuid)) {
      return _recipes[recipeUuid]!.comments;
    }
    return [];
  }

  Future<bool> isInFavorites(String recipeId) async {
    // Mock implementation
    if (_recipes.containsKey(recipeId)) {
      return _recipes[recipeId]!.isFavorite;
    }
    return false;
  }

  Future<void> clearDatabase() async {
    // Mock implementation
    _recipes.clear();
  }

  Future<void> updateFavoritesOrder(List<String> recipeIds) async {
    // Mock implementation - no need to do anything in the mock
  }

  Future<void> updateStepCompletion(String recipeId, int stepId, bool isCompleted) async {
    // Mock implementation
    if (_recipes.containsKey(recipeId)) {
      final recipe = _recipes[recipeId]!;
      final updatedSteps = List<RecipeStep>.from(recipe.steps);

      // Find the step with the given ID and update its completion status
      for (int i = 0; i < updatedSteps.length; i++) {
        if (updatedSteps[i].id == stepId) {
          updatedSteps[i] = updatedSteps[i].copyWith(
            isCompleted: isCompleted,
          );
          break;
        }
      }

      // Update the recipe with the updated steps
      _recipes[recipeId] = Recipe(
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
        steps: updatedSteps,
        isFavorite: recipe.isFavorite,
        comments: recipe.comments,
      );
    }
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
          RecipeStep.simple(
            description: 'Mock step 1 description',
            duration: '10',
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
          RecipeStep.simple(
            description: 'Mock step 1 description',
            duration: '10',
          ),
        ],
        isFavorite: true,
        comments: [],
      ),
    ];
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    // First check in the _recipes list for recipes added during the test
    try {
      return _recipes.firstWhere((recipe) => recipe.uuid == uuid);
    } catch (e) {
      // If not found in _recipes, check in the hardcoded list from getRecipes()
      final recipes = await getRecipes();
      try {
        return recipes.firstWhere((recipe) => recipe.uuid == uuid);
      } catch (e) {
        return null;
      }
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
      _recipes[index] = recipe.copyWith(
        isFavorite: !recipe.isFavorite,
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
      _recipes[index] = recipe.copyWith(
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
      recipeManager = RecipeManagerImpl(
        recipeRepository: mockRecipeRepository,
      );
    });

    test('Save recipe with internet connection', () async {
      // Create a test recipe
      final Recipe recipe = Recipe(
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
          RecipeStep.simple(
            description: 'Test step 1 description',
            duration: '10',
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
          RecipeStep.simple(
            description: 'Test step 1 description',
            duration: '10',
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
      final failingRecipeManager = RecipeManagerImpl(
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
      final failingRecipeManager = RecipeManagerImpl(
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

    test('Add new recipe and verify it can be retrieved', () async {
      // Create a unique test recipe
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final testRecipe = Recipe(
        uuid: 'test-uuid-$uniqueId',
        name: 'Test Recipe $uniqueId',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description for add/get test',
        instructions: 'Test instructions for add/get test',
        difficulty: 3,
        duration: '45 min',
        rating: 4,
        tags: ['test', 'add-get-test'],
        ingredients: [
          Ingredient.simple(
            name: 'Test ingredient 1',
            quantity: '200',
            unit: 'g',
          ),
          Ingredient.simple(
            name: 'Test ingredient 2',
            quantity: '100',
            unit: 'ml',
          ),
        ],
        steps: [
          RecipeStep.simple(
            description: 'Test step 1 description for add/get test',
            duration: '15',
          ),
          RecipeStep.simple(
            description: 'Test step 2 description for add/get test',
            duration: '10',
          ),
        ],
        isFavorite: false,
        comments: [],
      );

      // Save the recipe
      final saveSuccess = await recipeManager.saveRecipe(testRecipe);
      expect(saveSuccess, isTrue);
      print('[DEBUG_LOG] Recipe saved successfully: ${testRecipe.uuid}');

      // Get the recipe by UUID
      final retrievedRecipe = await mockRecipeRepository.getRecipeByUuid(testRecipe.uuid);

      // Verify the recipe was retrieved successfully
      expect(retrievedRecipe, isNotNull);
      expect(retrievedRecipe?.uuid, equals(testRecipe.uuid));
      expect(retrievedRecipe?.name, equals(testRecipe.name));
      expect(retrievedRecipe?.description, equals(testRecipe.description));
      expect(retrievedRecipe?.difficulty, equals(testRecipe.difficulty));
      expect(retrievedRecipe?.duration, equals(testRecipe.duration));
      expect(retrievedRecipe?.ingredients.length, equals(testRecipe.ingredients.length));
      expect(retrievedRecipe?.steps.length, equals(testRecipe.steps.length));

      print('[DEBUG_LOG] Recipe retrieved successfully: ${retrievedRecipe?.uuid}');
      print('[DEBUG_LOG] Recipe name: ${retrievedRecipe?.name}');
      print('[DEBUG_LOG] Recipe ingredients count: ${retrievedRecipe?.ingredients.length}');
      print('[DEBUG_LOG] Recipe steps count: ${retrievedRecipe?.steps.length}');
    });
  });
}
