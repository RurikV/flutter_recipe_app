// Conditional exports for TensorFlow Lite
// This file uses conditional exports to provide the appropriate implementation based on the platform

// If dart.library.html is available (web platform), use the web implementation
// Otherwise, use the native implementation
export 'tflite_flutter_web.dart' if (dart.library.ffi) 'tflite_flutter.dart';