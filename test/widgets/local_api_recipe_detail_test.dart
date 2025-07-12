import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/data/models/recipe.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/data/models/recipe_step.dart';
import 'package:recipe_master/screens/recipe_detail_screen.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';
import 'package:recipe_master/data/models/recipe_image.dart';
import 'package:recipe_master/widgets/ingredient/ingredients_table.dart';
import 'package:recipe_master/widgets/step/recipe_steps_list.dart';

// Mock RecipeManager that simulates the exact local API response structure
class LocalApiMockRecipeManager implements RecipeManager {
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
    // Simulate the exact local API response structure that's causing issues
    final localApiResponse = {
      'id': int.parse(uuid),
      'name': 'Local API Test Recipe',
      'duration': 30,
      'photo': 'https://placehold.co/400x300/png?text=Local+API+Recipe',
      'recipeIngredients': [
        {
          'count': 1,
          'ingredient': {
            'name': 'Сливочный сыр',
            'measureUnit': {
              'one': 'ст. ложка',
              'few': 'ст. ложки',
              'many': 'ст. ложек'
            }
          }
        },
        {
          'count': 2,
          'ingredient': {
            'name': 'Мука',
            'measureUnit': {
              'one': 'стакан',
              'few': 'стакана',
              'many': 'стаканов'
            }
          }
        },
        {
          'count': 3,
          'ingredient': {
            'name': 'Яйца',
            'measureUnit': {
              'one': 'штука',
              'few': 'штуки',
              'many': 'штук'
            }
          }
        }
      ],
      'recipeStepLinks': [
        {
          'step': {
            'name': 'Подготовить ингредиенты',
            'duration': 5
          },
          'number': 1
        },
        {
          'step': {
            'name': 'Смешать сухие ингредиенты',
            'duration': 10
          },
          'number': 2
        },
        {
          'step': {
            'name': 'Добавить яйца и перемешать',
            'duration': 5
          },
          'number': 3
        },
        {
          'step': {
            'name': 'Выпекать в духовке',
            'duration': 25
          },
          'number': 4
        }
      ],
      'favoriteRecipes': [],
      'comments': []
    };

    print('[DEBUG_LOG] LocalApiMockRecipeManager: Returning recipe data for UUID: $uuid');
    print('[DEBUG_LOG] Recipe ingredients count: ${(localApiResponse['recipeIngredients'] as List).length}');
    print('[DEBUG_LOG] Recipe steps count: ${(localApiResponse['recipeStepLinks'] as List).length}');

    // Parse using Recipe.fromJson to simulate real data flow
    final recipe = Recipe.fromJson(localApiResponse);
    
    print('[DEBUG_LOG] Parsed recipe ingredients count: ${recipe.ingredients.length}');
    print('[DEBUG_LOG] Parsed recipe steps count: ${recipe.steps.length}');
    
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
class LocalApiMockObjectDetectionService implements ObjectDetectionService {
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

  group('Local API Recipe Detail Widget Tests', () {
    testWidgets('RecipeDetailScreen should display ingredients and steps from local API', (WidgetTester tester) async {
      print('[DEBUG_LOG] Starting RecipeDetailScreen test with local API simulation');
      
      // Create a basic recipe that will be enhanced by the mock manager
      final initialRecipe = Recipe(
        uuid: '123',
        name: 'Initial Recipe',
        images: 'https://placehold.co/400x300/png?text=Initial',
        description: 'Initial description',
        instructions: 'Initial instructions',
        difficulty: 1,
        duration: '10',
        rating: 3,
        tags: [],
        ingredients: [], // Empty initially - should be populated by API call
        steps: [], // Empty initially - should be populated by API call
      );

      // Create mock services
      final mockRecipeManager = LocalApiMockRecipeManager();
      final mockObjectDetectionService = LocalApiMockObjectDetectionService();

      // Create Redux store
      final store = createStore();

      print('[DEBUG_LOG] Building RecipeDetailScreen widget');

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

      print('[DEBUG_LOG] Waiting for widget to settle');
      // Wait for the loading to complete and API call to finish
      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking for recipe name');
      // Verify that the recipe name is displayed (should be updated from API)
      expect(find.text('Local API Test Recipe'), findsOneWidget);

      print('[DEBUG_LOG] Checking for ingredients section');
      // Verify that ingredients section is displayed
      expect(find.text('Ингредиенты'), findsOneWidget);

      print('[DEBUG_LOG] Checking for specific ingredients');
      // Verify that specific ingredients are displayed
      expect(find.textContaining('Сливочный сыр'), findsOneWidget);
      expect(find.textContaining('Мука'), findsOneWidget);
      expect(find.textContaining('Яйца'), findsOneWidget);

      print('[DEBUG_LOG] Checking for ingredient quantities');
      // Verify ingredient quantities and units
      expect(find.textContaining('1 ст. ложка'), findsOneWidget);
      expect(find.textContaining('2 стакана'), findsOneWidget);
      expect(find.textContaining('3 штуки'), findsOneWidget);

      print('[DEBUG_LOG] Checking for recipe steps');
      // Verify that steps are displayed
      expect(find.textContaining('Подготовить ингредиенты'), findsOneWidget);
      expect(find.textContaining('Смешать сухие ингредиенты'), findsOneWidget);
      expect(find.textContaining('Добавить яйца и перемешать'), findsOneWidget);
      expect(find.textContaining('Выпекать в духовке'), findsOneWidget);

      print('[DEBUG_LOG] Local API RecipeDetailScreen test completed successfully!');
    });

    testWidgets('IngredientsTable widget should display local API ingredients correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing IngredientsTable widget directly');
      
      // Create ingredients that match local API structure
      final ingredients = [
        Ingredient.simple(
          name: 'Сливочный сыр',
          quantity: '1',
          unit: 'ст. ложка',
        ),
        Ingredient.simple(
          name: 'Мука',
          quantity: '2',
          unit: 'стакана',
        ),
        Ingredient.simple(
          name: 'Яйца',
          quantity: '3',
          unit: 'штуки',
        ),
      ];

      // Test the IngredientsTable widget directly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientsTable(ingredients: ingredients),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking IngredientsTable content');
      
      // Verify ingredients header
      expect(find.text('Ингредиенты'), findsOneWidget);
      
      // Verify all ingredients are displayed
      expect(find.text('Сливочный сыр'), findsOneWidget);
      expect(find.text('1 ст. ложка'), findsOneWidget);
      expect(find.text('Мука'), findsOneWidget);
      expect(find.text('2 стакана'), findsOneWidget);
      expect(find.text('Яйца'), findsOneWidget);
      expect(find.text('3 штуки'), findsOneWidget);

      print('[DEBUG_LOG] IngredientsTable test passed!');
    });

