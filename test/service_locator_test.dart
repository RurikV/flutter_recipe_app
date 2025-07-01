import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_recipe_app/database/app_database.dart';
import 'package:flutter_recipe_app/services/object_detection_service.dart';
import 'package:flutter_recipe_app/services/isolate_object_detection_service.dart';

final GetIt getIt = GetIt.instance;

/// Initialize the service locator for tests
void initializeTestServiceLocator() {
  // Reset the service locator if it's already been initialized
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }

  if (getIt.isRegistered<ObjectDetectionService>()) {
    getIt.unregister<ObjectDetectionService>();
  }

  // Register the AppDatabase
  final appDatabase = AppDatabase();
  getIt.registerSingleton<AppDatabase>(appDatabase);

  // Register the ObjectDetectionService with a mock implementation for tests
  getIt.registerSingleton<ObjectDetectionService>(
    IsolateObjectDetectionService(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Locator Tests', () {
    test('Initialize test service locator', () {
      // Initialize the service locator
      initializeTestServiceLocator();

      // Verify that the service locator has been initialized
      expect(getIt.isRegistered<AppDatabase>(), isTrue);
      expect(getIt.isRegistered<ObjectDetectionService>(), isTrue);
    });
  });
}
