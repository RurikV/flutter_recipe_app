import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/domain/services/api_service.dart';

// Use the MockApiService from service_locator_test.dart
import 'service_locator_test.dart' as test_locator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Creation Tests', () {
    late ApiService apiService;

    setUp(() {
      // Create a new MockApiService instance directly
      apiService = test_locator.MockApiService();
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
            id: 1,
            name: 'Test step 1',
            duration: 10,
          ),
          RecipeStep(
            id: 2,
            name: 'Test step 2',
            duration: 15,
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe created successfully: ${createdRecipe['id']}');
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
            id: 1,
            name: 'Test step with empty duration',
            duration: 5,
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe with empty duration created successfully: ${createdRecipe['id']}');
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
            id: 1,
            name: 'Test step with non-numeric duration',
            duration: 20,
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe with non-numeric duration created successfully: ${createdRecipe['id']}');
      } catch (e) {
        fail('Failed to create recipe with non-numeric duration: $e');
      }
    });
  });
}
