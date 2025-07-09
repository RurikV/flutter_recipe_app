/// Abstract interface for configuration service
/// Provides access to application configuration values
abstract class ConfigService {
  /// Get the API base URL from configuration
  Future<String> getApiBaseUrl();
  
  /// Initialize the configuration service
  Future<void> initialize();
}