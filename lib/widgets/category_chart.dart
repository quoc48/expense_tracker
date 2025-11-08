import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/currency_formatter.dart';
import '../theme/typography/app_typography.dart';

/// A bar chart showing expense breakdown by category (UPDATED - Phase 5.5.1)
/// Uses fl_chart for beautiful and interactive visualizations
/// Now uses Vietnamese category names directly instead of enums
///
/// **Phase 2 Visual Enhancements:**
/// - Gradient fills on bars for modern look
/// - Smooth animations when data changes
/// - Enhanced bar styling with shadows
/// - Better color scheme for visual hierarchy
class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryBreakdown;  // Changed from Map<Category, double>

  const CategoryChart({
    super.key,
    required this.categoryBreakdown,
  });

  /// Helper: Get icon for Vietnamese category name
  IconData _getCategoryIcon(String categoryNameVi) {
    switch (categoryNameVi) {
      case 'Thực phẩm':
      case 'Cà phê':
        return Icons.restaurant;
      case 'Đi lại':
        return Icons.directions_car;
      case 'Hoá đơn':
      case 'Tiền nhà':
        return Icons.lightbulb;
      case 'Giải trí':
      case 'Du lịch':
        return Icons.movie;
      case 'Tạp hoá':
      case 'Thời trang':
        return Icons.shopping_bag;
      case 'Sức khỏe':
        return Icons.medical_services;
      case 'Giáo dục':
        return Icons.school;
      case 'Quà vật':
      case 'TẾT':
      case 'Biểu gia đình':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }


  @override
  Widget build(BuildContext context) {
    // If no data, show empty state
    if (categoryBreakdown.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No category data available',
            style: ComponentTextStyles.emptyMessage(Theme.of(context).textTheme),
          ),
        ),
      );
    }

    // Sort categories by amount (descending)
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final theme = Theme.of(context);

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: sortedEntries.first.value * 1.2, // Add 20% padding
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final categoryNameVi = sortedEntries[groupIndex].key;  // Now a String
                  final amount = sortedEntries[groupIndex].value;
                  return BarTooltipItem(
                    '$categoryNameVi\n',  // Already in Vietnamese!
                    theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.format(amount, context: CurrencyContext.compact),
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= sortedEntries.length) {
                      return const Text('');
                    }
                    final categoryNameVi = sortedEntries[value.toInt()].key;  // Now a String
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(
                        _getCategoryIcon(categoryNameVi),  // Use helper method
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: sortedEntries.first.value * 0.25, // Match grid interval to prevent overlap
                  getTitlesWidget: (value, meta) {
                    if (value == 0) {
                      return Text(
                        '0',
                        style: AppTypography.currencySmall(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      );
                    }
                    // Use compact format for chart axis labels with monospace font
                    return Text(
                      CurrencyFormatter.format(value, context: CurrencyContext.compact),
                      style: AppTypography.currencySmall(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              horizontalInterval: sortedEntries.first.value * 0.25, // Increased to reduce label density
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(51),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            groupsSpace: 40, // Significantly increased spacing between bar columns for better readability
            barGroups: sortedEntries.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    // Phase 2: Gradient fill for bars
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    width: 22,  // Slightly wider for better visibility
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),  // Softer corners
                    ),
                    // Phase 2: Add shadow for depth
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: sortedEntries.first.value * 1.2,
                      color: Colors.grey.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          // Phase 2: Smooth animation when data changes
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
