import 'dart:async';
import 'package:flutter/services.dart';
import '../plugins/bluetooth_le_scanner/bluetooth_le_scanner.dart';

/// Result class for scan operations
class ScanResult {
  final bool success;
  final String message;

  ScanResult({required this.success, required this.message});
}

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
  /// Returns a ScanResult with success status and error message if any
  Future<ScanResult> startScan() async {
    if (_isScanning) {
      return ScanResult(success: true, message: 'Already scanning');
    }

    try {
      final bool result = await BluetoothLeScanner.startScan();
      _isScanning = result;
      if (result) {
        return ScanResult(success: true, message: 'Scanning started successfully');
      } else {
        return ScanResult(success: false, message: 'Failed to start scanning');
      }
    } on PlatformException catch (e) {
      print('Error starting BLE scan: ${e.message}');
      _isScanning = false;

      // Provide specific error messages based on the error code
      String userMessage;
      switch (e.code) {
        case 'PERMISSION_DENIED':
          userMessage = 'Для сканирования Bluetooth устройств необходимо разрешение на доступ к геолокации. Пожалуйста, предоставьте разрешение в настройках приложения.';
          break;
        case 'BLUETOOTH_DISABLED':
          userMessage = 'Bluetooth отключен. Пожалуйста, включите Bluetooth и попробуйте снова.';
          break;
        case 'BLUETOOTH_UNAVAILABLE':
          userMessage = 'Bluetooth недоступен на этом устройстве.';
          break;
        default:
          userMessage = 'Ошибка при запуске сканирования: ${e.message ?? 'Неизвестная ошибка'}';
      }

      return ScanResult(success: false, message: userMessage);
    } catch (e) {
      print('Error starting BLE scan: $e');
      _isScanning = false;
      return ScanResult(success: false, message: 'Неожиданная ошибка при запуске сканирования');
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
