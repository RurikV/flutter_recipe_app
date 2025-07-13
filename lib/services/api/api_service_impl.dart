import 'dart:async';
import 'dart:io' if (dart.library.html) 'web_http_client.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' if (dart.library.html) 'package:dio/browser.dart';
import 'package:dio/io.dart' if (dart.library.html) 'web_http_client.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import '../../../../../data/models/recipe.dart';
import 'api_service.dart';
import '../../config/app_config.dart';

// Cache entry class for storing cached API responses
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// ApiServiceImpl handles direct API calls to the backend.
/// It provides methods for each API endpoint without combining data from multiple endpoints.
class ApiServiceImpl implements ApiService {
  final Dio _dio;
  final String baseUrl = AppConfig.baseUrl;
  final int _maxRetries = 3;

  // Simple in-memory cache for API responses
  final Map<String, CacheEntry> _cache = {};
  static const Duration _cacheTTL = Duration(minutes: 5);

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
    const cacheKey = 'recipes_list';

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      if (kDebugMode) print('ApiService: Returning cached recipes');
      return cached.data as List<dynamic>;
    }

    if (kDebugMode) print('ApiService.getRecipesData() called with baseUrl: $baseUrl');
    final result = await _requestWithRetry(
      request: () async {
        // Add pagination parameter for better performance
        final response = await _dio.get('/recipe?count=20');
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipes: ${response.statusCode}');
        }
        if (kDebugMode) print('Successfully received ${(response.data as List).length} recipes');
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load recipes',
    );

    // Cache the result
    _cache[cacheKey] = CacheEntry(result, DateTime.now());
    return result;
  }

  @override
  Future<Map<String, dynamic>> getRecipeData(String id) async {
    final cacheKey = 'recipe_$id';

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      if (kDebugMode) print('ApiService: Returning cached recipe $id');
      return cached.data as Map<String, dynamic>;
    }

    if (kDebugMode) print('ApiService.getRecipeData() called for id: $id');
    final result = await _requestWithRetry(
      request: () async {
        final response = await _dio.get('/recipe/$id');
        if (response.statusCode != 200) {
          throw Exception('Failed to load recipe: ${response.statusCode}');
        }

        final recipeData = response.data as Map<String, dynamic>;
        if (kDebugMode) {
          print('ApiService: Recipe loaded - ${recipeData['name']}');
          final ingredients = recipeData['recipeIngredients'] as List?;
          final steps = recipeData['recipeStepLinks'] as List?;
          print('ApiService: Ingredients: ${ingredients?.length ?? 0}, Steps: ${steps?.length ?? 0}');
        }

        return recipeData;
      },
      errorMessage: 'Failed to load recipe',
    );

    // Cache the result
    _cache[cacheKey] = CacheEntry(result, DateTime.now());
    return result;
  }

  @override
  Future<List<dynamic>> getIngredientsData() async {
    const cacheKey = 'ingredients_list';

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      if (kDebugMode) print('ApiService: Returning cached ingredients');
      return cached.data as List<dynamic>;
    }

    final result = await _requestWithRetry(
      request: () async {
        final response = await _dio.get('/ingredient');
        if (response.statusCode != 200) {
          throw Exception('Failed to load ingredients: ${response.statusCode}');
        }
        return response.data as List<dynamic>;
      },
      errorMessage: 'Failed to load ingredients',
    );

    // Cache the result
    _cache[cacheKey] = CacheEntry(result, DateTime.now());
    return result;
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
    final result = await _requestWithRetry(
      request: () async {
        // Convert Recipe to API format
        final recipeData = {
          'name': recipe.name,
          'description': recipe.description,
          'instructions': recipe.instructions,
          'difficulty': recipe.difficulty,
          'duration': _parseDurationToInt(recipe.duration),
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

    // Invalidate cache after successful recipe creation so new recipe appears instantly
    _invalidateRecipesCaches();

    return result;
  }

  // Helper method to parse duration string to integer (in minutes)
  int _parseDurationToInt(String duration) {
    if (duration.isEmpty) return 0;

    // Try to parse as integer first (if it's already a number)
    final intValue = int.tryParse(duration);
    if (intValue != null) return intValue;

    // Extract numbers from the string
    final RegExp numberRegex = RegExp(r'\d+');
    final match = numberRegex.firstMatch(duration);
    if (match == null) return 0;

    final number = int.tryParse(match.group(0)!) ?? 0;

    // Convert to minutes based on unit
    final lowerDuration = duration.toLowerCase();
    if (lowerDuration.contains('hour') || lowerDuration.contains('hr')) {
      return number * 60; // Convert hours to minutes
    } else if (lowerDuration.contains('second') || lowerDuration.contains('sec')) {
      return (number / 60).round(); // Convert seconds to minutes
    } else {
      // Default to minutes or no unit specified
      return number;
    }
  }

  // Helper method to invalidate recipes-related caches
  void _invalidateRecipesCaches() {
    // Remove recipes list cache
    _cache.remove('recipes_list');

    // Remove all individual recipe caches
    final keysToRemove = <String>[];
    for (final key in _cache.keys) {
      if (key.startsWith('recipe_')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (kDebugMode) print('ApiService: Invalidated recipes caches after recipe creation');
  }

  @override
  Future<Map<String, dynamic>> updateRecipe(String id, Recipe recipe) async {
    final result = await _requestWithRetry(
      request: () async {
        // Convert Recipe to API format
        final recipeData = {
          'name': recipe.name,
          'description': recipe.description,
          'instructions': recipe.instructions,
          'difficulty': recipe.difficulty,
          'duration': _parseDurationToInt(recipe.duration),
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

    // Invalidate cache after successful recipe update so changes appear instantly
    _invalidateRecipesCaches();

    return result;
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _requestWithRetry(
      request: () async {
        final response = await _dio.delete('/recipe/$id');
        if (response.statusCode != 200) {
          throw Exception('Failed to delete recipe: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to delete recipe',
    );

    // Invalidate cache after successful recipe deletion so changes appear instantly
    _invalidateRecipesCaches();
  }

  @override
  Future<Map<String, dynamic>> createRecipeData(Map<String, dynamic> recipeData) async {
    // Parse duration if it exists and is a string
    final processedData = Map<String, dynamic>.from(recipeData);
    if (processedData.containsKey('duration') && processedData['duration'] is String) {
      processedData['duration'] = _parseDurationToInt(processedData['duration'] as String);
    }

    final result = await _requestWithRetry(
      request: () async {
        final response = await _dio.post('/recipe', data: processedData);
        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception('Failed to create recipe data: ${response.statusCode}');
        }
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Failed to create recipe data',
    );

    // Invalidate cache after successful recipe creation so new recipe appears instantly
    _invalidateRecipesCaches();

    return result;
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
    // Parse duration if it exists and is a string
    final processedData = Map<String, dynamic>.from(recipeData);
    if (processedData.containsKey('duration') && processedData['duration'] is String) {
      processedData['duration'] = _parseDurationToInt(processedData['duration'] as String);
    }

    return _requestWithRetry(
      request: () async {
        final response = await _dio.put('/recipe/$id', data: processedData);
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
