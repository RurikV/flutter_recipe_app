import 'package:flutter_recipe_app/models/recipe.dart';
import 'package:flutter_recipe_app/models/user.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/actions.dart';

// Main reducer that combines all reducers
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    recipes: recipesReducer(state.recipes, action),
    favoriteRecipes: favoriteRecipesReducer(state.favoriteRecipes, action),
    isLoading: loadingReducer(state.isLoading, action),
    error: errorReducer(state.error, action),
    user: authUserReducer(state.user, action),
    isAuthenticated: authStatusReducer(state.isAuthenticated, action),
  );
}

// Recipes reducer
List<Recipe> recipesReducer(List<Recipe> recipes, dynamic action) {
  if (action is RecipesLoadedAction) {
    return action.recipes.cast<Recipe>();
  } else if (action is FavoriteToggledAction) {
    return recipes.map((recipe) {
      if (recipe.uuid == action.recipeId) {
        return recipe.copyWith(isFavorite: action.isFavorite);
      }
      return recipe;
    }).toList();
  } else if (action is CommentAddedAction) {
    return recipes.map((recipe) {
      if (recipe.uuid == action.recipeId) {
        // Create a new list with all existing comments plus the new one
        final updatedComments = [...recipe.comments, action.comment];
        // Use dynamic to avoid type casting issues
        return recipe.copyWith(comments: updatedComments as dynamic);
      }
      return recipe;
    }).toList();
  } else if (action is StepStatusUpdatedAction) {
    return recipes.map((recipe) {
      if (recipe.uuid == action.recipeId) {
        // Create a new list with all existing steps
        final updatedSteps = recipe.steps.map((step) {
          if (recipe.steps.indexOf(step) == action.stepIndex) {
            return step.copyWith(isCompleted: action.isCompleted);
          }
          return step;
        }).toList();
        return recipe.copyWith(steps: updatedSteps);
      }
      return recipe;
    }).toList();
  }
  return recipes;
}

// Favorite recipes reducer
List<Recipe> favoriteRecipesReducer(List<Recipe> favoriteRecipes, dynamic action) {
  if (action is FavoriteRecipesLoadedAction) {
    return action.favoriteRecipes.cast<Recipe>();
  } else if (action is FavoriteToggledAction) {
    if (action.isFavorite) {
      // Add to favorites if not already there
      final recipe = favoriteRecipes.firstWhere(
        (r) => r.uuid == action.recipeId,
        orElse: () => Recipe(
          uuid: action.recipeId,
          name: '',
          description: '',
          instructions: '',
          difficulty: 0,
          duration: '',
          rating: 0,
          tags: [],
          isFavorite: true,
        ),
      );
      if (!favoriteRecipes.any((r) => r.uuid == action.recipeId)) {
        return [...favoriteRecipes, recipe.copyWith(isFavorite: true)];
      }
    } else {
      // Remove from favorites
      return favoriteRecipes.where((recipe) => recipe.uuid != action.recipeId).toList();
    }
  }
  return favoriteRecipes;
}

// Loading reducer
bool loadingReducer(bool isLoading, dynamic action) {
  if (action is LoadRecipesAction || action is LoadFavoriteRecipesAction) {
    return true;
  } else if (action is RecipesLoadedAction || 
             action is RecipesLoadErrorAction || 
             action is FavoriteRecipesLoadedAction) {
    return false;
  }
  return isLoading;
}

// Error reducer
String errorReducer(String error, dynamic action) {
  if (action is RecipesLoadErrorAction) {
    return action.error;
  } else if (action is LoginErrorAction) {
    return action.error;
  } else if (action is RegisterErrorAction) {
    return action.error;
  } else if (action is RecipesLoadedAction || 
             action is FavoriteRecipesLoadedAction ||
             action is LoginSuccessAction ||
             action is RegisterSuccessAction) {
    return '';
  }
  return error;
}

// Authentication user reducer
User? authUserReducer(User? user, dynamic action) {
  if (action is LoginSuccessAction) {
    return action.user;
  } else if (action is RegisterSuccessAction) {
    return action.user;
  } else if (action is LogoutAction) {
    return null;
  }
  return user;
}

// Authentication status reducer
bool authStatusReducer(bool isAuthenticated, dynamic action) {
  if (action is LoginSuccessAction || action is RegisterSuccessAction) {
    return true;
  } else if (action is LogoutAction) {
    return false;
  }
  return isAuthenticated;
}
