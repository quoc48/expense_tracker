import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Card showing average spending per day this month
///
/// **Why This Card Exists**
/// Different months have different lengths (28-31 days).
/// Daily average normalizes spending across months for fair comparison.
/// "Am I spending 1M/day or 500k/day on average?"
///
/// **Flutter Concept: Calculated Properties**
/// Instead of storing the daily average, we calculate it on the fly
/// from totalAmount and daysInMonth. This keeps data in sync automatically.
///
/// **Learning: Division and Edge Cases**
/// We must handle division by zero (daysInMonth could be 0 in theory).
/// Flutter best practice: handle edge cases gracefully with empty states.
class DailyAverageCard extends StatelessWidget {
  /// Total spending for the month
  final double totalAmount;

  /// Number of days in the current month (28-31)
  /// Used to calculate: average = totalAmount / daysInMonth
  final int daysInMonth;

  const DailyAverageCard({
    super.key,
    required this.totalAmount,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Edge case: Protect against division by zero
    if (daysInMonth == 0 || totalAmount == 0) {
      return SummaryStatCard(
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No spending data',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Calculate daily average
    // Example: 30,000,000 VND / 31 days = ~967,742 VND/day
    final dailyAverage = totalAmount / daysInMonth;

    return SummaryStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.today, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Daily Average',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily average amount
          Text(
            CurrencyFormatter.format(dailyAverage, context: CurrencyContext.full),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),

          // Explanation text
          Text(
            'per day this month',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Context: Days in month
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '$daysInMonth days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
