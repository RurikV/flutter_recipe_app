import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
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

// Helper function to create a database connection for native platforms
Future<QueryExecutor> createNativeConnection(String dbName) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, dbName));
  return NativeDatabase(file);
}
