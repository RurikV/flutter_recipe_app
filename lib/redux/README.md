# Redux Implementation Plan

## Overview
This document outlines the plan for implementing Redux state management in the Flutter Recipe App, replacing the current state management approach (StatefulWidget, Provider, ChangeNotifier/ValueListenable).

## Components

### 1. State
- `AppState`: Represents the entire state of the application
  - `recipes`: List of all recipes
  - `favoriteRecipes`: List of favorite recipes
  - `isLoading`: Loading state
  - `error`: Error state

### 2. Actions
- `LoadRecipesAction`: Trigger loading recipes
- `RecipesLoadedAction`: Recipes loaded successfully
- `RecipesLoadErrorAction`: Error loading recipes
- `LoadFavoriteRecipesAction`: Trigger loading favorite recipes
- `FavoriteRecipesLoadedAction`: Favorite recipes loaded successfully
- `ToggleFavoriteAction`: Toggle favorite status of a recipe
- `FavoriteToggledAction`: Favorite status toggled successfully
- `AddCommentAction`: Add a comment to a recipe
- `CommentAddedAction`: Comment added successfully
- `UpdateStepStatusAction`: Update step completion status
- `StepStatusUpdatedAction`: Step status updated successfully

### 3. Reducers
- `appReducer`: Main reducer that combines all reducers
- `recipesReducer`: Handles recipe-related actions
- `favoriteRecipesReducer`: Handles favorite recipes actions
- `loadingReducer`: Handles loading state
- `errorReducer`: Handles error state

### 4. Middleware
- `loadRecipesMiddleware`: Handles loading recipes
- `loadFavoriteRecipesMiddleware`: Handles loading favorite recipes
- `toggleFavoriteMiddleware`: Handles toggling favorite status
- `addCommentMiddleware`: Handles adding comments
- `updateStepStatusMiddleware`: Handles updating step status

## Implementation Steps

### 1. Setup Redux
- Add Redux dependencies ✓
- Create AppState class ✓
- Create actions ✓
- Create reducers ✓
- Create middleware ✓
- Create store ✓
- Provide store to app ✓

### 2. Modify RecipeDetailScreen
- Create view model to connect Redux state to UI
- Replace local state management with Redux
- Use StoreConnector to connect to Redux store
- Dispatch actions for toggling favorites, adding comments, and updating step status

### 3. Modify RecipeListScreen
- Create view model to connect Redux state to UI
- Replace local state management with Redux
- Use StoreConnector to connect to Redux store
- Display favorite status in recipe cards

### 4. Modify FavoritesScreen
- Create view model to connect Redux state to UI
- Replace local state management with Redux
- Use StoreConnector to connect to Redux store

### 5. Integrate with API and Store
- Modify middleware to use API and Store
- Save data from API to Redux store
- Save data from Redux store to Store

### 6. Testing
- Test favorite toggling
- Test recipe list display
- Test favorites screen
- Test API integration
- Test Store integration