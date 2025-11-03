import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Unified card showing spending overview with budget context
///
/// **Purpose:**
/// Consolidates total spending and budget tracking into one card to eliminate
/// redundancy and improve information hierarchy.
///
/// **Information Flow:**
/// 1. Hero: Total Spending (what you SPENT) - the fact
/// 2. Status: Budget health check badge - quick evaluation
/// 3. Context: Progress bar showing % of budget used
/// 4. Action: Remaining + Previous comparison - actionable insights
///
/// **Design Rationale:**
/// - Spending is the primary fact → gets hero treatment
/// - Budget is context → shown inline with progress bar
/// - Remaining is actionable → "how much MORE can I spend?"
/// - Previous provides trend → "is this normal for me?"
///
/// **Eliminated Redundancy:**
/// Previous design showed spending amount in TWO cards (Budget card + Total card).
/// Now it appears ONCE as the hero number with all context below.
class MonthlyOverviewCard extends StatelessWidget {
  /// Total amount spent this month (hero number)
  final double totalAmount;

  /// Monthly budget set by user
  final double budgetAmount;

  /// Previous month's total spending
  final double previousMonthAmount;

  /// Previous month name (e.g., "October")
  final String previousMonthName;

  /// Whether this is the current month (affects display mode)
  /// - true: Full mode with budget tracking
  /// - false: Simplified mode showing only spending facts
  final bool isCurrentMonth;

  const MonthlyOverviewCard({
    super.key,
    required this.totalAmount,
    required this.budgetAmount,
    required this.previousMonthAmount,
    required this.previousMonthName,
    this.isCurrentMonth = true,
  });

  /// Calculate percentage of budget used
  double get _percentageUsed {
    if (budgetAmount <= 0) return 0.0;
    return (totalAmount / budgetAmount) * 100;
  }

  /// Calculate remaining budget (can be negative if over budget)
  double get _remainingAmount {
    return budgetAmount - totalAmount;
  }

  /// Get status color based on budget usage
  /// Green: < 70%, Yellow: 70-90%, Red: > 90%
  Color _getStatusColor() {
    if (_percentageUsed < 70) {
      return Colors.green;
    } else if (_percentageUsed < 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get status icon based on budget usage
  IconData _getStatusIcon() {
    if (_percentageUsed < 70) {
      return Icons.check_circle;
    } else if (_percentageUsed < 90) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  /// Get status text based on budget usage
  String _getStatusText() {
    if (_percentageUsed < 70) {
      return 'On track';
    } else if (_percentageUsed < 90) {
      return 'Approaching limit';
    } else if (_percentageUsed >= 100) {
      return 'Over budget';
    } else {
      return 'Near limit';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();
    final statusText = _getStatusText();

    // Calculate percentage change for previous month comparison
    final percentageChange = previousMonthAmount > 0
        ? ((totalAmount - previousMonthAmount) / previousMonthAmount) * 100
        : 0.0;
    final isIncrease = percentageChange > 0;
    final isDecrease = percentageChange < 0;
    final trendColor = isIncrease ? Colors.red : (isDecrease ? Colors.green : Colors.grey);
    final trendIcon = isIncrease ? Icons.arrow_upward : (isDecrease ? Icons.arrow_downward : Icons.remove);

    // Clamp progress between 0 and 1 for progress bar
    final progressValue = (_percentageUsed / 100).clamp(0.0, 1.0);

    return SummaryStatCard(
      isPrimary: true, // Elevated card - most important info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Monthly Overview title
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Section: Total Spending (LARGE) + Status Badge (current month only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Total Spending (hero number)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(
                        totalAmount,
                        context: CurrencyContext.full,
                      ),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Spending',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // RIGHT: Status badge (only for current month)
              if (isCurrentMonth)
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Budget Context Section (only for current month)
          if (isCurrentMonth)
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget label with amount and percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget (${CurrencyFormatter.format(budgetAmount, context: CurrencyContext.compact)})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_percentageUsed.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar (clean, no text below)
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          if (isCurrentMonth) const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 12),

          // Bottom Metrics Row: Remaining + Previous (or just Previous for past months)
          Row(
            children: [
              // LEFT: Remaining Budget (only for current month)
              if (isCurrentMonth)
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _remainingAmount >= 0 ? Icons.savings : Icons.warning,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Remaining',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(
                        _remainingAmount.abs(),
                        context: CurrencyContext.compact,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _remainingAmount >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider (only for current month)
              if (isCurrentMonth)
                Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // RIGHT: Previous Month
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
                    // Amount and trend inline
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(
                            previousMonthAmount,
                            context: CurrencyContext.compact,
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (previousMonthAmount > 0) ...[
                          const SizedBox(width: 6),
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
                      ],
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
