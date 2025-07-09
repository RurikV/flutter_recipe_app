import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/data/models/user.dart';

class AppState {
  final List<Recipe> recipes;
  final List<Recipe> favoriteRecipes;
  final bool isLoading;
  final String error;
  final User? user;
  final bool isAuthenticated;

  AppState({
    required this.recipes,
    required this.favoriteRecipes,
    required this.isLoading,
    required this.error,
    this.user,
    required this.isAuthenticated,
  });

  // Initial state
  factory AppState.initial() {
    return AppState(
      recipes: [],
      favoriteRecipes: [],
      isLoading: false,
      error: '',
      user: null,
      isAuthenticated: false,
    );
  }

  // Copy with method to create a new state with updated values
  AppState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? favoriteRecipes,
    bool? isLoading,
    String? error,
    User? user,
    bool? isAuthenticated,
  }) {
    return AppState(
      recipes: recipes ?? this.recipes,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
