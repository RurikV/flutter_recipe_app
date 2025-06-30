import 'package:drift/drift.dart';
import 'package:drift/web.dart';

// Web-specific database connection
QueryExecutor createConnection() {
  return WebStorage('recipes_db');
}
