// Conditionally import dart:io only for non-web platforms
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// This file handles platform-specific database connections

/// Opens a database connection that works on all platforms
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Use WebDatabase for web platform
      return WebDatabase('recipes_db');
    } else {
      // Use NativeDatabase for mobile/desktop platforms
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = io.File(p.join(dbFolder.path, 'recipes.sqlite'));
      return NativeDatabase(file);
    }
  });
}
