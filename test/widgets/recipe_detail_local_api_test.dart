import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/screens/recipe_detail_screen.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/reducers.dart';
import 'package:recipe_master/l10n/app_localizations.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';
import '../service_locator_test.dart' as test_locator;
import 'package:recipe_master/data/usecases/recipe_manager_impl.dart';

// Extended MockRecipeRepository with clearRecipes method
class TestMockRecipeRepository extends test_locator.MockRecipeRepository {
  final Map<String, Recipe> _testRecipes = {};

  @override
  void addRecipe(Recipe recipe) {
    _testRecipes[recipe.uuid] = recipe;
  }

  void clearRecipes() {
    _testRecipes.clear();
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    return _testRecipes[uuid];
  }

  @override
  Future<List<Recipe>> getRecipes() async {
    return _testRecipes.values.toList();
  }
}

void main() {
  // Initialize the service locator for tests
  setUpAll(() {
    test_locator.initializeTestServiceLocator();
  });

  group('RecipeDetailScreen Local API Tests', () {
    late Store<AppState> store;
    late Recipe testRecipeWithoutDetails;
    late Recipe testRecipeWithDetails;
    late RecipeManager recipeManager;
    late ObjectDetectionService objectDetectionService;
    late TestMockRecipeRepository mockRecipeRepository;

    setUp(() {
      // Create RecipeManager instance
      mockRecipeRepository = TestMockRecipeRepository();
      recipeManager = RecipeManagerImpl(
        recipeRepository: mockRecipeRepository,
      );
      objectDetectionService = test_locator.MockObjectDetectionService();

      // Create a test recipe WITHOUT ingredients and steps (simulating initial load from list)
      testRecipeWithoutDetails = Recipe(
        uuid: 'test-uuid-no-details',
        name: 'Test Recipe Without Details',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 4,
        tags: ['test', 'local-api-test'],
        ingredients: [], // Empty ingredients list
        steps: [], // Empty steps list
        isFavorite: false,
        comments: [],
      );

      // Create a test recipe WITH ingredients and steps (simulating API response)
      testRecipeWithDetails = Recipe(
        uuid: 'test-uuid-no-details', // Same UUID as above
        name: 'Test Recipe Without Details',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 4,
        tags: ['test', 'local-api-test'],
        ingredients: [
          Ingredient.simple(
            name: 'Test ingredient 1',
            quantity: '200',
            unit: 'g',
          ),
          Ingredient.simple(
            name: 'Test ingredient 2',
            quantity: '100',
            unit: 'ml',
          ),
        ],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Test step 1',
            duration: 10,
          ),
          RecipeStep(
            id: 2,
            name: 'Test step 2',
            duration: 15,
          ),
        ],
        isFavorite: false,
        comments: [],
      );

      // Configure mock repository to return detailed recipe when getRecipeByUuid is called
      mockRecipeRepository.addRecipe(testRecipeWithDetails);

      // Create a Redux store with the test recipe
      store = Store<AppState>(
        appReducer,
        initialState: AppState(
          recipes: [testRecipeWithoutDetails],
          favoriteRecipes: [],
          isLoading: false,
          error: '',
          isAuthenticated: true,
        ),
      );
    });

    testWidgets('Recipe detail screen loads ingredients and steps from local API', (WidgetTester tester) async {
      print('[DEBUG_LOG] Test: Starting recipe detail screen test with local API');

      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => recipeManager),
            Provider<ObjectDetectionService>(create: (context) => objectDetectionService),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoreProvider<AppState>(
              store: store,
              child: RecipeDetailScreen(recipe: testRecipeWithoutDetails),
            ),
          ),
        ),
      );

      print('[DEBUG_LOG] Test: Widget built, waiting for loading to complete');

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Test: Loading completed, checking for ingredients and steps');

      // Verify that ingredients are displayed
      expect(find.text('Test ingredient 1'), findsOneWidget, reason: 'First ingredient should be displayed');
      expect(find.text('Test ingredient 2'), findsOneWidget, reason: 'Second ingredient should be displayed');
      expect(find.text('200'), findsOneWidget, reason: 'First ingredient quantity should be displayed');
      expect(find.text('100'), findsOneWidget, reason: 'Second ingredient quantity should be displayed');

      // Verify that steps are displayed
      expect(find.text('Test step 1'), findsOneWidget, reason: 'First step should be displayed');
      expect(find.text('Test step 2'), findsOneWidget, reason: 'Second step should be displayed');

      print('[DEBUG_LOG] Test: All assertions passed');
    });

    testWidgets('Recipe detail screen shows empty state when no ingredients and steps from API', (WidgetTester tester) async {
      print('[DEBUG_LOG] Test: Starting test for empty ingredients and steps');

      // Configure mock repository to return recipe without ingredients and steps
      mockRecipeRepository.clearRecipes();
      mockRecipeRepository.addRecipe(testRecipeWithoutDetails);

      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => recipeManager),
            Provider<ObjectDetectionService>(create: (context) => objectDetectionService),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoreProvider<AppState>(
              store: store,
              child: RecipeDetailScreen(recipe: testRecipeWithoutDetails),
            ),
          ),
        ),
      );

      print('[DEBUG_LOG] Test: Widget built, waiting for loading to complete');

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Test: Loading completed, checking for empty state');

      // Verify that no ingredients are displayed (should show empty state or no ingredients)
      expect(find.text('Test ingredient 1'), findsNothing, reason: 'No ingredients should be displayed');
      expect(find.text('Test ingredient 2'), findsNothing, reason: 'No ingredients should be displayed');

      // Verify that no steps are displayed (should show empty state or no steps)
      expect(find.text('Test step 1'), findsNothing, reason: 'No steps should be displayed');
      expect(find.text('Test step 2'), findsNothing, reason: 'No steps should be displayed');

      print('[DEBUG_LOG] Test: Empty state assertions passed');
    });
  });
}
