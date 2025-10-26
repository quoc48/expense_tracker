import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/analytics_calculator.dart';
import '../widgets/category_chart.dart';
import '../widgets/trends_chart.dart';

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

                  // Summary card
                  _buildSummaryCard(expenseProvider.expenses),
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

  /// Summary card showing this month vs last month comparison
  Widget _buildSummaryCard(List<Expense> expenses) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate this month's total
    final thisMonthTotal = AnalyticsCalculator.getTotalForMonth(
      expenses,
      _selectedMonth,
    );

    // Calculate previous month's total
    final previousMonth = AnalyticsCalculator.getPreviousMonth(_selectedMonth);
    final lastMonthTotal = AnalyticsCalculator.getTotalForMonth(
      expenses,
      previousMonth,
    );

    // Calculate percentage change
    final percentChange = AnalyticsCalculator.percentageChange(
      lastMonthTotal,
      thisMonthTotal,
    );

    // Determine if spending increased or decreased
    final isIncrease = percentChange > 0;
    final changeColor = isIncrease ? Colors.red : Colors.green;
    final changeIcon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // This month total (large, prominent)
            Text(
              currencyFormat.format(thisMonthTotal),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              'Total Spending',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),

            // Divider
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),

            // Comparison with previous month
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous month info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(lastMonthTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Change indicator
                if (lastMonthTotal > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: changeColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          changeIcon,
                          size: 16,
                          color: changeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${percentChange.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: changeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
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
