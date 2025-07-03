import 'dart:convert';
import '../../data/database/app_database.dart';
import '../../models/recipe.dart' as app_model;
import '../../models/ingredient.dart' as app_model;
import '../../models/recipe_step.dart' as app_model;
import '../../models/comment.dart' as app_model;
import '../../models/recipe_image.dart';
import 'package:drift/drift.dart';
import '../service_locator.dart' as serviceLocator;

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

      // Create or update the recipe
      await _database.insertRecipe(RecipesCompanion(
        uuid: Value(recipe.uuid),
        name: Value(recipe.name),
        images: Value(imagesJson),
        description: Value(recipe.description),
        instructions: Value(recipe.instructions),
        difficulty: Value(recipe.difficulty),
        duration: Value(recipe.duration),
        rating: Value(recipe.rating),
      ));

      // Handle tags
      if (existingRecipe != null) {
        // Delete existing tags for this recipe
        await _database.deleteTagsForRecipe(recipe.uuid);
      }
      // Insert new tags
      await _database.insertTagsForRecipe(recipe.uuid, recipe.tags);

      // Handle ingredients
      if (existingRecipe != null) {
        // Delete existing ingredients for this recipe
        await _database.deleteIngredientsForRecipe(recipe.uuid);
      }
      // Insert new ingredients
      final ingredients = recipe.ingredients.map((ingredient) => 
        IngredientsCompanion.insert(
          recipeUuid: recipe.uuid,
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
        )
      ).toList();
      await _database.insertIngredientsForRecipe(recipe.uuid, ingredients);

      // Handle steps
      if (existingRecipe != null) {
        // Delete existing steps for this recipe
        await _database.deleteStepsForRecipe(recipe.uuid);
      }
      // Insert new steps
      final steps = recipe.steps.map((step) => 
        RecipeStepsCompanion.insert(
          recipeUuid: recipe.uuid,
          description: step.name,
          duration: step.duration.toString(),
          isCompleted: Value(step.isCompleted),
        )
      ).toList();
      await _database.insertStepsForRecipe(recipe.uuid, steps);

      // Handle favorites status
      if (recipe.isFavorite && !wasInFavorites) {
        // Add to favorites if it wasn't already
        await _database.addToFavorites(recipe.uuid);
      } else if (!recipe.isFavorite && wasInFavorites) {
        // Remove from favorites if it was previously a favorite
        await _database.removeFromFavorites(recipe.uuid);
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
      await _database.removeFromFavorites(uuid);

      // Delete the recipe itself
      await _database.deleteRecipe(uuid);
    });
  }

  // Update the order of favorites
  Future<void> updateFavoritesOrder(List<String> recipeIds) async {
    await _database.transaction(() async {
      // Update the order for each recipe ID
      for (int i = 0; i < recipeIds.length; i++) {
        await _database.updateFavoriteOrder(recipeIds[i], i);
      }
    });
  }

  // Toggle the favorite status of a recipe
  Future<void> toggleFavorite(String recipeId) async {
    final isCurrentlyFavorite = await _database.isInFavorites(recipeId);

    if (isCurrentlyFavorite) {
      // Remove from favorites
      await _database.removeFromFavorites(recipeId);
    } else {
      // Add to favorites
      await _database.addToFavorites(recipeId);
    }
  }

  // Update a step's completion status
  Future<void> updateStepCompletion(String recipeId, int stepId, bool isCompleted) async {
    await _database.updateStepStatus(stepId, isCompleted);
  }

  // Update a recipe
  Future<void> updateRecipe(app_model.Recipe recipe) async {
    // Use the saveRecipe method to update the recipe
    await saveRecipe(recipe);
  }

  // Add a comment to a recipe
  Future<void> addComment(String recipeUuid, app_model.Comment comment) async {
    // Since we don't have a Comments table anymore, we'll just log the comment
    print('Adding comment to recipe $recipeUuid: ${comment.text}');
    // In a real implementation, this would save the comment to the database
  }

  // Get comments for a recipe
  Future<List<app_model.Comment>> getComments(String recipeUuid) async {
    // Since we don't have a Comments table anymore, we'll just return an empty list
    print('Getting comments for recipe $recipeUuid');
    // In a real implementation, this would retrieve comments from the database
    return [];
  }

  // Clear all data from the database
  Future<void> clearDatabase() async {
    await _database.transaction(() async {
      // Delete all data from all tables
      await (_database.delete(_database.recipeTags)).go();
      await (_database.delete(_database.ingredients)).go();
      await (_database.delete(_database.recipeSteps)).go();
      await (_database.delete(_database.photos)).go();
      // Delete recipes last since other tables reference it
      await (_database.delete(_database.recipes)).go();
    });
  }
}
