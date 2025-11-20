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

  /// Load all expenses from Supabase
  /// This should be called once when the app starts
  /// Fetches all expenses for the authenticated user
  Future<void> loadExpenses() async {
    _isLoading = true;
    // Notify listeners that loading has started
    // This allows UI to show a loading indicator
    notifyListeners();

    try {
      _expenses = await _repository.getAll();
      debugPrint('Loaded ${_expenses.length} expenses from Supabase');
    } catch (e) {
      // In production, you'd want proper error handling here
      debugPrint('Error loading expenses: $e');
      _expenses = [];
    } finally {
      _isLoading = false;
      // Notify listeners that loading is complete and data is ready
      notifyListeners();
    }
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
