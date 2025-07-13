import 'package:redux/redux.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/actions.dart';
import 'package:recipe_master/data/usecases/recipe_manager.dart';
import 'package:recipe_master/data/models/comment.dart' as model;
import 'package:recipe_master/data/models/recipe.dart';
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
  final deleteRecipe = _createDeleteRecipeMiddleware();

  return [
    loadRecipes,
    loadFavoriteRecipes,
    toggleFavorite,
    addComment,
    updateStepStatus,
    deleteRecipe,
  ];
}

// Middleware for loading recipes
Middleware<AppState> _createLoadRecipesMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is LoadRecipesAction) {
      next(action); // Let the reducer know we're loading

      try {
        final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
        final recipes = await recipeManager.getRecipes();
        store.dispatch(RecipesLoadedAction(recipes));

        // After recipes are loaded successfully, automatically load favorites
        // This ensures the cache is populated before getFavoriteRecipes() is called
        store.dispatch(LoadFavoriteRecipesAction());
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
        final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
        final favoriteRecipes = await recipeManager.getFavoriteRecipes();
        store.dispatch(FavoriteRecipesLoadedAction(favoriteRecipes));
      } catch (e) {
        // Handle error if needed
        print('Error loading favorite recipes: $e');
        // Don't dispatch empty list on error - preserve existing favorites in state
        // Only dispatch error action to update loading state
        store.dispatch(RecipesLoadErrorAction('Failed to load favorites: $e'));
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

      // Find the recipe in the state
      final recipe = store.state.recipes.firstWhere(
        (r) => r.uuid == action.recipeId,
        orElse: () => _createDefaultRecipe(action.recipeId),
      );

      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
      final success = await recipeManager.toggleFavorite(action.recipeId);

      if (success) {
        // Dispatch action to update state
        store.dispatch(FavoriteToggledAction(
          action.recipeId,
          !recipe.isFavorite,
        ));

        // Also load favorite recipes to ensure the favorites list is updated
        store.dispatch(LoadFavoriteRecipesAction());
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
      final comment = model.Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'User', // In a real app, this would be the current user's name
        text: action.commentText,
        date: DateTime.now().toString().substring(0, 10), // Format: YYYY-MM-DD
      );

      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
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
      final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
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

// Middleware for deleting recipes
Middleware<AppState> _createDeleteRecipeMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is DeleteRecipeAction) {
      next(action); // Let the reducer know we're processing

      try {
        final RecipeManager recipeManager = GetIt.instance.get<RecipeManager>();
        final success = await recipeManager.deleteRecipe(action.recipeId);

        if (success) {
          // Dispatch action to update state
          store.dispatch(RecipeDeletedAction(action.recipeId));

          // Reload recipes to ensure the list is updated
          store.dispatch(LoadRecipesAction());
        } else {
          store.dispatch(RecipeDeleteErrorAction('Failed to delete recipe'));
        }
      } catch (e) {
        store.dispatch(RecipeDeleteErrorAction('Error deleting recipe: $e'));
      }
    } else {
      next(action);
    }
  };
}
