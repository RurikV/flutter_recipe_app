import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/recipe_step.dart';
import 'package:flutter_recipe_app/models/ingredient.dart';
import 'package:flutter_recipe_app/screens/recipe_list_screen.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/reducers.dart';
import 'package:flutter_recipe_app/l10n/app_localizations.dart';
import 'package:flutter_recipe_app/widgets/recipe/duration_display.dart';
import 'package:flutter_recipe_app/domain/usecases/recipe_manager.dart';
import 'package:flutter_recipe_app/services/classification/object_detection_service.dart';
import '../service_locator_test.dart' as test_locator;
import 'package:flutter_recipe_app/data/usecases/recipe_manager_impl.dart';

void main() {
  // Initialize the service locator for tests
  setUpAll(() {
    test_locator.initializeTestServiceLocator();
  });

  group('Recipe List Navigation Integration Tests', () {
    late Store<AppState> store;
    late List<Recipe> testRecipes;
    late RecipeManager recipeManager;
    late ObjectDetectionService objectDetectionService;

    setUp(() {
      // Create RecipeManager instance
      recipeManager = RecipeManagerImpl(
        recipeRepository: test_locator.MockRecipeRepository(),
      );
      objectDetectionService = test_locator.MockObjectDetectionService();

      // Create test recipes
      testRecipes = [
        Recipe(
          uuid: 'test-uuid-1',
          name: 'Spaghetti Carbonara',
          images: 'file:///non-existent-image.jpg',
          description: 'A delicious pasta dish',
          instructions: 'Cook pasta, mix with eggs and bacon',
          difficulty: 2,
          duration: '30 min',
          rating: 5,
          tags: ['pasta', 'italian'],
          ingredients: [
            Ingredient.simple(name: 'Pasta', quantity: '200', unit: 'g'),
            Ingredient.simple(name: 'Eggs', quantity: '3', unit: 'pcs'),
            Ingredient.simple(name: 'Bacon', quantity: '100', unit: 'g'),
          ],
          steps: [
            RecipeStep.simple(
              description: 'Boil water in a large pot',
              duration: '5',
            ),
            RecipeStep.simple(
              description: 'Cook pasta according to package instructions',
              duration: '10',
            ),
          ],
          isFavorite: false,
          comments: [],
        ),
        Recipe(
          uuid: 'test-uuid-2',
          name: 'Chicken Curry',
          images: 'file:///non-existent-image.jpg',
          description: 'A spicy curry dish',
          instructions: 'Cook chicken with curry sauce',
          difficulty: 3,
          duration: '45 min',
          rating: 4,
          tags: ['chicken', 'curry', 'spicy'],
          ingredients: [
            Ingredient.simple(name: 'Chicken', quantity: '500', unit: 'g'),
            Ingredient.simple(name: 'Curry Paste', quantity: '2', unit: 'tbsp'),
            Ingredient.simple(name: 'Coconut Milk', quantity: '400', unit: 'ml'),
          ],
          steps: [
            RecipeStep.simple(
              description: 'Cut chicken into pieces',
              duration: '5',
            ),
            RecipeStep.simple(
              description: 'Cook chicken until browned',
              duration: '10',
            ),
          ],
          isFavorite: true,
          comments: [],
        ),
      ];

      // Create a Redux store with test recipes
      store = Store<AppState>(
        appReducer,
        initialState: AppState(
          recipes: testRecipes,
          favoriteRecipes: testRecipes.where((recipe) => recipe.isFavorite).toList(),
          isLoading: false,
          error: '',
          isAuthenticated: true,
        ),
      );
    });

    testWidgets('Navigate from recipe list to recipe detail and toggle favorite', (WidgetTester tester) async {
      // Build the RecipeListScreen widget wrapped with StoreProvider and Providers for RecipeManager and ObjectDetectionService
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => recipeManager),
            Provider<ObjectDetectionService>(create: (context) => objectDetectionService),
          ],
          child: StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const RecipeListScreen(loadRecipesOnInit: false),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that the recipe list screen is displayed
      // Use a more specific finder for the recipe names to avoid matching both instances
      expect(find.text('Spaghetti Carbonara', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).length, equals(1));
      expect(find.text('Chicken Curry', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).length, equals(1));

      print('[DEBUG_LOG] Recipe list screen displayed successfully');

      // Tap on the first recipe card
      // Use a specific finder to tap on the recipe card text
      final spaghettiCarbonaraFinder = find.text('Spaghetti Carbonara', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).first;
      await tester.tap(find.byWidget(spaghettiCarbonaraFinder.widget));
      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that the recipe detail screen is displayed
      // Use a more specific finder for the recipe name to avoid matching both the card and header
      expect(find.text('Spaghetti Carbonara', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 24
      ).length, equals(1));
      // Use a more specific finder for the duration to avoid matching both the card and detail screen
      expect(find.text('30 min', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.color == const Color(0xFF2ECC71) &&
                    element.findAncestorWidgetOfExactType<DurationDisplay>() != null
      ).length, equals(1));
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
      expect(find.text('Boil water in a large pot'), findsOneWidget);
      expect(find.text('Cook pasta according to package instructions'), findsOneWidget);

      print('[DEBUG_LOG] Recipe detail screen displayed successfully');

      // Verify that the favorite button is displayed (initially not favorite)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap the favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that the favorite button is now filled
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      print('[DEBUG_LOG] Favorite button toggled successfully');

      // Navigate back to the recipe list
      await tester.tap(find.byIcon(Icons.arrow_back));
      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that we're back on the recipe list screen
      // Use a more specific finder for the recipe names to avoid matching both instances
      expect(find.text('Spaghetti Carbonara', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).length, equals(1));
      expect(find.text('Chicken Curry', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).length, equals(1));

      print('[DEBUG_LOG] Navigation back to recipe list successful');

      // Tap on the second recipe card (which is already favorite)
      // Use a specific finder to tap on the recipe card text
      final chickenCurryFinder = find.text('Chicken Curry', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 22
      ).first;
      await tester.tap(find.byWidget(chickenCurryFinder.widget));

      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that the recipe detail screen is displayed
      // Use a more specific finder for the recipe name to avoid matching both the card and header
      expect(find.text('Chicken Curry', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.fontSize == 24
      ).length, equals(1));

      // Use a more specific finder for the duration to avoid matching both the card and detail screen
      expect(find.text('45 min', findRichText: false).evaluate().where(
        (element) => element.widget is Text && 
                    (element.widget as Text).style?.color == const Color(0xFF2ECC71) &&
                    element.findAncestorWidgetOfExactType<DurationDisplay>() != null
      ).length, equals(1));

      // Verify that the favorite button is filled (initially favorite)
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Tap the favorite button to unfavorite
      await tester.tap(find.byIcon(Icons.favorite));
      // Use multiple pump calls instead of pumpAndSettle to avoid timeout
      await tester.pump(); // Process initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Process animations
      await tester.pump(const Duration(milliseconds: 100)); // Process any remaining animations

      // Verify that the favorite button is now unfilled
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      print('[DEBUG_LOG] Favorite button toggled successfully for second recipe');
    });
  });
}
