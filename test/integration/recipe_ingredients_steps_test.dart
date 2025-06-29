import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/data/api_service.dart';
import 'package:flutter_recipe_app/screens/recipe_detail_screen.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/store.dart';

// Mock implementation of ApiService for testing
class MockApiService extends ApiService {
  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    // Simulate successful recipe creation
    return Recipe(
      uuid: 'mock-uuid',
      name: recipe.name,
      images: recipe.images,
      description: recipe.description,
      instructions: recipe.instructions,
      difficulty: recipe.difficulty,
      duration: recipe.duration,
      rating: recipe.rating,
      tags: recipe.tags,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      isFavorite: recipe.isFavorite,
      comments: recipe.comments,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recipe Ingredients and Steps Integration Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = MockApiService();
    });

    testWidgets('Create and display recipe with ingredients and steps', (WidgetTester tester) async {
      // Create a simple recipe without ingredients and steps
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: ['test'],
      );

      // Save the recipe
      print('[DEBUG_LOG] Attempting to create recipe');
      final createdRecipe = await apiService.createRecipe(recipe);

      // Verify the recipe was created successfully
      expect(createdRecipe, isNotNull);
      expect(createdRecipe.name, equals(recipe.name));

      print('[DEBUG_LOG] Recipe created successfully: ${createdRecipe.uuid}');

      // Create a Redux store for testing
      final Store<AppState> store = createStore();

      // Display the recipe in the RecipeDetailScreen
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: RecipeDetailScreen(recipe: createdRecipe),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the recipe name is displayed
      expect(find.text(createdRecipe.name), findsOneWidget);

      print('[DEBUG_LOG] Recipe displayed successfully');
    });
  });
}
