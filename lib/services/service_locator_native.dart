import 'dart:async';
import 'package:get_it/get_it.dart';

// Local database has been removed for performance optimization.
// App now uses API with caching instead of local database.

final GetIt serviceLocator = GetIt.instance;

Future<void> initLocator() async {
  // Database registration removed - app now uses API with caching instead of local database
}

// Service locator interface methods
T get<T extends Object>() {
  return serviceLocator.get<T>();
}

void registerLazySingleton<T extends Object>(T Function() function) {
  serviceLocator.registerLazySingleton<T>(function);
}

FutureOr unregister<T extends Object>() {
  return serviceLocator.unregister<T>();
}
