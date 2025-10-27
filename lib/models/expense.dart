import 'package:flutter/material.dart';

// Enum: A special type that represents a fixed set of constant values
// ExpenseType classifies how necessary the expense was
enum ExpenseType {
  mustHave,    // Essential expenses (rent, groceries, utilities)
  niceToHave,  // Discretionary but reasonable (dining out, entertainment)
  wasted,      // Regrettable spending (impulse purchases, unused subscriptions)
}

// Category enum for organizing expenses by type
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

// Extension: Adds custom methods to existing enums
// This helps us display user-friendly names and get appropriate icons
extension ExpenseTypeExtension on ExpenseType {
  // Display name for UI (Vietnamese)
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

  // Color coding for visual feedback
  Color get color {
    switch (this) {
      case ExpenseType.mustHave:
        return Colors.green;
      case ExpenseType.niceToHave:
        return Colors.orange;
      case ExpenseType.wasted:
        return Colors.red;
    }
  }
}

extension CategoryExtension on Category {
  // Display name for UI (Vietnamese)
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

  // Icon for each category
  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transportation:
        return Icons.directions_car;
      case Category.utilities:
        return Icons.lightbulb;
      case Category.entertainment:
        return Icons.movie;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.health:
        return Icons.medical_services;
      case Category.education:
        return Icons.school;
      case Category.other:
        return Icons.more_horiz;
    }
  }
}

// The Expense class: Blueprint for expense data
// This is a simple Dart class (PODO - Plain Old Dart Object)
class Expense {
  // Properties (fields) - these are final because we'll create new objects for edits
  final String id;
  final String description;
  final double amount;
  final Category category;
  final ExpenseType type;
  final DateTime date;
  final String? note; // The ? makes this nullable (optional)

  // Constructor: Special method called when creating a new Expense object
  // 'required' means these parameters must be provided
  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note, // Optional parameter (nullable)
  });

  // Named constructor for creating an Expense from a Map (JSON data)
  // This is essential for loading data from storage
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      // Convert string back to enum
      category: Category.values.firstWhere(
        (c) => c.name == map['category'],
      ),
      type: ExpenseType.values.firstWhere(
        (t) => t.name == map['type'],
      ),
      // Parse ISO8601 string back to DateTime
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  // Convert Expense object to Map (for JSON storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category.name, // Convert enum to string
      'type': type.name,
      'date': date.toIso8601String(), // Convert DateTime to ISO8601 string
      'note': note,
    };
  }

  // CopyWith method: Creates a new Expense with some fields changed
  // This is the immutable pattern - we don't modify existing objects
  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    Category? category,
    ExpenseType? type,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
