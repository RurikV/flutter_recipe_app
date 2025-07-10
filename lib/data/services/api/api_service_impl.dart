import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' if (dart.library.html) 'package:dio/browser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../data/models/recipe.dart';
import '../../../../domain/services/api_service.dart';

// Import HttpClient, X509Certificate, and IOHttpClientAdapter only for non-web platforms
import 'dart:io' if (dart.library.html) 'web_http_client.dart';
// Import IOHttpClientAdapter explicitly for non-web platforms
import 'package:dio/io.dart' if (dart.library.html) 'web_http_client.dart' show IOHttpClientAdapter;

/// ApiServiceImpl handles direct API calls to the backend.
/// It provides methods for each API endpoint without combining data from multiple endpoints.
class ApiServiceImpl implements ApiService {
  final Dio _dio;
  final String baseUrl = 'https://foodapi.dzolotov.pro';
  final int _maxRetries = 3;

  ApiServiceImpl() : _dio = Dio() {
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
      // Check if this is a web-specific CORS error
      if (kIsWeb && e is DioException && e.type == DioExceptionType.connectionError) {
        final corsErrorMessage = '''
$errorMessage: Network connection failed on web platform.

This is likely due to CORS (Cross-Origin Resource Sharing) restrictions.
The API server at $baseUrl may not be configured to allow requests from web browsers.

Possible solutions:
1. Configure the API server to include proper CORS headers
2. Use a proxy server for development
3. Run the app on a mobile device or desktop where CORS doesn't apply

Technical details: ${e.message}
''';
        print('CORS Error detected on web platform: $e');
        throw Exception(corsErrorMessage);
      }

      if (retries < _maxRetries) {
        // Don't retry CORS errors on web as they won't resolve
        if (kIsWeb && e is DioException && e.type == DioExceptionType.connectionError) {
          print('Skipping retry for CORS error on web platform');
        } else {
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
      }
      print('API request failed after $_maxRetries attempts: $e');
      print('$errorMessage: $e');
      throw Exception('$errorMessage: $e');
    }
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<void> deleteRecipeData(String id) async {
    await deleteRecipe(id);
  }

  @override
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

  @override
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
