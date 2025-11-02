import 'package:intl/intl.dart';

/// Context for currency formatting - determines how numbers are displayed
enum CurrencyContext {
  /// Full format with thousand separators and currency symbol
  /// Example: "50.000₫" (Vietnamese period separator)
  full,

  /// Compact format for charts and small spaces
  /// Example: "50k", "1.2M"
  compact,

  /// Short compact with currency symbol
  /// Example: "50k₫", "1.2M₫"
  shortCompact,
}

/// Utility class for formatting Vietnamese đồng (₫) amounts
///
/// Features:
/// - Vietnamese number formatting (period as thousands separator)
/// - Integer-only (no decimals for đồng)
/// - Context-based formatting (full, compact, shortCompact)
///
/// Usage:
/// ```dart
/// CurrencyFormatter.format(50000, context: CurrencyContext.full);  // "50.000₫"
/// CurrencyFormatter.format(50000, context: CurrencyContext.compact);  // "50k"
/// CurrencyFormatter.format(1500000, context: CurrencyContext.shortCompact);  // "1.5M₫"
/// ```
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Currency symbol for Vietnamese đồng
  static const String currencySymbol = '₫';

  /// Format amount based on context
  ///
  /// Parameters:
  /// - amount: The numeric amount to format
  /// - context: The formatting context (defaults to full)
  ///
  /// Returns formatted string appropriate for the context
  static String format(
    double amount, {
    CurrencyContext context = CurrencyContext.full,
  }) {
    switch (context) {
      case CurrencyContext.full:
        return formatFull(amount);
      case CurrencyContext.compact:
        return formatCompact(amount);
      case CurrencyContext.shortCompact:
        return formatShortCompact(amount);
    }
  }

  /// Format with full Vietnamese style: "50.000₫"
  /// Uses period (.) as thousands separator, no decimals
  static String formatFull(double amount) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0,
      locale: 'vi_VN',  // Vietnamese locale uses period as separator
    );
    return formatter.format(amount);
  }

  /// Format in compact style for charts: "50k", "8.5m", "1.5b"
  /// No currency symbol, uses lowercase k/m/b suffixes
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      // Billions: 1.5b (lowercase)
      return '${(amount / 1000000000).toStringAsFixed(1)}b';
    } else if (amount >= 1000000) {
      // Millions: 8.5m (lowercase)
      final millions = amount / 1000000;
      return millions >= 10
          ? '${millions.toStringAsFixed(0)}m'  // 10m, 15m (no decimals)
          : '${millions.toStringAsFixed(1)}m';  // 8.5m, 9.8m (1 decimal)
    } else if (amount >= 1000) {
      // Thousands: 50k
      final thousands = amount / 1000;
      return thousands >= 10
          ? '${thousands.toStringAsFixed(0)}k'  // 50k (no decimals)
          : '${thousands.toStringAsFixed(1)}k';  // 1.5k (1 decimal)
    } else {
      // Less than 1000: show full number
      return amount.toStringAsFixed(0);
    }
  }

  /// Format in short compact style with symbol: "50k₫", "8.5m₫"
  /// Same as compact but includes currency symbol
  static String formatShortCompact(double amount) {
    return '${formatCompact(amount)}$currencySymbol';
  }

  /// Helper method to parse formatted string back to double
  /// Useful for form validation and editing
  ///
  /// Handles:
  /// - Vietnamese formatting: "50.000" -> 50000.0
  /// - Raw numbers: "50000" -> 50000.0
  /// - Invalid input: returns null
  static double? parse(String input) {
    if (input.isEmpty) return null;

    // Remove currency symbol and whitespace
    String cleaned = input
        .replaceAll(currencySymbol, '')
        .replaceAll(' ', '')
        .trim();

    // Remove thousand separators (periods in Vietnamese, commas in international)
    cleaned = cleaned.replaceAll('.', '').replaceAll(',', '');

    // Try to parse
    return double.tryParse(cleaned);
  }

  /// Format for input fields (no formatting, just raw number)
  /// This is for displaying the editable value in TextFormField
  ///
  /// Example: 50000.0 -> "50000"
  static String formatForInput(double amount) {
    return amount.toStringAsFixed(0);
  }
}
