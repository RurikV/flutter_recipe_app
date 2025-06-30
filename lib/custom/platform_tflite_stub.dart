// Stub implementation of TensorFlow Lite functionality for web platforms
// This file is only imported on web platforms and provides stub implementations
// that don't use dart:ffi

import 'dart:typed_data';
import 'package:flutter/services.dart';

// Stub implementation of Interpreter
class Interpreter {
  bool _deleted = false;
  bool _allocated = false;

  Interpreter._();

  // Factory methods that return a stub implementation
  factory Interpreter.fromFile(dynamic modelFile, {InterpreterOptions? options}) {
    return Interpreter._();
  }

  factory Interpreter.fromBuffer(Uint8List buffer, {InterpreterOptions? options}) {
    return Interpreter._();
  }

  static Future<Interpreter> fromAsset(String assetName, {InterpreterOptions? options}) async {
    return Interpreter._();
  }

  factory Interpreter.fromAddress(int address, {bool allocated = false, bool deleted = false}) {
    return Interpreter._();
  }

  void close() {
    _deleted = true;
  }

  void allocateTensors() {
    _allocated = true;
  }

  void invoke() {
    // No-op on web
  }

  void run(Object input, Object output) {
    // No-op on web
  }

  void runForMultipleInputs(List<Object> inputs, Map<int, Object> outputs) {
    // No-op on web
  }

  List<Tensor> getInputTensors() {
    return [];
  }

  List<Tensor> getOutputTensors() {
    return [];
  }

  Tensor getInputTensor(int index) {
    return Tensor._();
  }

  Tensor getOutputTensor(int index) {
    return Tensor._();
  }

  int getInputIndex(String opName) {
    return 0;
  }

  int getOutputIndex(String opName) {
    return 0;
  }

  void resetVariableTensors() {
    // No-op on web
  }

  int get address => 0;
  bool get isAllocated => _allocated;
  bool get isDeleted => _deleted;
}

// Stub implementation of Tensor
class Tensor {
  Tensor._();

  String get name => '';
  TensorType get type => TensorType.noType;
  List<int> get shape => [];
  Uint8List get data => Uint8List(0);

  set data(Uint8List bytes) {
    // No-op on web
  }

  int numDimensions() => 0;
  int numBytes() => 0;
  int numElements() => 0;

  void setTo(Object src) {
    // No-op on web
  }

  Object copyTo(Object dst) {
    return dst;
  }

  List<int>? getInputShapeIfDifferent(Object? input) {
    return null;
  }
}

// Stub implementation of InterpreterOptions
class InterpreterOptions {
  InterpreterOptions();

  void setNumThreads(int numThreads) {
    // No-op on web
  }

  void useNnApiForAndroid(bool useNnapi) {
    // No-op on web
  }

  void useMetalDelegateForIOS(bool useMetal) {
    // No-op on web
  }

  void addDelegate(Delegate delegate) {
    // No-op on web
  }
}

// Stub implementation of Delegate
abstract class Delegate {
  void delete();
}

// Stub implementation of TensorType
enum TensorType {
  noType,
  float32,
  int32,
  uint8,
  int64,
  string,
  boolean,
  int16,
  complex64,
  int8,
  float16,
  float64,
  complex128,
  uint64,
  resource,
  variant,
  uint32,
  uint16,
  int4
}