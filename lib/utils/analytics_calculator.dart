import '../models/expense.dart';
import '../models/month_total.dart';

/// AnalyticsCalculator provides utility functions for processing expense data
/// into analytics-ready formats for charts and summaries.
///
/// Learning: This is a "utility class" with static methods - like a toolbox of functions.
/// We don't need to create instances of it, just call the methods directly:
/// `AnalyticsCalculator.getTotalForMonth(expenses, month)`
class AnalyticsCalculator {
  // Private constructor to prevent instantiation
  // This class is meant to be used only through its static methods
  AnalyticsCalculator._();

  /// Check if two dates are in the same month and year
  /// Ignores the day component - useful for filtering expenses by month
  ///
  /// Example:
  /// isSameMonth(DateTime(2025, 10, 1), DateTime(2025, 10, 26)) → true
  /// isSameMonth(DateTime(2025, 10, 26), DateTime(2025, 11, 1)) → false
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Get all expenses for a specific month
  ///
  /// Parameters:
  /// - expenses: Full list of all expenses
  /// - month: The month to filter by (day is ignored)
  ///
  /// Returns: List of expenses that occurred in the specified month
  static List<Expense> getExpensesForMonth(
    List<Expense> expenses,
    DateTime month,
  ) {
    return expenses
        .where((expense) => isSameMonth(expense.date, month))
        .toList();
  }

  /// Calculate total spending for a specific month
  ///
  /// Parameters:
  /// - expenses: Full list of all expenses
  /// - month: The month to calculate total for
  ///
  /// Returns: Total amount spent in that month
  static double getTotalForMonth(List<Expense> expenses, DateTime month) {
    final monthExpenses = getExpensesForMonth(expenses, month);

    // fold() is like reduce() - it combines all values into a single result
    // Starting with 0.0, we add each expense's amount
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get spending breakdown by category for a specific month
  ///
  /// Parameters:
  /// - expenses: Full list of all expenses
  /// - month: The month to analyze
  ///
  /// Returns: Map where keys are Vietnamese category names and values are total amounts
  /// Example: {"Cà phê": 250.0, "Đi lại": 100.0, ...} (UPDATED - Phase 5.5.1)
  static Map<String, double> getCategoryBreakdown(
    List<Expense> expenses,
    DateTime month,
  ) {
    final monthExpenses = getExpensesForMonth(expenses, month);
    final breakdown = <String, double>{};

    // Group expenses by category (Vietnamese name) and sum amounts
    for (final expense in monthExpenses) {
      breakdown[expense.categoryNameVi] =
          (breakdown[expense.categoryNameVi] ?? 0.0) + expense.amount;
    }

    return breakdown;
  }

  /// Get spending breakdown by expense type for a specific month (UPDATED - Phase 5.5.1)
  ///
  /// Parameters:
  /// - expenses: Full list of all expenses
  /// - month: The month to analyze
  ///
  /// Returns: Map where keys are Vietnamese type names and values are total amounts
  /// Example: {"Phải chi": 500.0, "Phát sinh": 200.0, ...}
  static Map<String, double> getTypeBreakdown(
    List<Expense> expenses,
    DateTime month,
  ) {
    final monthExpenses = getExpensesForMonth(expenses, month);
    final breakdown = <String, double>{};

    for (final expense in monthExpenses) {
      breakdown[expense.typeNameVi] =
          (breakdown[expense.typeNameVi] ?? 0.0) + expense.amount;
    }

    return breakdown;
  }

  /// Get monthly spending trend for the last N months
  ///
  /// Parameters:
  /// - expenses: Full list of all expenses
  /// - monthCount: Number of months to include (e.g., 6 for last 6 months)
  /// - endMonth: The ending month (defaults to current month)
  ///
  /// Returns: List of MonthTotal objects, ordered from oldest to newest
  /// Example: For monthCount=6, returns [Month1, Month2, ..., Month6]
  static List<MonthTotal> getMonthlyTrend(
    List<Expense> expenses,
    int monthCount, {
    DateTime? endMonth,
  }) {
    // Use current month if endMonth not specified
    final end = endMonth ?? DateTime.now();
    final monthTotals = <MonthTotal>[];

    // Loop backwards from the end month to get the last N months
    for (int i = monthCount - 1; i >= 0; i--) {
      // Calculate the month by subtracting i months from the end month
      final month = DateTime(end.year, end.month - i, 1);
      final total = getTotalForMonth(expenses, month);

      monthTotals.add(MonthTotal(month: month, total: total));
    }

    return monthTotals;
  }

  /// Calculate percentage change between two amounts
  ///
  /// Parameters:
  /// - oldValue: Previous amount
  /// - newValue: Current amount
  ///
  /// Returns: Percentage change (positive = increase, negative = decrease)
  /// Example: percentageChange(100, 120) → 20.0 (20% increase)
  ///          percentageChange(100, 80) → -20.0 (20% decrease)
  static double percentageChange(double oldValue, double newValue) {
    if (oldValue == 0) {
      // Avoid division by zero
      // If old value is 0 and new value is positive, it's infinite increase
      return newValue > 0 ? 100.0 : 0.0;
    }
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Get the previous month from a given date
  ///
  /// Parameters:
  /// - date: The reference date
  ///
  /// Returns: First day of the previous month
  static DateTime getPreviousMonth(DateTime date) {
    // Handle year rollover (January → December of previous year)
    if (date.month == 1) {
      return DateTime(date.year - 1, 12, 1);
    }
    return DateTime(date.year, date.month - 1, 1);
  }

  /// Get the next month from a given date
  ///
  /// Parameters:
  /// - date: The reference date
  ///
  /// Returns: First day of the next month
  static DateTime getNextMonth(DateTime date) {
    // Handle year rollover (December → January of next year)
    if (date.month == 12) {
      return DateTime(date.year + 1, 1, 1);
    }
    return DateTime(date.year, date.month + 1, 1);
  }

  /// Check if a month is in the future
  ///
  /// Parameters:
  /// - month: The month to check
  ///
  /// Returns: true if the month is after the current month
  static bool isFutureMonth(DateTime month) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final checkMonth = DateTime(month.year, month.month, 1);
    return checkMonth.isAfter(currentMonth);
  }

  /// Get the start of the current month
  static DateTime get currentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get the number of days in a given month
  ///
  /// Different months have different lengths:
  /// - January, March, May, July, August, October, December: 31 days
  /// - April, June, September, November: 30 days
  /// - February: 28 days (29 in leap years)
  ///
  /// Learning: DateTime trick for getting days in month
  /// DateTime(year, month + 1, 0) gives us the last day of the current month
  /// Example: DateTime(2025, 11, 0) = October 31, 2025
  ///
  /// Why? Because day 0 of November = last day of October
  static int daysInMonth(DateTime month) {
    // Get the last day of this month by going to day 0 of next month
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    return lastDayOfMonth.day;
  }
}
