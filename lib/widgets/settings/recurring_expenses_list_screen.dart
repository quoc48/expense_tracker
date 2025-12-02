import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/recurring_expense.dart';
import '../../providers/recurring_expense_provider.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../theme/constants/app_spacing.dart';
import 'add_recurring_expense_sheet.dart';
import 'recurring_expense_action_sheet.dart';

/// Full-screen list of recurring expenses with empty state
///
/// **Design Reference**: Figma node-id=78-4062 (list), 78-3867 (empty)
///
/// **Features:**
/// - Empty state with illustration and "New Recurring Expense" button
/// - Grouped sections: ACTIVE (n) / INACTIVE (n)
/// - Tap item to show action sheet (edit/pause/delete)
/// - Header with back button (left) + plus button (right)
///
/// **Navigation:**
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const RecurringExpensesListScreen(),
/// ));
/// ```
class RecurringExpensesListScreen extends StatefulWidget {
  const RecurringExpensesListScreen({super.key});

  @override
  State<RecurringExpensesListScreen> createState() =>
      _RecurringExpensesListScreenState();
}

class _RecurringExpensesListScreenState
    extends State<RecurringExpensesListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurringExpenseProvider>().loadRecurringExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Consumer<RecurringExpenseProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Header
                _buildHeader(context, provider),

                // Content
                Expanded(
                  child: provider.isLoading
                      ? _buildLoading(context)
                      : provider.expenses.isEmpty
                          ? _buildEmptyState(context)
                          : _buildList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build header with back button, title, and add button
  ///
  /// **Design Reference**: Figma node-id=78-4063
  /// - Height: 56px
  /// - Back button: 40x40 white circle, left side
  /// - Title: "Recurring Expenses" centered
  /// - Plus button: 40x40 white circle, right side
  Widget _buildHeader(BuildContext context, RecurringExpenseProvider provider) {
    final textColor = AppColors.getTextPrimary(context);
    final buttonBg = AppColors.getSurface(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back button - 40x40 circle, 24px icon (Regular weight)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: buttonBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.caretLeft,
                size: 24,
                color: textColor,
              ),
            ),
          ),

          // Title (centered)
          Expanded(
            child: Text(
              'Recurring Expenses',
              textAlign: TextAlign.center,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),

          // Add button (only show when we have items or want to always show)
          GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: buttonBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.plus,
                size: 24, // Figma: 24px Regular weight
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.getTextPrimary(context),
      ),
    );
  }

  /// Build empty state with illustration and CTA button
  ///
  /// **Design Reference**: Figma node-id=78-3867
  /// - Image: 180x180px centered
  /// - Text: "There is nothing yet" - 14px Regular, gray
  /// - Button: "New Recurring Expense" - 220x48px, black bg, 12px radius
  Widget _buildEmptyState(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration - notebook empty state
            Image.asset(
              'assets/images/notebook.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // Empty text
            Text(
              'There is nothing yet',
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.gray,
              ),
            ),

            const SizedBox(height: 24),

            // CTA Button
            GestureDetector(
              onTap: () => _showAddSheet(context),
              child: Container(
                width: 220,
                height: 48,
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'New Recurring Expense',
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getSurface(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list with grouped sections (ACTIVE / INACTIVE)
  ///
  /// **Design Reference**: Figma node-id=78-4062
  Widget _buildList(BuildContext context, RecurringExpenseProvider provider) {
    final activeExpenses = provider.activeExpenses;
    final inactiveExpenses = provider.inactiveExpenses;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active section (only if there are active items)
        if (activeExpenses.isNotEmpty) ...[
          _buildSectionHeader('ACTIVE', activeExpenses.length),
          const SizedBox(height: 12),
          _buildExpenseCard(context, activeExpenses),
        ],

        // Spacing between sections
        if (activeExpenses.isNotEmpty && inactiveExpenses.isNotEmpty)
          const SizedBox(height: 24),

        // Inactive section (only if there are inactive items)
        if (inactiveExpenses.isNotEmpty) ...[
          _buildSectionHeader('INACTIVE', inactiveExpenses.length),
          const SizedBox(height: 12),
          _buildExpenseCard(context, inactiveExpenses),
        ],
      ],
    );
  }

  /// Build section header like "ACTIVE (2)"
  ///
  /// **Design Reference**: 12px gray text (#8E8E93)
  Widget _buildSectionHeader(String label, int count) {
    return Text(
      '$label ($count)',
      style: AppTypography.style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.gray,
      ),
    );
  }

  /// Build card containing expense items
  ///
  /// **Design Reference**: White card with 8px radius, items separated by dividers
  Widget _buildExpenseCard(
      BuildContext context, List<RecurringExpense> expenses) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < expenses.length; i++) ...[
            _buildExpenseItem(context, expenses[i]),
            if (i < expenses.length - 1)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 1,
                color: AppColors.getDivider(context),
              ),
          ],
        ],
      ),
    );
  }

  /// Build individual expense item row
  ///
  /// **Design Reference**: Figma node-id=78-4080
  /// - 32x32 icon circle (gray6 bg)
  /// - Description (14px) + Frequency subtitle (10px gray)
  /// - Amount on right (14px)
  Widget _buildExpenseItem(BuildContext context, RecurringExpense expense) {
    final textColor = AppColors.getTextPrimary(context);
    final isDark = AppColors.isDarkMode(context);
    final iconBgColor = isDark ? AppColors.neutral300Dark : AppColors.gray6;

    return InkWell(
      onTap: () => _showActionSheet(context, expense),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                expense.categoryIcon,
                size: 16,
                color: textColor,
              ),
            ),

            const SizedBox(width: 12),

            // Description + Frequency
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Monthly (1st)',
                    style: AppTypography.style(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              _formatAmount(expense.amount),
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format amount with comma separators
  String _formatAmount(double amount) {
    final intValue = amount.toInt();
    final str = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Show add recurring expense sheet
  Future<void> _showAddSheet(BuildContext context) async {
    // Capture provider before async gap
    final provider = context.read<RecurringExpenseProvider>();

    final result = await showAddRecurringExpenseSheet(context: context);

    if (result != null && mounted) {
      await provider.createRecurringExpense(result);
    }
  }

  /// Show action sheet for existing expense (edit/pause/delete)
  Future<void> _showActionSheet(
      BuildContext context, RecurringExpense expense) async {
    // Capture provider before async gap
    final provider = context.read<RecurringExpenseProvider>();

    final action = await showRecurringExpenseActionSheet(
      context: context,
      expense: expense,
    );

    if (action == null || !mounted) return;

    switch (action) {
      case RecurringExpenseAction.edit:
        // Show edit sheet with existing data
        final updated = await showAddRecurringExpenseSheet(
          context: context,
          existingExpense: expense,
        );
        if (updated != null && mounted) {
          await provider.updateRecurringExpense(updated);
        }
        break;

      case RecurringExpenseAction.pause:
        await provider.toggleActive(expense.id);
        break;

      case RecurringExpenseAction.remove:
        await provider.deleteRecurringExpense(expense.id);
        break;
    }
  }
}
