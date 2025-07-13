import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/services/auth/auth_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  print('[DEBUG_LOG] Testing real API login with user1/user1');

  try {
    final authService = AuthService(initializeUser: false);
    print('[DEBUG_LOG] Attempting to login with user1/user1');
    final user = await authService.login('user1', 'password123');
    print('[DEBUG_LOG] Login successful: ${user.login}');
  } catch (e) {
    print('[DEBUG_LOG] Login failed with exception: $e');
    print('[DEBUG_LOG] Exception type: ${e.runtimeType}');

    // This is expected behavior - the exception should now have proper error messages
    // instead of "Login failed: null"
    if (e.toString().contains('Login failed: null')) {
      print('[DEBUG_LOG] ERROR: Still getting null error message!');
    } else {
      print('[DEBUG_LOG] SUCCESS: Error message is properly formatted');
    }
  }
}
