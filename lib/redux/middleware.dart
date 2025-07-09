import 'package:redux/redux.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/actions.dart';
import 'package:flutter_recipe_app/domain/usecases/recipe_manager.dart';
import 'package:flutter_recipe_app/domain/entities/comment.dart' as domain;
import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/data/mappers/recipe_mapper.dart';
import 'package:get_it/get_it.dart';

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
        final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
        final domainRecipes = await recipeManager.getRecipes();
        final dataModelRecipes = domainRecipes.map((domainRecipe) => RecipeMapper.toModel(domainRecipe)).toList();
        print('[INFO] Successfully loaded ${dataModelRecipes.length} recipes');
        store.dispatch(RecipesLoadedAction(dataModelRecipes));
      } catch (e) {
        print('[ERROR] Failed to load recipes in middleware: $e');
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

      // Check if user is authenticated
      if (!store.state.isAuthenticated) {
        // If not authenticated, return empty list
        store.dispatch(FavoriteRecipesLoadedAction([]));
        return;
      }

      try {
        final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
        final domainFavoriteRecipes = await recipeManager.getFavoriteRecipes();
        final dataModelFavoriteRecipes = domainFavoriteRecipes.map((domainRecipe) => RecipeMapper.toModel(domainRecipe)).toList();
        print('[INFO] Successfully loaded ${dataModelFavoriteRecipes.length} favorite recipes');
        store.dispatch(FavoriteRecipesLoadedAction(dataModelFavoriteRecipes));
      } catch (e) {
        print('[ERROR] Failed to load favorite recipes in middleware: $e');
        // Note: No error action dispatched for favorites, but error is logged
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
      // Pass the action to the next dispatcher so the reducer can handle it immediately
      next(action);

      // Check if user is authenticated
      if (!store.state.isAuthenticated) {
        // If not authenticated, show error or redirect to login
        // For now, we'll just return without doing anything
        return;
      }

      // Find the recipe in the state
      final recipe = store.state.recipes.firstWhere(
        (r) => r.uuid == action.recipeId,
        orElse: () => _createDefaultRecipe(action.recipeId),
      );

      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
      final success = await recipeManager.toggleFavorite(action.recipeId);

      if (success) {
        print('[INFO] Successfully toggled favorite status for recipe: ${action.recipeId}');
        // Dispatch action to update state
        store.dispatch(FavoriteToggledAction(
          action.recipeId,
          !recipe.isFavorite,
        ));

        // Also load favorite recipes to ensure the favorites list is updated
        store.dispatch(LoadFavoriteRecipesAction());
      } else {
        print('[ERROR] Failed to toggle favorite status for recipe: ${action.recipeId}');
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
      final comment = domain.Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'User', // In a real app, this would be the current user's name
        text: action.commentText,
        date: DateTime.now().toString().substring(0, 10), // Format: YYYY-MM-DD
      );

      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
      final success = await recipeManager.addComment(action.recipeId, comment);

      if (success) {
        print('[INFO] Successfully added comment to recipe: ${action.recipeId}');
        // Dispatch action to update state
        store.dispatch(CommentAddedAction(action.recipeId, comment));
      } else {
        print('[ERROR] Failed to add comment to recipe: ${action.recipeId}');
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
      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
      final success = await recipeManager.updateStepStatus(
        action.recipeId,
        action.stepIndex,
        action.isCompleted,
      );

      if (success) {
        print('[INFO] Successfully updated step status for recipe: ${action.recipeId}, step: ${action.stepIndex}, completed: ${action.isCompleted}');
        // Dispatch action to update state
        store.dispatch(StepStatusUpdatedAction(
          action.recipeId,
          action.stepIndex,
          action.isCompleted,
        ));
      } else {
        print('[ERROR] Failed to update step status for recipe: ${action.recipeId}, step: ${action.stepIndex}');
      }
    } else {
      next(action);
    }
  };
}
