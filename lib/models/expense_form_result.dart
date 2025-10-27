import 'expense.dart';

/// Result returned from the Add/Edit Expense form
///
/// Contains both the expense object and the original Vietnamese names
/// selected by the user. This preserves the exact category/type
/// to avoid data loss during save operations.
class ExpenseFormResult {
  final Expense expense;
  final String categoryNameVi;
  final String typeNameVi;

  ExpenseFormResult({
    required this.expense,
    required this.categoryNameVi,
    required this.typeNameVi,
  });
}
