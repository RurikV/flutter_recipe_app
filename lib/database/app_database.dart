import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'database_extensions.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Recipes, RecipeTags, Ingredients, RecipeSteps])
class AppDatabase extends _$AppDatabase {
  late final DatabaseExtensions _extensions;

  AppDatabase() : super(_openConnection()) {
    _extensions = DatabaseExtensions(this);
  }

  @override
  int get schemaVersion => 1;

  // Recipe operations
  Future<List<Recipe>> getAllRecipes() => _extensions.getAllRecipes();
  Future<List<Recipe>> getFavoriteRecipes() => _extensions.getFavoriteRecipes();
  Future<Recipe?> getRecipeByUuid(String uuid) => _extensions.getRecipeByUuid(uuid);
  Future<int> insertRecipe(RecipesCompanion recipe) => _extensions.insertRecipe(recipe);
  Future<bool> updateRecipe(RecipesCompanion recipe) => _extensions.updateRecipe(recipe);
  Future<int> deleteRecipe(String uuid) => _extensions.deleteRecipe(uuid);

  // Tag operations
  Future<List<String>> getTagsForRecipe(String recipeUuid) => _extensions.getTagsForRecipe(recipeUuid);
  Future<void> insertTagsForRecipe(String recipeUuid, List<String> tags) => _extensions.insertTagsForRecipe(recipeUuid, tags);
  Future<int> deleteTagsForRecipe(String recipeUuid) => _extensions.deleteTagsForRecipe(recipeUuid);

  // Ingredient operations
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeUuid) => _extensions.getIngredientsForRecipe(recipeUuid);
  Future<void> insertIngredientsForRecipe(String recipeUuid, List<IngredientsCompanion> ingredients) => _extensions.insertIngredientsForRecipe(recipeUuid, ingredients);
  Future<int> deleteIngredientsForRecipe(String recipeUuid) => _extensions.deleteIngredientsForRecipe(recipeUuid);

  // Recipe step operations
  Future<List<RecipeStep>> getStepsForRecipe(String recipeUuid) => _extensions.getStepsForRecipe(recipeUuid);
  Future<void> insertStepsForRecipe(String recipeUuid, List<RecipeStepsCompanion> steps) => _extensions.insertStepsForRecipe(recipeUuid, steps);
  Future<int> deleteStepsForRecipe(String recipeUuid) => _extensions.deleteStepsForRecipe(recipeUuid);
  Future<bool> updateStepStatus(int stepId, bool isCompleted) => _extensions.updateStepStatus(stepId, isCompleted);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recipes.sqlite'));
    return NativeDatabase(file);
  });
}
