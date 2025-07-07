import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';

// Use the MockApiService from service_locator_test.dart
import 'service_locator_test.dart' as test_locator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Step API Tests', () {
    late test_locator.MockApiService apiService;

    setUp(() {
      // Create a new MockApiService instance directly
      apiService = test_locator.MockApiService();
    });

    test('Create recipe with steps - verify steps are created and linked separately', () async {
      // Create a recipe with steps and ingredients
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe with Steps',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: [],
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
        expect(createdRecipe['steps'].length, equals(recipe.steps.length));

        // Verify that steps were created separately
        expect(apiService.createdSteps.length, equals(recipe.steps.length));
        expect(apiService.createdSteps[0]['name'], equals(recipe.steps[0].name));
        expect(apiService.createdSteps[1]['name'], equals(recipe.steps[1].name));

        // Verify that step links were created
        expect(apiService.createdStepLinks.length, equals(recipe.steps.length));
        expect(apiService.createdStepLinks[0]['number'], equals(1));
        expect(apiService.createdStepLinks[1]['number'], equals(2));

        // Verify that ingredients were created
        expect(apiService.createdIngredients.length, equals(recipe.ingredients.length));
        expect(apiService.createdIngredients[0]['count'], equals(100));

        print('[DEBUG_LOG] Recipe with steps created successfully: ${createdRecipe['id']}');
      } catch (e) {
        fail('Failed to create recipe with steps: $e');
      }
    });
  });
}
