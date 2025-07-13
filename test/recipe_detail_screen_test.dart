import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/data/models/recipe_step.dart';

void main() {
  group('Recipe Detail Screen Data Flow Tests', () {
    test('Recipe with ingredients and steps should be properly structured', () {
      // Create a recipe with ingredients and steps similar to what the API returns
      final recipe = Recipe(
        uuid: '8',
        name: 'Test Recipe with Ingredients and Steps',
        images: 'https://placehold.co/400x300/png?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30',
        rating: 4,
        tags: [],
        ingredients: [
          Ingredient.simple(
            name: 'Сливочный сыр',
            quantity: '1',
            unit: 'ст. ложка',
          ),
          Ingredient.simple(
            name: 'Мука',
            quantity: '2',
            unit: 'стакана',
          ),
        ],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Смешать ингредиенты',
            duration: 5,
          ),
          RecipeStep(
            id: 2,
            name: 'Выпекать в духовке',
            duration: 25,
          ),
        ],
        isFavorite: false,
        comments: [],
      );

      // Verify that the recipe has the expected data
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.steps.length, equals(2));

      // Verify ingredient details
      expect(recipe.ingredients[0].name, equals('Сливочный сыр'));
      expect(recipe.ingredients[0].quantity, equals('1'));
      expect(recipe.ingredients[0].unit, equals('ст. ложка'));

      expect(recipe.ingredients[1].name, equals('Мука'));
      expect(recipe.ingredients[1].quantity, equals('2'));
      expect(recipe.ingredients[1].unit, equals('стакана'));

      // Verify step details
      expect(recipe.steps[0].name, equals('Смешать ингредиенты'));
      expect(recipe.steps[0].duration, equals(5));

      expect(recipe.steps[1].name, equals('Выпекать в духовке'));
      expect(recipe.steps[1].duration, equals(25));

      print('[DEBUG_LOG] Recipe structure test passed!');
      print('[DEBUG_LOG] Recipe has ${recipe.ingredients.length} ingredients and ${recipe.steps.length} steps');
      print('[DEBUG_LOG] Ingredients: ${recipe.ingredients.map((i) => '${i.name} - ${i.quantity} ${i.unit}').join(', ')}');
      print('[DEBUG_LOG] Steps: ${recipe.steps.map((s) => '${s.name} (${s.duration} min)').join(', ')}');
    });

    test('Recipe.fromJson should create recipe with ingredients and steps from API response', () {
      // Simulate the API response structure that our backend returns
      final apiResponse = {
        'id': 8,
        'name': 'API Test Recipe',
        'duration': 30,
        'photo': 'https://placehold.co/400x300/png?text=API+Test',
        'description': 'API test description',
        'instructions': 'API test instructions',
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

      // Verify that the recipe was parsed correctly
      expect(recipe.uuid, equals('8'));
      expect(recipe.name, equals('API Test Recipe'));
      expect(recipe.duration, equals('30'));

      // Verify ingredients were parsed correctly
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.ingredients[0].name, equals('Сливочный сыр'));
      expect(recipe.ingredients[0].quantity, equals('1'));
      expect(recipe.ingredients[0].unit, equals('ст. ложка'));

      expect(recipe.ingredients[1].name, equals('Мука'));
      expect(recipe.ingredients[1].quantity, equals('2'));
      expect(recipe.ingredients[1].unit, equals('стакана'));

      // Verify steps were parsed correctly
      expect(recipe.steps.length, equals(2));
      expect(recipe.steps[0].name, equals('Смешать ингредиенты'));
      expect(recipe.steps[0].duration, equals(5));

      expect(recipe.steps[1].name, equals('Выпекать в духовке'));
      expect(recipe.steps[1].duration, equals(25));

      print('[DEBUG_LOG] API parsing test passed!');
      print('[DEBUG_LOG] Parsed recipe with ${recipe.ingredients.length} ingredients and ${recipe.steps.length} steps');
    });
  });
}