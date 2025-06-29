import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class TfliteIsolate {
  @pragma('vm:entry-point')
  static Future<dynamic> runModelOnBinary(List<dynamic> args) async {
    try {
      final binary = args[0] as Uint8List;
      final labelsContent = args[1] as String;
      final modelBuffer = args[2] as Uint8List;

      // Process image
      img.Image? oriImage = img.decodeImage(binary.buffer.asUint8List());
      img.Image? resizedImage =
          img.copyResize(oriImage!, height: 224, width: 224);

      // Prepare input data
      final inputData = imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);

      // Load model from buffer instead of asset
      final interpreter = await Interpreter.fromBuffer(modelBuffer);

      // Allocate tensors
      final inputTensor = interpreter.getInputTensors().first;
      final outputTensor = interpreter.getOutputTensors().first;

      // Prepare input and output buffers
      final inputBuffer = inputData;
      final outputBuffer = Float32List(outputTensor.shape.reduce((a, b) => a * b));

      // Run inference
      interpreter.run(inputBuffer, outputBuffer);

      // Parse labels from the content
      final labels = labelsContent.split('\n');

      // Process results
      var results = <Map<String, dynamic>>[];

      // Find the top result
      var maxScore = 0.0;
      var maxIndex = 0;

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

      // Clean up
      interpreter.close();

      return json.encode(results[0]);
    } catch (e) {
      final errorMessage = 'TfliteIsolate error: $e';
      print(errorMessage);
      // Return a valid JSON object with error information
      return json.encode({
        'index': -1,
        'label': 'Не распознал фото: $e',
        'confidence': 0.0,
        'error': errorMessage,
      });
    }
  }

  static Float32List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r.toDouble() - mean) / std;
        buffer[pixelIndex++] = (pixel.g.toDouble() - mean) / std;
        buffer[pixelIndex++] = (pixel.b.toDouble() - mean) / std;
      }
    }
    return convertedBytes;
  }
}
