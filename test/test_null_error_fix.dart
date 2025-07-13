import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:recipe_master/services/auth/auth_service.dart';

// Create a Dio instance that simulates the null error scenario
Dio createNullErrorDio() {
  final dio = Dio();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Simulate a DioException with null message and unknown type
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        message: null, // This is the key - null message
      ));
    },
  ));

  return dio;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  print('[DEBUG_LOG] Testing null error message fix');

  try {
    final mockDio = createNullErrorDio();
    final authService = AuthService(dio: mockDio, initializeUser: false);

    print('[DEBUG_LOG] Attempting login that should trigger null error scenario');
    await authService.login('user1', 'password123');

    print('[DEBUG_LOG] ERROR: Login should have failed but succeeded');
  } catch (e) {
    print('[DEBUG_LOG] Login failed with exception: $e');
    print('[DEBUG_LOG] Exception type: ${e.runtimeType}');

    // Check if we still get the "Login failed: null" error
    if (e.toString().contains('Login failed: null')) {
      print('[DEBUG_LOG] FAILURE: Still getting null error message!');
    } else if (e.toString().contains('Login failed: Unknown network error occurred')) {
      print('[DEBUG_LOG] SUCCESS: Error message is now properly formatted with meaningful description');
    } else {
      print('[DEBUG_LOG] INFO: Got different error message: ${e.toString()}');
    }
  }
}
