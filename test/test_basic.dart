import 'package:recipe_master/domain/entities/recipe.dart';
import 'package:recipe_master/domain/entities/recipe_step.dart';
import 'package:recipe_master/domain/entities/ingredient.dart';

void main() {
  print('[DEBUG_LOG] Testing basic entity creation');
  
  try {
    // Test RecipeStep creation
    final step = RecipeStep(
      id: 1,
      name: 'Test step',
      description: 'Test description',
      duration: '10',
    );
    print('[DEBUG_LOG] RecipeStep created successfully: ${step.name}');
    
    // Test Ingredient creation
    final ingredient = Ingredient(
      id: 1,
      name: 'Test ingredient',
      quantity: '100',
      unit: 'g',
    );
    print('[DEBUG_LOG] Ingredient created successfully: ${ingredient.name}');
    
    // Test Recipe creation
    final recipe = Recipe(
      uuid: 'test-uuid',
      name: 'Test Recipe',
      images: 'test-image.jpg',
      description: 'Test description',
      instructions: 'Test instructions',
      difficulty: 1,
      duration: '30 min',
      rating: 5,
      tags: ['test'],
      ingredients: [ingredient],
      steps: [step],
    );
    print('[DEBUG_LOG] Recipe created successfully: ${recipe.name}');
    
    print('[DEBUG_LOG] All basic entity tests passed!');
  } catch (e) {
    print('[DEBUG_LOG] Error in basic entity test: $e');
  }
}