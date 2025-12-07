import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';
import '../services/connectivity_monitor.dart';
import '../services/queue_service.dart';

/// ExpenseProvider manages the global state for all expenses in the app.
/// It extends ChangeNotifier which is part of Flutter's built-in state management.
///
/// Learning: ChangeNotifier is the foundation of the Provider pattern.
/// When you call notifyListeners(), all widgets listening to this provider
/// will rebuild automatically - no need to manually manage setState() everywhere!
///
/// Why use Provider instead of setState?
/// - Share state across multiple screens without passing data through constructors
/// - Separate business logic from UI code
/// - Avoid "prop drilling" (passing data through many widget layers)
/// - Better performance (only rebuilds widgets that actually listen to changes)
class ExpenseProvider extends ChangeNotifier {
  // Private state - the underscore makes it inaccessible outside this class
  List<Expense> _expenses = [];
  bool _isLoading = false;

  // Performance guard: Prevent duplicate/concurrent loadExpenses() calls
  bool _isLoadingInProgress = false;

  // Repository for data access (now using Supabase instead of SharedPreferences)
  final ExpenseRepository _repository = SupabaseExpenseRepository();

  // Offline queue services (optional - for backward compatibility)
  final ConnectivityMonitor? _connectivityMonitor;
  final QueueService? _queueService;

  // Constructor with optional offline services
  ExpenseProvider({
    ConnectivityMonitor? connectivityMonitor,
    QueueService? queueService,
  })  : _connectivityMonitor = connectivityMonitor,
        _queueService = queueService;

  // Public getters - allow read-only access to private state
  // This is a common pattern: private state, public getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  // Computed properties - derived from the state
  int get expenseCount => _expenses.length;

  double get totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Load all expenses using Background Preload pattern:
  /// 1. Load current month expenses quickly (user sees data fast)
  /// 2. Load remaining history in background (seamless experience)
  ///
  /// Performance: Two-phase loading with timing metrics.
  Future<void> loadExpenses() async {
    // Guard: Prevent duplicate concurrent calls
    if (_isLoadingInProgress) {
      debugPrint('⚠️ [PERF] loadExpenses already in progress, skipping duplicate call');
      return;
    }
    _isLoadingInProgress = true;

    final totalStopwatch = Stopwatch()..start();
    debugPrint('📊 [PERF] loadExpenses: START (Background Preload)');

    _isLoading = true;
    notifyListeners();

    try {
      // ═══════════════════════════════════════════════════════════════════
      // PHASE 1: Load current month expenses (FAST - user sees data quickly)
      // ═══════════════════════════════════════════════════════════════════
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of month

      try {
        final phase1Stopwatch = Stopwatch()..start();
        _expenses = await _repository.getByDateRange(startOfMonth, endOfMonth)
            .timeout(const Duration(seconds: 10));
        phase1Stopwatch.stop();

        debugPrint('📊 [PERF] Phase 1 (current month): ${phase1Stopwatch.elapsedMilliseconds}ms '
            '(${_expenses.length} expenses)');

        // Add pending queued items for current month
        _addQueuedExpenses();

        // UI can now show current month data!
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ Phase 1 complete - UI showing ${_expenses.length} current month expenses');

      } catch (e) {
        debugPrint('⚠️ Phase 1 failed (offline?): $e');
        _expenses = [];
        _addQueuedExpenses();
        _isLoading = false;
        notifyListeners();
      }

      // ═══════════════════════════════════════════════════════════════════
      // PHASE 2: Load remaining history in background (user doesn't wait)
      // ═══════════════════════════════════════════════════════════════════
      _loadRemainingExpensesInBackground(startOfMonth);

      totalStopwatch.stop();
      debugPrint('📊 [PERF] loadExpenses Phase 1 TOTAL: ${totalStopwatch.elapsedMilliseconds}ms');

    } catch (e) {
      debugPrint('❌ Critical error loading expenses: $e');
      _expenses = [];
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoadingInProgress = false;
    }
  }

  /// Phase 2: Load expenses before current month in background
  /// This runs silently - user already sees current month data
  Future<void> _loadRemainingExpensesInBackground(DateTime currentMonthStart) async {
    try {
      final phase2Stopwatch = Stopwatch()..start();
      debugPrint('📊 [PERF] Phase 2 (background): Starting...');

      // Get all expenses before current month
      final veryOldDate = DateTime(2020, 1, 1); // Reasonable start date
      final dayBeforeMonth = currentMonthStart.subtract(const Duration(days: 1));

      final olderExpenses = await _repository.getByDateRange(veryOldDate, dayBeforeMonth)
          .timeout(const Duration(seconds: 30)); // Longer timeout for history

      phase2Stopwatch.stop();
      debugPrint('📊 [PERF] Phase 2 (background): ${phase2Stopwatch.elapsedMilliseconds}ms '
          '(${olderExpenses.length} older expenses)');

      // Merge with current expenses
      _expenses = [..._expenses, ...olderExpenses];
      _expenses.sort((a, b) => b.date.compareTo(a.date)); // Newest first
      notifyListeners();

      debugPrint('✅ Phase 2 complete - Total ${_expenses.length} expenses loaded');

    } catch (e) {
      // Silent failure - we already have current month, don't disrupt user
      debugPrint('⚠️ Phase 2 (background) failed: $e - keeping current month data');
    }
  }

