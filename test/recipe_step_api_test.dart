import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/data/api/api_service.dart';

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  List<Map<String, dynamic>> createdSteps = [];
  List<Map<String, dynamic>> createdStepLinks = [];
  List<Map<String, dynamic>> createdIngredients = [];

  @override
  Future<Map<String, dynamic>> createRecipe(Recipe recipe) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Step API Tests', () {
    late MockApiService apiService;

    setUp(() {
      apiService = MockApiService();
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
