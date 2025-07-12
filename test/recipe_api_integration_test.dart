import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';

void main() {
  group('Recipe API Integration Tests', () {
    test('Recipe.fromJson should parse API response with ingredients and steps', () {
      // This is the actual structure returned by our fixed API
      final apiResponse = {
        'id': 8,
        'name': 'Test Recipe',
        'duration': 30,
        'photo': 'https://example.com/test.jpg',
        'description': 'Test description',
        'instructions': 'Test instructions',
        'difficulty': 2,
        'rating': 4,
        'tags': [],
        'recipeIngredients': [
          {
            'count': 1,
            'ingredient': {
              'name': 'Сливочный сыр',
              'measureUnit': {
                'one': 'ст. ложка',
                'few': 'ст. ложки',
                'many': 'ст. ложек'
              }
            }
          },
          {
            'count': 2,
            'ingredient': {
              'name': 'Мука',
              'measureUnit': {
                'one': 'стакан',
                'few': 'стакана',
                'many': 'стаканов'
              }
            }
          }
        ],
        'recipeStepLinks': [
          {
            'step': {
              'name': 'Смешать ингредиенты',
              'duration': 5
            },
            'number': 1
          },
          {
            'step': {
              'name': 'Выпекать в духовке',
              'duration': 25
            },
            'number': 2
          }
        ],
        'comments': []
      };

      // Parse the API response
      final recipe = Recipe.fromJson(apiResponse);

      // Verify basic recipe properties
      expect(recipe.uuid, equals('8'));
      expect(recipe.name, equals('Test Recipe'));
      expect(recipe.duration, equals('30'));

      // Verify ingredients are parsed correctly
      expect(recipe.ingredients.length, equals(2));

      final firstIngredient = recipe.ingredients[0];
      expect(firstIngredient.name, equals('Сливочный сыр'));
      expect(firstIngredient.quantity, equals('1'));
      expect(firstIngredient.unit, equals('ст. ложка')); // Should use 'one' form for count=1

      final secondIngredient = recipe.ingredients[1];
      expect(secondIngredient.name, equals('Мука'));
      expect(secondIngredient.quantity, equals('2'));
      expect(secondIngredient.unit, equals('стакана')); // Should use 'few' form for count=2

      // Verify steps are parsed correctly
      expect(recipe.steps.length, equals(2));

      final firstStep = recipe.steps[0];
      expect(firstStep.name, equals('Смешать ингредиенты'));
      expect(firstStep.duration, equals(5));

      final secondStep = recipe.steps[1];
      expect(secondStep.name, equals('Выпекать в духовке'));
      expect(secondStep.duration, equals(25));

      print('[DEBUG_LOG] Recipe parsing test passed!');
      print('[DEBUG_LOG] Ingredients: ${recipe.ingredients.map((i) => '${i.name} - ${i.quantity} ${i.unit}').join(', ')}');
      print('[DEBUG_LOG] Steps: ${recipe.steps.map((s) => '${s.name} (${s.duration} min)').join(', ')}');
    });

    test('Recipe.fromJson should handle empty ingredients and steps', () {
      final apiResponse = {
        'id': 9,
        'name': 'Empty Recipe',
        'duration': 10,
        'photo': 'https://example.com/empty.jpg',
        'description': 'Empty description',
        'instructions': 'Empty instructions',
        'difficulty': 1,
        'rating': 3,
        'tags': [],
        'recipeIngredients': [],
        'recipeStepLinks': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(apiResponse);

      expect(recipe.ingredients.length, equals(0));
      expect(recipe.steps.length, equals(0));

      print('[DEBUG_LOG] Empty recipe parsing test passed!');
    });
  });
}