    testWidgets('RecipeStepsList widget should display local API steps correctly', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing RecipeStepsList widget directly');
      
      // Create steps that match local API structure
      final steps = [
        RecipeStep(
          id: 1,
          name: 'Подготовить ингредиенты',
          duration: 5,
        ),
        RecipeStep(
          id: 2,
          name: 'Смешать сухие ингредиенты',
          duration: 10,
        ),
        RecipeStep(
          id: 3,
          name: 'Добавить яйца и перемешать',
          duration: 5,
        ),
        RecipeStep(
          id: 4,
          name: 'Выпекать в духовке',
          duration: 25,
        ),
      ];

      // Test the RecipeStepsList widget directly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeStepsList(
              steps: steps,
              isCookingMode: false,
              recipeId: 'test-recipe',
              onStepStatusChanged: (index, isCompleted) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('[DEBUG_LOG] Checking RecipeStepsList content');
      
      // Verify all steps are displayed
      expect(find.textContaining('Подготовить ингредиенты'), findsOneWidget);
      expect(find.textContaining('Смешать сухие ингредиенты'), findsOneWidget);
      expect(find.textContaining('Добавить яйца и перемешать'), findsOneWidget);
      expect(find.textContaining('Выпекать в духовке'), findsOneWidget);

      print('[DEBUG_LOG] RecipeStepsList test passed!');
    });

    testWidgets('Recipe.fromJson should correctly parse local API response structure', (WidgetTester tester) async {
      print('[DEBUG_LOG] Testing Recipe.fromJson with local API structure');
      
      // Test the exact structure that local API returns
      final localApiResponse = {
        'id': 456,
        'name': 'Local API Parsing Test',
        'duration': 45,
        'photo': 'https://placehold.co/400x300/png?text=Parsing+Test',
        'recipeIngredients': [
          {
            'count': 1,
            'ingredient': {
              'name': 'Тестовый ингредиент 1',
              'measureUnit': {
                'one': 'штука',
                'few': 'штуки',
                'many': 'штук'
              }
            }
          },
          {
            'count': 5,
            'ingredient': {
              'name': 'Тестовый ингредиент 2',
              'measureUnit': {
                'one': 'грамм',
                'few': 'грамма',
                'many': 'граммов'
              }
            }
          }
        ],
        'recipeStepLinks': [
          {
            'step': {
              'name': 'Тестовый шаг 1',
              'duration': 10
            },
            'number': 1
          },
          {
            'step': {
              'name': 'Тестовый шаг 2',
              'duration': 15
            },
            'number': 2
          }
        ],
        'favoriteRecipes': [],
        'comments': []
      };

      // Parse the response
      final recipe = Recipe.fromJson(localApiResponse);

      // Verify parsing results
      expect(recipe.uuid, equals('456'));
      expect(recipe.name, equals('Local API Parsing Test'));
      expect(recipe.duration, equals('45'));

      // Verify ingredients parsing
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.ingredients[0].name, equals('Тестовый ингредиент 1'));
      expect(recipe.ingredients[0].quantity, equals('1'));
      expect(recipe.ingredients[0].unit, equals('штука')); // 'one' form for count=1

      expect(recipe.ingredients[1].name, equals('Тестовый ингредиент 2'));
      expect(recipe.ingredients[1].quantity, equals('5'));
      expect(recipe.ingredients[1].unit, equals('граммов')); // 'many' form for count=5

      // Verify steps parsing
      expect(recipe.steps.length, equals(2));
      expect(recipe.steps[0].name, equals('Тестовый шаг 1'));
      expect(recipe.steps[0].duration, equals(10));
      expect(recipe.steps[1].name, equals('Тестовый шаг 2'));
      expect(recipe.steps[1].duration, equals(15));

      print('[DEBUG_LOG] Recipe.fromJson parsing test passed!');
      print('[DEBUG_LOG] Parsed ${recipe.ingredients.length} ingredients and ${recipe.steps.length} steps');
    });
  });
}