import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/screens/recipe_detail_screen.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/reducers.dart';
import 'package:flutter_recipe_app/l10n/app_localizations.dart';
import '../service_locator_test.dart';

void main() {
  // Initialize the service locator for tests
  setUpAll(() {
    initializeTestServiceLocator();
  });
  group('RecipeDetailScreen Widget Tests', () {
    late Store<AppState> store;
    late Recipe testRecipe;

    setUp(() {
      // Create a test recipe
      testRecipe = Recipe(
        uuid: 'test-uuid',
        name: 'Test Recipe',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 4,
        tags: ['test', 'widget-test'],
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

      // Create a Redux store with the test recipe
      store = Store<AppState>(
        appReducer,
        initialState: AppState(
          recipes: [testRecipe],
          favoriteRecipes: [],
          isLoading: false,
          error: '',
          isAuthenticated: true,
        ),
      );
    });

    testWidgets('Favorite button toggles favorite status', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoreProvider<AppState>(
            store: store,
            child: RecipeDetailScreen(recipe: testRecipe),
          ),
        ),
      );

      // Verify that the recipe is not favorite initially
      expect(store.state.recipes.first.isFavorite, false);

      // Find the favorite button
      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);

      // Tap the favorite button
      await tester.tap(favoriteButton);
      await tester.pump();

      // Verify that the recipe is now favorite
      expect(store.state.recipes.first.isFavorite, true);

      // Find the filled favorite icon
      final filledFavoriteButton = find.byIcon(Icons.favorite);
      expect(filledFavoriteButton, findsOneWidget);

      // Tap the favorite button again
      await tester.tap(filledFavoriteButton);
      await tester.pump();

      // Verify that the recipe is not favorite again
      expect(store.state.recipes.first.isFavorite, false);

      print('[DEBUG_LOG] Favorite button toggle test passed');
    });

    testWidgets('Recipe steps are displayed correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoreProvider<AppState>(
            store: store,
            child: RecipeDetailScreen(recipe: testRecipe),
          ),
        ),
      );

      // Verify that the recipe steps are displayed
      expect(find.text('Test step 1'), findsOneWidget);
      expect(find.text('Test step 2'), findsOneWidget);

      print('[DEBUG_LOG] Recipe steps display test passed');
    });

    testWidgets('All widgets are displayed correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StoreProvider<AppState>(
            store: store,
            child: RecipeDetailScreen(recipe: testRecipe),
          ),
        ),
      );

      // Verify that the recipe name is displayed
      expect(find.text('Test Recipe'), findsOneWidget);

      // Verify that the duration is displayed
      expect(find.text('30 min'), findsOneWidget);

      // Verify that the ingredients are displayed
      expect(find.text('Test ingredient 1'), findsOneWidget);
      expect(find.text('Test ingredient 2'), findsOneWidget);

      // Verify that the cooking mode button is displayed
      expect(find.text('Начать готовить'), findsOneWidget);

      print('[DEBUG_LOG] All widgets display test passed');
    });
  });
}
