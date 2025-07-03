import 'dart:async';
import 'package:get_it/get_it.dart';
import '../data/database/app_database.dart';

// Use web-specific implementation to avoid ffi on web

final GetIt serviceLocator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase with web-specific implementation
  // The platform-specific implementation is handled by conditional imports in app_database.dart
  serviceLocator.registerSingleton<AppDatabase>(AppDatabase());
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
