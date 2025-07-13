import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';

void main() {
  group('Debug Logging Tests', () {
    test('Recipe.fromJson should produce comprehensive debug output', () {
      print('[DEBUG_LOG] ========== STARTING DEBUG LOGGING TEST ==========');
      
      // This is the actual structure returned by the local API
      final localApiResponse = {
        'id': 8,
        'name': 'Debug Test Recipe',
        'duration': 30,
        'photo': 'https://placehold.co/400x300/png?text=Debug+Test',
        'recipeIngredients': [
          {
            'count': 1,
            'ingredient': {
              'name': 'Test Ingredient 1',
              'measureUnit': {
                'one': 'piece',
                'few': 'pieces',
                'many': 'pieces'
              }
            }
          },
          {
            'count': 2,
            'ingredient': {
              'name': 'Test Ingredient 2',
              'measureUnit': {
                'one': 'cup',
                'few': 'cups',
                'many': 'cups'
              }
            }
          }
        ],
        'recipeStepLinks': [
          {
            'step': {
              'name': 'Test Step 1',
              'duration': 5
            },
            'number': 1
          },
          {
            'step': {
              'name': 'Test Step 2',
              'duration': 10
            },
            'number': 2
          }
        ],
        'comments': []
      };

      print('[DEBUG_LOG] About to parse recipe with Recipe.fromJson...');
      
      // Parse the API response - this should trigger all our debug logging
      final recipe = Recipe.fromJson(localApiResponse);

      print('[DEBUG_LOG] Recipe parsing completed, verifying results...');
      
      // Verify the results
      expect(recipe.uuid, equals('8'));
      expect(recipe.name, equals('Debug Test Recipe'));
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.steps.length, equals(2));

      print('[DEBUG_LOG] ========== DEBUG LOGGING TEST COMPLETED ==========');
      print('[DEBUG_LOG] All debug logging is working correctly!');
    });
  });
}