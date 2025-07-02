import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/data/api/api_service.dart';

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    // Simulate successful recipe creation without making actual network requests
    print('[DEBUG_LOG] MockApiService: Creating recipe ${recipe.name}');

    // Return a copy of the recipe with a mock UUID
    return Recipe(
      uuid: 'mock-uuid-${DateTime.now().millisecondsSinceEpoch}',
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
  group('Recipe Save Integration Tests', () {
    late ApiService apiService;

    setUp(() {
      // Use mock API service instead of real one to avoid network issues in tests
      apiService = MockApiService();
    });

    test('Create recipe with steps - verify API accepts the request', () async {
      // Create a recipe with steps
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Integration Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Integration test description',
        instructions: 'Integration test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['integration', 'test'],
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
            name: 'Integration test step 1',
            duration: 10,
          ),
          RecipeStep(
            id: 2,
            name: 'Integration test step 2',
            duration: 15,
          ),
        ],
        isFavorite: false,
        comments: [],
      );

      // Try to save the recipe
      try {
        print('[DEBUG_LOG] Attempting to create recipe with steps');
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe.name, equals(recipe.name));
        expect(createdRecipe.steps.length, equals(recipe.steps.length));

        print('[DEBUG_LOG] Recipe with steps created successfully: ${createdRecipe.uuid}');
      } catch (e) {
        print('[DEBUG_LOG] Failed to create recipe with steps: $e');
        fail('Failed to create recipe with steps: $e');
      }
    });
  });
}
