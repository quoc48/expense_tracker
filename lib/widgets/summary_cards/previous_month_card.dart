import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Card comparing current month spending to previous month
///
/// **Why This Card Exists**
/// Users want to track spending trends: "Am I spending more or less than last month?"
/// Visual feedback (arrow + color) makes trends immediately obvious.
///
/// **Flutter Concept: Conditional UI**
/// We show different icons (↑↓) and colors (red/green) based on the data.
/// This is a fundamental pattern in Flutter: UI adapts to data state.
///
/// **Learning: Percentage Calculations**
/// Formula: ((current - previous) / previous) * 100
/// Example: Previous 2M, Current 2.5M = +25% increase
/// Edge case: If previous is 0, percentage is meaningless (show "New Month")
///
/// **Material Design: Color Psychology**
/// - Green = good (spending decreased)
/// - Red = bad (spending increased)
/// - Grey = neutral (no previous data)
class PreviousMonthCard extends StatelessWidget {
  /// Previous month's total spending
  final double previousMonthAmount;

  /// Current month's total spending (for comparison)
  final double currentMonthAmount;

  /// Optional: Name of the previous month (e.g., "September 2025")
  final String? previousMonthName;

  const PreviousMonthCard({
    super.key,
    required this.previousMonthAmount,
    required this.currentMonthAmount,
    this.previousMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Edge case: No previous month data
    if (previousMonthAmount == 0) {
      return SummaryStatCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.history, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Previous Month',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Empty state
            Center(
              child: Column(
                children: [
                  Icon(Icons.history_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No previous data',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Calculate percentage change
    // Positive = spending increased (bad)
    // Negative = spending decreased (good)
    final percentageChange = ((currentMonthAmount - previousMonthAmount) / previousMonthAmount) * 100;

    // Determine trend direction
    final isIncrease = percentageChange > 0;
    final isDecrease = percentageChange < 0;

    // Choose arrow icon
    IconData trendIcon;
    if (isIncrease) {
      trendIcon = Icons.arrow_upward;  // ↑ spending went up
    } else if (isDecrease) {
      trendIcon = Icons.arrow_downward;  // ↓ spending went down
    } else {
      trendIcon = Icons.remove;  // — no change
    }

    // Choose color (expense context: decrease is good, increase is bad)
    Color trendColor;
    if (isIncrease) {
      trendColor = Colors.red;  // Bad: spending increased
    } else if (isDecrease) {
      trendColor = Colors.green;  // Good: spending decreased
    } else {
      trendColor = Colors.grey;  // Neutral: no change
    }

    return SummaryStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.history, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Previous Month',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Previous month amount
          Text(
            CurrencyFormatter.format(previousMonthAmount, context: CurrencyContext.full),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),

          // Previous month label
          Text(
            previousMonthName ?? 'last month',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Comparison badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trendIcon,
                  size: 16,
                  color: trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentageChange.abs().toStringAsFixed(1)}%',  // Show as "25.5%"
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isIncrease ? 'more' : (isDecrease ? 'less' : 'same'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: trendColor,
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
