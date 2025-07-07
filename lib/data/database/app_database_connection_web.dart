import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// Web-specific database connection
QueryExecutor createConnection() {
  // The path to the sql.js wasm file is configured in index.html via window.sqliteWasmPath
  return WasmDatabase.open(
    databaseName: 'recipes_db',
    sqlite3WasmUri: Uri.parse('sqlite3.wasm'),
  );
}
