import 'dart:convert';
import '../database/app_database.dart';
import '../../models/recipe.dart' as app_model;
import '../../models/ingredient.dart' as app_model;
import '../../models/recipe_step.dart' as app_model;
import '../../models/comment.dart' as app_model;
import '../../models/recipe_image.dart';
import 'package:drift/drift.dart';
import '../services/service_locator.dart' as serviceLocator;

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
        final List<Map<String, dynamic>> imagesList = recipe.images.map((img) => {
          'path': img.path,
          'detectedObjects': img.detectedObjects.map((obj) => {
            'label': obj.label,
            'confidence': obj.confidence,
            'boundingBox': obj.boundingBox,
          }).toList(),
        }).toList();
        imagesJson = jsonEncode(imagesList);
      } catch (e) {
        // If encoding fails, use the first image's path or an empty string
        imagesJson = recipe.images.isNotEmpty ? recipe.images.first.path : "";
      }

      if (existingRecipe != null) {
        // Update the existing recipe
        await _database.updateRecipe(
          RecipesCompanion(
            uuid: Value(recipe.uuid),
            name: Value(recipe.name),
            images: Value(imagesJson),
            description: Value(recipe.description),
            instructions: Value(recipe.instructions),
            difficulty: Value(recipe.difficulty),
            duration: Value(recipe.duration),
            rating: Value(recipe.rating),
            isFavorite: Value(recipe.isFavorite), // Keep for backward compatibility
          ),
        );
      } else {
        // Insert a new recipe
        await _database.insertRecipe(
          RecipesCompanion.insert(
            uuid: recipe.uuid,
            name: recipe.name,
            images: imagesJson,
            description: recipe.description,
            instructions: recipe.instructions,
            difficulty: recipe.difficulty,
            duration: recipe.duration,
            rating: recipe.rating,
            isFavorite: Value(recipe.isFavorite), // Keep for backward compatibility
          ),
        );
      }

      // Handle favorites status
      if (recipe.isFavorite && !wasInFavorites) {
        // Add to favorites if it wasn't already there
        await _database.addToFavorites(recipe.uuid);
      } else if (!recipe.isFavorite && wasInFavorites) {
        // Remove from favorites if it was there
        await _database.removeFromFavorites(recipe.uuid);
      }

      // Delete existing tags, ingredients, and steps for this recipe
      await _database.deleteTagsForRecipe(recipe.uuid);
      await _database.deleteIngredientsForRecipe(recipe.uuid);
      await _database.deleteStepsForRecipe(recipe.uuid);

      // Insert new tags
      await _database.insertTagsForRecipe(recipe.uuid, recipe.tags);

      // Insert new ingredients
      await _database.insertIngredientsForRecipe(
        recipe.uuid,
        recipe.ingredients.map((i) => IngredientsCompanion.insert(
          recipeUuid: recipe.uuid,
          name: i.name,
          quantity: i.quantity,
          unit: i.unit,
        )).toList(),
      );

      // Insert new steps
      await _database.insertStepsForRecipe(
        recipe.uuid,
        recipe.steps.map((s) => RecipeStepsCompanion.insert(
          recipeUuid: recipe.uuid,
          description: s.name,
          duration: s.duration.toString(),
          isCompleted: Value(s.isCompleted),
        )).toList(),
      );

      // Comments are no longer supported
      // We removed the Comments table and related methods
    });
  }

  // Get step ID by recipe UUID and step index
  Future<int?> getStepId(String recipeUuid, int stepIndex) async {
    final steps = await _database.getStepsForRecipe(recipeUuid);
    if (stepIndex < 0 || stepIndex >= steps.length) {
      return null;
    }
    return steps[stepIndex].id;
  }

  // Update step completion status
  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    return _database.updateStepStatus(stepId, isCompleted);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      // Check if the recipe is already in favorites
      final isInFavorites = await _database.isInFavorites(recipeId);

      if (isInFavorites) {
        // Remove from favorites
        await _database.removeFromFavorites(recipeId);
      } else {
        // Add to favorites
        await _database.addToFavorites(recipeId);
      }

      // For backward compatibility, also update the isFavorite flag in the recipe
      final recipe = await _database.getRecipeByUuid(recipeId);
      if (recipe != null) {
        await _database.updateRecipe(
          RecipesCompanion(
            uuid: Value(recipeId),
            name: Value(recipe.name),
            images: Value(recipe.images),
            description: Value(recipe.description),
            instructions: Value(recipe.instructions),
            difficulty: Value(recipe.difficulty),
            duration: Value(recipe.duration),
            rating: Value(recipe.rating),
            isFavorite: Value(!isInFavorites), // Toggle the flag
          ),
        );
      }

      return true;
    } catch (e) {
      print('Error toggling favorite status: $e');
      return false;
    }
  }

  // Update a recipe
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    await saveRecipe(recipe);
  }

  // Get available ingredients
  Future<List<String>> getAvailableIngredients() async {
    final ingredients = await _database.getAllIngredients();
    return ingredients.map((i) => i.name).toList();
  }

  // Get available units of measurement
  Future<List<String>> getAvailableUnits() async {
    // Return a hardcoded list of common units since we don't have a dedicated table for units
    return [
      'г', 'кг', 'мл', 'л', 'шт', 'ст. ложка', 'ч. ложка', 'стакан', 'щепотка', 'по вкусу'
    ];
  }

  // Add a comment to a recipe
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Since comments are no longer supported in the database, we'll just log this
    print('Comment added to recipe $recipeUuid: ${comment.text}');
  }

  // Get comments for a recipe
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Since comments are no longer supported in the database, return an empty list
    return [];
  }

  // Delete a recipe
  Future<bool> deleteRecipe(String recipeId) async {
    final result = await _database.deleteRecipe(recipeId);
    return result > 0;
  }

  // Close the database
  Future<void> close() async {
    await _database.close();
  }
}
