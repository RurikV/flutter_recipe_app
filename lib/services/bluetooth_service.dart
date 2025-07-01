import 'dart:async';
import '../plugins/bluetooth_le_scanner/bluetooth_le_scanner.dart';

/// A service class for interacting with Bluetooth LE devices.
class BluetoothService {
  /// Stream of BLE device scan results
  Stream<List<BluetoothDevice>> get scanResults => BluetoothLeScanner.scanResults;
  
  /// Flag to track if scanning is in progress
  bool _isScanning = false;
  
  /// Get the current scanning status
  bool get isScanning => _isScanning;
  
  /// Initialize the Bluetooth service
  Future<void> initialize() async {
    try {
      await BluetoothLeScanner.initialize();
    } catch (e) {
      print('Error initializing Bluetooth service: $e');
      rethrow;
    }
  }
  
  /// Start scanning for Bluetooth LE devices
  Future<bool> startScan() async {
    if (_isScanning) {
      return true; // Already scanning
    }
    
    try {
      final bool result = await BluetoothLeScanner.startScan();
      _isScanning = result;
      return result;
    } catch (e) {
      print('Error starting BLE scan: $e');
      _isScanning = false;
      return false;
    }
  }
  
  /// Stop scanning for Bluetooth LE devices
  Future<bool> stopScan() async {
    if (!_isScanning) {
      return true; // Already stopped
    }
    
    try {
      final bool result = await BluetoothLeScanner.stopScan();
      _isScanning = !result;
      return result;
    } catch (e) {
      print('Error stopping BLE scan: $e');
      return false;
    }
  }
  
  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await BluetoothLeScanner.isBluetoothEnabled();
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      return false;
    }
  }
  
  /// Request to enable Bluetooth
  Future<bool> requestBluetoothEnable() async {
    try {
      return await BluetoothLeScanner.requestBluetoothEnable();
    } catch (e) {
      print('Error requesting Bluetooth enable: $e');
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopScan();
    BluetoothLeScanner.dispose();
  }
}