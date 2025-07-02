import 'dart:convert';
import 'app_database.dart';
import '../../models/recipe.dart' as app_model;
import '../../models/ingredient.dart' as app_model;
import '../../models/recipe_step.dart' as app_model;
import '../../models/comment.dart' as app_model;
import '../../models/recipe_image.dart';
import 'package:drift/drift.dart';
import '../../services/service_locator.dart' as serviceLocator;

class DatabaseService {
  final AppDatabase _database = serviceLocator.get<AppDatabase>();

  // Get all recipes with their related data
  Future<List<app_model.Recipe>> getAllRecipes() async {
    final recipes = await _database.getAllRecipes();
    return Future.wait(recipes.map((recipe) => _getCompleteRecipe(recipe)).toList());
  }

  // Get favorite recipes with their related data
  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    // Get recipes from the Favorites table, ordered by the 'order' field
    final recipes = await _database.getFavoriteRecipes();

    // Convert database recipes to app model recipes with all related data
    return Future.wait(recipes.map((recipe) => _getCompleteRecipe(recipe)).toList());
  }

  // Check if a recipe is in favorites
  Future<bool> isInFavorites(String recipeId) async {
    return _database.isInFavorites(recipeId);
  }

  // Get a recipe by UUID with all related data
  Future<app_model.Recipe?> getRecipeByUuid(String uuid) async {
    final recipe = await _database.getRecipeByUuid(uuid);
    if (recipe == null) {
      return null;
    }
    return _getCompleteRecipe(recipe);
  }

  // Helper method to get a complete recipe with all related data
  Future<app_model.Recipe> _getCompleteRecipe(Recipe recipe) async {
    final tags = await _database.getTagsForRecipe(recipe.uuid);
    final ingredients = await _database.getIngredientsForRecipe(recipe.uuid);
    final steps = await _database.getStepsForRecipe(recipe.uuid);

    // Check if the recipe is in favorites
    final isInFavorites = await _database.isInFavorites(recipe.uuid);

    // Convert the images string from the database to a List<RecipeImage>
    List<RecipeImage> recipeImages = [];
    try {
      if (recipe.images.isNotEmpty) {
        try {
          // Try to parse as JSON first
          final List<dynamic> decodedList = jsonDecode(recipe.images);
          recipeImages = decodedList
              .map((item) => RecipeImage.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (e) {
          // If parsing fails, treat it as a single image URL
          recipeImages = [RecipeImage(path: recipe.images)];
        }
      }
    } catch (e) {
      // If any error occurs, use an empty list
      recipeImages = [];
    }

    return app_model.Recipe(
      uuid: recipe.uuid,
      name: recipe.name,
      images: recipeImages,
      description: recipe.description,
      instructions: recipe.instructions,
      difficulty: recipe.difficulty,
      duration: recipe.duration,
      rating: recipe.rating,
      tags: tags,
      ingredients: ingredients.map((i) => app_model.Ingredient.simple(
        name: i.name,
        quantity: i.quantity,
        unit: i.unit,
      )).toList(),
      steps: steps.map((s) => app_model.RecipeStep(
        id: s.id,
        name: s.description,
        duration: int.tryParse(s.duration) ?? 0,
        isCompleted: s.isCompleted,
      )).toList(),
      isFavorite: isInFavorites, // Set isFavorite based on Favorites table
      comments: [], // Empty list since we removed the Comments table
    );
  }

  // Save a recipe with all its related data
  Future<void> saveRecipe(app_model.Recipe recipe) async {
    // Start a transaction to ensure all operations succeed or fail together
    await _database.transaction(() async {
      // Check if the recipe already exists
      final existingRecipe = await _database.getRecipeByUuid(recipe.uuid);

      // Check if the recipe is currently in favorites
      final wasInFavorites = await _database.isInFavorites(recipe.uuid);

      // Convert the List<RecipeImage> to a JSON string for storage
      String imagesJson = "";
      try {
        // Convert each RecipeImage to a Map and then encode the list to JSON
        final List<Map<String, dynamic>> imagesList = recipe.images.map((img) => img.toJson()).toList();
        imagesJson = jsonEncode(imagesList);
      } catch (e) {
        // If encoding fails, use an empty string
        imagesJson = "";
      }

      // Create a RecipesCompanion object for the recipe
      final recipeCompanion = RecipesCompanion(
        uuid: Value(recipe.uuid),
        name: Value(recipe.name),
        images: Value(imagesJson),
        description: Value(recipe.description),
        instructions: Value(recipe.instructions),
        difficulty: Value(recipe.difficulty),
        duration: Value(recipe.duration),
        rating: Value(recipe.rating),
        isFavorite: Value(recipe.isFavorite), // Set isFavorite based on the recipe's isFavorite property
      );

      // Insert or update the recipe
      if (existingRecipe == null) {
        await _database.insertRecipe(recipeCompanion);
      } else {
        await _database.updateRecipe(recipeCompanion);
      }

      // Update favorites status if it changed
      if (recipe.isFavorite != wasInFavorites) {
        if (recipe.isFavorite) {
          await _database.addToFavorites(recipe.uuid);
        } else {
          await _database.removeFromFavorites(recipe.uuid);
        }
      }

      // Delete existing tags, ingredients, and steps for the recipe
      await _database.deleteTagsForRecipe(recipe.uuid);
      await _database.deleteIngredientsForRecipe(recipe.uuid);
      await _database.deleteStepsForRecipe(recipe.uuid);

      // Insert new tags
      if (recipe.tags.isNotEmpty) {
        await _database.insertTagsForRecipe(recipe.uuid, recipe.tags);
      }

      // Insert new ingredients
      if (recipe.ingredients.isNotEmpty) {
        final ingredientsCompanions = recipe.ingredients.map((ingredient) => IngredientsCompanion(
          recipeUuid: Value(recipe.uuid),
          name: Value(ingredient.name),
          quantity: Value(ingredient.quantity),
          unit: Value(ingredient.unit),
        )).toList();
        await _database.insertIngredientsForRecipe(recipe.uuid, ingredientsCompanions);
      }

      // Insert new steps
      if (recipe.steps.isNotEmpty) {
        final stepsCompanions = recipe.steps.map((step) => RecipeStepsCompanion(
          recipeUuid: Value(recipe.uuid),
          description: Value(step.name),
          duration: Value(step.duration.toString()),
          isCompleted: Value(step.isCompleted),
        )).toList();
        await _database.insertStepsForRecipe(recipe.uuid, stepsCompanions);
      }
    });
  }

  // Delete a recipe and all its related data
  Future<void> deleteRecipe(String uuid) async {
    await _database.transaction(() async {
      // Delete related data first
      await _database.deleteTagsForRecipe(uuid);
      await _database.deleteIngredientsForRecipe(uuid);
      await _database.deleteStepsForRecipe(uuid);

      // Delete the recipe
      await _database.deleteRecipe(uuid);
    });
  }

  // Update the completion status of a recipe step
  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    return _database.updateStepStatus(stepId, isCompleted);
  }

  // Get all unique ingredients from the database
  Future<List<app_model.Ingredient>> getAllIngredients() async {
    final ingredients = await _database.getAllIngredients();
    return ingredients.map((i) => app_model.Ingredient.simple(
      name: i.name,
      quantity: i.quantity,
      unit: i.unit,
    )).toList();
  }

  // Additional methods required by RecipeRepositoryImpl

  /// Update a recipe - delegates to saveRecipe
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    await saveRecipe(recipe);
  }

  /// Toggle favorite status for a recipe
  Future<bool> toggleFavorite(String uuid) async {
    final recipe = await getRecipeByUuid(uuid);
    if (recipe == null) {
      return false;
    }

    // Toggle the favorite status
    final updatedRecipe = app_model.Recipe(
      uuid: recipe.uuid,
      name: recipe.name,
      images: recipe.images,
      description: recipe.description,
      instructions: recipe.instructions,
      difficulty: recipe.difficulty,
      duration: recipe.duration,
      rating: recipe.rating,
      tags: recipe.tags,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      isFavorite: !recipe.isFavorite,
      comments: recipe.comments,
    );

    // Save the updated recipe
    await saveRecipe(updatedRecipe);
    return true;
  }

  /// Get available ingredients (names only)
  Future<List<String>> getAvailableIngredients() async {
    final ingredients = await getAllIngredients();
    return ingredients.map((i) => i.name).toSet().toList();
  }

  /// Get available units
  Future<List<String>> getAvailableUnits() async {
    final ingredients = await getAllIngredients();
    return ingredients.map((i) => i.unit).where((unit) => unit.isNotEmpty).toSet().toList();
  }

  /// Add a comment to a recipe
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Since we're not storing comments in the database, this is a no-op
    // In a real implementation, this would add the comment to a comments table
    print('Adding comment to recipe $recipeUuid: ${comment.text}');
  }

  /// Get comments for a recipe
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Since we're not storing comments in the database, return an empty list
    // In a real implementation, this would query the comments table
    return [];
  }
}
