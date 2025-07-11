import 'package:redux/redux.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/reducers.dart';
import 'package:recipe_master/redux/middleware.dart';

// Create the Redux store
Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createMiddleware(),
  );
}
