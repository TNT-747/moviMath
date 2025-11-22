import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // Check if connected to mobile or wifi
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi);
  }
}
