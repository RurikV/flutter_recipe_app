import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_service.dart';

/// Implementation of the ConnectivityService interface
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  /// Constructor with optional Connectivity dependency
  ConnectivityServiceImpl({Connectivity? connectivity}) 
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;
}
