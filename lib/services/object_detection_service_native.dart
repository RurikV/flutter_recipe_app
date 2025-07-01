import 'dart:async';
import 'package:get_it/get_it.dart';
import 'object_detection_service.dart';
import 'isolate_object_detection_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initObjectDetectionService() async {
  // Register the isolate implementation of the object detection service
  serviceLocator.registerLazySingleton<ObjectDetectionService>(
    () => IsolateObjectDetectionService()
  );
}

// Service locator interface methods
ObjectDetectionService getObjectDetectionService() {
  return serviceLocator.get<ObjectDetectionService>();
}
