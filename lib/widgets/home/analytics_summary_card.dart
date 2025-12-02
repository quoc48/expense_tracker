import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/colors/app_colors.dart';
import '../../utils/currency_formatter.dart';

/// AnalyticsSummaryCard displays the main spending summary with budget progress.
///
/// **Design Reference**: Figma node-id=5-939 (White summary card)
///
/// **Components**:
/// 1. Month label ("November Spent") - centered
/// 2. Large amount display (23,434,000 đ) - centered
/// 3. Remaining budget with progress bar
/// 4. Spending trend line chart (last 6 months)
///
/// **Typography**: All text uses MomoTrustSans font family
class AnalyticsSummaryCard extends StatelessWidget {
  /// Current month's total spending
  final double totalSpent;

  /// Monthly budget amount (0 means no budget set)
  final double budgetAmount;

  /// Monthly spending data for trend chart
  /// Key: DateTime (first day of month), Value: total spent
  final Map<DateTime, double> monthlyTrends;

  /// Currently selected/displayed month
  final DateTime selectedMonth;

  /// Whether to show the budget progress bar section.
  /// When false, hides the progress bar but keeps the budget line on the chart.
  /// Defaults to true.
  final bool showBudgetProgress;

  const AnalyticsSummaryCard({
    super.key,
    required this.totalSpent,
    required this.budgetAmount,
    required this.monthlyTrends,
    required this.selectedMonth,
    this.showBudgetProgress = true,
  });

  // Momo Trust Sans text style helper
  TextStyle _momoTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textBlack,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'MomoTrustSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // Figma spec: top 24, bottom 16, left/right 0
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 0, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Figma: 16px radius
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center all content
        children: [
          // Header: Month label + Amount (centered)
          _buildHeader(context),

          // Divider between Part 1 and Part 2
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: const Color(0xFFF2F2F7), // Figma: #F2F2F7
          ),

          // Budget progress section (only show if budget is set AND showBudgetProgress is true)
          // Note: The budget line on the chart still shows based on budgetAmount > 0
          if (budgetAmount > 0 && showBudgetProgress) ...[
            _buildBudgetProgress(context),
            // Divider between Part 2 and Part 3
            Container(
              height: 1,
              color: const Color(0xFFF2F2F7), // Figma: #F2F2F7
            ),
          ],

