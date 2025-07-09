import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/data/models/ingredient.dart';
import 'package:flutter_recipe_app/data/models/recipe_step.dart';

void main() {
  test('Recipe serialization and deserialization preserves ingredients and steps', () {
    // Create a recipe with ingredients and steps
    final recipe = Recipe(
      uuid: 'test-uuid',
      name: 'Test Recipe',
      images: 'https://example.com/image.jpg',
      description: 'Test description',
      instructions: 'Test instructions',
      difficulty: 2,
      duration: '30 min',
      rating: 0,
      tags: ['test', 'recipe'],
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
      ],
      isFavorite: false,
      comments: [],
    );

    // Convert the recipe to JSON
    final json = recipe.toJson();

    // Convert the JSON back to a recipe
    final deserializedRecipe = Recipe.fromJson(json);

    // Verify that the deserialized recipe has the same ingredients and steps
    expect(deserializedRecipe.ingredients.length, equals(recipe.ingredients.length));
    expect(deserializedRecipe.ingredients[0].name, equals(recipe.ingredients[0].name));
    expect(deserializedRecipe.ingredients[0].quantity, equals(recipe.ingredients[0].quantity));
    expect(deserializedRecipe.ingredients[0].unit, equals(recipe.ingredients[0].unit));

    expect(deserializedRecipe.steps.length, equals(recipe.steps.length));
    expect(deserializedRecipe.steps[0].name, equals(recipe.steps[0].name));
    expect(deserializedRecipe.steps[0].duration, equals(recipe.steps[0].duration));
  });
}