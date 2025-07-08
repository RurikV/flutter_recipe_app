import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/data/models/recipe_step.dart';
import 'package:flutter_recipe_app/data/models/comment.dart';
import 'package:flutter_recipe_app/data/models/user.dart';
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
        // Create a new comment
        final comment = action.comment as Comment;
        // Create a new list with all existing comments
        final List<Comment> updatedComments = List<Comment>.from(recipe.comments);
        // Add the new comment
        updatedComments.add(comment);
        // Return a new recipe with updated comments
        return Recipe(
          uuid: recipe.uuid,
          name: recipe.name,
          images: recipe.images,
          mainImage: recipe.mainImage,
          description: recipe.description,
          instructions: recipe.instructions,
          difficulty: recipe.difficulty,
          duration: recipe.duration,
          rating: recipe.rating,
          tags: recipe.tags,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
          isFavorite: recipe.isFavorite,
          comments: updatedComments,
        );
      }
      return recipe;
    }).toList();
  } else if (action is StepStatusUpdatedAction) {
    return recipes.map((recipe) {
      if (recipe.uuid == action.recipeId) {
        // Create a new list with all existing steps
        final List<RecipeStep> updatedSteps = List<RecipeStep>.from(recipe.steps);
        // Update the step at the specified index
        updatedSteps[action.stepIndex] = RecipeStep(
          id: recipe.steps[action.stepIndex].id,
          name: recipe.steps[action.stepIndex].name,
          duration: recipe.steps[action.stepIndex].duration,
          isCompleted: action.isCompleted,
        );
        // Return a new recipe with updated steps
        return Recipe(
          uuid: recipe.uuid,
          name: recipe.name,
          images: recipe.images,
          mainImage: recipe.mainImage,
          description: recipe.description,
          instructions: recipe.instructions,
          difficulty: recipe.difficulty,
          duration: recipe.duration,
          rating: recipe.rating,
          tags: recipe.tags,
          ingredients: recipe.ingredients,
          steps: updatedSteps,
          isFavorite: recipe.isFavorite,
          comments: recipe.comments,
        );
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
  } else if (action is ToggleFavoriteAction) {
    // This is just the initial action, don't modify the state yet
    return favoriteRecipes;
  } else if (action is FavoriteToggledAction) {
    if (action.isFavorite) {
      // We don't need to add the recipe here since the LoadFavoriteRecipesAction
      // will be dispatched after this and will load the complete recipe from the database
      return favoriteRecipes;
    } else {
      // Remove from favorites
      return favoriteRecipes.where((recipe) => recipe.uuid != action.recipeId).toList();
    }
  }
  return favoriteRecipes;
}

// Loading reducer
bool loadingReducer(bool isLoading, dynamic action) {
  if (action is LoadRecipesAction || 
      action is LoadFavoriteRecipesAction ||
      action is LoginAction ||
      action is RegisterAction) {
    return true;
  } else if (action is RecipesLoadedAction || 
             action is RecipesLoadErrorAction || 
             action is FavoriteRecipesLoadedAction ||
             action is LoginSuccessAction ||
             action is LoginErrorAction ||
             action is RegisterSuccessAction ||
             action is RegisterErrorAction) {
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