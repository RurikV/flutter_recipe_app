import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Custom class for Comment data since the generated class is not available
class CommentData {
  final String id;
  final String recipeUuid;
  final String authorName;
  final String text;
  final String date;

  CommentData({
    required this.id,
    required this.recipeUuid,
    required this.authorName,
    required this.text,
    required this.date,
  });

  // Factory constructor to create a CommentData from a database row
  factory CommentData.fromData(Map<String, dynamic> data) {
    return CommentData(
      id: data['id'] as String,
      recipeUuid: data['recipe_uuid'] as String,
      authorName: data['author_name'] as String,
      text: data['text'] as String,
      date: data['date'] as String,
    );
  }
}

// Tables
class Recipes extends Table {
  TextColumn get uuid => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get images => text()();
  TextColumn get description => text()();
  TextColumn get instructions => text()();
  IntColumn get difficulty => integer()();
  TextColumn get duration => text()();
  IntColumn get rating => integer()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class RecipeTags extends Table {
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get tag => text()();

  @override
  Set<Column> get primaryKey => {recipeUuid, tag};
}

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get name => text()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
}

class RecipeSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get description => text()();
  TextColumn get duration => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}


@DriftDatabase(tables: [Recipes, RecipeTags, Ingredients, RecipeSteps])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
    return update(recipeSteps).replace(
      RecipeStepsCompanion(
        id: Value(stepId),
        isCompleted: Value(isCompleted),
      )
    );
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recipes.sqlite'));
    return NativeDatabase(file);
  });
}
