import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'connectivity_service.dart';

/// Implementation of the ConnectivityService interface
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  /// Constructor with optional Connectivity dependency
  ConnectivityServiceImpl({Connectivity? connectivity}) 
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isConnected() async {
    // On web platform, connectivity_plus might not work correctly for localhost
    // Always return true for web development to allow API calls
    if (kIsWeb) {
      print('[DEBUG_LOG] ConnectivityService: Web platform detected, assuming connected');
      return true;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;
    print('[DEBUG_LOG] ConnectivityService: Connectivity result: $connectivityResult, isConnected: $isConnected');
    return isConnected;
  }

  @override
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;
}
