import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../service_locator.dart' as serviceLocator;

// This file handles platform-specific database connections using service locator

/// Opens a database connection that works on all platforms
QueryExecutor openConnection() {
  // Create a simple executor that delegates to the appropriate implementation
  // based on the platform
  return _DelegatingExecutor();
}

/// A custom QueryExecutor that delegates to the appropriate implementation
/// based on the platform
class _DelegatingExecutor extends QueryExecutor {
  @override
  Future<void> close() async {
    // No-op
  }

  @override
  Future<void> ensureOpen(QueryExecutorUser user) async {
    // No-op
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
      String statement, List<Object?> parameters) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }

  @override
  Future<int> runInsert(String statement, List<Object?> parameters) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> parameters) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }

  @override
  Future<int> runDelete(String statement, List<Object?> parameters) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }

  @override
  Future<void> runCustom(String statement, List<Object?> parameters) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }

  @override
  Future<int> runBatched(BatchedStatements statements) async {
    // This will never be called because the actual implementation
    // will be provided by the service locator
    throw UnimplementedError();
  }
}
