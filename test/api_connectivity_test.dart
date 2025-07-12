import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/config/app_config.dart';
import 'package:recipe_master/services/connectivity/connectivity_service.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

// Mock connectivity service for testing
class MockConnectivityService implements ConnectivityService {
  @override
  Future<bool> isConnected() async {
    return true; // Always return true for testing
  }

  @override
  Stream<ConnectivityResult> get connectivityStream => Stream.value(ConnectivityResult.wifi);
}

void main() {
  group('API Connectivity Tests', () {
    test('Should verify mock connectivity service works', () async {
      // Create mock connectivity service
      final connectivityService = MockConnectivityService();

      // Test connectivity
      final isConnected = await connectivityService.isConnected();
      expect(isConnected, isTrue);
      print('[DEBUG_LOG] ✅ Mock connectivity service test passed!');

      // Test connectivity stream
      final connectivityStream = connectivityService.connectivityStream;
      final firstResult = await connectivityStream.first;
      expect(firstResult, equals(ConnectivityResult.wifi));
      print('[DEBUG_LOG] ✅ Mock connectivity stream test passed!');
    });

    test('Should verify app configuration points to local API', () {
      final baseUrl = AppConfig.baseUrl;

      // Verify that the app is configured to use local API
      expect(baseUrl, contains('localhost:3000'));
      print('[DEBUG_LOG] ✅ App configuration verified: $baseUrl');
    });
  });
}
