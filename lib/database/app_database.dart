// Use standard imports to handle platform-specific code
import 'package:drift/drift.dart';

// Import platform-specific connection functions conditionally
import 'app_database_connection_native.dart'
    if (dart.library.html) 'app_database_connection_web.dart';

import 'tables.dart';
import 'database_extensions.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Recipes, Photos, RecipeTags, Ingredients, RecipeSteps])
class AppDatabase extends _$AppDatabase {
  late final DatabaseExtensions _extensions;

  // Singleton instance
  static AppDatabase? _instance;

  // Factory constructor to return the singleton instance
  factory AppDatabase() {
    return _instance ??= AppDatabase._internal();
  }

  // Constructor that accepts a QueryExecutor for platform-specific implementations
  factory AppDatabase.withConnection(QueryExecutor connection) {
    return AppDatabase._(connection);
  }

  // Private constructor for singleton
  AppDatabase._internal() : super(_openConnection()) {
    _extensions = DatabaseExtensions(this);
  }

  // Private constructor with connection
  AppDatabase._(super.connection) {
    _extensions = DatabaseExtensions(this);
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add the Photos table if upgrading from version 1
        await m.createTable(photos);
      }
      // Removed Favorites table migration as we're using the isFavorite field in Recipes table
    },
  );

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
  Future<List<Ingredient>> getAllIngredients() => _extensions.getAllIngredients();

  // Recipe step operations
  Future<List<RecipeStep>> getStepsForRecipe(String recipeUuid) => _extensions.getStepsForRecipe(recipeUuid);
  Future<void> insertStepsForRecipe(String recipeUuid, List<RecipeStepsCompanion> steps) => _extensions.insertStepsForRecipe(recipeUuid, steps);
  Future<int> deleteStepsForRecipe(String recipeUuid) => _extensions.deleteStepsForRecipe(recipeUuid);
  Future<bool> updateStepStatus(int stepId, bool isCompleted) => _extensions.updateStepStatus(stepId, isCompleted);

  // Photo operations
  Future<List<Photo>> getPhotosForRecipe(String recipeUuid) => _extensions.getPhotosForRecipe(recipeUuid);
  Future<int> insertPhoto(PhotosCompanion photo) => _extensions.insertPhoto(photo);
  Future<int> deletePhoto(int photoId) => _extensions.deletePhoto(photoId);

  // Favorites operations (using isFavorite field in Recipes table)
  Future<void> addToFavorites(String recipeUuid) => _extensions.addToFavorites(recipeUuid);
  Future<void> removeFromFavorites(String recipeUuid) => _extensions.removeFromFavorites(recipeUuid);
  Future<bool> isInFavorites(String recipeUuid) => _extensions.isInFavorites(recipeUuid);

  // Platform-specific database connection
  static QueryExecutor _openConnection() {
    // Use the platform-specific connection function
    return createConnection();
  }
}
