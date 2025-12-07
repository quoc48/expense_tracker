import 'package:flutter/material.dart';
import '../theme/minimalist/minimalist_icons.dart';

/// RecurringExpense model for automatic monthly expense creation
///
/// **Feature Overview:**
/// Recurring expenses are templates that automatically create real expenses
/// on the 1st of each month when the user opens the app.
///
/// **Key Fields:**
/// - `categoryNameVi` / `typeNameVi`: Vietnamese strings from Supabase (same as Expense)
/// - `lastCreatedDate`: Tracks when the last expense was auto-created
/// - `isActive`: Allows pausing without deleting (resume later)
/// - `startDate`: When this recurring expense was created
///
/// **Auto-Creation Logic:**
/// On app open, check each active recurring expense:
/// 1. Get current month (e.g., December 2025)
/// 2. If `lastCreatedDate` is null OR month < current month → create expense
/// 3. Update `lastCreatedDate` to current month
///
/// **Why store Vietnamese names directly?**
/// Same as Expense model - Supabase is the source of truth for categories/types.
/// This avoids enum mappings and preserves exact category names.
class RecurringExpense {
  final String id;
  final String description;
  final double amount;

  // Vietnamese names directly from Supabase (no enum conversion)
  final String categoryNameVi; // e.g., "Hoá đơn", "Giải trí"
  final String typeNameVi; // e.g., "Phải chi", "Phát sinh"

  // Recurring-specific fields
  final DateTime startDate; // When this template was created
  final DateTime? lastCreatedDate; // Last time an expense was auto-created
  final bool isActive; // Can pause/resume without deleting

  final String? note;

  RecurringExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryNameVi,
    required this.typeNameVi,
    required this.startDate,
    this.lastCreatedDate,
    this.isActive = true,
    this.note,
  });

  /// Get icon for category based on Vietnamese name
  /// Uses the same centralized icon mapping as Expense
  IconData get categoryIcon {
    return MinimalistIcons.getCategoryIconFill(categoryNameVi);
  }

  /// Factory constructor for creating from Supabase row
  ///
  /// **Database Schema (recurring_expenses table):**
  /// - id: UUID (primary key)
  /// - user_id: UUID (foreign key to auth.users)
  /// - category_id: UUID (foreign key to categories)
  /// - type_id: UUID (foreign key to expense_types)
  /// - description: text
  /// - amount: numeric
  /// - start_date: date
  /// - last_created_date: date (nullable)
  /// - is_active: boolean (default true)
  /// - note: text (nullable)
  factory RecurringExpense.fromSupabaseRow(Map<String, dynamic> row) {
    return RecurringExpense(
      id: row['id'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      categoryNameVi: row['categories']?['name_vi'] as String? ?? 'Khác',
      typeNameVi: row['expense_types']?['name_vi'] as String? ?? 'Phát sinh',
      startDate: DateTime.parse(row['start_date'] as String),
      lastCreatedDate: row['last_created_date'] != null
          ? DateTime.parse(row['last_created_date'] as String)
          : null,
      isActive: row['is_active'] as bool? ?? true,
      note: row['note'] as String?,
    );
  }

  /// Convert to Map for local storage (if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'categoryNameVi': categoryNameVi,
      'typeNameVi': typeNameVi,
      'startDate': startDate.toIso8601String(),
      'lastCreatedDate': lastCreatedDate?.toIso8601String(),
      'isActive': isActive,
      'note': note,
    };
  }

  /// CopyWith for immutable updates
  ///
  /// **Usage:**
  /// ```dart
  /// // Pause a recurring expense
  /// final paused = expense.copyWith(isActive: false);
  ///
  /// // Update last created date after auto-creation
  /// final updated = expense.copyWith(lastCreatedDate: DateTime.now());
  /// ```
  RecurringExpense copyWith({
    String? id,
    String? description,
    double? amount,
    String? categoryNameVi,
    String? typeNameVi,
    DateTime? startDate,
    DateTime? lastCreatedDate,
    bool? isActive,
    String? note,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryNameVi: categoryNameVi ?? this.categoryNameVi,
      typeNameVi: typeNameVi ?? this.typeNameVi,
      startDate: startDate ?? this.startDate,
      lastCreatedDate: lastCreatedDate ?? this.lastCreatedDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
    );
  }

  /// Check if expense needs to be created for current month
  ///
  /// Returns true if:
  /// 1. This is an active recurring expense, AND
  /// 2. Current month is AFTER the month when recurring was created, AND
  /// 3. Either never created before (lastCreatedDate is null), OR
  ///    last creation was before current month
  ///
  /// **Example 1 - New recurring, same month:**
  /// - Today: Dec 2, 2025
  /// - startDate: Dec 2, 2025 (just created)
  /// - lastCreatedDate: null
  /// - Result: false (don't create until Jan 2026)
  ///
  /// **Example 2 - New recurring, next month:**
  /// - Today: Jan 5, 2026
  /// - startDate: Dec 2, 2025
  /// - lastCreatedDate: null
  /// - Result: true (create for January)
  ///
  /// **Example 3 - Existing recurring:**
  /// - Today: Dec 2, 2025
  /// - startDate: Oct 15, 2025
  /// - lastCreatedDate: Nov 1, 2025
  /// - Result: true (need to create for December)
  bool needsCreationForMonth(DateTime currentDate) {
    if (!isActive) return false;

    // Compare year and month only
    final currentYearMonth = currentDate.year * 12 + currentDate.month;
    final startYearMonth = startDate.year * 12 + startDate.month;

    // Don't create expense for the same month the recurring was created
    // First expense should be created starting from the NEXT month
    if (currentYearMonth <= startYearMonth) return false;

    // If never created before, need to create
    if (lastCreatedDate == null) return true;

    // Otherwise, check if we've already created for current month
    final lastYearMonth =
        lastCreatedDate!.year * 12 + lastCreatedDate!.month;

    return currentYearMonth > lastYearMonth;
  }

  @override
  String toString() {
    return 'RecurringExpense(id: $id, description: $description, amount: $amount, '
        'category: $categoryNameVi, type: $typeNameVi, isActive: $isActive, '
        'lastCreated: $lastCreatedDate)';
  }
}
