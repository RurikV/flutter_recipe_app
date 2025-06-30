import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:drift/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter_recipe_app/database/app_database.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase as a singleton
  serviceLocator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // You can register other services here
}

// Helper functions to match the interface in unsupported.dart
T get<T extends Object>() {
  return serviceLocator.get<T>();
}

void registerLazySingleton<T extends Object>(T Function() function) {
  serviceLocator.registerLazySingleton<T>(function);
}

FutureOr unregister<T extends Object>({
  Object? instance,
  String? instanceName,
  FutureOr Function(T)? disposingFunction,
}) {
  return serviceLocator.unregister<T>();
}

// Helper function to create a database connection for web platforms
Future<QueryExecutor> createNativeConnection(String dbName) async {
  // For web platforms, we return a WebDatabase
  return WebDatabase(dbName);
}
