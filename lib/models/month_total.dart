/// MonthTotal represents the total spending for a specific month.
/// Used for analytics and trend visualization.
///
/// Learning: This is a simple data class (also called a "value object" or "DTO").
/// It just holds data without any complex behavior - perfect for passing data to charts.
class MonthTotal {
  /// The month this total represents (only year and month matter, day is ignored)
  final DateTime month;

  /// Total amount spent in this month
  final double total;

  MonthTotal({
    required this.month,
    required this.total,
  });

  /// Helper to get a normalized month (first day of the month)
  /// This ensures all MonthTotal objects for the same month have identical DateTime values
  DateTime get normalizedMonth => DateTime(month.year, month.month, 1);

  /// Format month for display (e.g., "Jan 2025", "Feb 2025")
  String get monthName {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[month.month - 1]} ${month.year}';
  }

  /// Short month name for charts (e.g., "Jan", "Feb")
  String get shortMonthName {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month.month - 1];
  }

  @override
  String toString() => 'MonthTotal(month: $monthName, total: \$${total.toStringAsFixed(2)})';
}
