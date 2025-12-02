import '../models/recurring_expense.dart';

/// Abstract interface for recurring expense data operations
///
/// **Repository Pattern Benefits:**
/// - Clean separation between business logic and data sources
/// - Easy to switch implementations (Supabase, SQLite, mock)
/// - Simple to test with mock repositories
/// - Clear contract for all implementations
///
/// **Recurring Expense Operations:**
/// Unlike regular expenses, recurring expenses need additional operations:
/// - Toggle active/inactive status (pause/resume)
/// - Update `lastCreatedDate` after auto-creation
/// - Get only active expenses for auto-creation logic
abstract class RecurringExpenseRepository {
  /// Get all recurring expenses for the current user
  ///
  /// Returns both active and inactive expenses.
  /// Typically used for the management list screen.
  Future<List<RecurringExpense>> getAll();

  /// Get only active recurring expenses
  ///
  /// Used by the auto-creation service to check which
  /// expenses need to generate real expenses this month.
  Future<List<RecurringExpense>> getActive();

  /// Get a single recurring expense by ID
  ///
  /// Returns the expense if found, null otherwise.
  Future<RecurringExpense?> getById(String id);

  /// Create a new recurring expense template
  ///
  /// The expense should have a unique ID generated before calling.
  /// Returns the created recurring expense.
  Future<RecurringExpense> create(RecurringExpense expense);

  /// Update an existing recurring expense
  ///
  /// Updates fields like description, amount, category, type, note.
  /// For pause/resume, prefer using [toggleActive] instead.
  Future<RecurringExpense> update(RecurringExpense expense);

  /// Toggle the active status (pause/resume)
  ///
  /// Simpler than full update when just changing active state.
  /// Returns the updated recurring expense.
  Future<RecurringExpense> toggleActive(String id, bool isActive);

  /// Update the last created date after auto-creation
  ///
  /// Called by RecurringExpenseService after successfully creating
  /// a real expense from this template.
  ///
  /// **Important:** This should be called AFTER the real expense
  /// is successfully created to avoid creating duplicates if
  /// the expense creation fails.
  Future<void> updateLastCreatedDate(String id, DateTime date);

  /// Delete a recurring expense template
  ///
  /// This is a hard delete - the template is permanently removed.
  /// Note: Already-created expenses are NOT affected.
  Future<void> delete(String id);

  /// Get available categories (delegates to expense repository)
  ///
  /// Returns Vietnamese category names from Supabase.
  Future<List<String>> getCategories();

  /// Get available expense types (delegates to expense repository)
  ///
  /// Returns Vietnamese expense type names from Supabase.
  Future<List<String>> getExpenseTypes();
}
