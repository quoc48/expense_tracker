import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/analytics_calculator.dart';
import '../widgets/category_chart.dart';
import '../widgets/trends_chart.dart';
import '../widgets/summary_cards/monthly_overview_card.dart';
import '../widgets/summary_cards/type_breakdown_card.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/typography/app_typography.dart';

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
              padding: const EdgeInsets.all(20.0), // Material Design 3: 20px edge padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month selector
                  _buildMonthSelector(),
                  const SizedBox(height: 20),

                  // Summary cards grid with fade transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _buildSummaryCardsGrid(
                      allExpenses: expenseProvider.expenses,
                      monthExpenses: monthExpenses,
                      // Use month as key to trigger animation on month change
                      key: ValueKey(_selectedMonth.toString()),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Charts with fade transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: monthExpenses.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            key: ValueKey('${_selectedMonth.toString()}_charts'),
                            children: [
                              // Category Breakdown Chart
                              _buildCategoryBreakdownCard(monthExpenses),
                              const SizedBox(height: 20),

                              // Spending Trends Chart
                              _buildSpendingTrendsCard(expenseProvider.expenses),
                            ],
                          ),
                  ),
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
              style: Theme.of(context).textTheme.titleLarge,
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

  /// Summary cards showing consolidated monthly metrics
  ///
  /// **Learning: Simplified Card Layout**
  /// Instead of 5 separate mini-cards, we consolidated related metrics:
  /// - MonthlyTotalCard now includes daily average and previous month inline
  /// - TypeBreakdownCard shows spending type distribution
  /// This reduces visual clutter and improves information hierarchy.
  ///
  /// **Material Design: Information Density**
  /// - Full-width cards for better readability on mobile
  /// - Related metrics grouped together logically
  /// - Consistent spacing and padding throughout
  Widget _buildSummaryCardsGrid({
    required List<Expense> allExpenses,
    required List<Expense> monthExpenses,
    Key? key,
  }) {
    // Get user preferences for budget
    final prefsProvider = Provider.of<UserPreferencesProvider>(context);
    final budget = prefsProvider.preferences?.monthlyBudget ?? 0.0;

    // Check if viewing current month (budget tracking only relevant for current month)
    final isCurrentMonth = AnalyticsCalculator.isSameMonth(
      _selectedMonth,
      DateTime.now(),
    );

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

    // Format previous month name (short format: "October")
    final monthFormat = DateFormat('MMMM');
    final previousMonthName = monthFormat.format(previousMonth);

    return Column(
      children: [
        // 1. Monthly Overview (always show - it displays spending data)
        // Budget sections hidden when budget = 0
        // Current month: Full mode with budget tracking (if budget > 0)
        // Past months: Simplified mode with only spending facts
        MonthlyOverviewCard(
          totalAmount: thisMonthTotal,
          budgetAmount: budget,
          previousMonthAmount: lastMonthTotal,
          previousMonthName: previousMonthName,
          isCurrentMonth: isCurrentMonth,
        ),
        const SizedBox(height: 12),

        // 2. Type Breakdown (full width)
        // Shows: Phải chi, Phát sinh, Lãng phí percentages (sorted by highest)
        TypeBreakdownCard(
          typeBreakdown: typeBreakdown,
          totalAmount: thisMonthTotal,
        ),
      ],
    );
  }

  /// Empty state when no expenses exist for the selected month
  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses this month',
              style: ComponentTextStyles.emptyTitle(theme.textTheme),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see analytics',
              style: ComponentTextStyles.emptyMessage(theme.textTheme),
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
                  style: Theme.of(context).textTheme.titleMedium,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart
            TrendsChart(
              monthlyTrends: monthlyTrends,
              selectedMonth: _selectedMonth,
            ),
          ],
        ),
      ),
    );
  }
}
