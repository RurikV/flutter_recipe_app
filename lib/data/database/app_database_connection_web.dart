import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// Web-specific database connection using WASM
QueryExecutor createConnection() {
  return LazyDatabase(() async {
    // Use WASM database which is more efficient than SQL.js
    return WasmDatabase.open(
      databaseName: 'recipes_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );
  });
}
