import 'package:flutter_recipe_app/models/recipe.dart';

class AppState {
  final List<Recipe> recipes;
  final List<Recipe> favoriteRecipes;
  final bool isLoading;
  final String error;

  AppState({
    required this.recipes,
    required this.favoriteRecipes,
    required this.isLoading,
    required this.error,
  });

  // Initial state
  factory AppState.initial() {
    return AppState(
      recipes: [],
      favoriteRecipes: [],
      isLoading: false,
      error: '',
    );
  }

  // Copy with method to create a new state with updated values
  AppState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? favoriteRecipes,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      recipes: recipes ?? this.recipes,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}