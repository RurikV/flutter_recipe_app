import 'package:drift/drift.dart';
import 'package:drift/web.dart';

// Web-specific database connection using SQL.js
QueryExecutor createConnection() {
  return LazyDatabase(() async {
    // Use SQL.js which is configured in index.html
    return WebDatabase('recipes_db');
  });
}
