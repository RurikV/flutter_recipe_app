import 'dart:convert';
import 'dart:io';
import '../data/usecases/recipe_manager_impl.dart';
import '../data/models/recipe.dart';
import '../data/models/ingredient.dart';
import '../data/models/recipe_step.dart';

/// Script to seed the API database with dummy data from the Flutter app
class ApiDataSeeder {
  static const String baseUrl = 'http://localhost:3000';

  // Dummy ingredients from the Flutter app
  static final List<String> dummyIngredients = [
    'Соевый соус',
    'Вода',
    'Мёд',
    'Коричневый сахар',
    'Чеснок',
    'Тёртый свежий имбирь',
    'Лимонный сок',
    'Кукурузный крахмал',
    'Растительное масло',
    'Филе лосося или сёмги',
    'Кунжут',
    'Спагетти',
    'Яйца',
    'Сыр пармезан',
    'Гуанчиале',
    'Черный перец',
    'Свекла',
    'Капуста',
    'Картофель',
    'Морковь',
    'Лук',
    'Томатная паста',
    'Помидоры',
    'Огурцы',
    'Болгарский перец',
    'Красный лук',
    'Оливки',
    'Сыр фета',
    'Оливковое масло',
    'Лосось',
    'Сливочный сыр',
    'Авокадо',
    'Рис для суши',
    'Нори',
    'Маскарпоне',
    'Кофе',
    'Печенье савоярди',
    'Какао',
  ];

  // Dummy units from the Flutter app
  static final List<String> dummyUnits = [
    'ст. ложка',
    'ч. ложка',
    'стакан',
    'мл',
    'л',
    'г',
    'кг',
    'шт',
    'зубчик',
    'по вкусу',
    'щепотка',
  ];

  /// Seed all data to the API
  static Future<void> seedAllData() async {
    print('🌱 Starting API data seeding...');

    try {
      // 1. Create a test user
      await _createTestUser();

      // 2. Seed measure units
      await _seedMeasureUnits();

      // 3. Seed ingredients
      await _seedIngredients();

      // 4. Seed recipes
      await _seedRecipes();

      print('✅ API data seeding completed successfully!');
    } catch (e) {
      print('❌ Error during API data seeding: $e');
      rethrow;
    }
  }

  /// Create a test user for the API
  static Future<void> _createTestUser() async {
    print('👤 Creating test user...');

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$baseUrl/user'));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');

      final userData = {
        'login': 'testuser',
        'password': 'testpassword123',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'
      };

