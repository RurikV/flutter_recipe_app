import 'package:redux/redux.dart';
import 'package:flutter_recipe_app/redux/app_state.dart';
import 'package:flutter_recipe_app/redux/reducers.dart';
import 'package:flutter_recipe_app/redux/middleware.dart';

// Create the Redux store
Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createMiddleware(),
  );
}
