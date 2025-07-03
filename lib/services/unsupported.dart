import 'dart:async';

// This file is used when neither dart:ffi nor dart:html is available
// It provides stub implementations that throw UnimplementedError

// Forward declaration of the ObjectDetectionService interface
abstract class ObjectDetectionService {
  Future<void> initialize();
  Future<List<dynamic>> detectObjects(dynamic image);
  bool get isInitialized;
}

Future<void> initObjectDetectionService() async {
  throw UnimplementedError('Object detection service is not supported on this platform');
}

ObjectDetectionService getObjectDetectionService() {
  throw UnimplementedError('Object detection service is not supported on this platform');
}

// Service locator interface methods
T get<T extends Object>() {
  throw UnimplementedError('Service locator is not supported on this platform');
}

Future<void> initLocator() async {
  throw UnimplementedError('Service locator is not supported on this platform');
}

void registerLazySingleton<T extends Object>(T Function() function) {
  throw UnimplementedError('Service locator is not supported on this platform');
}

FutureOr unregister<T extends Object>() {
  throw UnimplementedError('Service locator is not supported on this platform');
}