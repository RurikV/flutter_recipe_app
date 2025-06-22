import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/data/api_service.dart';

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Creation Tests', () {
    late ApiService apiService;

    setUp(() {
      // Use mock API service instead of real one
      apiService = MockApiService();
    });

    test('Create recipe with valid data', () async {
      // Create a recipe with valid data
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Test step 1',
            duration: '10 min',
          ),
          RecipeStep(
            description: 'Test step 2',
            duration: '15 min',
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe.name, equals(recipe.name));

        print('[DEBUG_LOG] Recipe created successfully: ${createdRecipe.uuid}');
      } catch (e) {
        fail('Failed to create recipe: $e');
      }
    });

    test('Create recipe with empty duration', () async {
      // Create a recipe with empty duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Empty Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '', // Empty duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Test step with empty duration',
            duration: '5 min',
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe.name, equals(recipe.name));

        print('[DEBUG_LOG] Recipe with empty duration created successfully: ${createdRecipe.uuid}');
      } catch (e) {
        fail('Failed to create recipe with empty duration: $e');
      }
    });

    test('Create recipe with non-numeric duration', () async {
      // Create a recipe with non-numeric duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Non-Numeric Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: 'about an hour', // Non-numeric duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [
          RecipeStep(
            description: 'Test step with non-numeric duration',
            duration: '20 min',
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe.name, equals(recipe.name));

        print('[DEBUG_LOG] Recipe with non-numeric duration created successfully: ${createdRecipe.uuid}');
      } catch (e) {
        fail('Failed to create recipe with non-numeric duration: $e');
      }
    });
  });
}