          // Trend chart
          _buildTrendChart(context),
        ],
      ),
    );
  }

  /// Builds the header section with month label and large amount display
  /// All content is centered
  Widget _buildHeader(BuildContext context) {
    // Format month name (e.g., "November Spent")
    final monthFormat = DateFormat('MMMM');
    final monthName = monthFormat.format(selectedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Month label - 14px, w500, gray
        Text(
          '$monthName Spent',
          style: _momoTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),

        const SizedBox(height: 8), // Figma: 8px spacing

        // Large amount display - 32px, bold, black
        Text(
          CurrencyFormatter.format(totalSpent),
          style: _momoTextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold, // Figma: bold weight
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  /// Builds the budget progress section with remaining amount and progress bar
  Widget _buildBudgetProgress(BuildContext context) {
    // Calculate remaining budget and percentage
    final remaining = budgetAmount - totalSpent;
    final percentage = (totalSpent / budgetAmount).clamp(0.0, 1.0);
    final percentageDisplay = (percentage * 100).round();

    // Determine color based on spending level
    final progressColor = _getProgressColor(percentage);

    return Padding(
      // Figma: padding left/right 16px
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Label row: "Remaining Budget" ... "4,5m"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining Budget',
                style: _momoTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
              Text(
                CurrencyFormatter.formatCompact(remaining.abs()),
                style: _momoTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8), // Figma: 8px spacing

          // Progress bar with percentage
          Row(
            children: [
              // Progress bar (flexible width)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: AppColors.gray6,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Percentage display - 12px, w500, gray
              Text(
                '$percentageDisplay%',
                style: _momoTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the spending trend area chart with line
  ///
  /// **Chart Specification:**
  /// - 7 equal-width columns: May (hidden), Jun, Jul, Aug, Sep, Oct, Nov (visible)
  /// - Graph container = 6 visible columns stretched to full width
  /// - May column is clipped off left edge for continuous line effect
  /// - Dots positioned at center of each column
  /// - Only current month dot is visible
  /// - Line connects dots (straight segments)
  Widget _buildTrendChart(BuildContext context) {
    // Convert monthly trends to chart data points
    final sortedMonths = monthlyTrends.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Need at least 2 points for a meaningful line chart
    if (sortedMonths.length < 2) {
      return SizedBox(
        height: 146,
        child: Center(
          child: Text(
            'Not enough data for trend',
            style: _momoTextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
        ),
      );
    }

    // Number of visible months (columns)
    final visibleMonths = sortedMonths.length; // 6
    // Total columns including hidden month
    final totalColumns = visibleMonths + 1; // 7

    // Build spots: dots at CENTER of each column
    // Column 0 = hidden (May), Columns 1-6 = visible (Jun-Nov)
    // Dot positions: 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5 (center of each column)
    final spots = <FlSpot>[];

    // Hidden month (column 0) - dot at center (0.5)
    final firstMonthAmount = monthlyTrends[sortedMonths.first] ?? 0;
    spots.add(FlSpot(0.5, firstMonthAmount));

    // Visible months (columns 1-6) - dots at centers (1.5, 2.5, etc.)
    for (var i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final amount = monthlyTrends[month] ?? 0;
      // Column index is i+1, center is at i+1+0.5 = i+1.5
      spots.add(FlSpot((i + 1.5), amount));
    }

    // Y-axis auto-scales from 0 to max data value + padding
    final maxDataValue = monthlyTrends.values.reduce((a, b) => a > b ? a : b);
    final yAxisMax = maxDataValue * 1.2;

    // Current month dot position (last visible column center)
    final currentMonthX = visibleMonths + 0.5; // 6.5

    // Chart area height
    const chartHeight = 114.0;

    // Calculate budget label position
    double? budgetLabelTop;
    if (budgetAmount > 0 && budgetAmount <= yAxisMax) {
      final budgetRatio = budgetAmount / yAxisMax;
      budgetLabelTop = chartHeight * (1 - budgetRatio);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Area chart with line
                LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),

                    // X-axis: show columns 1-7 (clip column 0 which is May)
                    // minX=1 means left edge starts at column 1 boundary
                    // maxX=7 means right edge ends at column 7 boundary (after Nov)
                    minX: 1,
                    maxX: totalColumns.toDouble(), // 7
                    minY: 0,
                    maxY: yAxisMax,

                    clipData: const FlClipData.all(),

                    // Budget baseline
                    extraLinesData: budgetAmount > 0
                        ? ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: budgetAmount,
                                color: AppColors.gray.withValues(alpha: 0.5),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                            ],
                          )
                        : null,

                    // Line and area
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: AppColors.categoryIndigo,
                        barWidth: 2,
                        isStrokeCapRound: true,

                        // Only show dot on current month
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) {
                            return spot.x == currentMonthX;
                          },
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: AppColors.categoryIndigo,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),

                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.categoryIndigo.withValues(alpha: 0.25),
                              AppColors.categoryIndigo.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],

                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              CurrencyFormatter.formatCompact(spot.y),
                              _momoTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),

                // Budget label - Figma spec
                if (budgetAmount > 0 && budgetLabelTop != null)
                  Positioned(
                    left: 0,
                    top: budgetLabelTop - 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7), // Figma: #F2F2F7
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'Budget (${CurrencyFormatter.formatCompact(budgetAmount)})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'MomoTrustSans',
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack, // Figma: #000
                          fontFeatures: [
                            FontFeature.disable('liga'),
                            FontFeature.disable('clig'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // X-axis divider line
          Container(
            height: 1,
            color: const Color(0xFFF2F2F7),
          ),

          // Month labels row - 6 equal-width containers (Jun-Nov)
          // Each container matches one visible column width
          Row(
            children: List.generate(sortedMonths.length, (index) {
              final month = sortedMonths[index];
              final label = DateFormat('MMM').format(month);
              final isCurrentMonth = index == sortedMonths.length - 1;

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: _momoTextStyle(
                      fontSize: 11,
                      fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.w400,
                      color: isCurrentMonth ? AppColors.textBlack : AppColors.gray,
                    ),
                  ),
                ),
              );
            }),
          ),

          // Bottom spacing
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Returns appropriate color based on budget usage percentage
  Color _getProgressColor(double percentage) {
    if (percentage < 0.7) return AppColors.categoryGreen;
    if (percentage < 0.9) return AppColors.categoryOrange;
    return AppColors.categoryPink;
  }
}
