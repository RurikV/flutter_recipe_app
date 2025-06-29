import '../../models/ingredient.dart' as model;
import '../../models/recipe_step.dart' as model;
import '../../domain/entities/ingredient.dart' as entity;
import '../../domain/entities/recipe_step.dart' as entity;

/// Utility class to convert between model and domain entity types
class EntityConverters {
  /// Convert a model Ingredient to a domain entity Ingredient
  static entity.Ingredient modelToEntityIngredient(model.Ingredient ingredient) {
    return entity.Ingredient(
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.unit,
    );
  }

  /// Convert a domain entity Ingredient to a model Ingredient
  static model.Ingredient entityToModelIngredient(entity.Ingredient ingredient) {
    return model.Ingredient.simple(
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.unit,
    );
  }

  /// Convert a list of model Ingredients to a list of domain entity Ingredients
  static List<entity.Ingredient> modelToEntityIngredients(List<model.Ingredient> ingredients) {
    return ingredients.map((ingredient) => modelToEntityIngredient(ingredient)).toList();
  }

  /// Convert a list of domain entity Ingredients to a list of model Ingredients
  static List<model.Ingredient> entityToModelIngredients(List<entity.Ingredient> ingredients) {
    return ingredients.map((ingredient) => entityToModelIngredient(ingredient)).toList();
  }

  /// Convert a model RecipeStep to a domain entity RecipeStep
  static entity.RecipeStep modelToEntityRecipeStep(model.RecipeStep step) {
    return entity.RecipeStep(
      description: step.name, // Use name instead of description
      duration: step.duration.toString(), // Convert int to String
      isCompleted: step.isCompleted,
    );
  }

  /// Convert a domain entity RecipeStep to a model RecipeStep
  static model.RecipeStep entityToModelRecipeStep(entity.RecipeStep step) {
    return model.RecipeStep(
      id: 0, // Default ID
      name: step.description, // Use description for name
      duration: int.tryParse(step.duration) ?? 0, // Convert String to int
      isCompleted: step.isCompleted,
    );
  }

  /// Convert a list of model RecipeSteps to a list of domain entity RecipeSteps
  static List<entity.RecipeStep> modelToEntityRecipeSteps(List<model.RecipeStep> steps) {
    return steps.map((step) => modelToEntityRecipeStep(step)).toList();
  }

  /// Convert a list of domain entity RecipeSteps to a list of model RecipeSteps
  static List<model.RecipeStep> entityToModelRecipeSteps(List<entity.RecipeStep> steps) {
    return steps.map((step) => entityToModelRecipeStep(step)).toList();
  }
}
