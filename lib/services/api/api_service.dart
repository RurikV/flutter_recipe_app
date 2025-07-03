import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' if (dart.library.html) 'package:dio/browser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/recipe.dart';

// Import HttpClient, X509Certificate, and IOHttpClientAdapter only for non-web platforms
import 'dart:io' if (dart.library.html) 'web_http_client.dart';
// Import IOHttpClientAdapter explicitly for non-web platforms
import 'package:dio/io.dart' if (dart.library.html) 'web_http_client.dart' show IOHttpClientAdapter;

/// ApiService handles direct API calls to the backend.
/// It provides methods for each API endpoint without combining data from multiple endpoints.
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

    // Configure HTTP client adapter based on platform
    if (!kIsWeb) {
      // Native platforms: Configure to accept self-signed certificates
      final adapter = _dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    // For web, use the default BrowserHttpClientAdapter which is already set
  }

  // Generic method to handle API requests with retry logic
  Future<T> _requestWithRetry<T>({
    required Future<T> Function() request,
    required String errorMessage,
    int retries = 0,
  }) async {
    try {
      print('Making API request (attempt ${retries + 1}/$_maxRetries)');
      final result = await request();
      print('API request successful');
      return result;
    } catch (e) {
      if (retries < _maxRetries) {
        // Exponential backoff: wait 2^retries seconds before retrying
        final waitTime = Duration(seconds: 1 << retries);
        print('API request failed: $e');
        print('Retrying request after $waitTime (attempt ${retries + 1}/$_maxRetries)');
        await Future.delayed(waitTime);
        return _requestWithRetry(
          request: request,
          errorMessage: errorMessage,
          retries: retries + 1,
        );
      }
      print('API request failed after $_maxRetries attempts: $e');
      print('$errorMessage: $e');
      throw Exception('$errorMessage: $e');
    }
  }

  // Basic API endpoint methods

  /// Get all recipes (basic data only)
  Future<List<dynamic>> getRecipesData() async {
    print('ApiService.getRecipesData() called with baseUrl: $baseUrl');
    return _requestWithRetry(
      request: () async {
        print('Making GET request to $baseUrl/recipe');
        final response = await _dio.get('/recipe');
        if (response.statusCode != 200) {
          print('Failed to load recipes: ${response.statusCode}');
          throw Exception('Failed to load recipes: ${response.statusCode}');
        }
        print('Successfully received response from $baseUrl/recipe');
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load recipes',
    );
  }

  /// Get a recipe by ID (basic data only)
  Future<Map<String, dynamic>> getRecipeData(String id) async {
    print('ApiService.getRecipeData() called for id: $id with baseUrl: $baseUrl');
    return _requestWithRetry(
      request: () async {
        print('Making GET request to $baseUrl/recipe/$id');
        final response = await _dio.get('/recipe/$id');
        if (response.statusCode != 200) {
          print('Failed to load recipe: ${response.statusCode}');
          throw Exception('Failed to load recipe: ${response.statusCode}');
        }
        print('Successfully received response from $baseUrl/recipe/$id');
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to load recipe',
    );
  }

  /// Get all ingredients
  Future<List<dynamic>> getIngredientsData() async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/ingredient');
        if (response.statusCode != 200) {
          throw Exception('Failed to load ingredients: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load ingredients',
    );
  }

  /// Get all measure units
  Future<List<dynamic>> getMeasureUnitsData() async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/measure_unit');
        if (response.statusCode != 200) {
          throw Exception('Failed to load measure units: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load measure units',
    );
  }

  /// Get all recipe ingredients
  Future<List<dynamic>> getRecipeIngredientsData() async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/recipe_ingredient');
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipe ingredients: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load recipe ingredients',
    );
  }

  /// Get all recipe steps
  Future<List<dynamic>> getRecipeStepsData() async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/recipe_step');
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipe steps: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load recipe steps',
    );
  }

  /// Get all recipe step links
  Future<List<dynamic>> getRecipeStepLinksData() async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/recipe_step_link');
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipe step links: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load recipe step links',
    );
  }

  /// Get all comments for a recipe
  Future<List<dynamic>> getCommentsForRecipe(String recipeId) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/comment?recipe=$recipeId');
        if (response.statusCode != 200) {
          throw Exception('Failed to load comments: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load comments',
    );
  }

  /// Add a comment to a recipe
  Future<Map<String, dynamic>> addComment(String recipeId, String authorName, String text) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/comment', data: {
          'recipe': {'id': recipeId},
          'authorName': authorName,
          'text': text,
        });
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to add comment: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to add comment',
    );
  }

  /// Create a new recipe
  Future<Map<String, dynamic>> createRecipe(Recipe recipe) async {
    return _requestWithRetry(
      request: () async {
        // Convert Recipe to API format
        final recipeData = {
          'name': recipe.name,
          'description': recipe.description,
          'instructions': recipe.instructions,
          'difficulty': recipe.difficulty,
          'duration': recipe.duration,
          'rating': recipe.rating,
        };

        final response = await _dio.post('/recipe', data: recipeData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe',
    );
  }

  /// Update an existing recipe
  Future<Map<String, dynamic>> updateRecipe(String id, Recipe recipe) async {
    return _requestWithRetry(
      request: () async {
        // Convert Recipe to API format
        final recipeData = {
          'name': recipe.name,
          'description': recipe.description,
          'instructions': recipe.instructions,
          'difficulty': recipe.difficulty,
          'duration': recipe.duration,
          'rating': recipe.rating,
        };

        final response = await _dio.put('/recipe/$id', data: recipeData);
        if (response.statusCode != 200) {
          throw Exception('Failed to update recipe: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to update recipe',
    );
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String id) async {
    await _requestWithRetry(
      request: () async {
        final response = await _dio.delete('/recipe/$id');
        if (response.statusCode != 204) {
          throw Exception('Failed to delete recipe: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to delete recipe',
    );
  }

  // Additional methods required by RecipeRepositoryImpl

  /// Create recipe data - delegates to createRecipe
  Future<Map<String, dynamic>> createRecipeData(Map<String, dynamic> recipeData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/recipe', data: recipeData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe data',
    );
  }

  /// Create ingredient data
  Future<Map<String, dynamic>> createIngredientData(Map<String, dynamic> ingredientData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/ingredient', data: ingredientData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create ingredient data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create ingredient data',
    );
  }

  /// Create recipe ingredient data
  Future<Map<String, dynamic>> createRecipeIngredientData(Map<String, dynamic> recipeIngredientData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/recipe_ingredient', data: recipeIngredientData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe ingredient data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe ingredient data',
    );
  }

  /// Create recipe step data
  Future<Map<String, dynamic>> createRecipeStepData(Map<String, dynamic> stepData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/recipe_step', data: stepData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe step data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe step data',
    );
  }

  /// Create recipe step link data
  Future<Map<String, dynamic>> createRecipeStepLinkData(Map<String, dynamic> stepLinkData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/recipe_step_link', data: stepLinkData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe step link data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe step link data',
    );
  }

  /// Update recipe data - delegates to updateRecipe
  Future<Map<String, dynamic>> updateRecipeData(String id, Map<String, dynamic> recipeData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.put('/recipe/$id', data: recipeData);
        if (response.statusCode != 200) {
          throw Exception('Failed to update recipe data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to update recipe data',
    );
  }

  /// Delete recipe data - delegates to deleteRecipe
  Future<void> deleteRecipeData(String id) async {
    await deleteRecipe(id);
  }

  /// Add comment data
  Future<Map<String, dynamic>> addCommentData(String recipeId, Map<String, dynamic> commentData) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post('/comment', data: {
          'recipe': {'id': recipeId},
          ...commentData,
        });
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to add comment data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to add comment data',
    );
  }

  /// Get comments data
  Future<List<dynamic>> getCommentsData(String recipeId) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/comment?recipe=$recipeId');
        if (response.statusCode != 200) {
          throw Exception('Failed to load comments data: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load comments data',
    );
  }
}
