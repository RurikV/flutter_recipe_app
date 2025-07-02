import 'dart:async';
import 'package:get_it/get_it.dart';
import '../database/app_database.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase with native database implementation
  serviceLocator.registerLazySingleton<AppDatabase>(
    () => AppDatabase()
  );
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