  /// Helper to add queued (offline) expenses to the list
  void _addQueuedExpenses() {
    if (_queueService == null) return;

    final pendingReceipts = _queueService.getPendingReceipts();
    if (pendingReceipts.isEmpty) return;

    for (final receipt in pendingReceipts) {
      for (final item in receipt.items) {
        final queuedExpense = Expense(
          id: 'pending_${receipt.id}_${item.hashCode}',
          description: item.description,
          amount: item.amount,
          categoryNameVi: item.categoryNameVi,
          typeNameVi: item.typeNameVi,
          date: item.date,
          note: item.note,
        );
        _expenses.add(queuedExpense);
      }
    }
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    debugPrint('📦 Added ${_queueService.getPendingCount()} pending queued items');
  }

  /// Add a new expense to the list with offline queue support
  /// Returns true if successful (saved to Supabase or queued offline)
  /// Vietnamese names are now part of the Expense object itself!
  ///
  /// Offline Queue Strategy (Option A):
  /// - If online: Save directly to Supabase
  /// - If offline: Queue to Hive (will sync automatically when online)
  Future<bool> addExpense(Expense expense) async {
    try {
      // Check connectivity if services are available
      final bool isOnline = _connectivityMonitor != null
          ? await _connectivityMonitor.checkConnectivity()
          : true; // Assume online if no connectivity service

      // Add to in-memory list first (optimistic update)
      _expenses.add(expense);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      if (isOnline) {
        // Online: Save directly to Supabase
        await _repository.create(expense);
        debugPrint('✅ Saved expense to Supabase: ${expense.description}');
      } else {
        // Offline: Queue for later sync
        if (_queueService != null) {
          await _queueService.enqueueExpense(expense);
          debugPrint('📦 Queued expense for offline sync: ${expense.description}');
        } else {
          // No queue service available, try to save anyway (will fail if truly offline)
          await _repository.create(expense);
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error adding expense: $e');
      // Remove the expense if operation failed
      _expenses.remove(expense);
      notifyListeners();
      return false;
    }
  }

  /// Update an existing expense (SIMPLIFIED - Phase 5.5.1)
  /// Returns true if successful, false otherwise
  /// Vietnamese names are now part of the Expense object itself!
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      // Find the index of the expense to update
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);

      if (index == -1) {
        debugPrint('Expense not found: ${updatedExpense.id}');
        return false;
      }

      // Update the expense
      _expenses[index] = updatedExpense;

      // Re-sort by date
      _expenses.sort((a, b) => b.date.compareTo(a.date));

      // Save to Supabase (Vietnamese names are in the expense object)
      await _repository.update(updatedExpense);

      // Notify listeners
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      // Rollback on error (would need to restore old expense here)
      notifyListeners();
      return false;
    }
  }

  /// Delete an expense
  /// Returns the deleted expense if successful (for undo functionality), null otherwise
  Future<Expense?> deleteExpense(String expenseId) async {
    try {
      // Find the expense to delete
      final index = _expenses.indexWhere((e) => e.id == expenseId);

      if (index == -1) {
        debugPrint('Expense not found: $expenseId');
        return null;
      }

      // Remove from list and store for undo
      final deletedExpense = _expenses.removeAt(index);

      // Save to Supabase (DELETE operation)
      debugPrint('🗑️ Deleting expense from Supabase: $expenseId');
      await _repository.delete(expenseId);
      debugPrint('✅ Successfully deleted from Supabase: $expenseId');

      // Notify listeners
      notifyListeners();

      return deletedExpense;
    } catch (e) {
      debugPrint('❌ Error deleting expense: $e');
      debugPrint('❌ Error details: ${e.runtimeType}');
      // Restore the expense to the list if delete failed
      // Don't restore yet - let's see the error first
      return null;
    }
  }

  /// Restore a deleted expense (for undo functionality)
  /// Inserts the expense at the specified index to maintain original position
  Future<bool> restoreExpense(Expense expense, int index) async {
    try {
      // Insert at the original position
      _expenses.insert(index, expense);

      // Save to Supabase
      await _repository.create(expense);

      // Notify listeners
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error restoring expense: $e');
      return false;
    }
  }

  /// Get expenses for a specific month
  /// Useful for analytics and filtering
  List<Expense> getExpensesForMonth(DateTime month) {
    return _expenses.where((expense) {
      return expense.date.year == month.year &&
             expense.date.month == month.month;
    }).toList();
  }

  /// Get total spending for a specific month
  double getTotalForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
