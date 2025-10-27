import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';

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

  /// Add a new expense to the list
  /// Returns true if successful, false otherwise
  /// [categoryNameVi] and [typeNameVi] preserve the exact Vietnamese names from the form
  Future<bool> addExpense(Expense expense, {String? categoryNameVi, String? typeNameVi}) async {
    try {
      // Add to in-memory list
      _expenses.add(expense);

      // Sort by date (newest first)
      _expenses.sort((a, b) => b.date.compareTo(a.date));

      // Save to Supabase with original Vietnamese names
      await _repository.create(expense, categoryNameVi: categoryNameVi, typeNameVi: typeNameVi);

      // Notify listeners that the data has changed
      // This will trigger a rebuild in all listening widgets
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      // Remove the expense if save failed
      _expenses.remove(expense);
      notifyListeners();
      return false;
    }
  }

  /// Update an existing expense
  /// Returns true if successful, false otherwise
  /// [categoryNameVi] and [typeNameVi] preserve the exact Vietnamese names from the form
  Future<bool> updateExpense(Expense updatedExpense, {String? categoryNameVi, String? typeNameVi}) async {
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

      // Save to Supabase with original Vietnamese names
      await _repository.update(updatedExpense, categoryNameVi: categoryNameVi, typeNameVi: typeNameVi);

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

      // Save to Supabase
      await _repository.delete(expenseId);

      // Notify listeners
      notifyListeners();

      return deletedExpense;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
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
