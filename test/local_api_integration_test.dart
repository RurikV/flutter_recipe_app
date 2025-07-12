import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';

void main() {
  group('Local API Integration Tests', () {
    test('Recipe.fromJson should parse local API response correctly', () {
      // This is the actual response from our local API
      final localApiResponse = {
        'id': 8,
        'name': '122',
        'duration': 0,
        'photo': '[{"path":"/Users/rurik/Library/Developer/CoreSimulator/Devices/6D318E55-5F8B-4454-BBEC-9C07C57CD881/data/Containers/Data/Application/9D587DAD-251D-4791-B12D-ADB5EF84F9C6/Documents/images/1752331914917_image_picker_EF82EF08-CE78-4753-BD40-47831409D155-4719-000013D3DD21EBDB.jpg","detectedObjects":[]}]',
        'recipeIngredients': [
          {
            'count': 1,
            'ingredient': {
              'name': 'Сливочный сыр',
              'measureUnit': {
                'one': 'ст. ложка',
                'few': 'ст. ложка',
                'many': 'ст. ложка'
              }
            }
          }
        ],
        'recipeStepLinks': [
          {
            'step': {
              'name': '111',
              'duration': 0
            },
            'number': 1
          }
        ],
        'favoriteRecipes': [],
        'comments': []
      };

      // Parse the local API response
      final recipe = Recipe.fromJson(localApiResponse);

      // Verify basic recipe properties
      expect(recipe.uuid, equals('8'));
      expect(recipe.name, equals('122'));
      expect(recipe.duration, equals('0'));

      // Verify ingredients are parsed correctly
      expect(recipe.ingredients.length, equals(1));
      final ingredient = recipe.ingredients[0];
      expect(ingredient.name, equals('Сливочный сыр'));
      expect(ingredient.quantity, equals('1'));
      expect(ingredient.unit, equals('ст. ложка')); // Should use 'one' form for count=1

      // Verify steps are parsed correctly
      expect(recipe.steps.length, equals(1));
      final step = recipe.steps[0];
      expect(step.name, equals('111'));
      expect(step.duration, equals(0));

      print('[DEBUG_LOG] Local API parsing test passed!');
      print('[DEBUG_LOG] Recipe: ${recipe.name}');
      print('[DEBUG_LOG] Ingredients: ${recipe.ingredients.map((i) => '${i.name} - ${i.quantity} ${i.unit}').join(', ')}');
      print('[DEBUG_LOG] Steps: ${recipe.steps.map((s) => '${s.name} (${s.duration} min)').join(', ')}');
    });

    test('Recipe.fromJson should handle local API response with multiple ingredients and steps', () {
      // Simulate a more complex local API response
      final complexApiResponse = {
        'id': 9,
        'name': 'Complex Recipe',
        'duration': 45,
        'photo': 'https://placehold.co/400x300/png?text=Complex+Recipe',
        'recipeIngredients': [
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
          },
          {
            'count': 3,
            'ingredient': {
              'name': 'Яйца',
              'measureUnit': {
                'one': 'штука',
                'few': 'штуки',
                'many': 'штук'
              }
            }
          }
        ],
        'recipeStepLinks': [
          {
            'step': {
              'name': 'Смешать сухие ингредиенты',
              'duration': 5
            },
            'number': 1
          },
          {
            'step': {
              'name': 'Добавить яйца',
              'duration': 3
            },
            'number': 2
          },
          {
            'step': {
              'name': 'Выпекать',
              'duration': 30
            },
            'number': 3
          }
        ],
        'favoriteRecipes': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(complexApiResponse);

      // Verify ingredients
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.ingredients[0].name, equals('Мука'));
      expect(recipe.ingredients[0].quantity, equals('2'));
      expect(recipe.ingredients[0].unit, equals('стакана')); // 'few' form for count=2

      expect(recipe.ingredients[1].name, equals('Яйца'));
      expect(recipe.ingredients[1].quantity, equals('3'));
      expect(recipe.ingredients[1].unit, equals('штуки')); // 'few' form for count=3

      // Verify steps
      expect(recipe.steps.length, equals(3));
      expect(recipe.steps[0].name, equals('Смешать сухие ингредиенты'));
      expect(recipe.steps[1].name, equals('Добавить яйца'));
      expect(recipe.steps[2].name, equals('Выпекать'));

      print('[DEBUG_LOG] Complex local API parsing test passed!');
    });
  });
}