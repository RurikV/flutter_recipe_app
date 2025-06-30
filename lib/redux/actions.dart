// Authentication actions
class LoginAction {
  final String username;
  final String password;

  LoginAction(this.username, this.password);
}

class LoginSuccessAction {
  final dynamic user;

  LoginSuccessAction(this.user);
}

class LoginErrorAction {
  final String error;

  LoginErrorAction(this.error);
}

class RegisterAction {
  final String username;
  final String email;
  final String password;

  RegisterAction(this.username, this.email, this.password);
}

class RegisterSuccessAction {
  final dynamic user;

  RegisterSuccessAction(this.user);
}

class RegisterErrorAction {
  final String error;

  RegisterErrorAction(this.error);
}

class LogoutAction {}

class CheckAuthStatusAction {}

// Recipe actions
class LoadRecipesAction {}

class RecipesLoadedAction {
  final List<dynamic> recipes;

  RecipesLoadedAction(this.recipes);
}

class RecipesLoadErrorAction {
  final String error;

  RecipesLoadErrorAction(this.error);
}

class LoadFavoriteRecipesAction {}

class FavoriteRecipesLoadedAction {
  final List<dynamic> favoriteRecipes;

  FavoriteRecipesLoadedAction(this.favoriteRecipes);
}

class ToggleFavoriteAction {
  final String recipeId;

  ToggleFavoriteAction(this.recipeId);
}

class FavoriteToggledAction {
  final String recipeId;
  final bool isFavorite;

  FavoriteToggledAction(this.recipeId, this.isFavorite);
}

class AddCommentAction {
  final String recipeId;
  final String commentText;

  AddCommentAction(this.recipeId, this.commentText);
}

class CommentAddedAction {
  final String recipeId;
  final dynamic comment;

  CommentAddedAction(this.recipeId, this.comment);
}

class UpdateStepStatusAction {
  final String recipeId;
  final int stepIndex;
  final bool isCompleted;

  UpdateStepStatusAction(this.recipeId, this.stepIndex, this.isCompleted);
}

class StepStatusUpdatedAction {
  final String recipeId;
  final int stepIndex;
  final bool isCompleted;

  StepStatusUpdatedAction(this.recipeId, this.stepIndex, this.isCompleted);
}
