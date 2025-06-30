import 'package:flutter/foundation.dart' show kIsWeb;

// This file provides a platform-specific implementation of TensorFlow Lite functionality
// It conditionally imports and uses TensorFlow Lite only on non-web platforms

// For non-web platforms, we'll use the actual TensorFlow Lite implementation
// For web platforms, we'll provide stub implementations that don't use dart:ffi

// Import the appropriate implementation based on the platform
import 'platform_tflite_stub.dart' if (dart.library.io) 'platform_tflite_native.dart' as tfl;

// Re-export the classes from the appropriate implementation
export 'package:tflite_flutter/tflite_flutter.dart' hide Interpreter, Tensor, TensorType;
export 'platform_tflite_stub.dart' if (dart.library.io) 'platform_tflite_native.dart';
