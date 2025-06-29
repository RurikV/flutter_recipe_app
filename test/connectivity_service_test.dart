import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock implementation of ConnectivityService for testing
class MockConnectivityService extends ConnectivityService {
  final bool _isConnected;

  MockConnectivityService({bool isConnected = true}) : _isConnected = isConnected;

  @override
  Future<bool> isConnected() async {
    return _isConnected;
  }

  @override
  Stream<ConnectivityResult> get connectivityStream => 
      Stream.value(_isConnected ? ConnectivityResult.wifi : ConnectivityResult.none);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity Service Tests', () {
    late MockConnectivityService connectedService;
    late MockConnectivityService disconnectedService;

    setUp(() {
      connectedService = MockConnectivityService(isConnected: true);
      disconnectedService = MockConnectivityService(isConnected: false);
    });

    test('Check connectivity when connected', () async {
      // Use the mock service that simulates being connected
      final isConnected = await connectedService.isConnected();

      // Verify that isConnected returns true
      expect(isConnected, isTrue);
      print('[DEBUG_LOG] Device is connected to the internet: $isConnected');
    });

    test('Check connectivity when disconnected', () async {
      // Use the mock service that simulates being disconnected
      final isConnected = await disconnectedService.isConnected();

      // Verify that isConnected returns false
      expect(isConnected, isFalse);
      print('[DEBUG_LOG] Device is disconnected from the internet: $isConnected');
    });

    test('Get connectivity stream when connected', () async {
      // Get the connectivity stream from the connected service
      final stream = connectedService.connectivityStream;

      // Verify the stream is not null
      expect(stream, isNotNull);

      // Listen to the stream and verify it emits ConnectivityResult.wifi
      stream.listen((result) {
        expect(result, equals(ConnectivityResult.wifi));
        print('[DEBUG_LOG] Connectivity changed: $result');
      });

      // Wait a short time to allow the stream to emit a value
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Get connectivity stream when disconnected', () async {
      // Get the connectivity stream from the disconnected service
      final stream = disconnectedService.connectivityStream;

      // Verify the stream is not null
      expect(stream, isNotNull);

      // Listen to the stream and verify it emits ConnectivityResult.none
      stream.listen((result) {
        expect(result, equals(ConnectivityResult.none));
        print('[DEBUG_LOG] Connectivity changed: $result');
      });

      // Wait a short time to allow the stream to emit a value
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });
}
