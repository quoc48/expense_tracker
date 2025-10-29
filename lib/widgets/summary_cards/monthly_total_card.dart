import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Card displaying this month's total spending (PRIMARY CARD)
///
/// **Why This Card Exists**
/// The most important metric users want to see immediately:
/// "How much did I spend this month?"
///
/// **Material Design 3: Visual Hierarchy**
/// This is the PRIMARY card - it gets:
/// - Higher elevation (4dp vs 2dp)
/// - Larger text size
/// - Primary color accent
/// - Full width (spans 2 columns in grid)
///
/// **Learning: StatelessWidget**
/// This widget doesn't need to track state (no user interaction).
/// It just displays data passed to it. StatelessWidget is perfect for this.
class MonthlyTotalCard extends StatelessWidget {
  /// The total amount spent this month
  final double totalAmount;

  /// Optional: Month name to display (e.g., "October 2025")
  /// If null, defaults to "This Month"
  final String? monthName;

  const MonthlyTotalCard({
    super.key,
    required this.totalAmount,
    this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme for consistent colors and text styles
    final theme = Theme.of(context);

    return SummaryStatCard(
      isPrimary: true,  // Higher elevation, more prominent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // Align text to left
        children: [
          // Header label
          Text(
            monthName ?? 'This Month',  // Use provided name or default
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],  // Subtle color for label
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),  // Spacing between label and amount

          // Main amount (LARGE and prominent)
          Text(
            CurrencyFormatter.format(totalAmount, context: CurrencyContext.full),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,  // Use app's primary color
              fontSize: 32,  // Extra large for importance
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
        ],
      ),
    );
  }
}
