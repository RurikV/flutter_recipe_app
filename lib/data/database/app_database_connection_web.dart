import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// Web-specific database connection
QueryExecutor createConnection() {
  return LazyDatabase(() async {
    // The path to the sql.js wasm file is configured in index.html via window.sqliteWasmPath
    final result = await WasmDatabase.open(
      databaseName: 'recipes_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
