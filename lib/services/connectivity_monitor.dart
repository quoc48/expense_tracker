import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring internet connectivity status
///
/// This service provides real-time connectivity status and notifies listeners
/// when the connection state changes. Used by ExpenseProvider to determine
/// whether to save directly to Supabase or queue for later sync.
///
/// Usage:
/// ```dart
/// final monitor = ConnectivityMonitor();
/// await monitor.initialize();
///
/// // Check current status
/// if (monitor.isOnline) {
///   // Save to cloud
/// }
///
/// // Listen to changes
/// monitor.connectivityStream.listen((isOnline) {
///   if (isOnline) {
///     // Trigger sync
///   }
/// });
/// ```
class ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  // Current connectivity status
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Stream for listeners
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the connectivity monitor
  ///
  /// Checks initial connectivity status and sets up listener for changes
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      _isOnline = await checkConnectivity();

      // Listen to connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          debugPrint('❌ Connectivity monitoring error: $error');
        },
      );

      debugPrint('✅ Connectivity monitor initialized (online: $_isOnline)');
    } catch (e) {
      debugPrint('❌ Failed to initialize connectivity monitor: $e');
      // Assume online on error
      _isOnline = true;
    }
  }

  /// Check current connectivity status
  ///
  /// Returns true if device has any internet connection (WiFi, mobile, etc.)
  /// Returns false if no connection or connection check fails
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();

      // Check if any result indicates connectivity
      // ConnectivityResult.none means no connection
      final hasConnection = results.any((result) => result != ConnectivityResult.none);

      return hasConnection;
    } catch (e) {
      debugPrint('❌ Connectivity check failed: $e');
      // Assume online on error (fail-safe)
      return true;
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    // Check if any result indicates connectivity
    final hasConnection = results.any((result) => result != ConnectivityResult.none);

    // Only notify if status actually changed
    if (hasConnection != _isOnline) {
      _isOnline = hasConnection;

      debugPrint('🌐 Connectivity changed: ${hasConnection ? "ONLINE" : "OFFLINE"}');

      // Notify listeners
      _connectivityController.add(hasConnection);
    }
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
