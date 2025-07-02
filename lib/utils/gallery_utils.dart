import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Future<String?> pickImageFromGallery() async {
    final XFile? imgFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imgFile == null) return null;

    final Uint8List bytes = await imgFile.readAsBytes();
    return base64Encode(bytes);
  }
}

class TfliteDto {
  double? confidence;
  int? index;
  String? label;

  TfliteDto({this.confidence, this.index, this.label});

  TfliteDto.fromJson(Map<String, dynamic> json) {
    try {
      confidence = json['confidence'] as double?;
      index = json['index'] as int?;
      label = json['label'] as String?;
    } catch (e) {
      print('Error parsing TfliteDto from JSON: $e');
      confidence = 0.0;
      index = -1;
      label = 'Error: $e';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['confidence'] = confidence;
    data['index'] = index;
    data['label'] = label;
    return data;
  }

  @override
  String toString() {
    try {
      if (confidence == null || label == null) {
        return 'Unknown object';
      }
      return '$label (${(confidence! * 100.0).toStringAsFixed(2)}%)';
    } catch (e) {
      print('Error in TfliteDto.toString(): $e');
      return 'Error: $e';
    }
  }
}
