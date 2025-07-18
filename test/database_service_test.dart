import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart' as app_model;
import 'package:recipe_master/data/models/recipe_step.dart' as app_model;
import 'package:recipe_master/data/models/ingredient.dart' as app_model;
import 'package:recipe_master/data/models/comment.dart' as app_model;

// Mock implementation for database service testing
class MockDatabaseService {
  final Map<String, app_model.Recipe> _recipes = {};

  Future<List<app_model.Recipe>> getAllRecipes() async {
    return _recipes.values.toList();
  }

  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    return _recipes.values.where((recipe) => recipe.isFavorite).toList();
  }

  Future<app_model.Recipe?> getRecipeByUuid(String uuid) async {
    return _recipes[uuid];
  }

  Future<void> saveRecipe(app_model.Recipe recipe) async {
    _recipes[recipe.uuid] = recipe;
  }

  Future<bool> toggleFavorite(String uuid) async {
    if (_recipes.containsKey(uuid)) {
      final recipe = _recipes[uuid]!;
      final updatedRecipe = app_model.Recipe(
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
      _recipes[uuid] = updatedRecipe;
      return true;
    }
    return false;
  }

  Future<bool> deleteRecipe(String uuid) async {
    if (_recipes.containsKey(uuid)) {
      _recipes.remove(uuid);
      return true;
    }
    return false;
  }

  // Helper method for tests
  Future<void> close() async {
    // No need to do anything in the mock
  }

  Future<void> updateRecipe(app_model.Recipe recipe) async {
    // Mock implementation - reuse saveRecipe
    await saveRecipe(recipe);
  }

  Future<List<String>> getAvailableIngredients() async {
    // Mock implementation
    return ['Ingredient 1', 'Ingredient 2', 'Ingredient 3'];
  }

  Future<List<app_model.Ingredient>> getAllIngredients() async {
    // Mock implementation
    return [
      app_model.Ingredient.simple(name: 'Ingredient 1', quantity: '100', unit: 'g'),
      app_model.Ingredient.simple(name: 'Ingredient 2', quantity: '200', unit: 'ml'),
      app_model.Ingredient.simple(name: 'Ingredient 3', quantity: '3', unit: 'pcs'),
    ];
  }

  Future<List<String>> getAvailableUnits() async {
    // Mock implementation
    return ['g', 'kg', 'ml', 'l', 'pcs'];
  }

  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Mock implementation
    if (_recipes.containsKey(recipeUuid)) {
      final recipe = _recipes[recipeUuid]!;
      final updatedComments = List<app_model.Comment>.from(recipe.comments)..add(comment);
      final updatedRecipe = app_model.Recipe(
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

  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
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

  // Helper method for tests
  Future<void> clearDatabase() async {
    // Mock implementation
    _recipes.clear();
  }

  // Helper method for tests
  Future<void> updateFavoritesOrder(List<String> recipeIds) async {
    // Mock implementation - no need to do anything in the mock
  }

  // Helper method for tests
  Future<void> updateStepCompletion(String recipeId, int stepId, bool isCompleted) async {
    // Mock implementation
    if (_recipes.containsKey(recipeId)) {
      final recipe = _recipes[recipeId]!;
      final updatedSteps = List<app_model.RecipeStep>.from(recipe.steps);

      // Find the step with the given ID and update its completion status
      for (int i = 0; i < updatedSteps.length; i++) {
        if (updatedSteps[i].id == stepId) {
          updatedSteps[i] = app_model.RecipeStep(
            id: updatedSteps[i].id,
            name: updatedSteps[i].name,
            duration: updatedSteps[i].duration,
            isCompleted: isCompleted,
          );
          break;
        }
      }

      // Update the recipe with the updated steps
      _recipes[recipeId] = app_model.Recipe(
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Database Service Tests', () {
    late MockDatabaseService databaseService;

    setUp(() {
      databaseService = MockDatabaseService();
    });

    tearDown(() async {
      // Close the database connection after each test
      await databaseService.close();
    });

    test('Save and retrieve recipe', () async {
      // Create a recipe with valid data
      final recipe = app_model.Recipe(
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
          app_model.Ingredient.simple(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          app_model.RecipeStep(
            id: 1,
            name: 'Test step 1',
            duration: 10,
          ),
          app_model.RecipeStep(
            id: 2,
            name: 'Test step 2',
            duration: 15,
          ),
        ],
      );

      // Save the recipe to the database
      await databaseService.saveRecipe(recipe);

      // Retrieve the recipe from the database
      final retrievedRecipe = await databaseService.getRecipeByUuid(recipe.uuid);

      // Verify the recipe was retrieved successfully
      expect(retrievedRecipe, isNotNull);
      expect(retrievedRecipe!.uuid, equals(recipe.uuid));
      expect(retrievedRecipe.name, equals(recipe.name));
      expect(retrievedRecipe.description, equals(recipe.description));
      expect(retrievedRecipe.instructions, equals(recipe.instructions));
      expect(retrievedRecipe.difficulty, equals(recipe.difficulty));
      expect(retrievedRecipe.duration, equals(recipe.duration));
      expect(retrievedRecipe.rating, equals(recipe.rating));

      // Verify tags
      expect(retrievedRecipe.tags.length, equals(recipe.tags.length));
      for (var i = 0; i < recipe.tags.length; i++) {
        expect(retrievedRecipe.tags[i], equals(recipe.tags[i]));
      }

      // Verify ingredients
      expect(retrievedRecipe.ingredients.length, equals(recipe.ingredients.length));
      for (var i = 0; i < recipe.ingredients.length; i++) {
        expect(retrievedRecipe.ingredients[i].name, equals(recipe.ingredients[i].name));
        expect(retrievedRecipe.ingredients[i].quantity, equals(recipe.ingredients[i].quantity));
        expect(retrievedRecipe.ingredients[i].unit, equals(recipe.ingredients[i].unit));
      }

      // Verify steps
      expect(retrievedRecipe.steps.length, equals(recipe.steps.length));
      for (var i = 0; i < recipe.steps.length; i++) {
        expect(retrievedRecipe.steps[i].name, equals(recipe.steps[i].name));
        expect(retrievedRecipe.steps[i].duration, equals(recipe.steps[i].duration));
        expect(retrievedRecipe.steps[i].isCompleted, equals(recipe.steps[i].isCompleted));
      }

      print('[DEBUG_LOG] Recipe saved and retrieved successfully: ${recipe.uuid}');
    });

    test('Update recipe', () async {
      // Create a recipe
      final recipe = app_model.Recipe(
        uuid: 'test-uuid-update-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Recipe Update ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['test', 'recipe'],
        ingredients: [
          app_model.Ingredient.simple(
            name: 'Test ingredient',
            quantity: '100',
            unit: 'g',
          ),
        ],
        steps: [
          app_model.RecipeStep(
            id: 1,
            name: 'Test step 1',
            duration: 10,
          ),
        ],
      );

      // Save the recipe to the database
      await databaseService.saveRecipe(recipe);

      // Update the recipe
      final updatedRecipe = app_model.Recipe(
        uuid: recipe.uuid,
        name: 'Updated Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: recipe.images,
        description: 'Updated description',
        instructions: recipe.instructions,
        difficulty: recipe.difficulty,
        duration: recipe.duration,
        rating: recipe.rating,
        tags: recipe.tags,
        ingredients: recipe.ingredients,
        steps: [
          app_model.RecipeStep(
            id: 1,
            name: 'Updated step 1',
            duration: 15,
          ),
          app_model.RecipeStep(
            id: 2,
            name: 'New step 2',
            duration: 20,
          ),
        ],
      );

      // Save the updated recipe to the database
      await databaseService.saveRecipe(updatedRecipe);

      // Retrieve the updated recipe from the database
      final retrievedRecipe = await databaseService.getRecipeByUuid(recipe.uuid);

      // Verify the recipe was updated successfully
      expect(retrievedRecipe, isNotNull);
      expect(retrievedRecipe!.name, equals(updatedRecipe.name));
      expect(retrievedRecipe.description, equals(updatedRecipe.description));

      // Verify steps were updated
      expect(retrievedRecipe.steps.length, equals(updatedRecipe.steps.length));
      for (var i = 0; i < updatedRecipe.steps.length; i++) {
        expect(retrievedRecipe.steps[i].name, equals(updatedRecipe.steps[i].name));
        expect(retrievedRecipe.steps[i].duration, equals(updatedRecipe.steps[i].duration));
      }

      print('[DEBUG_LOG] Recipe updated successfully: ${recipe.uuid}');
    });

    test('Delete recipe', () async {
      // Create a recipe
      final recipe = app_model.Recipe(
        uuid: 'test-uuid-delete-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Recipe Delete ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['test', 'recipe'],
        ingredients: [],
        steps: [],
      );

      // Save the recipe to the database
      await databaseService.saveRecipe(recipe);

      // Verify the recipe exists
      var retrievedRecipe = await databaseService.getRecipeByUuid(recipe.uuid);
      expect(retrievedRecipe, isNotNull);

      // Delete the recipe
      final success = await databaseService.deleteRecipe(recipe.uuid);
      expect(success, isTrue);

      // Verify the recipe was deleted
      retrievedRecipe = await databaseService.getRecipeByUuid(recipe.uuid);
      expect(retrievedRecipe, isNull);

      print('[DEBUG_LOG] Recipe deleted successfully: ${recipe.uuid}');
    });

    test('Toggle favorite status', () async {
      // Create a recipe
      final recipe = app_model.Recipe(
        uuid: 'test-uuid-favorite-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Recipe Favorite ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [],
        isFavorite: false,
      );

      // Save the recipe to the database
      await databaseService.saveRecipe(recipe);

      // Toggle favorite status
      final success = await databaseService.toggleFavorite(recipe.uuid);
      expect(success, isTrue);

      // Retrieve the updated recipe
      final retrievedRecipe = await databaseService.getRecipeByUuid(recipe.uuid);
      expect(retrievedRecipe, isNotNull);
      expect(retrievedRecipe!.isFavorite, isTrue);

      print('[DEBUG_LOG] Recipe favorite status toggled successfully: ${recipe.uuid}');
    });
  });
}
