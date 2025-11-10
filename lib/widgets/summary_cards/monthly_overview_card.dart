import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/currency_formatter.dart';
import '../../theme/typography/app_typography.dart';
import '../../theme/minimalist/minimalist_colors.dart';
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
  /// Minimalist: Warm earth tones for alerts, gray for on-track
  Color _getStatusColor() {
    if (_percentageUsed < 70) {
      return MinimalistColors.gray500;  // Secondary - on track (no alert)
    } else if (_percentageUsed < 90) {
      return MinimalistColors.alertWarning;  // Sandy gold - approaching limit
    } else if (_percentageUsed < 100) {
      return MinimalistColors.alertCritical;  // Peachy orange - near limit
    } else {
      return MinimalistColors.alertError;  // Coral terracotta - over budget
    }
  }

  /// Get text color for status badge
  /// Yellow needs dark text for contrast, orange/red can use accent color
  Color _getStatusTextColor() {
    if (_percentageUsed < 70) {
      return MinimalistColors.gray500;  // Match badge color
    } else if (_percentageUsed < 90) {
      return MinimalistColors.gray900;  // Dark text for yellow background
    } else {
      return _getStatusColor();  // Orange/red have good contrast
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
    final statusTextColor = _getStatusTextColor();
    final statusText = _getStatusText();

    // Calculate percentage change for previous month comparison
    final percentageChange = previousMonthAmount > 0
        ? ((totalAmount - previousMonthAmount) / previousMonthAmount) * 100
        : 0.0;
    final isIncrease = percentageChange > 0;
    final isDecrease = percentageChange < 0;
    // Minimalist: Use darker grayscale for better contrast (darker = worse)
    final trendColor = isIncrease
        ? MinimalistColors.gray900  // Primary text - spending increased (worse) - darker for contrast
        : (isDecrease
            ? MinimalistColors.gray700  // Body text - spending decreased (better) - darker for readability
            : MinimalistColors.gray600); // Labels - no change - darker for visibility
    final trendIcon = isIncrease
        ? PhosphorIconsLight.arrowUp
        : (isDecrease
            ? PhosphorIconsLight.arrowDown
            : PhosphorIconsLight.minus);

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
                PhosphorIconsLight.wallet,
                size: 20,
                color: MinimalistColors.gray700,  // Body text - subtle
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Spent',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: MinimalistColors.gray900,  // Primary text - high contrast
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
                child: Text(
                  CurrencyFormatter.format(
                    totalAmount,
                    context: CurrencyContext.full,
                  ),
                  style: AppTypography.currencyLarge(color: MinimalistColors.gray900),  // Primary text - hero number
                ),
              ),
              // RIGHT: Status badge (only for current month with budget set)
              if (isCurrentMonth && budgetAmount > 0)
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,  // Use separate text color for better contrast
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Budget Context Section (only for current month with budget set)
          if (isCurrentMonth && budgetAmount > 0)
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget label with amount and percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Budget (${CurrencyFormatter.format(budgetAmount, context: CurrencyContext.compact)})',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_percentageUsed.toStringAsFixed(1)}%',
                    style: AppTypography.currencySmall(color: statusColor).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar (clean, no text below)
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: MinimalistColors.gray200,  // Dividers - light background
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          if (isCurrentMonth && budgetAmount > 0) const SizedBox(height: 16),

          // Divider
          Divider(color: MinimalistColors.gray300, height: 1),  // Inactive borders - subtle divider
          const SizedBox(height: 12),

          // Bottom Metrics Row: Remaining + Previous (or just Previous for past months)
          Row(
            children: [
              // LEFT: Remaining Budget (only for current month with budget set)
              if (isCurrentMonth && budgetAmount > 0)
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _remainingAmount >= 0
                              ? PhosphorIconsLight.piggyBank
                              : PhosphorIconsLight.warning,
                          size: 16,
                          color: MinimalistColors.gray600,  // Labels
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Remaining',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(
                        _remainingAmount.abs(),
                        context: CurrencyContext.compact,
                      ),
                      style: AppTypography.currencyMedium(
                        color: _remainingAmount >= 0
                            ? MinimalistColors.gray700  // Body text - neutral
                            : MinimalistColors.gray800,  // Subheadings - slightly darker for negative
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider (only for current month with budget set)
              if (isCurrentMonth && budgetAmount > 0)
                Container(
                height: 40,
                width: 1,
                color: MinimalistColors.gray300,  // Inactive borders - subtle divider
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // RIGHT: Previous Month
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsLight.clockCounterClockwise,
                          size: 16,
                          color: MinimalistColors.gray600,  // Labels
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Previous',
                            style: theme.textTheme.bodySmall,
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
                          style: AppTypography.currencyMedium(
                            color: MinimalistColors.gray700,  // Body text
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
                                  style: AppTypography.currencySmall(color: trendColor).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
