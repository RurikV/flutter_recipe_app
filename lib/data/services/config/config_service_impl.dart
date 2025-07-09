import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/services/config_service.dart';

/// Implementation of ConfigService that reads configuration from assets/config.json
class ConfigServiceImpl implements ConfigService {
  Map<String, dynamic>? _config;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final String configString = await rootBundle.loadString('assets/config.json');
      _config = json.decode(configString) as Map<String, dynamic>;
      _initialized = true;
      print('Configuration loaded successfully');
    } catch (e) {
      print('Error loading configuration: $e');
      // Fallback to default configuration
      _config = {
        'api': {
          'baseUrl': 'https://foodapi.dzolotov.pro'
        }
      };
      _initialized = true;
    }
  }

  @override
  Future<String> getApiBaseUrl() async {
    if (!_initialized) {
      await initialize();
    }
    
    final apiConfig = _config?['api'] as Map<String, dynamic>?;
    final baseUrl = apiConfig?['baseUrl'] as String?;
    
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API baseUrl not found in configuration');
    }
    
    return baseUrl;
  }
}