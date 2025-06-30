library tflite_flutter;

// This file is a facade for TensorFlow Lite functionality
// It provides a unified API for both web and non-web platforms

// For web platforms, we use stub implementations
// For non-web platforms, we use the actual TensorFlow Lite implementation

// Only export the platform-specific implementation
// This ensures that only one implementation is used
export 'platform_tflite.dart';
