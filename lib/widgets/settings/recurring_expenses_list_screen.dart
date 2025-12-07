import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/recurring_expense.dart';
import '../../providers/recurring_expense_provider.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../theme/constants/app_spacing.dart';
import 'add_recurring_expense_sheet.dart';
import 'recurring_expense_action_sheet.dart';
import '../common/primary_button.dart';
import '../common/success_overlay.dart';

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
                fontSize: 16,
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
  /// **Design Reference**: Figma node-id=78-3867, 80-4574 (notebook icon)
  /// - Image: 180x180px centered (dark mode compatible)
  /// - Text: "There is nothing yet" - 14px Regular, black (not gray)
  /// - Button: "New Recurring Expense" - 220x48px, black bg, 12px radius, MomoTrustSans
  Widget _buildEmptyState(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration - notebook empty state (Figma node-id=80-4574)
            // Uses theme-aware SVG for proper light/dark mode colors
            SvgPicture.asset(
              AppColors.isDarkMode(context)
                  ? 'assets/images/notebook_dark.svg'
                  : 'assets/images/notebook.svg',
              width: 180,
              height: 180,
            ),

            const SizedBox(height: 24),

            // Empty text - should be black (textPrimary), not gray
            Text(
              'There is nothing yet',
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textColor, // Bug fix: was AppColors.gray, now uses textPrimary
              ),
            ),

            const SizedBox(height: 24),

            // CTA Button - Uses PrimaryButton for consistent MomoTrustSans font
            // PrimaryButton uses ElevatedButton which properly applies the theme font
            SizedBox(
              width: 220,
              child: PrimaryButton(
                label: 'New Recurring Expense',
                onPressed: () => _showAddSheet(context),
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
        fontSize: 14,
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
    final dividerColor = AppColors.getDivider(context);

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
              // Divider - same style as expense_list_tile.dart
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: dividerColor,
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Build individual expense item row
  ///
  /// **Design Reference**: Figma node-id=78-4080 (active), 78-4161 (inactive)
  /// - Active: 32x32 icon circle with category color (10% opacity bg)
  /// - Inactive: 32x32 icon circle with gray6 bg (#F2F2F7)
  /// - Description (14px) + Frequency subtitle (10px gray)
  /// - Amount on right (14px)
  Widget _buildExpenseItem(BuildContext context, RecurringExpense expense) {
    final textColor = AppColors.getTextPrimary(context);
    final isDark = AppColors.isDarkMode(context);

    // Active items use category color, inactive use gray
    final categoryColor = AppColors.getCategoryColor(expense.categoryNameVi);
    final iconBgColor = expense.isActive
        ? categoryColor.withValues(alpha: 0.1) // 10% category color
        : (isDark ? AppColors.neutral300Dark : AppColors.gray6); // Gray for inactive
    final iconColor = expense.isActive
        ? categoryColor // Category color for active
        : (isDark ? AppColors.gray : textColor); // Gray icon for inactive

    return InkWell(
      onTap: () => _showActionSheet(context, expense),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon circle - color based on active status
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
                color: iconColor,
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
                      fontSize: 16,
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
                      fontSize: 12,
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
                fontSize: 16,
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
      // Show success overlay
      if (mounted) {
        await showSuccessOverlay(
          context: context,
          message: 'Recurring expense added',
        );
      }
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
        if (!mounted) return;
        final updated = await showAddRecurringExpenseSheet(
          // Use this.context after mounted check for proper lint compliance
          context: this.context,
          existingExpense: expense,
        );
        if (updated != null && mounted) {
          await provider.updateRecurringExpense(updated);
          // Show success overlay
          if (mounted) {
            await showSuccessOverlay(
              context: this.context,
              message: 'Recurring expense updated',
            );
          }
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