      request.add(utf8.encode(jsonEncode(userData)));
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 409) {
        print('✅ Test user created or already exists');
      } else {
        print('⚠️ Failed to create test user: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Seed measure units to the API
  static Future<void> _seedMeasureUnits() async {
    print('📏 Seeding measure units...');

    final client = HttpClient();
    try {
      for (final unit in dummyUnits) {
        final request = await client.postUrl(Uri.parse('$baseUrl/measure_unit'));
        request.headers.set('Content-Type', 'application/json; charset=utf-8');

        final unitData = {
          'one': unit,
          'few': unit,
          'many': unit,
        };

        request.add(utf8.encode(jsonEncode(unitData)));
        final response = await request.close();

        if (response.statusCode == 200) {
          print('✅ Created measure unit: $unit');
        } else if (response.statusCode == 409) {
          print('⚠️ Measure unit already exists: $unit');
        } else {
          print('❌ Failed to create measure unit $unit: ${response.statusCode}');
        }
      }
    } finally {
      client.close();
    }
  }

  /// Seed ingredients to the API
  static Future<void> _seedIngredients() async {
    print('🥕 Seeding ingredients...');

    final client = HttpClient();
    try {
      for (int i = 0; i < dummyIngredients.length; i++) {
        final ingredient = dummyIngredients[i];
        final request = await client.postUrl(Uri.parse('$baseUrl/ingredient'));
        request.headers.set('Content-Type', 'application/json; charset=utf-8');

        final ingredientData = {
          'name': ingredient,
          'caloriesForUnit': (i * 10 + 50).toDouble(), // Dummy calories
          'measureUnit': {'id': (i % dummyUnits.length) + 1}, // Cycle through measure units
        };

        request.add(utf8.encode(jsonEncode(ingredientData)));
        final response = await request.close();

        if (response.statusCode == 200) {
          print('✅ Created ingredient: $ingredient');
        } else if (response.statusCode == 409) {
          print('⚠️ Ingredient already exists: $ingredient');
        } else {
          print('❌ Failed to create ingredient $ingredient: ${response.statusCode}');
        }
      }
    } finally {
      client.close();
    }
  }

  /// Seed recipes to the API
  static Future<void> _seedRecipes() async {
    print('🍝 Seeding recipes...');

    final dummyRecipes = RecipeManagerImpl.getDummyRecipes();
    final client = HttpClient();

    try {
      for (final recipe in dummyRecipes) {
        // Create the recipe first
        final recipeRequest = await client.postUrl(Uri.parse('$baseUrl/recipe'));
        recipeRequest.headers.set('Content-Type', 'application/json; charset=utf-8');

        // Convert duration from string to minutes
        int durationMinutes = _parseDuration(recipe.duration);

        final recipeData = {
          'name': recipe.name,
          'duration': durationMinutes,
          'photo': recipe.images.isNotEmpty ? recipe.images.first.path : '',
        };

        recipeRequest.add(utf8.encode(jsonEncode(recipeData)));
        final recipeResponse = await recipeRequest.close();

        if (recipeResponse.statusCode == 200) {
          print('✅ Created recipe: ${recipe.name}');

          // Parse the response to get the recipe ID
          final responseBody = await recipeResponse.transform(utf8.decoder).join();
          final responseData = jsonDecode(responseBody);
          final recipeId = responseData['id'];

          // Create recipe steps
          await _createRecipeSteps(recipe.steps, recipeId);

          // Create recipe ingredients (if any)
          if (recipe.ingredients.isNotEmpty) {
            await _createRecipeIngredients(recipe.ingredients, recipeId);
          }

        } else if (recipeResponse.statusCode == 409) {
          print('⚠️ Recipe already exists: ${recipe.name}');
        } else {
          print('❌ Failed to create recipe ${recipe.name}: ${recipeResponse.statusCode}');
        }
      }
    } finally {
      client.close();
    }
  }

  /// Create recipe steps for a recipe
  static Future<void> _createRecipeSteps(List<RecipeStep> steps, int recipeId) async {
    final client = HttpClient();

    try {
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];

        // First create the recipe step
        final stepRequest = await client.postUrl(Uri.parse('$baseUrl/recipe_step'));
        stepRequest.headers.set('Content-Type', 'application/json; charset=utf-8');

        final stepData = {
          'name': step.name,
          'duration': step.duration,
        };

        stepRequest.add(utf8.encode(jsonEncode(stepData)));
        final stepResponse = await stepRequest.close();

        if (stepResponse.statusCode == 200) {
          final stepResponseBody = await stepResponse.transform(utf8.decoder).join();
          final stepResponseData = jsonDecode(stepResponseBody);
          final stepId = stepResponseData['id'];

          // Then create the recipe step link
          final linkRequest = await client.postUrl(Uri.parse('$baseUrl/recipe_step_link'));
          linkRequest.headers.set('Content-Type', 'application/json; charset=utf-8');

          final linkData = {
            'number': i + 1,
            'recipe': {'id': recipeId},
            'step': {'id': stepId},
          };

          linkRequest.add(utf8.encode(jsonEncode(linkData)));
          final linkResponse = await linkRequest.close();

          if (linkResponse.statusCode == 200) {
            print('  ✅ Created step ${i + 1}: ${step.name.substring(0, 50)}...');
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// Create recipe ingredients for a recipe
  static Future<void> _createRecipeIngredients(List<Ingredient> ingredients, int recipeId) async {
    final client = HttpClient();

    try {
      for (final ingredient in ingredients) {
        // Find the ingredient ID by name (simplified approach)
        final ingredientId = dummyIngredients.indexOf(ingredient.name) + 1;

        if (ingredientId > 0) {
          final request = await client.postUrl(Uri.parse('$baseUrl/recipe_ingredient'));
          request.headers.set('Content-Type', 'application/json; charset=utf-8');

          final data = {
            'count': int.tryParse(ingredient.quantity) ?? 1,
            'ingredient': {'id': ingredientId},
            'recipe': {'id': recipeId},
          };

          request.add(utf8.encode(jsonEncode(data)));
          final response = await request.close();

          if (response.statusCode == 200) {
            print('  ✅ Added ingredient: ${ingredient.name}');
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// Parse duration string to minutes
  static int _parseDuration(String duration) {
    // Simple parsing for common formats
    if (duration.contains('час')) {
      final hours = RegExp(r'(\d+)\s*час').firstMatch(duration)?.group(1);
      final minutes = RegExp(r'(\d+)\s*минут').firstMatch(duration)?.group(1);
      return (int.tryParse(hours ?? '0') ?? 0) * 60 + (int.tryParse(minutes ?? '0') ?? 0);
    } else if (duration.contains('минут')) {
      final minutes = RegExp(r'(\d+)\s*минут').firstMatch(duration)?.group(1);
      return int.tryParse(minutes ?? '0') ?? 0;
    }
    return 30; // Default to 30 minutes
  }
}

/// Main function to run the seeding script
void main() async {
  await ApiDataSeeder.seedAllData();
}
