import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/colors/app_colors.dart';
import '../utils/analytics_calculator.dart';
import '../widgets/common/logout_confirmation_dialog.dart';
import '../widgets/home/analytics_summary_card.dart';
import '../widgets/home/category_card.dart';
import '../widgets/home/select_month_sheet.dart';

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
      // Use iOS-style gray background from Figma - adaptive for dark mode
      backgroundColor: AppColors.getBackground(context),
      // Extend body behind system UI (nav bar area)
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        // Don't add bottom padding - let content scroll behind nav bar
        bottom: false,
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            if (expenseProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(context),

                // Content - flush with header (0 top padding per Figma spec)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
      floating: false,
      pinned: true, // Sticky header - stays visible when scrolling
      backgroundColor: AppColors.getBackground(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56,
      title: Text(
        'Analytic',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextPrimary(context),
          fontFeatures: [
            FontFeature.disable('liga'),
            FontFeature.disable('clig'),
          ],
        ),
      ),
      actions: [
        // Calendar icon - matches Settings page pattern
        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              PhosphorIconsRegular.calendarDots,
              size: 24,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ),
        // Sign out icon - matches Settings page pattern
        GestureDetector(
          onTap: () => showLogoutConfirmationDialog(context),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              PhosphorIconsRegular.signOut,
              size: 24,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the analytics summary card with spending data
  ///
  /// **Budget Display Logic**:
  /// - Budget LINE on chart: Always visible (when budget > 0)
  /// - Budget PROGRESS BAR: Only shown for current month
  /// - Past months: Hide progress bar, keep budget line on chart
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

    // Get monthly trends for chart (last 6 months ending at selected month)
    final monthlyTrends = _calculateMonthlyTrends(provider.expenses);

    // Only show budget progress bar for current month
    // Budget line on chart still shows for all months
    final currentMonth = AnalyticsCalculator.currentMonth;
    final isCurrentMonth = _selectedMonth.year == currentMonth.year &&
        _selectedMonth.month == currentMonth.month;

    return AnalyticsSummaryCard(
      totalSpent: totalSpent,
      budgetAmount: budget, // Always pass budget (for chart line)
      monthlyTrends: monthlyTrends,
      selectedMonth: _selectedMonth,
      showBudgetProgress: isCurrentMonth, // Only show progress bar for current month
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
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextPrimary(context),
          fontFeatures: const [
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

  /// Shows the month selector bottom sheet.
  ///
  /// **Design Reference**: Figma node-id=73-2603
  ///
  /// Uses the new SelectMonthSheet with:
  /// - Year navigation (left/right buttons + year display)
  /// - Month grid (4x3, Jan-Dec)
  /// - Selected state highlighting
  /// - Future months disabled
  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showSelectMonthSheet(
      context: context,
      selectedMonth: _selectedMonth,
      // Allow selection from Jan 2020 to current month
      firstDate: DateTime(2020, 1, 1),
      lastDate: AnalyticsCalculator.currentMonth,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
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

  /// Calculates monthly spending totals for trend chart.
  ///
  /// **Chart Logic**:
  /// - Shows 6 months ending at the selected month (visible in chart)
  /// - Plus 1 hidden month before for the continuous line effect
  /// - Example: If Nov 2025 selected → shows Jun-Nov (6 visible) + May (hidden)
  Map<DateTime, double> _calculateMonthlyTrends(List<Expense> expenses) {
    final trends = <DateTime, double>{};

    // Get 6 months ending at selected month
    // The chart will show these 6 + use 1 additional hidden month for line continuity
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(_selectedMonth.year, _selectedMonth.month - i, 1);
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
