import 'package:redux/redux.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/actions.dart';
import 'package:flutter_recipe_app/domain/usecases/recipe_manager.dart';
import 'package:flutter_recipe_app/models/comment.dart';
import 'package:flutter_recipe_app/models/recipe.dart';

// Helper method to create a default recipe
Recipe _createDefaultRecipe(String uuid) {
  return Recipe(
    uuid: uuid,
    name: '',
    images: null,
    description: '',
    instructions: '',
    difficulty: 0,
    duration: '',
    rating: 0,
    tags: [],
    isFavorite: true,
  );
}

// Create middleware
List<Middleware<AppState>> createMiddleware() {
  final loadRecipes = _createLoadRecipesMiddleware();
  final loadFavoriteRecipes = _createLoadFavoriteRecipesMiddleware();
  final toggleFavorite = _createToggleFavoriteMiddleware();
  final addComment = _createAddCommentMiddleware();
  final updateStepStatus = _createUpdateStepStatusMiddleware();

  return [
    loadRecipes,
    loadFavoriteRecipes,
    toggleFavorite,
    addComment,
    updateStepStatus,
  ];
}

// Middleware for loading recipes
Middleware<AppState> _createLoadRecipesMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is LoadRecipesAction) {
      next(action); // Let the reducer know we're loading

      try {
        final RecipeManager recipeManager = RecipeManager();
        final recipes = await recipeManager.getRecipes();
        store.dispatch(RecipesLoadedAction(recipes));
      } catch (e) {
        store.dispatch(RecipesLoadErrorAction(e.toString()));
      }
    } else {
      next(action);
    }
  };
}

// Middleware for loading favorite recipes
Middleware<AppState> _createLoadFavoriteRecipesMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is LoadFavoriteRecipesAction) {
      next(action); // Let the reducer know we're loading

      try {
        final RecipeManager recipeManager = RecipeManager();
        final favoriteRecipes = await recipeManager.getFavoriteRecipes();
        store.dispatch(FavoriteRecipesLoadedAction(favoriteRecipes));
      } catch (e) {
        // Handle error if needed
        print('Error loading favorite recipes: $e');
      }
    } else {
      next(action);
    }
  };
}

// Middleware for toggling favorite status
Middleware<AppState> _createToggleFavoriteMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is ToggleFavoriteAction) {
      // Find the recipe in the state
      final recipe = store.state.recipes.firstWhere(
        (r) => r.uuid == action.recipeId,
        orElse: () => _createDefaultRecipe(action.recipeId),
      );

      final RecipeManager recipeManager = RecipeManager();
      final success = await recipeManager.toggleFavorite(action.recipeId);

      if (success) {
        // Dispatch action to update state
        store.dispatch(FavoriteToggledAction(
          action.recipeId,
          !recipe.isFavorite,
        ));
      }
    } else {
      next(action);
    }
  };
}

// Middleware for adding comments
Middleware<AppState> _createAddCommentMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is AddCommentAction) {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'User', // In a real app, this would be the current user's name
        text: action.commentText,
        date: DateTime.now().toString().substring(0, 10), // Format: YYYY-MM-DD
      );

      final RecipeManager recipeManager = RecipeManager();
      final success = await recipeManager.addComment(action.recipeId, comment);

      if (success) {
        // Dispatch action to update state
        store.dispatch(CommentAddedAction(action.recipeId, comment));
      }
    } else {
      next(action);
    }
  };
}

// Middleware for updating step status
Middleware<AppState> _createUpdateStepStatusMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is UpdateStepStatusAction) {
      final RecipeManager recipeManager = RecipeManager();
      final success = await recipeManager.updateStepStatus(
        action.recipeId,
        action.stepIndex,
        action.isCompleted,
      );

      if (success) {
        // Dispatch action to update state
        store.dispatch(StepStatusUpdatedAction(
          action.recipeId,
          action.stepIndex,
          action.isCompleted,
        ));
      }
    } else {
      next(action);
    }
  };
}
