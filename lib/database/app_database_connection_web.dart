import 'package:drift/drift.dart';
import 'package:drift/web.dart';

// Web-specific database connection
QueryExecutor createConnection() {
  // The path to the sql.js wasm file is configured in index.html via window.sqliteWasmPath
  return WebDatabase(
    'recipes_db',
  );
}
