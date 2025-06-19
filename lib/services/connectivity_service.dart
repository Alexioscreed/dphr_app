import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isOnline = true;
  bool _isInitialized = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Initialize the connectivity service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        debugPrint('Connectivity error: $error');
      },
    );

    _isInitialized = true;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    // User is online if any connection type is available (not just none)
    _isOnline = results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      debugPrint('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
      debugPrint('Connection types: ${results.map((r) => r.name).join(', ')}');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
