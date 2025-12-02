import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/recurring_expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';
import '../repositories/supabase_recurring_expense_repository.dart';

/// Service for handling recurring expense auto-creation logic
///
/// **Purpose:**
/// This service is responsible for automatically creating real expenses
/// from recurring expense templates on the 1st of each month.
///
/// **When to Call:**
/// - On app open (after authentication)
/// - When user manually triggers a refresh
///
/// **Why a Service instead of putting logic in Provider?**
/// - Single Responsibility: Service handles business logic only
/// - Testability: Easier to unit test without UI dependencies
/// - Reusability: Can be called from multiple places (AuthGate, Provider)
/// - Separation of Concerns: Provider manages state, Service manages logic
///
/// **Auto-Creation Flow:**
/// 1. Get all active recurring expenses
/// 2. For each one, check if it needs creation for current month
/// 3. If yes, create a real expense with date = 1st of current month
/// 4. Update the recurring expense's lastCreatedDate
/// 5. Return the list of created expenses (for UI notification)
class RecurringExpenseService {
  final RecurringExpenseRepository _recurringRepo;
  final ExpenseRepository _expenseRepo;
  final _uuid = const Uuid();

  RecurringExpenseService({
    RecurringExpenseRepository? recurringRepo,
    ExpenseRepository? expenseRepo,
  })  : _recurringRepo = recurringRepo ?? SupabaseRecurringExpenseRepository(),
        _expenseRepo = expenseRepo ?? SupabaseExpenseRepository();

  /// Process all recurring expenses and create any needed for current month
  ///
  /// **Returns:** List of expenses that were created (can be empty)
  ///
  /// **Example Usage:**
  /// ```dart
  /// final service = RecurringExpenseService();
  /// final created = await service.processRecurringExpenses();
  /// if (created.isNotEmpty) {
  ///   showSnackBar('Created ${created.length} recurring expenses');
  /// }
  /// ```
  Future<List<Expense>> processRecurringExpenses() async {
    final now = DateTime.now();
    final createdExpenses = <Expense>[];

    try {
      // Get all active recurring expenses
      final activeRecurring = await _recurringRepo.getActive();
      debugPrint('🔄 Processing ${activeRecurring.length} active recurring expenses');

      for (final recurring in activeRecurring) {
        // Check if this recurring expense needs creation for current month
        if (recurring.needsCreationForMonth(now)) {
          try {
            // Create the expense for 1st of current month
            final expense = await _createExpenseFromRecurring(recurring, now);
            createdExpenses.add(expense);

            // Update the last created date
            await _recurringRepo.updateLastCreatedDate(recurring.id, now);

            debugPrint('✅ Created expense from recurring: ${recurring.description}');
          } catch (e) {
            // Log error but continue with other recurring expenses
            debugPrint('❌ Failed to create expense from recurring ${recurring.id}: $e');
          }
        }
      }

      if (createdExpenses.isNotEmpty) {
        debugPrint('🎉 Created ${createdExpenses.length} expenses from recurring templates');
      }

      return createdExpenses;
    } catch (e) {
      debugPrint('❌ Error processing recurring expenses: $e');
      return [];
    }
  }

  /// Create a real expense from a recurring expense template
  ///
  /// **Date Logic:**
  /// The expense is created with date = 1st of the current month
  /// This is consistent regardless of when the user opens the app
  Future<Expense> _createExpenseFromRecurring(
    RecurringExpense recurring,
    DateTime now,
  ) async {
    // Create expense for 1st of current month
    final expenseDate = DateTime(now.year, now.month, 1);

    final expense = Expense(
      id: _uuid.v4(),
      description: recurring.description,
      amount: recurring.amount,
      categoryNameVi: recurring.categoryNameVi,
      typeNameVi: recurring.typeNameVi,
      date: expenseDate,
      note: recurring.note != null
          ? '${recurring.note} (Recurring)'
          : '(Recurring)',
    );

    // Save to database
    return await _expenseRepo.create(expense);
  }

  /// Check if there are any recurring expenses that need processing
  ///
  /// **Use Case:**
  /// Show a badge or notification in settings if recurring expenses
  /// are pending creation. This is a lightweight check without creating.
  Future<int> getPendingCount() async {
    final now = DateTime.now();
    final activeRecurring = await _recurringRepo.getActive();

    int pending = 0;
    for (final recurring in activeRecurring) {
      if (recurring.needsCreationForMonth(now)) {
        pending++;
      }
    }

    return pending;
  }

  /// Force create expense for a specific recurring expense
  ///
  /// **Use Case:**
  /// User manually triggers creation from the management screen
  /// (e.g., "Create Now" button for testing or catch-up)
  Future<Expense?> forceCreateExpense(String recurringId) async {
    try {
      final recurring = await _recurringRepo.getById(recurringId);
      if (recurring == null) {
        debugPrint('❌ Recurring expense not found: $recurringId');
        return null;
      }

      final now = DateTime.now();
      final expense = await _createExpenseFromRecurring(recurring, now);
      await _recurringRepo.updateLastCreatedDate(recurringId, now);

      return expense;
    } catch (e) {
      debugPrint('❌ Error force creating expense: $e');
      return null;
    }
  }
}
