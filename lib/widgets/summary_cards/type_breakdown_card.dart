import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/typography/app_typography.dart';
import '../../theme/minimalist/minimalist_colors.dart';
import 'summary_stat_card.dart';

/// Card showing expense breakdown by type (Phải chi, Phát sinh, Lãng phí)
///
/// **Why This Card Exists**
/// Users want to see: "Am I spending too much on wasteful things?"
/// This card visualizes the split with colored percentage bars.
///
/// **Flutter Concept: Map Data Structure**
/// We use Map<String, double> where:
/// - Key: Type name in Vietnamese ("Phải chi", "Phát sinh", "Lãng phí")
/// - Value: Total amount for that type
///
/// **Material Design: Progress Indicators**
/// We use LinearProgressIndicator to show percentages visually.
/// Each type gets its own color for easy distinction.
class TypeBreakdownCard extends StatelessWidget {
  /// Map of expense type (Vietnamese) to total amount
  /// Example: {"Phải chi": 50000, "Phát sinh": 30000, "Lãng phí": 20000}
  final Map<String, double> typeBreakdown;

  /// Total amount (sum of all types) for calculating percentages
  final double totalAmount;

  const TypeBreakdownCard({
    super.key,
    required this.typeBreakdown,
    required this.totalAmount,
  });

  /// Get color for expense type - minimalist grayscale approach
  Color _getTypeColor(String typeNameVi) {
    switch (typeNameVi) {
      case 'Phải chi':
        return MinimalistColors.gray850;  // Strong emphasis - darkest (most important)
      case 'Phát sinh':
        return MinimalistColors.gray600;  // Labels - medium
      case 'Lãng phí':
        return MinimalistColors.gray500;  // Secondary - lightest
      default:
        return MinimalistColors.gray400;  // Disabled
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no spending, show empty state
    if (totalAmount == 0) {
      return SummaryStatCard(
        child: Column(
          children: [
            Icon(PhosphorIconsLight.chartPie, size: 48, color: MinimalistColors.gray400),  // Disabled
            const SizedBox(height: 8),
            Text(
              'No spending data',
              style: ComponentTextStyles.emptyMessage(Theme.of(context).textTheme),
            ),
          ],
        ),
      );
    }

    return SummaryStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (matching Category Chart style)
          Row(
            children: [
              Icon(PhosphorIconsLight.chartDonut, color: MinimalistColors.gray700),  // Body text - subtle
              const SizedBox(width: 8),  // Consistent icon-text spacing
              Flexible(
                child: Text(
                  'Type Breakdown',
                  style: theme.textTheme.titleMedium,  // Match Category Chart
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Build a row for each expense type (sorted by percentage, highest first)
          ...(typeBreakdown.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))  // Sort descending by amount
              .map((entry) {
            final typeNameVi = entry.key;
            final amount = entry.value;
            final percentage = (amount / totalAmount * 100);  // Calculate percentage
            final color = _getTypeColor(typeNameVi);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type name and percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          typeNameVi,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',  // Show as "50%"
                        style: AppTypography.currencySmall(color: color).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Progress bar (visual representation)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percentage / 100,  // Convert to 0.0-1.0 range
                      backgroundColor: color.withValues(alpha: 0.1),  // Light background
                      valueColor: AlwaysStoppedAnimation<Color>(color),  // Bar color
                      minHeight: 6,  // Thickness of the bar
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
