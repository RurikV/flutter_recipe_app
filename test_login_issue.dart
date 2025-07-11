import 'package:dio/dio.dart';
import 'lib/services/auth/auth_service.dart';

void main() async {
  print('[DEBUG_LOG] Testing login issue with user1/user1');
  
  try {
    final authService = AuthService(initializeUser: false);
    print('[DEBUG_LOG] Attempting to login with user1/user1');
    final user = await authService.login('user1', 'user1');
    print('[DEBUG_LOG] Login successful: ${user.login}');
  } catch (e) {
    print('[DEBUG_LOG] Login failed with exception: $e');
    print('[DEBUG_LOG] Exception type: ${e.runtimeType}');
  }
}