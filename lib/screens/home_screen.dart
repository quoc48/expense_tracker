import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/colors/app_colors.dart';
import '../utils/analytics_calculator.dart';
import '../widgets/home/analytics_summary_card.dart';
import '../widgets/home/category_card.dart';

/// HomeScreen displays the main analytics dashboard with spending summary.
///
/// **Design Reference**: Figma node-id=5-939
///
/// **Layout Structure**:
/// 1. App Bar: "Analytic" title + calendar/export icons
/// 2. Analytics Summary Card: Month total, budget progress, trend chart
/// 3. Category Section: Grid of CategoryCards showing spending by category
///
/// **Learning: Screen Architecture**
/// This screen follows the "Screen Layout First" approach:
/// 1. Define the overall structure (Scaffold, AppBar, body)
/// 2. Identify distinct sections (summary, categories)
/// 3. Extract complex sections into separate widgets
/// 4. Connect to data providers
///
/// Benefits:
/// - Clear separation of concerns
/// - Easier testing (each widget can be tested independently)
/// - Better code organization
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Currently displayed month
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = AnalyticsCalculator.currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use iOS-style gray background from Figma
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            if (expenseProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(context),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Analytics Summary Card
                      _buildSummaryCard(context, expenseProvider),

                      const SizedBox(height: 16),

                      // Category Section Header
                      _buildSectionHeader(context, 'Category'),

                      const SizedBox(height: 16),

                      // Category Grid
                      _buildCategoryGrid(context, expenseProvider),

                      // Bottom padding for floating nav bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the custom app bar with title and action icons
  ///
  /// **Design Reference**: Figma node-id=5-940
  /// - Title: "Analytic" - Momo Trust Sans, 14px, 600 weight, #000
  /// - Icons: Calendar grid + Export arrow (Regular weight, 12px spacing)
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56,
      titleSpacing: 20,
      title: const Text(
        'Analytic',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
          fontFeatures: [
            FontFeature.disable('liga'),
            FontFeature.disable('clig'),
          ],
        ),
      ),
      actions: [
        // Icons with 12px spacing between them (edge to edge)
        // Using Row to control exact spacing without IconButton padding interference
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar icon
              GestureDetector(
                onTap: () => _showMonthPicker(context),
                child: Icon(
                  PhosphorIconsRegular.calendarDots,
                  size: 24,
                  color: AppColors.textBlack,
                ),
              ),
              // 12px spacing between icons as per Figma
              const SizedBox(width: 12),
              // Export/Logout icon
              GestureDetector(
                onTap: () {
                  // TODO: Implement export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export coming soon')),
                  );
                },
                child: Icon(
                  PhosphorIconsRegular.signOut,
                  size: 24,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the analytics summary card with spending data
  Widget _buildSummaryCard(BuildContext context, ExpenseProvider provider) {
    // Get user's budget
    final prefsProvider = Provider.of<UserPreferencesProvider>(context);
    final budget = prefsProvider.monthlyBudget;

    // Calculate this month's total
    final monthExpenses = AnalyticsCalculator.getExpensesForMonth(
      provider.expenses,
      _selectedMonth,
    );
    final totalSpent = monthExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    // Get monthly trends for chart (last 6 months)
    final monthlyTrends = _calculateMonthlyTrends(provider.expenses);

    return AnalyticsSummaryCard(
      totalSpent: totalSpent,
      budgetAmount: budget,
      monthlyTrends: monthlyTrends,
      selectedMonth: _selectedMonth,
    );
  }

  /// Builds a section header with title
  ///
  /// **Design Reference**: Figma node-id=5-995
  /// - Font: Momo Trust Sans, 14px, weight 600
  /// - Color: #000 (Black)
  /// - Font features: 'liga' off, 'clig' off
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
          fontFeatures: [
            FontFeature.disable('liga'),
            FontFeature.disable('clig'),
          ],
        ),
      ),
    );
  }

  /// Builds the category spending grid
  ///
  /// **Design Logic**:
  /// - Always shows all 14 categories (even if no spending)
  /// - Fill percentage based on monthlyBudget / 14 per category
  /// - Categories sorted by spending (highest first)
  Widget _buildCategoryGrid(BuildContext context, ExpenseProvider provider) {
    // Get user's monthly budget for fill calculation
    final prefsProvider = Provider.of<UserPreferencesProvider>(context);
    final budget = prefsProvider.monthlyBudget;

    // Get expenses for selected month
    final monthExpenses = AnalyticsCalculator.getExpensesForMonth(
      provider.expenses,
      _selectedMonth,
    );

    // Calculate spending by category
    final categorySpending = _calculateCategorySpending(monthExpenses);

    // Always show CategoryCardGrid (it handles empty state internally by showing all 14 categories)
    return CategoryCardGrid(
      categorySpending: categorySpending,
      monthlyBudget: budget,
      onCategoryTap: (categoryName) {
        // TODO: Navigate to category detail or filter expenses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped: $categoryName')),
        );
      },
    );
  }

  /// Shows a month picker dialog
  Future<void> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();

    // Simple month picker using showDatePicker
    // Only allows selecting months (day is fixed to 1)
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(now.year, now.month, 1),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        // Normalize to first day of month
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  /// Calculates spending totals by category for the given expenses
  Map<String, double> _calculateCategorySpending(List<Expense> expenses) {
    final spending = <String, double>{};

    for (final expense in expenses) {
      // Use categoryNameVi which stores the Vietnamese category name
      final category = expense.categoryNameVi;
      spending[category] = (spending[category] ?? 0) + expense.amount;
    }

    return spending;
  }

  /// Calculates monthly spending totals for trend chart
  Map<DateTime, double> _calculateMonthlyTrends(List<Expense> expenses) {
    final trends = <DateTime, double>{};

    // Get last 6 months
    final now = DateTime.now();
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final normalizedMonth = DateTime(month.year, month.month, 1);

      final monthExpenses = AnalyticsCalculator.getExpensesForMonth(
        expenses,
        normalizedMonth,
      );

      final total = monthExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      trends[normalizedMonth] = total;
    }

    return trends;
  }
}
