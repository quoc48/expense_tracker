import 'package:flutter/material.dart';
import '../theme/minimalist/minimalist_icons.dart';
import '../theme/minimalist/minimalist_colors.dart';

// Legacy enums kept for backward compatibility and icon/color lookup
// These are NO LONGER used as data fields, only for UI helpers
enum ExpenseType {
  mustHave,
  niceToHave,
  wasted,
}

enum Category {
  food,
  transportation,
  utilities,
  entertainment,
  shopping,
  health,
  education,
  other,
}

// Extension methods for getting colors and icons
// These map Vietnamese names to UI elements
extension ExpenseTypeExtension on ExpenseType {
  String get displayName {
    switch (this) {
      case ExpenseType.mustHave:
        return 'Phải chi';
      case ExpenseType.niceToHave:
        return 'Phát sinh';
      case ExpenseType.wasted:
        return 'Lãng phí';
    }
  }

  /// Old color getter - kept for backward compatibility but using grayscale
  /// Use Expense.typeColor instead for consistent minimalist colors
  Color get color {
    switch (this) {
      case ExpenseType.mustHave:
        return MinimalistColors.gray850;  // Strong emphasis
      case ExpenseType.niceToHave:
        return MinimalistColors.gray600;  // Labels
      case ExpenseType.wasted:
        return MinimalistColors.gray500;  // Secondary
    }
  }
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return 'Thực phẩm';
      case Category.transportation:
        return 'Đi lại';
      case Category.utilities:
        return 'Hoá đơn';
      case Category.entertainment:
        return 'Giải trí';
      case Category.shopping:
        return 'Tạp hoá';
      case Category.health:
        return 'Sức khỏe';
      case Category.education:
        return 'Giáo dục';
      case Category.other:
        return 'Khác';
    }
  }

  IconData get icon {
    // Use centralized Phosphor icons via Vietnamese display name
    return MinimalistIcons.getCategoryIcon(displayName);
  }
}

/// The NEW Expense class: Using Vietnamese strings as source of truth
///
/// Architecture Change (Phase 5.5.1):
/// - BEFORE: Stored Category/ExpenseType enums → lost precision ("Cà phê" became "Thực phẩm")
/// - AFTER: Store Vietnamese strings directly from Supabase → perfect preservation
///
/// Benefits:
/// - No data loss (Cà phê stays Cà phê)
/// - No hardcoded mappings (Supabase is source of truth)
/// - Future-proof (add new categories in Supabase without code changes)
/// - Flexible (icons/colors determined dynamically)
class Expense {
  final String id;
  final String description;
  final double amount;

  // NEW: Store Vietnamese names directly (not enums!)
  final String categoryNameVi;  // e.g., "Cà phê", "Du lịch", "TẾT"
  final String typeNameVi;      // e.g., "Phải chi", "Phát sinh", "Lãng phí"

  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryNameVi,
    required this.typeNameVi,
    required this.date,
    this.note,
  });

  /// Get icon for category based on Vietnamese name
  /// Now uses centralized Phosphor icon mapping from MinimalistIcons
  IconData get categoryIcon {
    // Use centralized icon mapping (exactly 14 categories)
    return MinimalistIcons.getCategoryIcon(categoryNameVi);
  }

  /// Get color for expense type based on Vietnamese name
  /// Updated for minimalist design: subtle grayscale variations
  Color get typeColor {
    switch (typeNameVi) {
      case 'Phải chi':  // Must have - darkest (most important)
        return MinimalistColors.gray850;  // Strong emphasis
      case 'Phát sinh': // Nice to have - medium
        return MinimalistColors.gray600;  // Labels
      case 'Lãng phí':  // Wasted - lightest (least desirable)
        return MinimalistColors.gray500;  // Secondary
      default:
        return MinimalistColors.gray400;  // Disabled
    }
  }

  /// Factory constructor for creating from Supabase row
  /// This is simpler now - no enum conversion needed!
  factory Expense.fromSupabaseRow(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      categoryNameVi: row['categories']?['name_vi'] as String? ?? 'Khác',
      typeNameVi: row['expense_types']?['name_vi'] as String? ?? 'Phát sinh',
      date: DateTime.parse(row['date'] as String),
      note: row['note'] as String?,
    );
  }

  /// Legacy method for backward compatibility with local storage
  /// (if we still use SharedPreferences anywhere)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      categoryNameVi: map['categoryNameVi'] as String? ?? 'Khác',
      typeNameVi: map['typeNameVi'] as String? ?? 'Phát sinh',
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'categoryNameVi': categoryNameVi,
      'typeNameVi': typeNameVi,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  /// CopyWith for immutable updates
  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? categoryNameVi,
    String? typeNameVi,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryNameVi: categoryNameVi ?? this.categoryNameVi,
      typeNameVi: typeNameVi ?? this.typeNameVi,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
