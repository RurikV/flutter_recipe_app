import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for connectivity-related operations
abstract class ConnectivityService {
  /// Check if the device is connected to the internet
  Future<bool> isConnected();
  
  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream;
}