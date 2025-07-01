// Use conditional exports to provide the appropriate implementation based on the platform
export 'unsupported.dart'
    if (dart.library.ffi) 'service_locator_native.dart'
    if (dart.library.html) 'service_locator_web.dart';
