import '../models/expense.dart';

/// Abstract interface for expense data operations
///
/// This repository pattern provides a clean separation between
/// business logic and data sources. Implementations can use:
/// - Local storage (SharedPreferences, SQLite)
/// - Cloud storage (Supabase, Firebase)
/// - Mock data (for testing)
///
/// Benefits:
/// - Easy to switch between data sources
/// - Simple to test with mock repositories
/// - Clear contract for all implementations
abstract class ExpenseRepository {
  /// Get all expenses for the current user
  ///
  /// Returns a list of expenses, typically sorted by date (newest first).
  /// For cloud sources, this may include a network call.
  /// For local sources, this reads from device storage.
  Future<List<Expense>> getAll();

  /// Get a single expense by ID
  ///
  /// Returns the expense if found, null otherwise.
  Future<Expense?> getById(String id);

  /// Create a new expense
  ///
  /// The expense should have a unique ID generated before calling.
  /// Returns the created expense (may include server-generated fields).
  Future<Expense> create(Expense expense);

  /// Update an existing expense
  ///
  /// Updates the expense with matching ID.
  /// Throws an exception if the expense doesn't exist.
  Future<Expense> update(Expense expense);

  /// Delete an expense by ID
  ///
  /// For soft-delete implementations, this may just mark as deleted.
  /// For hard-delete, this removes the expense completely.
  Future<void> delete(String id);

  /// Get expenses within a date range
  ///
  /// Useful for analytics and filtering.
  /// Both dates are inclusive.
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end);

  /// Get total count of expenses
  ///
  /// Useful for pagination and statistics.
  Future<int> getCount();
}
