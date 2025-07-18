// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/services/api/api_service.dart';
import 'package:recipe_master/main.dart';
import 'package:recipe_master/presentation/providers/language_provider.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';

// Use the MockApiService from service_locator_test.dart
import 'service_locator_test.dart' as test_locator;

void main() {
  // Basic app rendering test
  testWidgets('App renders without errors', (WidgetTester tester) async {
    // Create a Redux store for testing
    final Store<AppState> store = createStore();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          Provider<Store<AppState>>(create: (context) => store),
        ],
        child: StoreProvider<AppState>(
          store: store,
          child: const MyApp(),
        ),
      ),
    );

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // Recipe creation tests
  group('Recipe Creation Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    late ApiService apiService;

    setUp(() {
      // Create a new MockApiService instance directly
      apiService = test_locator.MockApiService();
    });

    test('Create recipe with valid data', () async {
      // Create a recipe with valid data
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: [],
        ingredients: [],
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
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe created successfully: ${createdRecipe['id']}');
      } catch (e) {
        fail('Failed to create recipe: $e');
      }
    });

    test('Create recipe with empty duration', () async {
      // Create a recipe with empty duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Empty Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '', // Empty duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Test step with empty duration',
            duration: 5,
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe with empty duration created successfully: ${createdRecipe['id']}');
      } catch (e) {
        fail('Failed to create recipe with empty duration: $e');
      }
    });

    test('Create recipe with non-numeric duration', () async {
      // Create a recipe with non-numeric duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Non-Numeric Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: 'about an hour', // Non-numeric duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [
          RecipeStep(
            id: 1,
            name: 'Test step with non-numeric duration',
            duration: 20,
          ),
        ],
      );

      // Try to save the recipe
      try {
        final createdRecipe = await apiService.createRecipe(recipe);

        // Verify the recipe was created successfully
        expect(createdRecipe, isNotNull);
        expect(createdRecipe['name'], equals(recipe.name));

        print('[DEBUG_LOG] Recipe with non-numeric duration created successfully: ${createdRecipe['id']}');
      } catch (e) {
        fail('Failed to create recipe with non-numeric duration: $e');
      }
    });
  });
}
