import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../utils/currency_formatter.dart';

/// ExpenseListTile - A flat row component for displaying expenses.
///
/// **Design Reference**: Figma node-id=5-2165 (Expenses Screen)
///
/// **Visual Specs**:
/// - Row layout: Category icon (32px circular) | Text column | Amount
/// - Icon background: Category color with 10% opacity
/// - Icon: 18px filled icon, centered in 32px circle
/// - Description: 14px, black, regular weight
/// - Date: 10px, gray (#8E8E93), regular weight
/// - Amount: 14px, black, "70,000 đ" format
/// - Padding: 8px horizontal, 12px vertical
/// - Gap: 8px between icon and text
///
/// **Font**: Momo Trust Sans (Regular for text, no bold/semibold)
class ExpenseListTile extends StatelessWidget {
  /// The expense to display
  final Expense expense;

  /// Callback when tile is tapped (typically for editing)
  final VoidCallback? onTap;

  /// Callback when tile is long-pressed (optional)
  final VoidCallback? onLongPress;

  /// Whether to show the divider below the tile
  final bool showDivider;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get category color from our design system
    final categoryColor = AppColors.getCategoryColor(expense.categoryNameVi);

    // Date format: "Nov 24, 2025" as shown in Figma
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Adaptive divider color for dark mode
    final dividerColor = AppColors.getDivider(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main row content
        InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Left side: Icon + Text
                Expanded(
                  child: Row(
                    children: [
                      // Category icon circle (32x32)
                      _buildCategoryIcon(categoryColor),

                      // 8px gap between icon and text
                      const SizedBox(width: 8),

                      // Text column: Description + Date
                      Expanded(
                        child: _buildTextColumn(context, dateFormat),
                      ),
                    ],
                  ),
                ),

                // 16px gap before amount (from Figma)
                const SizedBox(width: 16),

                // Right side: Amount
                _buildAmount(context),
              ],
            ),
          ),
        ),

        // Divider (thin line between items) with 8px horizontal padding
        if (showDivider)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: dividerColor, // Adaptive for dark mode
            ),
          ),
      ],
    );
  }

  /// Build the circular category icon (32x32)
  /// Background: category color at 10% opacity
  /// Icon: 18px filled icon, centered
  Widget _buildCategoryIcon(Color categoryColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        // 10% opacity background as per Figma
        color: categoryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          MinimalistIcons.getCategoryIconFill(expense.categoryNameVi),
          size: 18,
          color: categoryColor,
        ),
      ),
    );
  }

  /// Build the text column (Description + Date)
  Widget _buildTextColumn(BuildContext context, DateFormat dateFormat) {
    final textColor = AppColors.getTextPrimary(context);
    final secondaryColor = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Description - 14px, black, regular
        Text(
          expense.description,
          style: TextStyle(
            fontFamily: 'MomoTrustSans',
            fontSize: 14,
            fontWeight: FontWeight.w400, // Regular
            color: textColor, // Adaptive for dark mode
            height: 1.2, // Compact line height
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // 4px gap between description and date
        const SizedBox(height: 4),

        // Date - 10px, gray, regular
        Text(
          dateFormat.format(expense.date),
          style: TextStyle(
            fontFamily: 'MomoTrustSans',
            fontSize: 10,
            fontWeight: FontWeight.w400, // Regular
            color: secondaryColor, // Adaptive for dark mode
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Build the amount text (right-aligned)
  /// Format: "70,000 đ" with space before đ
  Widget _buildAmount(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return Text(
      CurrencyFormatter.format(expense.amount, context: CurrencyContext.full),
      style: TextStyle(
        fontFamily: 'MomoTrustSans',
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        color: textColor, // Adaptive for dark mode
      ),
    );
  }
}

/// A dismissible version of ExpenseListTile with swipe-to-delete.
///
/// Wraps ExpenseListTile with Dismissible widget for swipe gestures.
/// Used in the main expenses list where delete functionality is needed.
class DismissibleExpenseListTile extends StatelessWidget {
  /// The expense to display
  final Expense expense;

  /// Callback when tile is tapped
  final VoidCallback? onTap;

  /// Callback when tile is dismissed via swipe
  final VoidCallback? onDismissed;

  /// Optional confirmation callback before dismissal
  /// Return true to allow dismissal, false to cancel
  final Future<bool?> Function()? confirmDismiss;

  /// Whether to show the divider below the tile
  final bool showDivider;

  const DismissibleExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDismissed,
    this.confirmDismiss,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: confirmDismiss != null
          ? (direction) async => await confirmDismiss!()
          : null,
      onDismissed: (direction) => onDismissed?.call(),
      child: ExpenseListTile(
        expense: expense,
        onTap: onTap,
        showDivider: showDivider,
      ),
    );
  }
}
