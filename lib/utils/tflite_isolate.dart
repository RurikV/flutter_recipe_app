import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class TfliteIsolate {
  @pragma('vm:entry-point')
  static Future<dynamic> runModelOnBinary(List<dynamic> args) async {
    Float32List? outputBuffer;
    Interpreter? interpreter;

    try {
      final binary = args[0] as Uint8List;
      final labelsContent = args[1] as String;
      final modelBuffer = args[2] as Uint8List;

      // Process image
      img.Image? oriImage = img.decodeImage(binary.buffer.asUint8List());
      if (oriImage == null) {
        throw Exception("Failed to decode image");
      }

      // Store original dimensions for potential use in bounding box calculations
      // These dimensions might be needed if we implement object detection with bounding boxes
      // ignore: unused_local_variable
      final originalHeight = oriImage.height;
      // ignore: unused_local_variable
      final originalWidth = oriImage.width;

      // Resize the image to 224x224 (MobileNet input size)
      img.Image resizedImage = img.copyResize(oriImage, height: 224, width: 224);

      // Prepare input data - create a properly shaped tensor [1, 224, 224, 3]
      final inputData = Float32List(1 * 224 * 224 * 3);
      int pixelIndex = 0;

      // Fill the input tensor with normalized pixel values
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Normalize to [-1, 1] range which is common for MobileNet models
          inputData[pixelIndex++] = (pixel.r / 127.5) - 1.0;
          inputData[pixelIndex++] = (pixel.g / 127.5) - 1.0;
          inputData[pixelIndex++] = (pixel.b / 127.5) - 1.0;
        }
      }

      // Load model from buffer instead of asset
      final interpreterOptions = InterpreterOptions()
        ..threads = 4; // Use multiple threads for better performance
      interpreter = Interpreter.fromBuffer(modelBuffer, options: interpreterOptions);

      // Get input and output tensor shapes
      interpreter.allocateTensors();
      final inputTensor = interpreter.getInputTensors().first;
      final outputTensor = interpreter.getOutputTensors().first;

      print('Input tensor shape: ${inputTensor.shape}');
      print('Output tensor shape: ${outputTensor.shape}');

      // Prepare output buffer based on the output tensor shape
      final outputSize = outputTensor.shape.reduce((a, b) => a * b);
      outputBuffer = Float32List(outputSize);

      try {
        // Reshape input if needed to match the expected shape
        final inputShape = inputTensor.shape;
        if (inputShape.length == 4) {
          // Model expects a 4D tensor [batch, height, width, channels]
          // Reshape our input data to match
          final reshapedInput = List.filled(1 * 224 * 224 * 3, 0.0);
          for (int i = 0; i < inputData.length; i++) {
            reshapedInput[i] = inputData[i];
          }

          // Run inference with the properly shaped input
          interpreter.run(reshapedInput, outputBuffer);
        } else {
          // Run inference with the original input
          interpreter.run(inputData, outputBuffer);
        }
      } catch (e) {
        // Check if this is the PAD operation error
        if (e.toString().contains('PAD') || e.toString().contains('failed precondition')) {
          print('Caught PAD operation error, trying alternative approach');

          try {
            // Try a completely different approach - use runForMultipleInputs
            final inputs = [inputData];
            final outputs = <int, Object>{0: outputBuffer};
            interpreter.runForMultipleInputs(inputs, outputs);
          } catch (innerError) {
            print('Alternative approach also failed: $innerError');

            // Try one more approach - reshape and use a different input format
            try {
              // Create a new interpreter with different options
              try {
                interpreter.close();
              } catch (closeError) {
                print('Error closing interpreter: $closeError');
              }

              final newOptions = InterpreterOptions()..threads = 1;
              interpreter = Interpreter.fromBuffer(modelBuffer, options: newOptions);
              interpreter.allocateTensors();

              // Try with a different normalization
              final newInput = Float32List(1 * 224 * 224 * 3);
              pixelIndex = 0;
              for (var y = 0; y < 224; y++) {
                for (var x = 0; x < 224; x++) {
                  final pixel = resizedImage.getPixel(x, y);
                  // Try with a different normalization (0-1 range)
                  newInput[pixelIndex++] = pixel.r / 255.0;
                  newInput[pixelIndex++] = pixel.g / 255.0;
                  newInput[pixelIndex++] = pixel.b / 255.0;
                }
              }

              // Run with the new input
              interpreter.run(newInput, outputBuffer);
            } catch (finalError) {
              print('Second approach failed: $finalError');

              // Try a third approach - use a completely different input format
              try {
                // Close the previous interpreter if it exists
                if (interpreter != null) {
                  try {
                    interpreter.close();
                  } catch (closeError) {
                    print('Error closing interpreter: $closeError');
                  }
                }

                // Create a new interpreter with default options
                interpreter = Interpreter.fromBuffer(modelBuffer);
                interpreter.allocateTensors();

                // Get the exact input shape the model expects
                final inputTensor = interpreter.getInputTensors().first;
                final inputShape = inputTensor.shape;
                print('Third attempt - Input tensor shape: $inputShape');

                // Create input data with the exact shape the model expects
                final inputSize = inputShape.reduce((a, b) => a * b);
                final finalInput = Float32List(inputSize);

                // If the model expects a 4D tensor [1, height, width, channels]
                if (inputShape.length == 4) {
                  final height = inputShape[1];
                  final width = inputShape[2];
                  final channels = inputShape[3];

                  // Resize image to match the expected dimensions
                  final finalResizedImage = img.copyResize(
                    oriImage,
                    height: height,
                    width: width,
                  );

                  // Fill the input tensor with normalized pixel values
                  pixelIndex = 0;
                  for (var y = 0; y < height; y++) {
                    for (var x = 0; x < width; x++) {
                      final pixel = finalResizedImage.getPixel(x, y);
                      // Try both normalization methods
                      if (channels == 3) {
                        // RGB format
                        finalInput[pixelIndex++] = (pixel.r / 127.5) - 1.0;
                        finalInput[pixelIndex++] = (pixel.g / 127.5) - 1.0;
                        finalInput[pixelIndex++] = (pixel.b / 127.5) - 1.0;
                      } else if (channels == 1) {
                        // Grayscale format
                        final gray = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
                        finalInput[pixelIndex++] = gray;
                      }
                    }
                  }
                } else {
                  // Just copy the existing data from inputData
                  for (int i = 0; i < math.min(inputData.length, finalInput.length); i++) {
                    finalInput[i] = inputData[i];
                  }
                }

                // Get output tensor shape
                final outputTensor = interpreter.getOutputTensors().first;
                final outputShape = outputTensor.shape;
                print('Third attempt - Output tensor shape: $outputShape');

                // Create a new output buffer with the correct size
                final newOutputSize = outputShape.reduce((a, b) => a * b);
                final newOutputBuffer = Float32List(newOutputSize);

                // Run inference with the final input
                interpreter.run(finalInput, newOutputBuffer);

                // Copy results to the original output buffer if sizes match
                if (newOutputBuffer.length == outputBuffer.length) {
                  for (int i = 0; i < newOutputBuffer.length; i++) {
                    outputBuffer[i] = newOutputBuffer[i];
                  }
                } else {
                  // If sizes don't match, just use the new output buffer
                  outputBuffer = newOutputBuffer;
                }
              } catch (thirdError) {
                print('All approaches failed: $thirdError');
                rethrow;
              }
            }
          }
        } else {
          // Rethrow other errors
          rethrow;
        }
      }

      // Parse labels from the content
      final labels = labelsContent.split('\n');

      // Process results
      var results = <Map<String, dynamic>>[];

      // Find the top result
      var maxScore = 0.0;
      var maxIndex = 0;

      // Log the output buffer for debugging
      print('Output buffer length: ${outputBuffer.length}');
      if (outputBuffer.isNotEmpty) {
        print('First few values: ${outputBuffer.sublist(0, math.min(5, outputBuffer.length))}');
      }

      for (var i = 0; i < outputBuffer.length; i++) {
        var score = outputBuffer[i];
        if (score > maxScore) {
          maxScore = score;
          maxIndex = i;
        }
      }

      // Create result object similar to tflite format
      var result = {
        'index': maxIndex,
        'label': maxIndex < labels.length ? labels[maxIndex] : 'Unknown',
        'confidence': maxScore,
      };

      results.add(result);

      // Log the result for debugging
      print('Detection result: $result');

      // Clean up
      try {
        interpreter.close();
      } catch (closeError) {
        print('Error closing interpreter: $closeError');
      }

      return json.encode(results[0]);
    } catch (e) {
      // Clean up resources if interpreter was created
      if (interpreter != null) {
        try {
          interpreter.close();
        } catch (closeError) {
          print('Error closing interpreter: $closeError');
        }
      }

      final errorMessage = 'TfliteIsolate error: $e';
      print(errorMessage);

      // Try to provide a more user-friendly error message
      String userMessage = 'Не распознал фото';
      if (e.toString().contains('PAD') || e.toString().contains('failed precondition')) {
        userMessage = 'Не удалось распознать объект на фото (ошибка модели)';
      } else if (e.toString().contains('decode')) {
        userMessage = 'Не удалось обработать изображение';
      }

      // Return a valid JSON object with error information
      return json.encode({
        'index': -1,
        'label': userMessage,
        'confidence': 0.0,
        'error': errorMessage,
      });
    }
  }

  static Float32List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    // Create a buffer for the normalized pixel values
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);

    int pixelIndex = 0;
    try {
      // Process each pixel in the image
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          // Get the pixel at (x, y)
          final pixel = image.getPixel(x, y);

          // Try the normalization method that works best for the model
          // For MobileNet V1, normalizing to [-1, 1] is common
          buffer[pixelIndex++] = (pixel.r / 127.5) - 1.0;
          buffer[pixelIndex++] = (pixel.g / 127.5) - 1.0;
          buffer[pixelIndex++] = (pixel.b / 127.5) - 1.0;
        }
      }
    } catch (e) {
      print('Error processing image: $e');
      // If there's an error, ensure we return a valid buffer
      // Fill the rest of the buffer with zeros if needed
      while (pixelIndex < convertedBytes.length) {
        buffer[pixelIndex++] = 0.0;
      }
    }

    return convertedBytes;
  }
}
