import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/screens/recipe_detail_screen.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';
import 'package:recipe_master/data/models/recipe_image.dart';
import 'package:recipe_master/widgets/ingredient/ingredients_table.dart';
import 'package:recipe_master/widgets/step/recipe_steps_list.dart';

// Mock RecipeManager that uses the EXACT real local API response
class RealLocalApiMockRecipeManager implements RecipeManager {
  @override
  Future<List<Recipe>> getRecipes() async {
    return [];
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    return [];
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    // This is the EXACT response from the real local API
    final realLocalApiResponse = {
      "id": 8,
      "name": "122",
      "duration": 0,
      "photo": "[{\"path\":\"/Users/rurik/Library/Developer/CoreSimulator/Devices/6D318E55-5F8B-4454-BBEC-9C07C57CD881/data/Containers/Data/Application/9D587DAD-251D-4791-B12D-ADB5EF84F9C6/Documents/images/1752331914917_image_picker_EF82EF08-CE78-4753-BD40-47831409D155-4719-000013D3DD21EBDB.jpg\",\"detectedObjects\":[]}]",
      "recipeIngredients": [
        {
          "count": 1,
          "ingredient": {
            "name": "Сливочный сыр",
            "measureUnit": {
              "one": "ст. ложка",
              "few": "ст. ложка",
              "many": "ст. ложка"
            }
          }
        }
      ],
      "recipeStepLinks": [
        {
          "step": {
            "name": "111",
            "duration": 0
          },
          "number": 1
        }
      ],
      "favoriteRecipes": [],
      "comments": []
    };

    print('[DEBUG_LOG] RealLocalApiMockRecipeManager: Using EXACT real API response for UUID: $uuid');
    print('[DEBUG_LOG] Real API ingredients count: ${(realLocalApiResponse['recipeIngredients'] as List).length}');
    print('[DEBUG_LOG] Real API steps count: ${(realLocalApiResponse['recipeStepLinks'] as List).length}');

    // Parse using Recipe.fromJson to simulate real data flow
    final recipe = Recipe.fromJson(realLocalApiResponse);
    
    print('[DEBUG_LOG] Parsed real API recipe ingredients count: ${recipe.ingredients.length}');
    print('[DEBUG_LOG] Parsed real API recipe steps count: ${recipe.steps.length}');
    
    if (recipe.ingredients.isNotEmpty) {
      print('[DEBUG_LOG] First ingredient: ${recipe.ingredients[0].name} - ${recipe.ingredients[0].quantity} ${recipe.ingredients[0].unit}');
    }
    
    if (recipe.steps.isNotEmpty) {
      print('[DEBUG_LOG] First step: ${recipe.steps[0].name} (${recipe.steps[0].duration} min)');
    }
    
    return recipe;
  }

  @override
  Future<List<String>> getIngredients() async {
    return [];
  }

  @override
  Future<List<String>> getUnits() async {
    return [];
  }

  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    return true;
  }

  @override
  Future<bool> toggleFavorite(String recipeId) async {
    return true;
  }

  @override
  Future<bool> addComment(String recipeId, comment) async {
    return true;
  }

  @override
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    return true;
  }
}

