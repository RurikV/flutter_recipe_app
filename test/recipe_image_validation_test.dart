import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/recipe.dart';

void main() {
  group('Recipe Image URL Validation Tests', () {
    test('Recipe.fromJson should replace example.com placeholder URLs', () {
      final apiResponse = {
        'id': 1,
        'name': 'Test Recipe',
        'duration': 30,
        'photo': 'https://example.com/recipe.jpg', // Problematic placeholder URL
        'description': 'Test description',
        'instructions': 'Test instructions',
        'difficulty': 2,
        'rating': 4,
        'tags': [],
        'recipeIngredients': [],
        'recipeStepLinks': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(apiResponse);

      // Verify that the problematic URL was replaced with a valid placeholder
      expect(recipe.images.length, equals(1));
      expect(recipe.images.first.path, equals('https://placehold.co/400x300/png?text=No+Image'));
      expect(recipe.images.first.path, isNot(contains('example.com')));

      print('[DEBUG_LOG] Problematic URL replacement test passed!');
      print('[DEBUG_LOG] Original URL: https://example.com/recipe.jpg');
      print('[DEBUG_LOG] Replaced with: ${recipe.images.first.path}');
    });

    test('Recipe.fromJson should replace placeholder.com URLs', () {
      final apiResponse = {
        'id': 2,
        'name': 'Another Test Recipe',
        'duration': 20,
        'photo': 'https://placeholder.com/400x300.jpg',
        'description': 'Test description',
        'instructions': 'Test instructions',
        'difficulty': 1,
        'rating': 3,
        'tags': [],
        'recipeIngredients': [],
        'recipeStepLinks': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(apiResponse);

      // Verify that the problematic URL was replaced
      expect(recipe.images.first.path, equals('https://placehold.co/400x300/png?text=No+Image'));
      expect(recipe.images.first.path, isNot(contains('placeholder.com')));

      print('[DEBUG_LOG] Placeholder.com URL replacement test passed!');
    });

    test('Recipe.fromJson should keep valid URLs unchanged', () {
      final apiResponse = {
        'id': 3,
        'name': 'Valid Recipe',
        'duration': 25,
        'photo': 'https://images.unsplash.com/photo-1588013273468-315fd88ea34c',
        'description': 'Test description',
        'instructions': 'Test instructions',
        'difficulty': 3,
        'rating': 5,
        'tags': [],
        'recipeIngredients': [],
        'recipeStepLinks': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(apiResponse);

      // Verify that valid URLs are kept unchanged
      expect(recipe.images.first.path, equals('https://images.unsplash.com/photo-1588013273468-315fd88ea34c'));

      print('[DEBUG_LOG] Valid URL preservation test passed!');
    });

    test('Recipe.fromJson should handle non-HTTP URLs', () {
      final apiResponse = {
        'id': 4,
        'name': 'Local Recipe',
        'duration': 15,
        'photo': 'local/path/to/image.jpg', // Non-HTTP URL
        'description': 'Test description',
        'instructions': 'Test instructions',
        'difficulty': 1,
        'rating': 2,
        'tags': [],
        'recipeIngredients': [],
        'recipeStepLinks': [],
        'comments': []
      };

      final recipe = Recipe.fromJson(apiResponse);

      // Verify that non-HTTP URLs are replaced with placeholder
      expect(recipe.images.first.path, equals('https://placehold.co/400x300/png?text=No+Image'));

      print('[DEBUG_LOG] Non-HTTP URL handling test passed!');
    });
  });
}