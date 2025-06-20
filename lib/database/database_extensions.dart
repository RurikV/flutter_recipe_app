import 'package:drift/drift.dart';
import 'app_database.dart';

// Extensions for AppDatabase
extension AppDatabaseExtensions on AppDatabase {
  // Recipe operations
  Future<List<Recipe>> getAllRecipes() {
    return select(recipes).get();
  }

  Future<List<Recipe>> getFavoriteRecipes() {
    return (select(recipes)..where((r) => r.isFavorite.equals(true))).get();
  }

  Future<Recipe?> getRecipeByUuid(String uuid) {
    return (select(recipes)..where((r) => r.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> insertRecipe(RecipesCompanion recipe) {
    return into(recipes).insert(recipe);
  }

  Future<bool> updateRecipe(RecipesCompanion recipe) {
    return update(recipes).replace(recipe);
  }

  Future<int> deleteRecipe(String uuid) {
    return (delete(recipes)..where((r) => r.uuid.equals(uuid))).go();
  }

  // Tag operations
  Future<List<String>> getTagsForRecipe(String recipeUuid) async {
    final query = select(recipeTags)..where((t) => t.recipeUuid.equals(recipeUuid));
    final results = await query.get();
    return results.map((t) => t.tag).toList();
  }

  Future<void> insertTagsForRecipe(String recipeUuid, List<String> tags) async {
    await batch((batch) {
      batch.insertAll(recipeTags, tags.map((tag) => 
        RecipeTagsCompanion.insert(recipeUuid: recipeUuid, tag: tag)
      ).toList());
    });
  }

  Future<int> deleteTagsForRecipe(String recipeUuid) {
    return (delete(recipeTags)..where((t) => t.recipeUuid.equals(recipeUuid))).go();
  }

  // Ingredient operations
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeUuid) {
    return (select(ingredients)..where((i) => i.recipeUuid.equals(recipeUuid))).get();
  }

  Future<void> insertIngredientsForRecipe(String recipeUuid, List<IngredientsCompanion> ingredients) async {
    await batch((batch) {
      batch.insertAll(this.ingredients, ingredients);
    });
  }

  Future<int> deleteIngredientsForRecipe(String recipeUuid) {
    return (delete(ingredients)..where((i) => i.recipeUuid.equals(recipeUuid))).go();
  }

  // Recipe step operations
  Future<List<RecipeStep>> getStepsForRecipe(String recipeUuid) {
    return (select(recipeSteps)..where((s) => s.recipeUuid.equals(recipeUuid))).get();
  }

  Future<void> insertStepsForRecipe(String recipeUuid, List<RecipeStepsCompanion> steps) async {
    await batch((batch) {
      batch.insertAll(recipeSteps, steps);
    });
  }

  Future<int> deleteStepsForRecipe(String recipeUuid) {
    return (delete(recipeSteps)..where((s) => s.recipeUuid.equals(recipeUuid))).go();
  }

  Future<bool> updateStepStatus(int stepId, bool isCompleted) async {
    final rowsAffected = await (update(recipeSteps)
      ..where((step) => step.id.equals(stepId)))
      .write(RecipeStepsCompanion(isCompleted: Value(isCompleted)));
    return rowsAffected > 0;
  }
}