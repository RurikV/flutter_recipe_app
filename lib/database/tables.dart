import 'package:drift/drift.dart';

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