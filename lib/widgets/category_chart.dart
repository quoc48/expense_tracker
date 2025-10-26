import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// A bar chart showing expense breakdown by category
/// Uses fl_chart for beautiful and interactive visualizations
class CategoryChart extends StatelessWidget {
  final Map<Category, double> categoryBreakdown;

  const CategoryChart({
    super.key,
    required this.categoryBreakdown,
  });

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

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
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
                  final category = sortedEntries[groupIndex].key;
                  final amount = sortedEntries[groupIndex].value;
                  return BarTooltipItem(
                    '${category.displayName}\n',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: currencyFormat.format(amount),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 16,
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
                    final category = sortedEntries[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(
                        category.icon,
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
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('\$0');
                    if (value >= 1000) {
                      return Text(
                        '\$${(value / 1000).toStringAsFixed(1)}k',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(178),
                        ),
                      );
                    }
                    return Text(
                      '\$${value.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
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
              drawHorizontalLine: true,
              drawVerticalLine: false,
              horizontalInterval: sortedEntries.first.value * 0.2,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(51),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: sortedEntries.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: theme.colorScheme.primary,
                    width: 24,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
