import 'package:flutter_recipe_app/services/auth/auth_service.dart';
import 'package:flutter_recipe_app/data/services/config/config_service_impl.dart';

void main() async {
  print('[DEBUG_LOG] Starting authentication test');

  // Initialize ConfigService
  final configService = ConfigServiceImpl();
  await configService.initialize();

  final authService = AuthService(configService: configService);

  try {
    print('[DEBUG_LOG] Attempting to login with user1 and user1');
    final user = await authService.login('user1', 'user1');
    print('[DEBUG_LOG] Login successful!');
    print('[DEBUG_LOG] User ID: ${user.id}');
    print('[DEBUG_LOG] User login: ${user.login}');
    print('[DEBUG_LOG] User token: ${user.token != null ? "Present" : "Missing"}');

    // Test getting user profile directly
    print('[DEBUG_LOG] Testing getUserProfile with ID 1');
    final userProfile = await authService.getUserProfile('1');
    print('[DEBUG_LOG] User profile retrieved successfully!');
    print('[DEBUG_LOG] Profile ID: ${userProfile.id}');
    print('[DEBUG_LOG] Profile login: ${userProfile.login}');

  } catch (e) {
    print('[DEBUG_LOG] Authentication failed: $e');
  } finally {
    authService.dispose();
  }
}
