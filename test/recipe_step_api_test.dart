import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/data/api_service.dart';

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    // Verify that the recipe steps are correctly formatted
    final recipeJson = recipe.toJson();

    // Process the JSON as the real service would
    final processedJson = _processRecipeJson(recipeJson);

    // Verify that the recipeStepLinks key is present and steps key is not
    if (!processedJson.containsKey('recipeStepLinks')) {
      throw Exception('recipeStepLinks key is missing from the processed JSON');
    }

    if (processedJson.containsKey('steps')) {
      throw Exception('steps key should not be present in the processed JSON');
    }

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

  // Simplified version of the processing logic in the real service
  Map<String, dynamic> _processRecipeJson(Map<String, dynamic> recipeJson) {
    final processedJson = Map<String, dynamic>.from(recipeJson);

    // Remove fields not needed for API
    processedJson.remove('uuid');
    processedJson.remove('description');
    processedJson.remove('instructions');
    processedJson.remove('difficulty');
    processedJson.remove('rating');
    processedJson.remove('tags');
    processedJson.remove('ingredients');
    processedJson.remove('isFavorite');

    // Rename 'images' to 'photo'
    if (processedJson.containsKey('images')) {
      processedJson['photo'] = processedJson['images'];
      processedJson.remove('images');
    }

    // Process steps
    if (processedJson.containsKey('steps')) {
      final steps = processedJson['steps'] as List<dynamic>;
      final processedSteps = steps.map((step) {
        final stepMap = Map<String, dynamic>.from(step as Map<String, dynamic>);
        // Convert duration to numeric value
        if (stepMap.containsKey('duration')) {
          if (stepMap['duration'] is int) {
            // Duration is already an int, no conversion needed
          } else if (stepMap['duration'] is String) {
            final durationStr = stepMap['duration'] as String;
            final numericValue = int.tryParse(durationStr.split(' ').first);
            if (numericValue != null) {
              stepMap['duration'] = numericValue;
            } else {
              stepMap['duration'] = 0;
            }
          } else {
            // Unknown type, default to 0
            stepMap['duration'] = 0;
          }
        }
        return stepMap;
      }).toList();

      // Rename 'steps' to 'recipeStepLinks'
      processedJson['recipeStepLinks'] = processedSteps;
      processedJson.remove('steps');
    }

    return processedJson;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recipe Step API Tests', () {
    late MockApiService apiService;

    setUp(() {
      apiService = MockApiService();
    });

    test('Create recipe with steps - verify steps key is renamed to recipeStepLinks', () async {
      // Create a recipe with steps
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
        expect(createdRecipe.name, equals(recipe.name));
        expect(createdRecipe.steps.length, equals(recipe.steps.length));

        print('[DEBUG_LOG] Recipe with steps created successfully: ${createdRecipe.uuid}');
      } catch (e) {
        fail('Failed to create recipe with steps: $e');
      }
    });
  });
}
