import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/data/models/measure_unit.dart';
import 'package:recipe_master/screens/recipe_detail_screen.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/data/usecases/recipe_manager_impl.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';
import '../service_locator_test.dart' as test_locator;

void main() {
  // Initialize the service locator for tests
  setUpAll(() {
    test_locator.initializeTestServiceLocator();
  });
  group('Recipe Integration Tests', () {
    late RecipeManager recipeManager;
    late ObjectDetectionService objectDetectionService;

    late test_locator.MockRecipeRepository mockRecipeRepository;

    setUp(() {
      // Create instance directly
      mockRecipeRepository = test_locator.MockRecipeRepository();
      recipeManager = RecipeManagerImpl(
        recipeRepository: mockRecipeRepository,
      );
      objectDetectionService = test_locator.MockObjectDetectionService();
    });
    testWidgets('Display a recipe with ingredients and steps', (WidgetTester tester) async {
      // Create measure units
      final gramsUnit = MeasureUnitRef(id: 1);
      final piecesUnit = MeasureUnitRef(id: 2);

      // Create ingredients (defined for demonstration but not used in this test)
      // ignore: unused_local_variable
      final pasta = Ingredient(
        id: 1,
        name: 'Pasta',
        caloriesForUnit: 350.0,
        measureUnit: gramsUnit,
      );

      // ignore: unused_local_variable
      final eggs = Ingredient(
        id: 2,
        name: 'Eggs',
        caloriesForUnit: 70.0,
        measureUnit: piecesUnit,
      );

      // ignore: unused_local_variable
      final bacon = Ingredient(
        id: 3,
        name: 'Bacon',
        caloriesForUnit: 120.0,
        measureUnit: gramsUnit,
      );

      // Create recipe steps
      final step1 = RecipeStep.simple(
        description: 'Boil water in a large pot',
        duration: '5',
      );

      final step2 = RecipeStep.simple(
        description: 'Cook pasta according to package instructions',
        duration: '10',
      );

      final step3 = RecipeStep.simple(
        description: 'In a separate pan, cook bacon until crispy',
        duration: '8',
      );

      // Create recipe
      final recipe = Recipe(
        uuid: '999',
        name: 'Spaghetti Carbonara',
        images: 'https://example.com/carbonara.jpg',
        description: 'A delicious pasta dish',
        instructions: 'Cook pasta, mix with eggs and bacon',
        difficulty: 2,
        duration: '30 мин',
        rating: 5,
        tags: ['pasta', 'italian'],
        ingredients: [
          Ingredient.simple(name: 'Pasta', quantity: '200', unit: 'g'),
          Ingredient.simple(name: 'Eggs', quantity: '3', unit: 'pcs'),
          Ingredient.simple(name: 'Bacon', quantity: '100', unit: 'g'),
        ],
        steps: [
          step1,
          step2,
          step3,
        ],
      );

      // Recipe ingredients and step links are not used in this test
      // They would be used in a more complex test that verifies the relationships
      // between recipes, ingredients, and steps

      // Add the recipe to the mock repository so it can be found by getRecipeByUuid
      mockRecipeRepository.addRecipe(recipe);

      // Create a Redux store for testing
      final Store<AppState> store = createStore();

      // Build the RecipeDetailScreen widget wrapped with StoreProvider and Providers for RecipeManager and ObjectDetectionService
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => recipeManager),
            Provider<ObjectDetectionService>(create: (context) => objectDetectionService),
          ],
          child: StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              home: RecipeDetailScreen(recipe: recipe),
            ),
          ),
        ),
      );

      // Wait for any loading to complete
      await tester.pumpAndSettle();

      // Verify that the recipe name is displayed
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);

      // Verify that the duration is displayed
      expect(find.text('30 мин'), findsOneWidget);

      // Verify that the ingredients are displayed
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('200 g'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('3 pcs'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
      expect(find.text('100 g'), findsOneWidget);

      // Verify that the steps are displayed
      expect(find.text('Boil water in a large pot'), findsOneWidget);
      expect(find.text('Cook pasta according to package instructions'), findsOneWidget);
      expect(find.text('In a separate pan, cook bacon until crispy'), findsOneWidget);
    });
  });
}
