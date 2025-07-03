// Use conditional exports to provide the appropriate implementation based on the platform
export 'classification/object_detection_service_native.dart'
    if (dart.library.html) 'classification/object_detection_service_web.dart';