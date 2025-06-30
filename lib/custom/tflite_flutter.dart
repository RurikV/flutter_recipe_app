library;

// Import platform-specific TensorFlow Lite implementation
// This will use the stub implementation on web platforms
// and the actual implementation on non-web platforms
import 'platform_tflite.dart';

// Re-export the platform-specific implementation
export 'platform_tflite.dart';

// Export our custom implementations
// These are now conditionally imported based on the platform
export 'interpreter.dart' if (dart.library.html) 'platform_tflite_stub.dart';
export 'tensor.dart' if (dart.library.html) 'platform_tflite_stub.dart';
