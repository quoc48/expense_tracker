import 'package:flutter/foundation.dart';
import '../services/queue_service.dart';
import '../services/connectivity_monitor.dart';
import '../repositories/expense_repository.dart';

/// Sync state enum
enum SyncState {
  idle,      // No pending items or not syncing
  pending,   // Items waiting to sync
  syncing,   // Currently syncing
  synced,    // Just finished syncing (temporary state)
  error,     // Sync failed
}

/// Provider for managing offline queue sync state
///
/// This provider exposes sync status and pending count to the UI,
/// allowing widgets to display sync badges, progress indicators, etc.
///
/// Usage in widgets:
/// ```dart
/// final syncProvider = Provider.of<SyncProvider>(context);
/// if (syncProvider.pendingCount > 0) {
///   // Show sync badge
/// }
/// ```
class SyncProvider extends ChangeNotifier {
  final QueueService _queueService;
  final ConnectivityMonitor _connectivityMonitor;
  final ExpenseRepository _expenseRepository;

  SyncState _syncState = SyncState.idle;
  int _pendingCount = 0;
  int _failedCount = 0;
  String? _lastError;
  DateTime? _lastSyncAt;

  SyncProvider({
    required QueueService queueService,
    required ConnectivityMonitor connectivityMonitor,
    required ExpenseRepository expenseRepository,
  })  : _queueService = queueService,
        _connectivityMonitor = connectivityMonitor,
        _expenseRepository = expenseRepository {
    // Initialize
    _initialize();
  }

  // Getters
  SyncState get syncState => _syncState;
  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  String? get lastError => _lastError;
  DateTime? get lastSyncAt => _lastSyncAt;
  bool get isOnline => _connectivityMonitor.isOnline;
  bool get hasPendingItems => _pendingCount > 0;
  bool get hasFailedItems => _failedCount > 0;

  /// Initialize sync provider
  Future<void> _initialize() async {
    // Update counts from queue
    _updateCounts();

    // Listen to queue service changes
    _queueService.addListener(_onQueueChanged);

    // Listen to connectivity changes for auto-sync
    _connectivityMonitor.connectivityStream.listen(_onConnectivityChanged);

    // Check if we should auto-sync on init (if online and has pending)
    if (_connectivityMonitor.isOnline && _pendingCount > 0) {
      await syncNow();
    }
  }

  /// Handle queue changes
  void _onQueueChanged() {
    _updateCounts();
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(bool isOnline) async {
    debugPrint('🌐 Connectivity changed in SyncProvider: ${isOnline ? "ONLINE" : "OFFLINE"}');

    if (isOnline && _pendingCount > 0) {
      debugPrint('🔄 Auto-syncing $_pendingCount pending items...');
      await syncNow();
    }

    notifyListeners();
  }

  /// Update pending and failed counts from queue
  void _updateCounts() {
    _pendingCount = _queueService.getPendingCount();
    _failedCount = _queueService.getFailedCount();

    // Update state based on counts
    if (_syncState != SyncState.syncing) {
      if (_pendingCount > 0 || _failedCount > 0) {
        _syncState = _failedCount > 0 ? SyncState.error : SyncState.pending;
      } else {
        _syncState = SyncState.idle;
      }
    }

    notifyListeners();
  }

  /// Manually trigger sync
  Future<bool> syncNow() async {
    if (!_connectivityMonitor.isOnline) {
      debugPrint('⚠️  Cannot sync: Device is offline');
      return false;
    }

    if (_syncState == SyncState.syncing) {
      debugPrint('⚠️  Already syncing, skipping...');
      return false;
    }

    try {
      _syncState = SyncState.syncing;
      _lastError = null;
      notifyListeners();

      // Process queue
      final syncedCount = await _queueService.processQueue(_expenseRepository);

      // Update counts
      _updateCounts();

      // Set synced state temporarily
      _syncState = SyncState.synced;
      _lastSyncAt = DateTime.now();
      notifyListeners();

      debugPrint('✅ Sync complete: $syncedCount items synced');

      // Reset to idle/pending after brief delay
      await Future.delayed(const Duration(seconds: 2));
      _updateCounts();

      return true;

    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      debugPrint('❌ Sync failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Retry failed items
  Future<bool> retryFailed() async {
    if (!_connectivityMonitor.isOnline) {
      debugPrint('⚠️  Cannot retry: Device is offline');
      return false;
    }

    try {
      _syncState = SyncState.syncing;
      _lastError = null;
      notifyListeners();

      final syncedCount = await _queueService.retryFailed(_expenseRepository);

      _updateCounts();
      _syncState = SyncState.synced;
      _lastSyncAt = DateTime.now();
      notifyListeners();

      debugPrint('✅ Retry complete: $syncedCount items synced');

      await Future.delayed(const Duration(seconds: 2));
      _updateCounts();

      return true;

    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      debugPrint('❌ Retry failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear all queued items (dangerous - for testing only)
  Future<void> clearQueue() async {
    await _queueService.clearAll();
    _updateCounts();
  }

  @override
  void dispose() {
    _queueService.removeListener(_onQueueChanged);
    super.dispose();
  }
}
