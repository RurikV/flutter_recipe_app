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

  Future<List<Recipe>> getFavoriteRecipes() {
    return (db.select(db.recipes)..where((r) => r.isFavorite.equals(true))).get();
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
}