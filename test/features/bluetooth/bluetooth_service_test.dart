import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:recipe_master/services/bluetooth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothService', () {
    late BluetoothService bluetoothService;

    setUp(() {
      bluetoothService = BluetoothService();
    });

    test('should return ScanResult with success true when scan starts successfully', () async {
      // Mock the method channel to return success
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.recipe_app/bluetooth_le_scanner'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'startScan':
              return true;
            case 'isBluetoothEnabled':
              return true;
            default:
              return null;
          }
        },
      );

      final result = await bluetoothService.startScan();

      expect(result.success, true);
      expect(result.message, 'Scanning started successfully');
    });

    test('should return ScanResult with permission error message when permission denied', () async {
      // Mock the method channel to throw permission denied error
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.recipe_app/bluetooth_le_scanner'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'startScan':
              throw PlatformException(
                code: 'PERMISSION_DENIED',
                message: 'Location permission not granted',
              );
            default:
              return null;
          }
        },
      );

      final result = await bluetoothService.startScan();

      expect(result.success, false);
      expect(result.message, contains('геолокации'));
      expect(result.message, contains('разрешение'));
    });

    test('should return ScanResult with bluetooth disabled error when bluetooth is off', () async {
      // Mock the method channel to throw bluetooth disabled error
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.recipe_app/bluetooth_le_scanner'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'startScan':
              throw PlatformException(
                code: 'BLUETOOTH_DISABLED',
                message: 'Bluetooth is disabled',
              );
            default:
              return null;
          }
        },
      );

      final result = await bluetoothService.startScan();

      expect(result.success, false);
      expect(result.message, contains('Bluetooth отключен'));
    });

    test('should handle already scanning state correctly', () async {
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.recipe_app/bluetooth_le_scanner'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'startScan':
              return true;
            default:
              return null;
          }
        },
      );

      // Start scanning first time
      await bluetoothService.startScan();

      // Try to start scanning again
      final result = await bluetoothService.startScan();

      expect(result.success, true);
      expect(result.message, 'Already scanning');
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.recipe_app/bluetooth_le_scanner'),
        null,
      );
    });
  });
}
