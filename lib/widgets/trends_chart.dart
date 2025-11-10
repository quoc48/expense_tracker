import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/month_total.dart';
import '../utils/currency_formatter.dart';
import '../theme/typography/app_typography.dart';
import '../theme/minimalist/minimalist_colors.dart';

/// A line chart showing spending trends over multiple months
/// Displays monthly totals with interactive tooltips
/// Highlights the selected month and shows contextual trend information
///
/// **Phase 2 Visual Enhancements:**
/// - Gradient fill below line chart for better visual appeal
/// - Smooth animations with duration and curves
/// - Enhanced dot styling with shadows
/// - Better color contrast for accessibility
class TrendsChart extends StatelessWidget {
  final List<MonthTotal> monthlyTrends;
  final DateTime selectedMonth; // Currently selected month to highlight

  const TrendsChart({
    super.key,
    required this.monthlyTrends,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    // If no data, show empty state
    if (monthlyTrends.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No trend data available',
            style: ComponentTextStyles.emptyMessage(Theme.of(context).textTheme),
          ),
        ),
      );
    }

    // Sort by date to ensure chronological order
    final sortedTrends = List<MonthTotal>.from(monthlyTrends)
      ..sort((a, b) => a.month.compareTo(b.month));

    // Find the index of the selected month in the sorted trends
    final selectedMonthIndex = sortedTrends.indexWhere((trend) =>
        trend.month.year == selectedMonth.year &&
        trend.month.month == selectedMonth.month);

    // Calculate trend: compare selected month with its previous month
    double? trendPercentage;
    bool? isIncreasing; // true = spending up (bad), false = spending down (good)
    if (selectedMonthIndex > 0) {
      // Selected month exists and has a previous month to compare
      final current = sortedTrends[selectedMonthIndex].total;
      final previous = sortedTrends[selectedMonthIndex - 1].total;
      if (previous > 0) {
        trendPercentage = ((current - previous) / previous) * 100;
        isIncreasing = trendPercentage > 0;
      }
    }

    final theme = Theme.of(context);

    // Calculate max value for better scaling
    final maxValue = sortedTrends.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    // Create line chart spots (data points)
    final spots = sortedTrends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.total);
    }).toList();

    // Minimalist: Use darker grayscale for better contrast (darker = worse trend)
    final lineColor = isIncreasing == null
        ? MinimalistColors.gray700 // Body text - default if no trend data
        : isIncreasing
            ? MinimalistColors.gray900 // Primary text - spending increased (worse) - darker for emphasis
            : MinimalistColors.gray800; // Subheadings - spending decreased (better) - darker for readability

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trend Indicator
        if (trendPercentage != null && isIncreasing != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncreasing ? PhosphorIconsLight.arrowUp : PhosphorIconsLight.arrowDown,
                  size: 20,
                  color: lineColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trendPercentage.abs().toStringAsFixed(1)}%',
                  style: AppTypography.currencyMedium(color: lineColor).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isIncreasing ? 'vs last month' : 'vs last month',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        // Chart
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
            minX: 0,
            maxX: (sortedTrends.length - 1).toDouble(),
            minY: 0,
            maxY: maxValue * 1.2, // Add 20% padding
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    final monthTotal = sortedTrends[index];
                    final monthStr = DateFormat.yMMM().format(monthTotal.month);

                    return LineTooltipItem(
                      '$monthStr\n',
                      theme.textTheme.labelMedium!.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(monthTotal.total, context: CurrencyContext.compact),
                          style: AppTypography.currencyMedium(
                            color: MinimalistColors.gray900,  // Primary text - strong contrast for amounts
                          ).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= sortedTrends.length || value < 0) {
                      return const Text('');
                    }
                    final monthTotal = sortedTrends[value.toInt()];
                    final monthStr = DateFormat.MMM().format(monthTotal.month);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.5, // Slight angle for better readability
                        child: Text(
                          monthStr,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: maxValue * 0.25, // Match grid line interval
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
              horizontalInterval: maxValue * 0.25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: MinimalistColors.gray300.withValues(alpha: 0.2),  // Inactive borders with transparency
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor, // Use trend-based color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Highlight selected month's dot in blue with larger size
                    final isSelectedMonth = index == selectedMonthIndex;
                    return FlDotCirclePainter(
                      radius: isSelectedMonth ? 6 : 4,
                      color: isSelectedMonth
                          ? MinimalistColors.gray900 // Primary text - selected month emphasized
                          : lineColor, // Trend color for other months
                      strokeWidth: isSelectedMonth ? 3 : 2,
                      strokeColor: theme.colorScheme.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  // Phase 2: Gradient fill for better visual appeal
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      lineColor.withValues(alpha: 0.3),  // More opaque at top
                      lineColor.withValues(alpha: 0.05), // Almost transparent at bottom
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                // Phase 2: Add smooth animation
                isStrokeJoinRound: true,
                shadow: Shadow(
                  color: lineColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ),
            ],
          ),
          // Phase 2: Smooth animation when data changes
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
          ),
        ),
      ],
    );
  }
}
