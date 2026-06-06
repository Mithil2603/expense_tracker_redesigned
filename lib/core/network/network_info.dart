import 'package:connectivity_plus/connectivity_plus.dart';

/// NetworkInfo — interface to check if the device is connected to the internet.
abstract interface class NetworkInfo {
  /// Returns true if there is an active internet connection.
  Future<bool> get isConnected;

  /// Emits connection updates (true if connected, false if disconnected).
  Stream<bool> get onConnectivityChanged;
}

/// NetworkInfoImpl — concrete implementation of [NetworkInfo] using [Connectivity].
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  /// Helper to map `List<ConnectivityResult>` (connectivity_plus v6/v7) to boolean.
  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    if (results.length == 1 && results.first == ConnectivityResult.none) return false;
    return true;
  }
}
