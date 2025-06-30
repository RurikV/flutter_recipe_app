// Empty implementation for web platform
// This file is used when dart.library.html is available (web platform)
// It provides empty implementations that don't use dart:ffi

// Export the dummy classes
export 'tflite_flutter_web.dart';

// Define a dummy Interpreter class that matches the interface of the real one
class Interpreter {
  static Future<Interpreter> fromAsset(String assetName, {dynamic options}) async {
    return Interpreter._();
  }

  static Future<Interpreter> fromBuffer(List<int> buffer, {dynamic options}) async {
    return Interpreter._();
  }

  Interpreter._();

  void close() {}

  void allocateTensors() {}

  void invoke() {}

  void run(Object input, Object output) {}

  void runForMultipleInputs(List<Object> inputs, Map<int, Object> outputs) {}

  // Add dummy getOutputTensor method for web
  Tensor getOutputTensor(int index) {
    return Tensor();
  }

  // Add dummy getOutputTensors method for web
  List<Tensor> getOutputTensors() {
    return [Tensor()];
  }

  // Add dummy getInputTensor method for web
  Tensor getInputTensor(int index) {
    return Tensor();
  }

  // Add dummy getInputTensors method for web
  List<Tensor> getInputTensors() {
    return [Tensor()];
  }

  // Add dummy resizeInputTensor method for web
  void resizeInputTensor(int tensorIndex, List<int> shape) {}
}

// Define a dummy Tensor class
class Tensor {
  Tensor();

  List<int> get shape => [1, 1, 1, 1]; // Return a dummy shape
}

// Define a dummy InterpreterOptions class
class InterpreterOptions {
  InterpreterOptions();
}
