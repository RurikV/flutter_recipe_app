import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import our platform-specific implementation
import 'platform_tflite.dart';
import '../custom/list_shape_extension.dart';

// Define TensorType enum to match the one in tensor.dart
enum TensorType {
  noType(TfLiteType.kTfLiteNoType),
  float32(TfLiteType.kTfLiteFloat32),
  int32(TfLiteType.kTfLiteInt32),
  uint8(TfLiteType.kTfLiteUInt8),
  int64(TfLiteType.kTfLiteInt64),
  string(TfLiteType.kTfLiteString),
  boolean(TfLiteType.kTfLiteBool),
  int16(TfLiteType.kTfLiteInt16),
  complex64(TfLiteType.kTfLiteComplex64),
  int8(TfLiteType.kTfLiteInt8),
  float16(TfLiteType.kTfLiteFloat16),
  float64(TfLiteType.kTfLiteFloat64),
  complex128(TfLiteType.kTfLiteComplex128),
  uint64(TfLiteType.kTfLiteUInt64),
  resource(TfLiteType.kTfLiteResource),
  variant(TfLiteType.kTfLiteVariant),
  uint32(TfLiteType.kTfLiteUInt32),
  uint16(TfLiteType.kTfLiteUInt16),
  int4(TfLiteType.kTfLiteInt4);

  const TensorType(this.value);
  final int value;
}

class ByteConversionError extends ArgumentError {
  ByteConversionError({
    required this.input,
    required this.tensorType,
  }) : super(
          'The input element is ${input.runtimeType} while tensor data type is $tensorType',
        );

  final Object input;
  final TensorType tensorType;
}

class ByteConversionUtils {
  static Uint8List convertObjectToBytes(Object o, TensorType tensorType) {
    if (o is Uint8List) {
      return o;
    }
    if (o is ByteBuffer) {
      return o.asUint8List();
    }
    List<int> bytes = <int>[];
    if (o is List) {
      for (var e in o) {
        bytes.addAll(convertObjectToBytes(e, tensorType));
      }
    } else {
      return _convertElementToBytes(o, tensorType);
    }
    return Uint8List.fromList(bytes);
  }

  static Uint8List _convertElementToBytes(Object o, TensorType tensorType) {
    // Float32
    if (tensorType.value == TfLiteType.kTfLiteFloat32) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List();
      }
      if (o is int) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o.toDouble(), Endian.little);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Uint8
    if (tensorType.value == TfLiteType.kTfLiteUInt8) {
      if (o is int) {
        var buffer = Uint8List(1).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setUint8(0, o);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Int32
    if (tensorType.value == TfLiteType.kTfLiteInt32) {
      if (o is int) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt32(0, o, Endian.little);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Int64
    if (tensorType.value == TfLiteType.kTfLiteInt64) {
      if (o is int) {
        var buffer = Uint8List(8).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt64(0, o, Endian.big);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Int16
    if (tensorType.value == TfLiteType.kTfLiteInt16) {
      if (o is int) {
        var buffer = Uint8List(2).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt16(0, o, Endian.little);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Float16
    if (tensorType.value == TfLiteType.kTfLiteFloat16) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List().sublist(0, 2);
      }
      if (o is int) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o.toDouble(), Endian.little);
        return buffer.asUint8List().sublist(0, 2);
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    // Int8
    if (tensorType.value == TfLiteType.kTfLiteInt8) {
      if (o is int) {
        var buffer = Uint8List(1).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt8(0, o);
        return buffer.asUint8List();
      }
      throw ByteConversionError(
        input: o,
        tensorType: tensorType,
      );
    }

    throw ArgumentError(
      'The input data tfliteType ${o.runtimeType} is unsupported',
    );
  }

  static Object convertBytesToObject(
      Uint8List bytes, TensorType tensorType, List<int> shape) {
    // stores flattened data
    List<dynamic> list = [];
    if (tensorType.value == TfLiteType.kTfLiteInt32) {
      for (var i = 0; i < bytes.length; i += 4) {
        list.add(ByteData.view(bytes.buffer).getInt32(i, Endian.little));
      }
      return list.reshape<int>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteFloat32) {
      for (var i = 0; i < bytes.length; i += 4) {
        list.add(ByteData.view(bytes.buffer).getFloat32(i, Endian.little));
      }
      return list.reshape<double>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteInt16) {
      for (var i = 0; i < bytes.length; i += 2) {
        list.add(ByteData.view(bytes.buffer).getInt16(i, Endian.little));
      }
      return list.reshape<int>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteFloat16) {
      Uint8List list32 = Uint8List(bytes.length * 2);
      for (var i = 0; i < bytes.length; i += 2) {
        list32[i] = bytes[i];
        list32[i + 1] = bytes[i + 1];
      }
      for (var i = 0; i < list32.length; i += 4) {
        list.add(ByteData.view(list32.buffer).getFloat32(i, Endian.little));
      }
      return list.reshape<double>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteInt8) {
      for (var i = 0; i < bytes.length; i += 1) {
        list.add(ByteData.view(bytes.buffer).getInt8(i));
      }
      return list.reshape<int>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteUInt8) {
      for (var i = 0; i < bytes.length; i += 1) {
        list.add(ByteData.view(bytes.buffer).getUint8(i));
      }
      return list.reshape<int>(shape);
    } else if (tensorType.value == TfLiteType.kTfLiteInt64) {
      for (var i = 0; i < bytes.length; i += 8) {
        list.add(ByteData.view(bytes.buffer).getInt64(i));
      }
      return list.reshape<int>(shape);
    }
    throw UnsupportedError("$tensorType is not Supported.");
  }
}