// Mock ObjectDetectionService
class RealLocalApiMockObjectDetectionService implements ObjectDetectionService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<List<ServiceDetectedObject>> detectObjects(RecipeImage image) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Local API Integration Tests', () {
    testWidgets('RecipeDetailScreen should display real local API data correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Starting test with REAL local API data structure');
      
      // Create a basic recipe that will be enhanced by the real API data
      final initialRecipe = Recipe(
        uuid: '8',
        name: 'Initial Recipe',
        images: 'https://placehold.co/400x300/png?text=Initial',
        description: 'Initial description',
        instructions: 'Initial instructions',
        difficulty: 1,
        duration: '10',
        rating: 3,
        tags: [],
        ingredients: [], // Empty initially - should be populated by real API call
        steps: [], // Empty initially - should be populated by real API call
      );

      // Create mock services that use real API data
      final mockRecipeManager = RealLocalApiMockRecipeManager();
      final mockObjectDetectionService = RealLocalApiMockObjectDetectionService();

      // Create Redux store
      final store = createStore();

      print('[DEBUG_LOG] Building RecipeDetailScreen with real API data');

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RecipeManager>(create: (context) => mockRecipeManager),
            Provider<ObjectDetectionService>(create: (context) => mockObjectDetectionService),
          ],
          child: StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              home: RecipeDetailScreen(recipe: initialRecipe),
            ),
          ),
        ),
      );

      print('[DEBUG_LOG] Waiting for widget to settle and API call to complete');
      // Wait for the loading to complete and API call to finish
      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking for updated recipe name from real API');
      // Verify that the recipe name is displayed (should be updated from real API)
      expect(find.text('122'), findsOneWidget);

      print('[DEBUG_LOG] Checking for ingredients section');
      // Verify that ingredients section is displayed
      expect(find.text('Ингредиенты'), findsOneWidget);

      print('[DEBUG_LOG] Checking for real API ingredient');
      // Verify that the real API ingredient is displayed
      expect(find.textContaining('Сливочный сыр'), findsOneWidget);

      print('[DEBUG_LOG] Checking for real API ingredient quantity');
      // Verify ingredient quantity and unit from real API
      expect(find.textContaining('1 ст. ложка'), findsOneWidget);

      print('[DEBUG_LOG] Checking for real API step');
      // Verify that the real API step is displayed
      expect(find.textContaining('111'), findsOneWidget);

      print('[DEBUG_LOG] Real local API integration test completed successfully!');
      print('[DEBUG_LOG] ✅ The app correctly displays ingredients and steps from real local API');
    });

    testWidgets('Recipe.fromJson should parse real local API response correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing Recipe.fromJson with REAL local API response');
      
      // Use the exact real API response structure
      final realApiResponse = {
        "id": 8,
        "name": "122",
        "duration": 0,
        "photo": "[{\"path\":\"/Users/rurik/Library/Developer/CoreSimulator/Devices/6D318E55-5F8B-4454-BBEC-9C07C57CD881/data/Containers/Data/Application/9D587DAD-251D-4791-B12D-ADB5EF84F9C6/Documents/images/1752331914917_image_picker_EF82EF08-CE78-4753-BD40-47831409D155-4719-000013D3DD21EBDB.jpg\",\"detectedObjects\":[]}]",
        "recipeIngredients": [
          {
            "count": 1,
            "ingredient": {
              "name": "Сливочный сыр",
              "measureUnit": {
                "one": "ст. ложка",
                "few": "ст. ложка",
                "many": "ст. ложка"
              }
            }
          }
        ],
        "recipeStepLinks": [
          {
            "step": {
              "name": "111",
              "duration": 0
            },
            "number": 1
          }
        ],
        "favoriteRecipes": [],
        "comments": []
      };

      // Parse the real API response
      final recipe = Recipe.fromJson(realApiResponse);

      // Verify parsing results
      expect(recipe.uuid, equals('8'));
      expect(recipe.name, equals('122'));
      expect(recipe.duration, equals('0'));

      // Verify ingredients parsing
      expect(recipe.ingredients.length, equals(1));
      expect(recipe.ingredients[0].name, equals('Сливочный сыр'));
      expect(recipe.ingredients[0].quantity, equals('1'));
      expect(recipe.ingredients[0].unit, equals('ст. ложка')); // 'one' form for count=1

      // Verify steps parsing
      expect(recipe.steps.length, equals(1));
      expect(recipe.steps[0].name, equals('111'));
      expect(recipe.steps[0].duration, equals(0));

      print('[DEBUG_LOG] Real API parsing test passed!');
      print('[DEBUG_LOG] ✅ Recipe.fromJson correctly parses real local API data');
      print('[DEBUG_LOG] Parsed ${recipe.ingredients.length} ingredients and ${recipe.steps.length} steps');
    });

    testWidgets('IngredientsTable should display real API ingredient correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing IngredientsTable with real API ingredient');
      
      // Create the exact ingredient from real API
      final realApiResponse = {
        "id": 8,
        "name": "122",
        "duration": 0,
        "photo": "test",
        "recipeIngredients": [
          {
            "count": 1,
            "ingredient": {
              "name": "Сливочный сыр",
              "measureUnit": {
                "one": "ст. ложка",
                "few": "ст. ложка",
                "many": "ст. ложка"
              }
            }
          }
        ],
        "recipeStepLinks": [],
        "favoriteRecipes": [],
        "comments": []
      };

      final recipe = Recipe.fromJson(realApiResponse);

      // Test the IngredientsTable widget with real API data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientsTable(ingredients: recipe.ingredients),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking IngredientsTable with real API data');
      
      // Verify ingredients header
      expect(find.text('Ингредиенты'), findsOneWidget);
      
      // Verify real API ingredient is displayed
      expect(find.text('Сливочный сыр'), findsOneWidget);
      expect(find.text('1 ст. ложка'), findsOneWidget);

      print('[DEBUG_LOG] ✅ IngredientsTable correctly displays real API ingredient!');
    });

    testWidgets('RecipeStepsList should display real API step correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing RecipeStepsList with real API step');
      
      // Create the exact step from real API
      final realApiResponse = {
        "id": 8,
        "name": "122",
        "duration": 0,
        "photo": "test",
        "recipeIngredients": [],
        "recipeStepLinks": [
          {
            "step": {
              "name": "111",
              "duration": 0
            },
            "number": 1
          }
        ],
        "favoriteRecipes": [],
        "comments": []
      };

      final recipe = Recipe.fromJson(realApiResponse);

      // Test the RecipeStepsList widget with real API data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeStepsList(
              steps: recipe.steps,
              isCookingMode: false,
              recipeId: 'test-recipe',
              onStepStatusChanged: (index, isCompleted) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking RecipeStepsList with real API data');
      
      // Verify real API step is displayed
      expect(find.textContaining('111'), findsOneWidget);

      print('[DEBUG_LOG] ✅ RecipeStepsList correctly displays real API step!');
    });
  });
}