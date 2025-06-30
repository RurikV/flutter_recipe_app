import 'package:flutter/foundation.dart' show kIsWeb;

// This file provides a platform-specific implementation of TensorFlow Lite functionality
// It conditionally imports and uses TensorFlow Lite only on non-web platforms

// For non-web platforms, we'll use the actual TensorFlow Lite implementation
// For web platforms, we'll provide stub implementations that don't use dart:ffi

// Export the appropriate implementation based on the platform
export 'platform_tflite_stub.dart' if (dart.library.io) 'platform_tflite_native.dart';