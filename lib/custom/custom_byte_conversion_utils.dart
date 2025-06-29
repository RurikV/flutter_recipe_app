import 'dart:typed_data';
import 'byte_conversion_utils.dart' as utils;
import 'tensor.dart';

/// This class is an alias for ByteConversionUtils to maintain compatibility
class CustomByteConversionUtils {
  static Uint8List convertObjectToBytes(Object o, TensorType tensorType) {
    // Convert from tensor.dart TensorType to byte_conversion_utils.dart TensorType
    utils.TensorType convertedType = utils.TensorType.values.firstWhere(
      (t) => t.value == tensorType.value,
      orElse: () => utils.TensorType.noType,
    );
    return utils.ByteConversionUtils.convertObjectToBytes(o, convertedType);
  }

  static Object convertBytesToObject(
      Uint8List bytes, TensorType tensorType, List<int> shape) {
    // Convert from tensor.dart TensorType to byte_conversion_utils.dart TensorType
    utils.TensorType convertedType = utils.TensorType.values.firstWhere(
      (t) => t.value == tensorType.value,
      orElse: () => utils.TensorType.noType,
    );
    return utils.ByteConversionUtils.convertBytesToObject(bytes, convertedType, shape);
  }
}
