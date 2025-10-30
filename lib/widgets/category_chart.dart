import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/currency_formatter.dart';

/// A horizontal bar chart showing expense breakdown by category
/// Uses fl_chart for beautiful and interactive visualizations
///
/// **Why Horizontal Bars?**
/// - Category names on LEFT (more space, fully readable)
/// - Bar lengths easier to compare visually
/// - No text rotation needed
/// - Better for mobile screens (portrait orientation)
class CategoryChart extends StatelessWidget {
  final Map<String, double> categoryBreakdown;

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
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No category data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort categories by amount (descending)
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final theme = Theme.of(context);

    // Dynamic height based on number of categories (40px per category + padding)
    final chartHeight = (sortedEntries.length * 45.0) + 40;

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: sortedEntries.first.value * 1.15, // Add 15% padding
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final categoryNameVi = sortedEntries[groupIndex].key;
                  final amount = sortedEntries[groupIndex].value;
                  return BarTooltipItem(
                    '$categoryNameVi\n',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.format(amount, context: CurrencyContext.full),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
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
              // Category names and icons on the LEFT (Y axis)
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 100, // Space for category names
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= sortedEntries.length || value.toInt() < 0) {
                      return const Text('');
                    }
                    final categoryNameVi = sortedEntries[value.toInt()].key;
                    final icon = _getCategoryIcon(categoryNameVi);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category name
                          Flexible(
                            child: Text(
                              categoryNameVi,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Icon
                          Icon(
                            icon,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Amounts on the BOTTOM (X axis)
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('0');
                    return Text(
                      CurrencyFormatter.format(value, context: CurrencyContext.shortCompact),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withAlpha(178),
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
              drawHorizontalLine: false, // No horizontal lines
              drawVerticalLine: true,    // Vertical lines for amounts
              verticalInterval: sortedEntries.first.value * 0.25,
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(51),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            groupsSpace: 6, // Gap between bars (4-6px as requested)
            barGroups: sortedEntries.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: theme.colorScheme.primary,
                    width: 20, // Bar thickness
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(4), // Rounded right end
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
