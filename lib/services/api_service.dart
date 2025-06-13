import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/recipe.dart';
import '../models/comment.dart';

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
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
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
        final response = await _dio.get('/recipe');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          return data.map((json) => Recipe.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load recipes: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to load recipes',
    );
  }

  // Get a recipe by ID
  Future<Recipe> getRecipe(String id) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.get('/recipe/$id');
        if (response.statusCode == 200) {
          return Recipe.fromJson(response.data);
        } else {
          throw Exception('Failed to load recipe: ${response.statusCode}');
        }
      },
      errorMessage: 'Failed to load recipe $id',
    );
  }

  // Create a new recipe
  Future<Recipe> createRecipe(Recipe recipe) async {
    return _requestWithRetry(
      request: () async {
        final response = await _dio.post(
          '/recipe',
          data: recipe.toJson(),
        );
        if (response.statusCode == 201) {
          return Recipe.fromJson(response.data);
        } else {
          throw Exception('Failed to create recipe: ${response.statusCode}');
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
