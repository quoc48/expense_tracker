import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Enhanced card displaying this month's total spending with daily average
/// and previous month comparison (PRIMARY CARD)
///
/// **Why This Card Exists**
/// Consolidates all key monthly metrics in one place:
/// - Total spending this month
/// - Daily average (normalized for month length)
/// - Previous month comparison with trend
///
/// **Material Design 3: Visual Hierarchy**
/// This is the PRIMARY card - it gets:
/// - Higher elevation (4dp vs 2dp)
/// - Larger text size
/// - Primary color accent
/// - Full width
/// - Divider to separate main stat from secondary stats
class MonthlyTotalCard extends StatelessWidget {
  /// The total amount spent this month
  final double totalAmount;

  /// Daily average spending
  final double dailyAverage;

  /// Number of days in the month
  final int daysInMonth;

  /// Previous month's total spending
  final double previousMonthAmount;

  /// Previous month name (e.g., "September 2025")
  final String previousMonthName;

  const MonthlyTotalCard({
    super.key,
    required this.totalAmount,
    required this.dailyAverage,
    required this.daysInMonth,
    required this.previousMonthAmount,
    required this.previousMonthName,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme for consistent colors and text styles
    final theme = Theme.of(context);

    // Calculate percentage change for comparison badge
    final percentageChange = previousMonthAmount > 0
        ? ((totalAmount - previousMonthAmount) / previousMonthAmount) * 100
        : 0.0;
    final isIncrease = percentageChange > 0;
    final isDecrease = percentageChange < 0;
    final trendColor = isIncrease ? Colors.red : (isDecrease ? Colors.green : Colors.grey);
    final trendIcon = isIncrease ? Icons.arrow_upward : (isDecrease ? Icons.arrow_downward : Icons.remove);

    return SummaryStatCard(
      isPrimary: true,  // Higher elevation, more prominent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main amount (LARGE and prominent)
          Text(
            CurrencyFormatter.format(totalAmount, context: CurrencyContext.full),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),

          // "Total Spending" sublabel
          Text(
            'Total Spending',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 12),

          // Row with Daily Average and Previous Month
          Row(
            children: [
              // LEFT: Daily Average section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Daily Avg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(dailyAverage, context: CurrencyContext.shortCompact),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month, size: 12, color: Colors.grey[700]),
                          const SizedBox(width: 2),
                          Text(
                            '$daysInMonth days',
                            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                height: 60,
                width: 1,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // RIGHT: Previous Month section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Previous',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(previousMonthAmount, context: CurrencyContext.shortCompact),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (previousMonthAmount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(trendIcon, size: 12, color: trendColor),
                            const SizedBox(width: 2),
                            Text(
                              '${percentageChange.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: trendColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
