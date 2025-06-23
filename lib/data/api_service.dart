import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../models/recipe.dart';
import '../../models/comment.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = 'https://foodapi.dzolotov.pro';
  final int _maxRetries = 3;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('DIO: $object'),
    ));

    // Configure Dio to accept self-signed certificates
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  // Generic method to handle API requests with retry logic
  Future<T> _requestWithRetry<T>({
    required Future<T> Function() request,
    required String errorMessage,
    int retries = 0,
  }) async {
    try {
      return await request();
    } catch (e) {
      if (retries < _maxRetries) {
        // Exponential backoff: wait 2^retries seconds before retrying
        final waitTime = Duration(seconds: 1 << retries);
        print('Retrying request after $waitTime (attempt ${retries + 1}/$_maxRetries)');
        await Future.delayed(waitTime);
        return _requestWithRetry(
          request: request,
          errorMessage: errorMessage,
          retries: retries + 1,
        );
      }
      print('$errorMessage: $e');
      throw Exception('$errorMessage: $e');
    }
  }

  // Get all recipes
  Future<List<Recipe>> getRecipes() async {
    return _requestWithRetry(
      request: () async {
        // First, get all recipes
        final recipesResponse = await _dio.get('/recipe');
        if (recipesResponse.statusCode != 200) {
          throw Exception('Failed to load recipes: ${recipesResponse.statusCode}');
        }

        final List<dynamic> recipesData = recipesResponse.data;

        // Now, get all recipe ingredients
        final ingredientsResponse = await _dio.get('/recipe_ingredient');
        if (ingredientsResponse.statusCode != 200) {
          throw Exception('Failed to load recipe ingredients: ${ingredientsResponse.statusCode}');
        }

        final List<dynamic> allRecipeIngredients = ingredientsResponse.data;

        // Get all ingredients
        final ingredientDetailsResponse = await _dio.get('/ingredient');
        if (ingredientDetailsResponse.statusCode != 200) {
          throw Exception('Failed to load ingredients: ${ingredientDetailsResponse.statusCode}');
        }

        final List<dynamic> allIngredientDetails = ingredientDetailsResponse.data;

        // Create a map of ingredient ID to ingredient details
        final Map<int, Map<String, dynamic>> ingredientDetailsById = {};
        for (final ingredient in allIngredientDetails) {
          if (ingredient['id'] != null) {
            ingredientDetailsById[ingredient['id'] as int] = ingredient;
          }
        }

        // Get all measure units
        final measureUnitsResponse = await _dio.get('/measure_unit');
        if (measureUnitsResponse.statusCode != 200) {
          throw Exception('Failed to load measure units: ${measureUnitsResponse.statusCode}');
        }

        final List<dynamic> allMeasureUnits = measureUnitsResponse.data;

        // Create a map of measure unit ID to measure unit details
        final Map<int, Map<String, dynamic>> measureUnitsById = {};
        for (final unit in allMeasureUnits) {
          if (unit['id'] != null) {
            measureUnitsById[unit['id'] as int] = unit;
          }
        }

        // Create a map of recipe ID to ingredients with full details
        final Map<String, List<dynamic>> ingredientsByRecipeId = {};
        for (final recipeIngredient in allRecipeIngredients) {
          if (recipeIngredient['recipe'] != null && recipeIngredient['recipe']['id'] != null) {
            final recipeId = recipeIngredient['recipe']['id'].toString();
            if (!ingredientsByRecipeId.containsKey(recipeId)) {
              ingredientsByRecipeId[recipeId] = [];
            }

            // Enhance recipe ingredient with full ingredient details and measure unit details
            if (recipeIngredient['ingredient'] != null && recipeIngredient['ingredient']['id'] != null) {
              final ingredientId = recipeIngredient['ingredient']['id'] as int;
              if (ingredientDetailsById.containsKey(ingredientId)) {
                // Add full ingredient details
                final ingredientDetails = ingredientDetailsById[ingredientId]!;
                recipeIngredient['ingredient'] = ingredientDetails;

                // Add full measure unit details if available
                if (ingredientDetails['measureUnit'] != null && ingredientDetails['measureUnit']['id'] != null) {
                  final measureUnitId = ingredientDetails['measureUnit']['id'] as int;
                  if (measureUnitsById.containsKey(measureUnitId)) {
                    ingredientDetails['measureUnit'] = measureUnitsById[measureUnitId]!;
                  }
                }
              }
            }

            ingredientsByRecipeId[recipeId]!.add(recipeIngredient);
          }
        }

        // Get all recipe step links
        final stepLinksResponse = await _dio.get('/recipe_step_link');
        if (stepLinksResponse.statusCode != 200) {
          throw Exception('Failed to load recipe step links: ${stepLinksResponse.statusCode}');
        }

        final List<dynamic> allRecipeStepLinks = stepLinksResponse.data;

        // Get all recipe steps
        final stepsResponse = await _dio.get('/recipe_step');
        if (stepsResponse.statusCode != 200) {
          throw Exception('Failed to load recipe steps: ${stepsResponse.statusCode}');
        }

        final List<dynamic> allRecipeSteps = stepsResponse.data;

        // Create a map of step ID to step details
        final Map<int, Map<String, dynamic>> stepDetailsById = {};
        for (final step in allRecipeSteps) {
          if (step['id'] != null) {
            stepDetailsById[step['id'] as int] = step;
          }
        }

        // Create a map of recipe ID to steps with full details
        final Map<String, List<dynamic>> stepsByRecipeId = {};
        for (final stepLink in allRecipeStepLinks) {
          if (stepLink['recipe'] != null && stepLink['recipe']['id'] != null) {
            final recipeId = stepLink['recipe']['id'].toString();
            if (!stepsByRecipeId.containsKey(recipeId)) {
              stepsByRecipeId[recipeId] = [];
            }

            // Enhance step link with full step details
            if (stepLink['step'] != null && stepLink['step']['id'] != null) {
              final stepId = stepLink['step']['id'] as int;
              if (stepDetailsById.containsKey(stepId)) {
                // Add full step details
                final stepDetails = stepDetailsById[stepId]!;
                stepLink['step'] = stepDetails;
              }
            }

            stepsByRecipeId[recipeId]!.add(stepLink);
          }
        }

        // Sort step links by number for each recipe
        for (final recipeId in stepsByRecipeId.keys) {
          stepsByRecipeId[recipeId]!.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
        }

        // Add ingredients and steps to each recipe and parse
        final List<Recipe> recipes = [];
        for (final recipeData in recipesData) {
          final recipeId = recipeData['id'].toString();
          if (ingredientsByRecipeId.containsKey(recipeId)) {
            recipeData['recipeIngredients'] = ingredientsByRecipeId[recipeId];
          }
          if (stepsByRecipeId.containsKey(recipeId)) {
            recipeData['recipeStepLinks'] = stepsByRecipeId[recipeId];
          }
          recipes.add(Recipe.fromJson(recipeData));
        }

        return recipes;
      },
      errorMessage: 'Failed to load recipes',
    );
  }

  // Get a recipe by ID
  Future<Recipe> getRecipe(String id) async {
    return _requestWithRetry(
      request: () async {
        // First, get the basic recipe data
        final recipeResponse = await _dio.get('/recipe/$id');
        if (recipeResponse.statusCode != 200) {
          throw Exception('Failed to load recipe: ${recipeResponse.statusCode}');
        }

        // Parse the basic recipe data
        final recipeData = recipeResponse.data;

        // Now, get the recipe ingredients
        final ingredientsResponse = await _dio.get('/recipe_ingredient');
        if (ingredientsResponse.statusCode != 200) {
          throw Exception('Failed to load recipe ingredients: ${ingredientsResponse.statusCode}');
        }

        // Filter ingredients for this recipe
        final List<dynamic> allRecipeIngredients = ingredientsResponse.data;
        final recipeIngredients = allRecipeIngredients.where((ingredient) {
          return ingredient['recipe'] != null && 
                 ingredient['recipe']['id'].toString() == id;
        }).toList();

        // Get all ingredients
        final ingredientDetailsResponse = await _dio.get('/ingredient');
        if (ingredientDetailsResponse.statusCode != 200) {
          throw Exception('Failed to load ingredients: ${ingredientDetailsResponse.statusCode}');
        }

        final List<dynamic> allIngredientDetails = ingredientDetailsResponse.data;

        // Create a map of ingredient ID to ingredient details
        final Map<int, Map<String, dynamic>> ingredientDetailsById = {};
        for (final ingredient in allIngredientDetails) {
          if (ingredient['id'] != null) {
            ingredientDetailsById[ingredient['id'] as int] = ingredient;
          }
        }

        // Get all measure units
        final measureUnitsResponse = await _dio.get('/measure_unit');
        if (measureUnitsResponse.statusCode != 200) {
          throw Exception('Failed to load measure units: ${measureUnitsResponse.statusCode}');
        }

        final List<dynamic> allMeasureUnits = measureUnitsResponse.data;

        // Create a map of measure unit ID to measure unit details
        final Map<int, Map<String, dynamic>> measureUnitsById = {};
        for (final unit in allMeasureUnits) {
          if (unit['id'] != null) {
            measureUnitsById[unit['id'] as int] = unit;
          }
        }

        // Enhance recipe ingredients with full ingredient details and measure unit details
        for (final recipeIngredient in recipeIngredients) {
          if (recipeIngredient['ingredient'] != null && recipeIngredient['ingredient']['id'] != null) {
            final ingredientId = recipeIngredient['ingredient']['id'] as int;
            if (ingredientDetailsById.containsKey(ingredientId)) {
              // Add full ingredient details
              final ingredientDetails = ingredientDetailsById[ingredientId]!;
              recipeIngredient['ingredient'] = ingredientDetails;

              // Add full measure unit details if available
              if (ingredientDetails['measureUnit'] != null && ingredientDetails['measureUnit']['id'] != null) {
                final measureUnitId = ingredientDetails['measureUnit']['id'] as int;
                if (measureUnitsById.containsKey(measureUnitId)) {
                  ingredientDetails['measureUnit'] = measureUnitsById[measureUnitId]!;
                }
              }
            }
          }
        }

        // Now, get the recipe step links
        final stepLinksResponse = await _dio.get('/recipe_step_link');
        if (stepLinksResponse.statusCode != 200) {
          throw Exception('Failed to load recipe step links: ${stepLinksResponse.statusCode}');
        }

        // Filter step links for this recipe
        final List<dynamic> allRecipeStepLinks = stepLinksResponse.data;
        final recipeStepLinks = allRecipeStepLinks.where((stepLink) {
          return stepLink['recipe'] != null && 
                 stepLink['recipe']['id'].toString() == id;
        }).toList();

        // Get all recipe steps
        final stepsResponse = await _dio.get('/recipe_step');
        if (stepsResponse.statusCode != 200) {
          throw Exception('Failed to load recipe steps: ${stepsResponse.statusCode}');
        }

        final List<dynamic> allRecipeSteps = stepsResponse.data;

        // Create a map of step ID to step details
        final Map<int, Map<String, dynamic>> stepDetailsById = {};
        for (final step in allRecipeSteps) {
          if (step['id'] != null) {
            stepDetailsById[step['id'] as int] = step;
          }
        }

        // Enhance step links with full step details
        for (final stepLink in recipeStepLinks) {
          if (stepLink['step'] != null && stepLink['step']['id'] != null) {
            final stepId = stepLink['step']['id'] as int;
            if (stepDetailsById.containsKey(stepId)) {
              // Add full step details
              final stepDetails = stepDetailsById[stepId]!;
              stepLink['step'] = stepDetails;
            }
          }
        }

        // Sort step links by number
        recipeStepLinks.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));

        // Add ingredients and steps to recipe data
        recipeData['recipeIngredients'] = recipeIngredients;
        recipeData['recipeStepLinks'] = recipeStepLinks;

        // Return the complete recipe
        return Recipe.fromJson(recipeData);
      },
      errorMessage: 'Failed to load recipe $id',
    );
  }

  // Create a new recipe
  Future<Recipe> createRecipe(Recipe recipe) async {
    return _requestWithRetry(
      request: () async {
        // Create a copy of the recipe JSON and modify fields to match API expectations
        // - remove 'uuid' as the API doesn't expect it when creating a new recipe
        // - rename 'images' to 'photo' as that's what the API expects
        // - remove 'description' as the API doesn't expect it when creating a new recipe
        // - remove 'instructions' as the API doesn't expect it when creating a new recipe
        // - remove 'difficulty' as the API doesn't expect it when creating a new recipe
        // - remove 'rating' as the API doesn't expect it when creating a new recipe
        // - remove 'tags' as the API doesn't expect it when creating a new recipe
        // - remove 'ingredients' as the API doesn't expect it when creating a new recipe
        // Rename 'steps' to 'recipesteplink' as that's what the API expects
        // - remove 'isFavorite' as the API doesn't expect it when creating a new recipe
        // - set a default value for 'duration' if it's empty as the API requires a non-null value
        final recipeJson = recipe.toJson();
        recipeJson.remove('uuid');
        recipeJson.remove('description');
        recipeJson.remove('instructions');
        recipeJson.remove('difficulty');
        recipeJson.remove('rating');
        recipeJson.remove('tags');
        recipeJson.remove('ingredients');
        recipeJson.remove('isFavorite');

        // Set a default value for duration if it's empty or convert to integer
        if (recipeJson['duration'] == '') {
          recipeJson['duration'] = 0; // Use integer 0 instead of string
        } else {
          // Try to extract numeric value from duration string (e.g., "30 min" -> 30)
          final durationStr = recipeJson['duration'] as String;
          final numericValue = int.tryParse(durationStr.split(' ').first);
          if (numericValue != null) {
            recipeJson['duration'] = numericValue;
          } else {
            recipeJson['duration'] = 0; // Default to 0 if parsing fails
          }
        }

        // Rename 'images' to 'photo'
        if (recipeJson.containsKey('images')) {
          recipeJson['photo'] = recipeJson['images'];
          recipeJson.remove('images');
        }

        // Process steps and convert durations to numeric values
        if (recipeJson.containsKey('steps')) {
          final steps = recipeJson['steps'] as List<dynamic>;
          final processedSteps = steps.map((step) {
            final stepMap = Map<String, dynamic>.from(step as Map<String, dynamic>);
            // Convert duration to numeric value
            if (stepMap.containsKey('duration')) {
              if (stepMap['duration'] is int) {
                // Duration is already an int, no conversion needed
              } else if (stepMap['duration'] is String) {
                final durationStr = stepMap['duration'] as String;
                // Extract numeric value from duration string (e.g., "10 min" -> 10)
                final numericValue = int.tryParse(durationStr.split(' ').first);
                if (numericValue != null) {
                  stepMap['duration'] = numericValue;
                } else {
                  stepMap['duration'] = 0; // Default to 0 if parsing fails
                }
              } else {
                // Unknown type, default to 0
                stepMap['duration'] = 0;
              }
            }
            return stepMap;
          }).toList();

          recipeJson['recipesteplink'] = processedSteps;
          recipeJson.remove('steps');
        }

        // Debug log to see the actual request payload
        print('DEBUG: Recipe JSON being sent to API: $recipeJson');

        try {
          final response = await _dio.post(
            '/recipe',
            data: recipeJson,
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            return Recipe.fromJson(response.data);
          } else {
            print('DEBUG: Error response: ${response.statusCode} - ${response.data}');
            throw Exception('Failed to create recipe: ${response.statusCode}');
          }
        } catch (e) {
          if (e is DioException) {
            print('DEBUG: DioException: ${e.message}');
            print('DEBUG: Response data: ${e.response?.data}');
          }
          rethrow;
        }
      },
      errorMessage: 'Failed to create recipe',
    );
  }

  // Update a recipe
  Future<Recipe> updateRecipe(Recipe recipe) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.put(
          '/recipe/${recipe.uuid}',
          data: recipe.toJson(),
        );
        if (response.statusCode == 200) {
          return Recipe.fromJson(response.data);
        } else {
          throw Exception('Failed to update recipe: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to update recipe ${recipe.uuid}',
    );
  }

  // Delete a recipe
  Future<bool> deleteRecipe(String id) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.delete('/recipe/$id');
        return response.statusCode == 204;
      },
      errorMessage: 'Failed to delete recipe $id',
    );
  }

  // Add a comment to a recipe
  Future<Comment> addComment(String recipeId, Comment comment) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post(
          '/recipe/$recipeId/comments',
          data: comment.toJson(),
        );
        if (response.statusCode == 201) {
          return Comment.fromJson(response.data);
        } else {
          throw Exception('Failed to add comment: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to add comment to recipe $recipeId',
    );
  }

  // Get recipe image
  Future<String> getRecipeImage(String imageUrl) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get(imageUrl);
        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Failed to load image: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to load image from $imageUrl',
    );
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.put(
          '/recipe/$recipeId/favorite',
          data: {'isFavorite': isFavorite},
        );
        return response.statusCode == 200;
      },
      errorMessage: 'Failed to toggle favorite status for recipe $recipeId',
    );
  }

  // Update a recipe step
  Future<bool> updateStep(String recipeId, int stepId, bool isCompleted) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.put(
          '/recipe/$recipeId/steps/$stepId',
          data: {'isCompleted': isCompleted},
        );
        return response.statusCode == 200;
      },
      errorMessage: 'Failed to update step $stepId for recipe $recipeId',
    );
  }
}
