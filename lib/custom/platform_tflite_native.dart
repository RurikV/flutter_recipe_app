// Native implementation of TensorFlow Lite functionality for non-web platforms
// This file is only imported on non-web platforms

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Re-export the TensorFlow Lite classes that are used in the project
export 'package:tflite_flutter/tflite_flutter.dart';

// If there are any custom implementations or extensions, they can be added here