import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/services/auth/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
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
