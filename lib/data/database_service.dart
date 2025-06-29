import 'dart:convert';
import '../database/app_database.dart';
import '../../models/recipe.dart' as app_model;
import '../../models/ingredient.dart' as app_model;
import '../../models/recipe_step.dart' as app_model;
import '../../models/recipe_image.dart';
import 'package:drift/drift.dart';

class DatabaseService {
  final AppDatabase _database = AppDatabase();

  // Get all recipes with their related data
  Future<List<app_model.Recipe>> getAllRecipes() async {
    final recipes = await _database.getAllRecipes();
    return Future.wait(recipes.map((recipe) => _getCompleteRecipe(recipe)).toList());
  }

  // Get favorite recipes with their related data
  Future<List<app_model.Recipe>> getFavoriteRecipes() async {
    final recipes = await _database.getFavoriteRecipes();
    return Future.wait(recipes.map((recipe) => _getCompleteRecipe(recipe)).toList());
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
      isFavorite: recipe.isFavorite,
      comments: [], // Empty list since we removed the Comments table
    );
  }

  // Save a recipe with all its related data
  Future<void> saveRecipe(app_model.Recipe recipe) async {
    // Start a transaction to ensure all operations succeed or fail together
    await _database.transaction(() async {
      // Check if the recipe already exists
      final existingRecipe = await _database.getRecipeByUuid(recipe.uuid);

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
            isFavorite: Value(recipe.isFavorite),
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
            isFavorite: Value(recipe.isFavorite),
          ),
        );
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
    final recipe = await _database.getRecipeByUuid(recipeId);
    if (recipe == null) {
      return false;
    }

    final newStatus = !recipe.isFavorite;
    return _database.updateRecipe(
      RecipesCompanion(
        uuid: Value(recipeId),
        isFavorite: Value(newStatus),
      ),
    );
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
