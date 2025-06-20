import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'database_operations.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Recipes, RecipeTags, Ingredients, RecipeSteps])
class AppDatabase extends _$AppDatabase {
  late final DatabaseOperations _operations;

  AppDatabase() : super(_openConnection()) {
    _operations = DatabaseOperations(this);
  }

  @override
  int get schemaVersion => 1;

  // Recipe operations
  Future<List<Recipe>> getAllRecipes() => _operations.getAllRecipes();
  Future<List<Recipe>> getFavoriteRecipes() => _operations.getFavoriteRecipes();
  Future<Recipe?> getRecipeByUuid(String uuid) => _operations.getRecipeByUuid(uuid);
  Future<int> insertRecipe(RecipesCompanion recipe) => _operations.insertRecipe(recipe);
  Future<bool> updateRecipe(RecipesCompanion recipe) => _operations.updateRecipe(recipe);
  Future<int> deleteRecipe(String uuid) => _operations.deleteRecipe(uuid);

  // Tag operations
  Future<List<String>> getTagsForRecipe(String recipeUuid) => _operations.getTagsForRecipe(recipeUuid);
  Future<void> insertTagsForRecipe(String recipeUuid, List<String> tags) => _operations.insertTagsForRecipe(recipeUuid, tags);
  Future<int> deleteTagsForRecipe(String recipeUuid) => _operations.deleteTagsForRecipe(recipeUuid);

  // Ingredient operations
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeUuid) => _operations.getIngredientsForRecipe(recipeUuid);
  Future<void> insertIngredientsForRecipe(String recipeUuid, List<IngredientsCompanion> ingredients) => _operations.insertIngredientsForRecipe(recipeUuid, ingredients);
  Future<int> deleteIngredientsForRecipe(String recipeUuid) => _operations.deleteIngredientsForRecipe(recipeUuid);

  // Recipe step operations
  Future<List<RecipeStep>> getStepsForRecipe(String recipeUuid) => _operations.getStepsForRecipe(recipeUuid);
  Future<void> insertStepsForRecipe(String recipeUuid, List<RecipeStepsCompanion> steps) => _operations.insertStepsForRecipe(recipeUuid, steps);
  Future<int> deleteStepsForRecipe(String recipeUuid) => _operations.deleteStepsForRecipe(recipeUuid);
  Future<bool> updateStepStatus(int stepId, bool isCompleted) => _operations.updateStepStatus(stepId, isCompleted);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recipes.sqlite'));
    return NativeDatabase(file);
  });
}
