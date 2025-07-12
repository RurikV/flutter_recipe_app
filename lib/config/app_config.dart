import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Application configuration constants
class AppConfig {
  /// Base URL for the API server
  static String get baseUrl {
    // Production URL (uncomment when deploying to production)
    // return 'https://foodapi.dzolotov.pro';

    // Development URLs based on platform:
    if (kIsWeb) {
      // Web development - use localhost
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android emulator - use 10.0.2.2 to access host machine's localhost
      // For physical Android device, replace with your development machine's IP address
      // Example: return 'http://192.168.1.100:3000';
      return 'http://10.0.2.2:3000';
    } else {
      // iOS simulator, desktop, or other platforms - use localhost
      return 'http://localhost:3000';
    }
  }

  /// Private constructor to prevent instantiation
  AppConfig._();
}
