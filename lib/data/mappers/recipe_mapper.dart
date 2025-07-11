import '../entities/recipe.dart' as domain;
import '../entities/ingredient.dart' as domain;
import '../entities/recipe_step.dart' as domain;
import '../entities/comment.dart' as domain;
import '../models/recipe.dart' as model;
import '../models/ingredient.dart' as model;
import '../models/recipe_step.dart' as model;
import '../models/comment.dart' as model;

class RecipeMapper {
  /// Convert domain Recipe to data model Recipe
  static model.Recipe toModel(domain.Recipe domainRecipe) {
    return model.Recipe(
      uuid: domainRecipe.uuid,
      name: domainRecipe.name,
      images: domainRecipe.images,
      description: domainRecipe.description,
      instructions: domainRecipe.instructions,
      difficulty: domainRecipe.difficulty,
      duration: domainRecipe.duration,
      rating: domainRecipe.rating,
      tags: domainRecipe.tags,
      ingredients: domainRecipe.ingredients
          .map((ingredient) => IngredientMapper.toModel(ingredient))
          .toList(),
      steps: domainRecipe.steps
          .map((step) => RecipeStepMapper.toModel(step))
          .toList(),
      isFavorite: domainRecipe.isFavorite,
      comments: domainRecipe.comments
          .map((comment) => CommentMapper.toModel(comment))
          .toList(),
    );
  }

  /// Convert data model Recipe to domain Recipe
  static domain.Recipe toDomain(model.Recipe modelRecipe) {
    return domain.Recipe(
      uuid: modelRecipe.uuid,
      name: modelRecipe.name,
      images: modelRecipe.mainImage, // Use mainImage from data model
      description: modelRecipe.description,
      instructions: modelRecipe.instructions,
      difficulty: modelRecipe.difficulty,
      duration: modelRecipe.duration,
      rating: modelRecipe.rating,
      tags: modelRecipe.tags,
      ingredients: modelRecipe.ingredients
          .map((ingredient) => IngredientMapper.toDomain(ingredient))
          .toList(),
      steps: modelRecipe.steps
          .map((step) => RecipeStepMapper.toDomain(step))
          .toList(),
      isFavorite: modelRecipe.isFavorite,
      comments: modelRecipe.comments
          .map((comment) => CommentMapper.toDomain(comment))
          .toList(),
    );
  }
}

class IngredientMapper {
  /// Convert domain Ingredient to data model Ingredient
  static model.Ingredient toModel(domain.Ingredient domainIngredient) {
    return model.Ingredient.simple(
      name: domainIngredient.name,
      quantity: domainIngredient.quantity,
      unit: domainIngredient.unit,
    );
  }

  /// Convert data model Ingredient to domain Ingredient
  static domain.Ingredient toDomain(model.Ingredient modelIngredient) {
    return domain.Ingredient(
      name: modelIngredient.name,
      quantity: modelIngredient.quantity,
      unit: modelIngredient.unit,
    );
  }
}

class RecipeStepMapper {
  /// Convert domain RecipeStep to data model RecipeStep
  static model.RecipeStep toModel(domain.RecipeStep domainStep) {
    return model.RecipeStep(
      id: domainStep.id,
      name: domainStep.description.isNotEmpty ? domainStep.description : domainStep.name,
      duration: int.tryParse(domainStep.duration) ?? 0,
      isCompleted: domainStep.isCompleted,
    );
  }

  /// Convert data model RecipeStep to domain RecipeStep
  static domain.RecipeStep toDomain(model.RecipeStep modelStep) {
    return domain.RecipeStep(
      id: modelStep.id,
      name: modelStep.name,
      description: modelStep.name, // Use name as description for compatibility
      duration: modelStep.duration.toString(),
      isCompleted: modelStep.isCompleted,
    );
  }
}

class CommentMapper {
  /// Convert domain Comment to data model Comment
  static model.Comment toModel(domain.Comment domainComment) {
    return model.Comment(
      id: domainComment.id,
      authorName: domainComment.authorName,
      text: domainComment.text,
      date: domainComment.date,
    );
  }

  /// Convert data model Comment to domain Comment
  static domain.Comment toDomain(model.Comment modelComment) {
    return domain.Comment(
      id: modelComment.id,
      authorName: modelComment.authorName,
      text: modelComment.text,
      date: modelComment.date,
    );
  }
}
