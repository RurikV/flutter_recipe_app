import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/data/models/ingredient.dart';
import 'package:flutter_recipe_app/data/models/recipe_step.dart';

void main() {
  group('Recipe Model Tests', () {
    test('Create a recipe with ingredients and steps using FoodApiTest approach', () {
      // Create recipe
      final recipe = Recipe(
        uuid: '999',
        name: 'Spaghetti Carbonara',
        images: 'https://example.com/carbonara.jpg',
        description: 'A delicious pasta dish',
        instructions: 'Cook pasta, mix with eggs and bacon',
        difficulty: 2,
        duration: '30',
        rating: 5,
        tags: ['pasta', 'italian'],
      );

      // Create recipe steps
      final step1 = RecipeStep(
        id: 1,
        name: 'Boil water in a large pot',
        duration: 5,
        isCompleted: false,
      );

      final step2 = RecipeStep(
        id: 2,
        name: 'Cook pasta according to package instructions',
        duration: 10,
        isCompleted: false,
      );

      final step3 = RecipeStep(
        id: 3,
        name: 'In a separate pan, cook bacon until crispy',
        duration: 8,
        isCompleted: false,
      );

      // Recipe ingredients and step links are not used in this test
      // They would be used in a more complex test that verifies the relationships
      // between recipes, ingredients, and steps

      // Create a recipe with ingredients and steps
      final updatedRecipe = recipe.copyWith(
        ingredients: [
          Ingredient.simple(name: 'Pasta', quantity: '200', unit: 'g'),
          Ingredient.simple(name: 'Eggs', quantity: '3', unit: 'pcs'),
          Ingredient.simple(name: 'Bacon', quantity: '100', unit: 'g'),
        ],
        steps: [
          step1,
          step2,
          step3,
        ],
      );

      // Verify the recipe
      expect(updatedRecipe.name, 'Spaghetti Carbonara');
      expect(updatedRecipe.ingredients.length, 3);
      expect(updatedRecipe.steps.length, 3);

      // Verify ingredients
      expect(updatedRecipe.ingredients[0].name, 'Pasta');
      expect(updatedRecipe.ingredients[0].quantity, '200');
      expect(updatedRecipe.ingredients[0].unit, 'g');

      expect(updatedRecipe.ingredients[1].name, 'Eggs');
      expect(updatedRecipe.ingredients[1].quantity, '3');
      expect(updatedRecipe.ingredients[1].unit, 'pcs');

      expect(updatedRecipe.ingredients[2].name, 'Bacon');
      expect(updatedRecipe.ingredients[2].quantity, '100');
      expect(updatedRecipe.ingredients[2].unit, 'g');

      // Verify steps
      expect(updatedRecipe.steps[0].name, 'Boil water in a large pot');
      expect(updatedRecipe.steps[0].duration.toString(), '5');

      expect(updatedRecipe.steps[1].name, 'Cook pasta according to package instructions');
      expect(updatedRecipe.steps[1].duration.toString(), '10');

      expect(updatedRecipe.steps[2].name, 'In a separate pan, cook bacon until crispy');
      expect(updatedRecipe.steps[2].duration.toString(), '8');
    });
  });
}
