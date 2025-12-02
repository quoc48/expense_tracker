import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/expense.dart';
import '../theme/colors/app_colors.dart';
import '../theme/constants/app_constants.dart';
import '../theme/constants/app_spacing.dart';
import '../theme/typography/app_typography.dart';
import '../utils/currency_formatter.dart';

/// Reusable expense card widget that displays an expense with consistent styling.
///
/// Features:
/// - Swipe-to-delete with confirmation (optional via enableSwipe)
/// - Warning indicator for uncertain/low-confidence items (showWarning)
/// - Tap to edit functionality (optional via onTap)
/// - Category icon with adaptive colors
/// - Currency formatting
/// - Date display (optional via showDate)
///
/// Used in:
/// - ExpenseListScreen: Main expense list
/// - ScanResultsView: Receipt scanning results
class ExpenseCard extends StatelessWidget {
  /// The expense to display
  final Expense expense;

  /// Callback when card is tapped (typically for editing)
  final VoidCallback? onTap;

  /// Callback when card is dismissed via swipe
  /// If provided, enables swipe-to-delete functionality
  final VoidCallback? onDismissed;

  /// Optional confirmation callback before dismissal
  /// Return true to allow dismissal, false to cancel
  /// If null, no confirmation is required
  final Future<bool?> Function()? confirmDismiss;

  /// Whether to enable swipe-to-delete
  /// If false, card cannot be dismissed
  final bool enableSwipe;

  /// Whether to show a warning indicator (⚠️) next to description
  /// Used for low-confidence Vision AI parsing results
  final bool showWarning;

  /// Whether to show the date in subtitle
  /// Set to false when date is controlled elsewhere (e.g., scan results summary)
  final bool showDate;

  /// Creates an expense card
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDismissed,
    this.confirmDismiss,
    this.enableSwipe = true,
    this.showWarning = false,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    final cardContent = Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.space2xs, // 4px - creates 8px total gap between cards
      ),
      // Minimalist: Subtle elevation for depth
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      child: ListTile(
        dense: true, // Enable dense mode for tighter spacing
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd, // 16px
          vertical: AppSpacing.space2xs, // 4px - ultra-compact
        ),
        minVerticalPadding: 0, // Remove default ListTile vertical padding
        leading: CircleAvatar(
          backgroundColor: AppColors.getAdaptiveNeutral(
            context,
            lightColor: AppColors.neutral100,
            darkColor: AppColors.neutral300Dark, // Lighter circle in dark mode
          ),
          radius: 20,
          child: Icon(
            expense.categoryIcon,
            color: AppColors.getTextPrimary(context),
            size: AppConstants.iconSizeSm,
          ),
        ),
        title: Row(
          children: [
            // Warning indicator for uncertain items
            if (showWarning) ...[
              Icon(
                PhosphorIconsLight.warningCircle,
                size: 16,
                color: Colors.orange,
              ),
              SizedBox(width: AppSpacing.space2xs),
            ],
            // Description text
            Expanded(
              child: Text(
                expense.description,
                style: ComponentTextStyles.expenseTitleCompact(theme.textTheme).copyWith(
                  color: AppColors.getTextPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.space2xs), // 4px minimal gap
          child: Text(
            showDate
                ? dateFormat.format(expense.date) // Show only date (original behavior)
                : '${expense.categoryNameVi} • ${expense.typeNameVi}', // Show category and type (scan results)
            style: ComponentTextStyles.expenseDateCompact(theme.textTheme).copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
        trailing: Text(
          CurrencyFormatter.format(expense.amount, context: CurrencyContext.full),
          style: AppTypography.currencyMedium(
            color: AppColors.getTextPrimary(context),
          ),
        ),
        onTap: onTap,
      ),
    );

    // If swipe is disabled or no onDismissed callback, return card directly
    if (!enableSwipe || onDismissed == null) {
      return cardContent;
    }

    // Otherwise, wrap in Dismissible for swipe-to-delete
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.spaceLg),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Icon(
          PhosphorIconsLight.trash,
          color: AppColors.neutral50, // Light color for delete icon on red background
          size: AppConstants.iconSizeLg,
        ),
      ),
      confirmDismiss: confirmDismiss != null
          ? (direction) async => await confirmDismiss!()
          : null,
      onDismissed: (direction) => onDismissed?.call(),
      child: cardContent,
    );
  }
}
