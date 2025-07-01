import 'dart:async';
import 'package:flutter/services.dart';

/// A class that provides methods to scan for Bluetooth LE devices.
class BluetoothLeScanner {
  static const MethodChannel _channel = MethodChannel('com.recipe_app/bluetooth_le_scanner');
  
  /// Stream controller for BLE device scan results
  static final StreamController<List<BluetoothDevice>> _scanResultsController = 
      StreamController<List<BluetoothDevice>>.broadcast();
  
  /// Stream of BLE device scan results
  static Stream<List<BluetoothDevice>> get scanResults => _scanResultsController.stream;
  
  /// Initialize the plugin and set up method call handler
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('initialize');
  }
  
  /// Start scanning for Bluetooth LE devices
  static Future<bool> startScan() async {
    try {
      final bool result = await _channel.invokeMethod('startScan');
      return result;
    } on PlatformException catch (e) {
      print('Error starting BLE scan: ${e.message}');
      return false;
    }
  }
  
  /// Stop scanning for Bluetooth LE devices
  static Future<bool> stopScan() async {
    try {
      final bool result = await _channel.invokeMethod('stopScan');
      return result;
    } on PlatformException catch (e) {
      print('Error stopping BLE scan: ${e.message}');
      return false;
    }
  }
  
  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isBluetoothEnabled');
      return result;
    } on PlatformException catch (e) {
      print('Error checking Bluetooth status: ${e.message}');
      return false;
    }
  }
  
  /// Request to enable Bluetooth
  static Future<bool> requestBluetoothEnable() async {
    try {
      final bool result = await _channel.invokeMethod('requestBluetoothEnable');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting Bluetooth enable: ${e.message}');
      return false;
    }
  }
  
  /// Handle method calls from the native side
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onScanResult':
        final List<dynamic> devicesData = call.arguments as List<dynamic>;
        final List<BluetoothDevice> devices = devicesData
            .map((dynamic data) => BluetoothDevice.fromMap(data as Map<dynamic, dynamic>))
            .toList();
        _scanResultsController.add(devices);
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }
  
  /// Dispose resources
  static void dispose() {
    _scanResultsController.close();
  }
}

/// A class representing a Bluetooth LE device.
class BluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  
  BluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
  
  /// Create a BluetoothDevice from a map
  factory BluetoothDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothDevice(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Unknown Device',
      rssi: map['rssi'] as int? ?? 0,
    );
  }
  
  @override
  String toString() {
    return 'BluetoothDevice{id: $id, name: $name, rssi: $rssi}';
  }
}