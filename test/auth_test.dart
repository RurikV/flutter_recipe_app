import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/services/auth/auth_service.dart';
import 'package:dio/dio.dart';

// Create a Dio instance with interceptors for mocking
Dio createMockDio() {
  final dio = Dio();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Mock login endpoint
      if (options.method == 'PUT' && options.path == '/user') {
        handler.resolve(Response(
          data: {
            'token': 'mock_token_123',
            'id': 1,
          },
          statusCode: 200,
          requestOptions: options,
        ));
        return;
      }

      // Mock getUserProfile endpoint
      if (options.method == 'GET' && options.path == '/user/1') {
        handler.resolve(Response(
          data: {
            'id': 1,
            'login': 'user1',
            'password': 'user1',
            'userFreezer': [],
            'favoriteRecipes': [],
            'comments': [],
          },
          statusCode: 200,
          requestOptions: options,
        ));
        return;
      }

      // For any other requests, return 404
      handler.resolve(Response(
        data: {'error': 'Not found'},
        statusCode: 404,
        requestOptions: options,
      ));
    },
  ));

  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthService Tests', () {
    late AuthService authService;
    late Dio mockDio;

    setUp(() {
      mockDio = createMockDio();
      authService = AuthService(dio: mockDio, initializeUser: false);
    });

    test('Should authenticate user1 with user1', () async {
      print('[DEBUG_LOG] Attempting to login with user1 and user1');

      try {
        final user = await authService.login('user1', 'user1');
        print('[DEBUG_LOG] Login successful: ${user.login}, ID: ${user.id}');
        expect(user.login, equals('user1'));
        expect(user.id, isNotNull);
      } catch (e) {
        print('[DEBUG_LOG] Login failed with error: $e');
        fail('Login should succeed but failed with: $e');
      }
    });

    test('Should get user profile for user ID 1', () async {
      print('[DEBUG_LOG] Attempting to get user profile for user ID 1');

      try {
        final user = await authService.getUserProfile('1');
        print('[DEBUG_LOG] User profile retrieved: ${user.login}, ID: ${user.id}');
        expect(user.id, equals(1));
      } catch (e) {
        print('[DEBUG_LOG] Get user profile failed with error: $e');
        fail('Get user profile should succeed but failed with: $e');
      }
    });

    tearDown(() {
      authService.dispose();
    });
  });
}
