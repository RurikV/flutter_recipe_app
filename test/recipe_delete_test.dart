import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/redux/actions.dart';
import 'package:recipe_master/redux/reducers.dart';
import 'package:recipe_master/data/models/recipe.dart';

void main() {
  group('Recipe Delete Tests', () {
    test('Should remove recipe from recipes list when RecipeDeletedAction is dispatched', () {
      // Create test recipes
      final recipe1 = Recipe(
        uuid: '1',
        name: 'Test Recipe 1',
        images: null,
        description: 'Test description 1',
        instructions: 'Test instructions 1',
        difficulty: 1,
        duration: '30 minutes',
        rating: 4,
        tags: ['test'],
        isFavorite: false,
      );

      final recipe2 = Recipe(
        uuid: '2',
        name: 'Test Recipe 2',
        images: null,
        description: 'Test description 2',
        instructions: 'Test instructions 2',
        difficulty: 2,
        duration: '45 minutes',
        rating: 5,
        tags: ['test'],
        isFavorite: true,
      );

      final initialRecipes = [recipe1, recipe2];

      // Test deleting recipe1
      final action = RecipeDeletedAction('1');
      final updatedRecipes = recipesReducer(initialRecipes, action);

      // Verify recipe1 is removed and recipe2 remains
      expect(updatedRecipes.length, equals(1));
      expect(updatedRecipes.first.uuid, equals('2'));
      expect(updatedRecipes.first.name, equals('Test Recipe 2'));

      print('[DEBUG_LOG] ✅ Recipe delete reducer test passed!');
    });

    test('Should remove recipe from favorites when RecipeDeletedAction is dispatched', () {
      // Create test favorite recipes
      final recipe1 = Recipe(
        uuid: '1',
        name: 'Favorite Recipe 1',
        images: null,
        description: 'Test description 1',
        instructions: 'Test instructions 1',
        difficulty: 1,
        duration: '30 minutes',
        rating: 4,
        tags: ['test'],
        isFavorite: true,
      );

      final recipe2 = Recipe(
        uuid: '2',
        name: 'Favorite Recipe 2',
        images: null,
        description: 'Test description 2',
        instructions: 'Test instructions 2',
        difficulty: 2,
        duration: '45 minutes',
        rating: 5,
        tags: ['test'],
        isFavorite: true,
      );

      final initialFavorites = [recipe1, recipe2];

      // Test deleting recipe1 from favorites
      final action = RecipeDeletedAction('1');
      final updatedFavorites = favoriteRecipesReducer(initialFavorites, action);

      // Verify recipe1 is removed from favorites and recipe2 remains
      expect(updatedFavorites.length, equals(1));
      expect(updatedFavorites.first.uuid, equals('2'));
      expect(updatedFavorites.first.name, equals('Favorite Recipe 2'));

      print('[DEBUG_LOG] ✅ Favorite recipe delete reducer test passed!');
    });

    test('Should handle empty recipe list when deleting', () {
      final emptyRecipes = <Recipe>[];
      final action = RecipeDeletedAction('nonexistent');
      final result = recipesReducer(emptyRecipes, action);

      expect(result.length, equals(0));
      print('[DEBUG_LOG] ✅ Empty recipe list delete test passed!');
    });
  });
}