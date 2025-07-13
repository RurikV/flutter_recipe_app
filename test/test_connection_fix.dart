import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/services/auth/auth_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  print('[DEBUG_LOG] Testing API connection fix with valid credentials');

  try {
    final authService = AuthService(initializeUser: false);
    print('[DEBUG_LOG] Attempting to login with user1/password123');
    final user = await authService.login('user1', 'password123');
    print('[DEBUG_LOG] Login successful: ${user.login}');
    print('[DEBUG_LOG] SUCCESS: Connection issue is resolved!');
  } catch (e) {
    print('[DEBUG_LOG] Login failed with exception: $e');
    print('[DEBUG_LOG] Exception type: ${e.runtimeType}');
    
    if (e.toString().contains('Connection refused') || e.toString().contains('connectionError')) {
      print('[DEBUG_LOG] ERROR: Connection issue still exists!');
    } else {
      print('[DEBUG_LOG] Connection works, but login failed for other reasons: $e');
    }
  }
}