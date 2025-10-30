import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/analytics_calculator.dart';
import '../utils/currency_formatter.dart';
import '../widgets/category_chart.dart';
import '../widgets/trends_chart.dart';
import '../widgets/summary_cards/monthly_total_card.dart';
import '../widgets/summary_cards/type_breakdown_card.dart';
import '../widgets/summary_cards/top_category_card.dart';
import '../widgets/summary_cards/daily_average_card.dart';
import '../widgets/summary_cards/previous_month_card.dart';

/// AnalyticsScreen displays spending analytics with monthly summaries and charts.
///
/// Learning: This screen demonstrates several key concepts:
/// - StatefulWidget for managing selected month
/// - Using Provider to access shared expense data
/// - Date arithmetic for month navigation
/// - Conditional UI based on data availability
/// - Material Design card layouts
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // State: Currently selected month for analytics
  // Defaults to current month
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    // Initialize to first day of current month
    _selectedMonth = AnalyticsCalculator.currentMonth;
  }

  /// Navigate to previous month
  void _previousMonth() {
    setState(() {
      _selectedMonth = AnalyticsCalculator.getPreviousMonth(_selectedMonth);
    });
  }

  /// Navigate to next month (only if not in the future)
  void _nextMonth() {
    final nextMonth = AnalyticsCalculator.getNextMonth(_selectedMonth);
    if (!AnalyticsCalculator.isFutureMonth(nextMonth)) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // Show loading indicator while expenses are being loaded
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get expenses for the selected month
          final monthExpenses = AnalyticsCalculator.getExpensesForMonth(
            expenseProvider.expenses,
            _selectedMonth,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month selector
                  _buildMonthSelector(),
                  const SizedBox(height: 20),

                  // Summary cards grid (5 cards)
                  _buildSummaryCardsGrid(expenseProvider.expenses, monthExpenses),
                  const SizedBox(height: 20),

                  // Empty state if no expenses this month
                  if (monthExpenses.isEmpty)
                    _buildEmptyState()
                  else ...[
                    // Category Breakdown Chart
                    _buildCategoryBreakdownCard(monthExpenses),
                    const SizedBox(height: 20),

                    // Spending Trends Chart
                    _buildSpendingTrendsCard(expenseProvider.expenses),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Month selector widget with previous/next buttons
  Widget _buildMonthSelector() {
    // Format: "October 2025"
    final monthFormat = DateFormat('MMMM yyyy');
    final isCurrentMonth = AnalyticsCalculator.isSameMonth(
      _selectedMonth,
      DateTime.now(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous month button
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
              tooltip: 'Previous month',
            ),

            // Month display
            Text(
              monthFormat.format(_selectedMonth),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),

            // Next month button (disabled if current month)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth ? null : _nextMonth,
              tooltip: isCurrentMonth ? 'Cannot view future months' : 'Next month',
            ),
          ],
        ),
      ),
    );
  }

  /// Summary cards grid showing 5 key metrics
  ///
  /// **Learning: GridView vs Column**
  /// Instead of stacking cards vertically with Column, we use GridView
  /// to create a responsive 2-column layout that adapts to screen size.
  ///
  /// **Material Design: Card Grid Patterns**
  /// - Primary card (Monthly Total) spans full width
  /// - Other cards arranged in 2 columns on tablet/desktop
  /// - All cards use the same base styling (DRY principle)
  Widget _buildSummaryCardsGrid(List<Expense> allExpenses, List<Expense> monthExpenses) {
    // Calculate this month's total
    final thisMonthTotal = AnalyticsCalculator.getTotalForMonth(
      allExpenses,
      _selectedMonth,
    );

    // Calculate previous month data
    final previousMonth = AnalyticsCalculator.getPreviousMonth(_selectedMonth);
    final lastMonthTotal = AnalyticsCalculator.getTotalForMonth(
      allExpenses,
      previousMonth,
    );

    // Calculate type breakdown (Phải chi, Phát sinh, Lãng phí)
    final typeBreakdown = AnalyticsCalculator.getTypeBreakdown(
      monthExpenses,
      _selectedMonth,
    );

    // Calculate category breakdown
    final categoryBreakdown = AnalyticsCalculator.getCategoryBreakdown(
      monthExpenses,
      _selectedMonth,
    );

    // Get days in selected month for daily average
    final daysInMonth = AnalyticsCalculator.daysInMonth(_selectedMonth);

    // Format month names
    final monthFormat = DateFormat('MMMM yyyy');
    final currentMonthName = monthFormat.format(_selectedMonth);
    final previousMonthName = monthFormat.format(previousMonth);

    return Column(
      children: [
        // Row 1: Monthly Total (spans full width - PRIMARY CARD)
        MonthlyTotalCard(
          totalAmount: thisMonthTotal,
          monthName: currentMonthName,
        ),
        const SizedBox(height: 8),

        // Row 2: Type Breakdown + Top Category (2 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TypeBreakdownCard(
                typeBreakdown: typeBreakdown,
                totalAmount: thisMonthTotal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TopCategoryCard(
                categoryBreakdown: categoryBreakdown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 3: Daily Average + Previous Month (2 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DailyAverageCard(
                totalAmount: thisMonthTotal,
                daysInMonth: daysInMonth,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PreviousMonthCard(
                previousMonthAmount: lastMonthTotal,
                currentMonthAmount: thisMonthTotal,
                previousMonthName: previousMonthName,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Empty state when no expenses exist for the selected month
  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses this month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see analytics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Category breakdown chart card
  Widget _buildCategoryBreakdownCard(List<Expense> monthExpenses) {
    // Calculate category breakdown for the selected month
    final categoryBreakdown = AnalyticsCalculator.getCategoryBreakdown(
      monthExpenses,
      _selectedMonth,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart
            CategoryChart(categoryBreakdown: categoryBreakdown),
          ],
        ),
      ),
    );
  }

  /// Spending trends chart card
  Widget _buildSpendingTrendsCard(List<Expense> allExpenses) {
    // Get last 6 months of trend data
    final monthlyTrends = AnalyticsCalculator.getMonthlyTrend(allExpenses, 6);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending Trends (Last 6 Months)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart
            TrendsChart(monthlyTrends: monthlyTrends),
          ],
        ),
      ),
    );
  }
}
