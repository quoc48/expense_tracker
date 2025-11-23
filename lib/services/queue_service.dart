import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../models/scanning/queued_receipt.dart';
import '../models/scanning/queued_item.dart';
import '../repositories/expense_repository.dart';

/// Service for managing offline expense queue
///
/// This service handles the queuing of expenses when offline and syncing them
/// when connectivity returns. Uses Hive for local persistence.
///
/// Queue Strategy (Option A - Remove After Sync):
/// - Offline: Save expense to Hive queue
/// - Online: Sync to Supabase → Remove from Hive
/// - Simple: No duplicate data management
///
/// Usage:
/// ```dart
/// final queueService = QueueService();
/// await queueService.initialize();
///
/// // Enqueue when offline
/// await queueService.enqueueExpense(expense);
///
/// // Process when online
/// await queueService.processQueue(repository);
/// ```
class QueueService extends ChangeNotifier {
  static const String _boxName = 'expense_queue';
  Box<QueuedReceipt>? _queueBox;
  final _uuid = const Uuid();

  // Track if queue is currently processing
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  /// Initialize the queue service
  ///
  /// Opens the Hive box for queued receipts
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _queueBox = await Hive.openBox<QueuedReceipt>(_boxName);
        debugPrint('✅ Queue service initialized (${getPendingCount()} items pending)');
      } else {
        _queueBox = Hive.box<QueuedReceipt>(_boxName);
        debugPrint('✅ Queue service using existing box');
      }

      // Debug: Show what's in the box on initialization
      debugPrint('📊 Queue box stats:');
      debugPrint('   Total items: ${_queueBox!.length}');
      debugPrint('   Pending: ${getPendingCount()}');
      debugPrint('   Failed: ${getFailedCount()}');
      debugPrint('   Box path: ${_queueBox!.path}');

    } catch (e) {
      debugPrint('❌ Failed to initialize queue service: $e');
      rethrow;
    }
  }

  /// Enqueue a single expense when offline
  ///
  /// Creates a QueuedReceipt with one item for manual expense entry
  Future<void> enqueueExpense(Expense expense) async {
    if (_queueBox == null) {
      throw StateError('Queue service not initialized');
    }

    try {
      // Convert Expense to QueuedItem
      final queuedItem = QueuedItem(
        description: expense.description,
        amount: expense.amount,
        categoryNameVi: expense.categoryNameVi,
        typeNameVi: expense.typeNameVi,
        date: expense.date,
        note: expense.note,
      );

      // Create QueuedReceipt with single item
      final queuedReceipt = QueuedReceipt(
        id: _uuid.v4(),
        queuedAt: DateTime.now(),
        items: [queuedItem],
        status: 'pending',
      );

      // Save to Hive
      final index = await _queueBox!.add(queuedReceipt);

      // CRITICAL: Explicitly flush to disk to ensure persistence across hot reload
      await _queueBox!.flush();

      notifyListeners();

      debugPrint('📦 Queued 1 expense: ${expense.description} (${expense.amount}đ)');
      debugPrint('   Box now has ${_queueBox!.length} items (just added at index $index)');
      debugPrint('   Box path: ${_queueBox!.path}');
    } catch (e) {
      debugPrint('❌ Failed to enqueue expense: $e');
      rethrow;
    }
  }

  /// Enqueue multiple expenses from receipt scanning
  ///
  /// Creates a QueuedReceipt with multiple items for scanned receipts
  Future<void> enqueueReceipt(List<Expense> expenses, DateTime receiptDate) async {
    if (_queueBox == null) {
      throw StateError('Queue service not initialized');
    }

    if (expenses.isEmpty) return;

    try {
      // Convert Expenses to QueuedItems
      final queuedItems = expenses.map((expense) {
        return QueuedItem(
          description: expense.description,
          amount: expense.amount,
          categoryNameVi: expense.categoryNameVi,
          typeNameVi: expense.typeNameVi,
          date: expense.date,
          note: expense.note,
        );
      }).toList();

      // Create QueuedReceipt with all items
      final queuedReceipt = QueuedReceipt(
        id: _uuid.v4(),
        queuedAt: DateTime.now(),
        items: queuedItems,
        status: 'pending',
      );

      // Save to Hive
      await _queueBox!.add(queuedReceipt);
      notifyListeners();

      debugPrint('📦 Queued receipt with ${expenses.length} items (${queuedReceipt.totalAmount}đ)');
    } catch (e) {
      debugPrint('❌ Failed to enqueue receipt: $e');
      rethrow;
    }
  }

  /// Process all pending items in the queue
  ///
  /// Syncs queued receipts to Supabase and removes successful ones
  /// Returns number of successfully synced receipts
  Future<int> processQueue(ExpenseRepository repository) async {
    if (_queueBox == null) {
      throw StateError('Queue service not initialized');
    }

    if (_isProcessing) {
      debugPrint('⏳ Queue already processing, skipping...');
      return 0;
    }

    _isProcessing = true;
    notifyListeners();

    int successCount = 0;
    int failCount = 0;

    try {
      final pendingReceipts = getPendingReceipts();

      if (pendingReceipts.isEmpty) {
        debugPrint('✅ Queue is empty, nothing to sync');
        return 0;
      }

      debugPrint('🔄 Processing ${pendingReceipts.length} queued receipts...');

      for (final receipt in pendingReceipts) {
        try {
          // Update status to syncing
          receipt.status = 'syncing';
          await receipt.save();

          // Convert QueuedItems to Expenses and save to Supabase
          for (final item in receipt.items) {
            final expense = Expense(
              id: '', // Repository will generate
              description: item.description,
              amount: item.amount,
              categoryNameVi: item.categoryNameVi,
              typeNameVi: item.typeNameVi,
              date: item.date,
              note: item.note,
            );

            await repository.create(expense);
          }

          // Success: Mark as success and delete from queue
          receipt.status = 'success';
          await receipt.save();
          await receipt.delete(); // Remove from Hive (Option A: Remove after sync)

          successCount++;
          debugPrint('✅ Synced receipt ${receipt.id} (${receipt.itemCount} items)');

        } catch (e) {
          // Failure: Update retry count and error message
          receipt.retryCount++;
          receipt.lastRetryAt = DateTime.now();
          receipt.errorMessage = e.toString();
          receipt.status = receipt.canRetry ? 'pending' : 'failed';
          await receipt.save();

          failCount++;
          debugPrint('❌ Failed to sync receipt ${receipt.id}: $e');

          // Exponential backoff: wait before next retry
          if (receipt.canRetry) {
            final backoffSeconds = _calculateBackoff(receipt.retryCount);
            debugPrint('   Retry ${receipt.retryCount}/5 after ${backoffSeconds}s');
          } else {
            debugPrint('   Max retries reached, marking as failed');
          }
        }
      }

      debugPrint('🎯 Queue processing complete: $successCount synced, $failCount failed');
      notifyListeners();
      return successCount;

    } catch (e) {
      debugPrint('❌ Queue processing error: $e');
      return successCount;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Retry failed receipts manually
  ///
  /// Resets retry count and attempts to sync again
  Future<int> retryFailed(ExpenseRepository repository) async {
    if (_queueBox == null) return 0;

    try {
      // Reset failed receipts to pending
      final failedReceipts = _queueBox!.values
          .where((receipt) => receipt.status == 'failed')
          .toList();

      for (final receipt in failedReceipts) {
        receipt.status = 'pending';
        receipt.retryCount = 0;
        receipt.errorMessage = null;
        await receipt.save();
      }

      debugPrint('🔄 Reset ${failedReceipts.length} failed receipts to pending');

      // Process queue
      return await processQueue(repository);
    } catch (e) {
      debugPrint('❌ Failed to retry: $e');
      return 0;
    }
  }

  /// Get all pending receipts (pending + retrying)
  List<QueuedReceipt> getPendingReceipts() {
    if (_queueBox == null) return [];

    return _queueBox!.values
        .where((receipt) => receipt.status == 'pending' || receipt.status == 'retrying')
        .toList();
  }

  /// Get all failed receipts
  List<QueuedReceipt> getFailedReceipts() {
    if (_queueBox == null) return [];

    return _queueBox!.values
        .where((receipt) => receipt.status == 'failed')
        .toList();
  }

  /// Get number of pending items (total expenses waiting to sync)
  int getPendingCount() {
    if (_queueBox == null) return 0;

    return _queueBox!.values
        .where((receipt) => receipt.status == 'pending' || receipt.status == 'retrying')
        .fold(0, (sum, receipt) => sum + receipt.itemCount);
  }

  /// Get number of failed items
  int getFailedCount() {
    if (_queueBox == null) return 0;

    return _queueBox!.values
        .where((receipt) => receipt.status == 'failed')
        .fold(0, (sum, receipt) => sum + receipt.itemCount);
  }

  /// Clear all successfully synced receipts
  Future<void> clearSuccessful() async {
    if (_queueBox == null) return;

    try {
      final successful = _queueBox!.values
          .where((receipt) => receipt.status == 'success')
          .toList();

      for (final receipt in successful) {
        await receipt.delete();
      }

      debugPrint('🗑️  Cleared ${successful.length} successful receipts');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to clear successful receipts: $e');
    }
  }

  /// Clear all queued receipts (dangerous - only for testing/reset)
  Future<void> clearAll() async {
    if (_queueBox == null) return;

    try {
      await _queueBox!.clear();
      debugPrint('🗑️  Cleared entire queue');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to clear queue: $e');
    }
  }

  /// Calculate exponential backoff delay in seconds
  ///
  /// Retry 1: 2s, Retry 2: 4s, Retry 3: 8s, Retry 4: 16s, Retry 5: 32s
  int _calculateBackoff(int retryCount) {
    return (2 * (1 << (retryCount - 1))).toInt(); // 2^retryCount
  }

  /// Dispose of resources
  @override
  void dispose() {
    // Don't close the box, it may be used elsewhere
    super.dispose();
  }
}
