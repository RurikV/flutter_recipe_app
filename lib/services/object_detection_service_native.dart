import 'dart:async';
import 'package:get_it/get_it.dart';
import 'object_detection_service.dart';
import 'native_object_detection_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initObjectDetectionService() async {
  // Register the native implementation of the object detection service
  serviceLocator.registerLazySingleton<ObjectDetectionService>(
    () => NativeObjectDetectionService()
  );
}

// Service locator interface methods
ObjectDetectionService getObjectDetectionService() {
  return serviceLocator.get<ObjectDetectionService>();
}