// Use conditional exports to provide the appropriate implementation based on the platform
export 'unsupported.dart'
    if (dart.library.ffi) 'object_detection_service_native_locator.dart'
    if (dart.library.html) 'object_detection_service_web_locator.dart';
