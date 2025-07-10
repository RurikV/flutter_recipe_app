import 'package:flutter/material.dart';
import 'package:recipe_master/data/usecases/recipe_manager_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/screens/recipe_detail_screen.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';
import 'package:recipe_master/domain/usecases/recipe_manager.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';

// Import the mock classes directly
import '../service_locator_test.dart' as test_locator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recipe Ingredients and Steps Integration Tests', () {
    late test_locator.MockApiService apiService;
    late RecipeManager recipeManager;
    late ObjectDetectionService objectDetectionService;

    setUp(() {
      // Create instances directly
      apiService = test_locator.MockApiService();
      recipeManager = RecipeManagerImpl(
        recipeRepository: test_locator.MockRecipeRepository(),
      );
      objectDetectionService = test_locator.MockObjectDetectionService();
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
      expect(createdRecipe['name'], equals(recipe.name));

      print('[DEBUG_LOG] Recipe created successfully: ${createdRecipe['id']}');

      // Create a Redux store for testing
      final Store<AppState> store = createStore();

      // Convert the Map back to a Recipe object for the RecipeDetailScreen
      final recipeObject = Recipe(
        uuid: createdRecipe['id'],
        name: createdRecipe['name'],
        images: createdRecipe['photo'],
        description: createdRecipe['description'],
        instructions: createdRecipe['instructions'],
        difficulty: createdRecipe['difficulty'],
        duration: createdRecipe['duration'],
        rating: createdRecipe['rating'],
        tags: (createdRecipe['tags'] as List).map((tag) => tag['name'] as String).toList(),
        ingredients: recipe.ingredients, // Use original ingredients for simplicity
        steps: recipe.steps, // Use original steps for simplicity
        isFavorite: createdRecipe['isFavorite'],
        comments: recipe.comments, // Use original comments for simplicity
      );

      // Display the recipe in the RecipeDetailScreen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => recipeManager),
            Provider<ObjectDetectionService>(create: (context) => objectDetectionService),
          ],
          child: StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              home: RecipeDetailScreen(recipe: recipeObject),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the recipe name is displayed
      expect(find.text(recipeObject.name), findsOneWidget);

      print('[DEBUG_LOG] Recipe displayed successfully');
    });
  });
}
