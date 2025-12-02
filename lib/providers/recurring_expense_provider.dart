import 'package:flutter/foundation.dart';
import '../models/recurring_expense.dart';
import '../repositories/recurring_expense_repository.dart';
import '../repositories/supabase_recurring_expense_repository.dart';
import '../services/recurring_expense_service.dart';

/// Provider for managing recurring expense state
///
/// **Responsibilities:**
/// - Load and cache recurring expenses
/// - CRUD operations with optimistic UI updates
/// - Separate active/inactive lists for grouped display
/// - Coordinate with RecurringExpenseService for auto-creation
///
/// **Usage in UI:**
/// ```dart
/// // Access in widget
/// final provider = context.watch<RecurringExpenseProvider>();
///
/// // Load data
/// await provider.loadRecurringExpenses();
///
/// // Get grouped lists
/// final active = provider.activeExpenses;
/// final inactive = provider.inactiveExpenses;
/// ```
class RecurringExpenseProvider extends ChangeNotifier {
  // Private state
  List<RecurringExpense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  // Repository for data access
  final RecurringExpenseRepository _repository;

  // Service for auto-creation (optional, can be injected)
  final RecurringExpenseService _service;

  // Cache for category/type dropdowns
  List<String>? _categories;
  List<String>? _expenseTypes;

  RecurringExpenseProvider({
    RecurringExpenseRepository? repository,
    RecurringExpenseService? service,
  })  : _repository = repository ?? SupabaseRecurringExpenseRepository(),
        _service = service ?? RecurringExpenseService();

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// All recurring expenses (both active and inactive)
  List<RecurringExpense> get expenses => _expenses;

  /// Only active recurring expenses
  List<RecurringExpense> get activeExpenses =>
      _expenses.where((e) => e.isActive).toList();

  /// Only inactive (paused) recurring expenses
  List<RecurringExpense> get inactiveExpenses =>
      _expenses.where((e) => !e.isActive).toList();

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Error message if last operation failed
  String? get error => _error;

  /// Total count of recurring expenses
  int get count => _expenses.length;

  /// Count of active recurring expenses
  int get activeCount => activeExpenses.length;

  /// Count of inactive recurring expenses
  int get inactiveCount => inactiveExpenses.length;

  /// Cached categories for dropdowns
  List<String>? get categories => _categories;

  /// Cached expense types for dropdowns
  List<String>? get expenseTypes => _expenseTypes;

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load all recurring expenses from database
  ///
  /// Also loads categories and expense types for dropdowns.
  Future<void> loadRecurringExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAll();

      // Load dropdown data if not cached
      _categories ??= await _repository.getCategories();
      _expenseTypes ??= await _repository.getExpenseTypes();

      debugPrint('✅ Loaded ${_expenses.length} recurring expenses');
    } catch (e) {
      _error = 'Failed to load recurring expenses: $e';
      debugPrint('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data from database
  Future<void> refresh() async {
    await loadRecurringExpenses();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new recurring expense
  ///
  /// Uses optimistic UI: adds to list immediately, then saves to database.
  /// On failure, removes from list and shows error.
  Future<bool> createRecurringExpense(RecurringExpense expense) async {
    try {
      // Optimistic update
      _expenses.add(expense);
      _sortExpenses();
      notifyListeners();

      // Save to database
      final saved = await _repository.create(expense);

      // Update with server response (may have different ID)
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = saved;
        notifyListeners();
      }

      _error = null;
      return true;
    } catch (e) {
      // Rollback optimistic update
      _expenses.removeWhere((e) => e.id == expense.id);
      _error = 'Failed to create recurring expense: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing recurring expense
  Future<bool> updateRecurringExpense(RecurringExpense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) {
      _error = 'Recurring expense not found';
      return false;
    }

    final original = _expenses[index];

    try {
      // Optimistic update
      _expenses[index] = expense;
      _sortExpenses();
      notifyListeners();

      // Save to database
      final saved = await _repository.update(expense);
      _expenses[index] = saved;

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback
      _expenses[index] = original;
      _error = 'Failed to update recurring expense: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Toggle active status (pause/resume)
  ///
  /// Simpler than full update - just flips the isActive flag.
  Future<bool> toggleActive(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) {
      _error = 'Recurring expense not found';
      return false;
    }

    final original = _expenses[index];
    final newActive = !original.isActive;

    try {
      // Optimistic update
      _expenses[index] = original.copyWith(isActive: newActive);
      _sortExpenses();
      notifyListeners();

      // Save to database
      final saved = await _repository.toggleActive(id, newActive);
      _expenses[index] = saved;

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback
      _expenses[index] = original;
      _error = 'Failed to toggle status: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Delete a recurring expense
  ///
  /// Returns the deleted expense for potential undo.
  Future<RecurringExpense?> deleteRecurringExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) {
      _error = 'Recurring expense not found';
      return null;
    }

    final deleted = _expenses[index];

    try {
      // Optimistic update
      _expenses.removeAt(index);
      notifyListeners();

      // Delete from database
      await _repository.delete(id);

      _error = null;
      return deleted;
    } catch (e) {
      // Rollback
      _expenses.insert(index, deleted);
      _error = 'Failed to delete recurring expense: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-CREATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Process all recurring expenses and create needed monthly expenses
  ///
  /// **Called from:** AuthGate on app open (after login)
  ///
  /// **Returns:** Number of expenses created
  Future<int> processAutoCreation() async {
    try {
      final created = await _service.processRecurringExpenses();

      // Refresh to update lastCreatedDate values
      if (created.isNotEmpty) {
        await loadRecurringExpenses();
      }

      return created.length;
    } catch (e) {
      debugPrint('❌ Error in auto-creation: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sort expenses: active first, then by description
  void _sortExpenses() {
    _expenses.sort((a, b) {
      // Active expenses first
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }
      // Then by description alphabetically
      return a.description.compareTo(b.description);
    });
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
