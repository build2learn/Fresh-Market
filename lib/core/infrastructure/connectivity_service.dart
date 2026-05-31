import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOnline = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    return _isOnline;
  }

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
