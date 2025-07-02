import 'package:drift/drift.dart';
import 'app_database.dart';

// Database operations implementation
class DatabaseExtensions {
  final AppDatabase db;

  DatabaseExtensions(this.db);

  // Recipe operations
  Future<List<Recipe>> getAllRecipes() {
    return db.select(db.recipes).get();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    // Get recipes that are marked as favorites in the Recipes table
    // This is a temporary solution until the Favorites table is properly generated
    return (db.select(db.recipes)..where((r) => r.isFavorite.equals(true))).get();
  }

  // Add a recipe to favorites
  Future<void> addToFavorites(String recipeUuid) async {
    // Get the recipe
    final recipe = await getRecipeByUuid(recipeUuid);
    if (recipe != null) {
      // Update the recipe to mark it as a favorite
      await db.update(db.recipes).replace(
        RecipesCompanion(
          uuid: Value(recipeUuid),
          name: Value(recipe.name),
          images: Value(recipe.images),
          description: Value(recipe.description),
          instructions: Value(recipe.instructions),
          difficulty: Value(recipe.difficulty),
          duration: Value(recipe.duration),
          rating: Value(recipe.rating),
          isFavorite: const Value(true),
        ),
      );
    }
  }

  // Remove a recipe from favorites
  Future<void> removeFromFavorites(String recipeUuid) async {
    // Get the recipe
    final recipe = await getRecipeByUuid(recipeUuid);
    if (recipe != null) {
      // Update the recipe to mark it as not a favorite
      await db.update(db.recipes).replace(
        RecipesCompanion(
          uuid: Value(recipeUuid),
          name: Value(recipe.name),
          images: Value(recipe.images),
          description: Value(recipe.description),
          instructions: Value(recipe.instructions),
          difficulty: Value(recipe.difficulty),
          duration: Value(recipe.duration),
          rating: Value(recipe.rating),
          isFavorite: const Value(false),
        ),
      );
    }
  }

  // Check if a recipe is in favorites
  Future<bool> isInFavorites(String recipeUuid) async {
    // Get the recipe
    final recipe = await getRecipeByUuid(recipeUuid);
    // Return true if the recipe exists and is marked as a favorite
    return recipe != null && recipe.isFavorite;
  }

  Future<Recipe?> getRecipeByUuid(String uuid) {
    return (db.select(db.recipes)..where((r) => r.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> insertRecipe(RecipesCompanion recipe) {
    return db.into(db.recipes).insert(recipe);
  }

  Future<bool> updateRecipe(RecipesCompanion recipe) {
    return db.update(db.recipes).replace(recipe);
  }

  Future<int> deleteRecipe(String uuid) {
    return (db.delete(db.recipes)..where((r) => r.uuid.equals(uuid))).go();
  }

  // Tag operations
  Future<List<String>> getTagsForRecipe(String recipeUuid) async {
    final query = db.select(db.recipeTags)..where((t) => t.recipeUuid.equals(recipeUuid));
    final results = await query.get();
    return results.map((t) => t.tag).toList();
  }

  Future<void> insertTagsForRecipe(String recipeUuid, List<String> tags) async {
    await db.batch((batch) {
      batch.insertAll(db.recipeTags, tags.map((tag) => 
        RecipeTagsCompanion.insert(recipeUuid: recipeUuid, tag: tag)
      ).toList());
    });
  }

  Future<int> deleteTagsForRecipe(String recipeUuid) {
    return (db.delete(db.recipeTags)..where((t) => t.recipeUuid.equals(recipeUuid))).go();
  }

  // Ingredient operations
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeUuid) {
    return (db.select(db.ingredients)..where((i) => i.recipeUuid.equals(recipeUuid))).get();
  }

  Future<void> insertIngredientsForRecipe(String recipeUuid, List<IngredientsCompanion> ingredients) async {
    await db.batch((batch) {
      batch.insertAll(db.ingredients, ingredients);
    });
  }

  Future<int> deleteIngredientsForRecipe(String recipeUuid) {
    return (db.delete(db.ingredients)..where((i) => i.recipeUuid.equals(recipeUuid))).go();
  }

  // Get all unique ingredients from the database
  Future<List<Ingredient>> getAllIngredients() async {
    final query = db.select(db.ingredients)
      ..orderBy([(i) => OrderingTerm.asc(i.name)]);
    return query.get();
  }

  // Recipe step operations
  Future<List<RecipeStep>> getStepsForRecipe(String recipeUuid) {
    return (db.select(db.recipeSteps)..where((s) => s.recipeUuid.equals(recipeUuid))).get();
  }

  Future<void> insertStepsForRecipe(String recipeUuid, List<RecipeStepsCompanion> steps) async {
    await db.batch((batch) {
      batch.insertAll(db.recipeSteps, steps);
    });
  }

  Future<int> deleteStepsForRecipe(String recipeUuid) {
    return (db.delete(db.recipeSteps)..where((s) => s.recipeUuid.equals(recipeUuid))).go();
  }

  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    final rowsAffected = await (db.update(db.recipeSteps)
      ..where((step) => step.id.equals(stepId)))
      .write(RecipeStepsCompanion(isCompleted: Value(isCompleted)));
    return rowsAffected > 0;
  }

  // Photo operations
  Future<List<Photo>> getPhotosForRecipe(String recipeUuid) {
    return (db.select(db.photos)..where((p) => p.recipeUuid.equals(recipeUuid))).get();
  }

  Future<int> insertPhoto(PhotosCompanion photo) {
    return db.into(db.photos).insert(photo);
  }

  Future<int> deletePhoto(int photoId) {
    return (db.delete(db.photos)..where((p) => p.id.equals(photoId))).go();
  }
}