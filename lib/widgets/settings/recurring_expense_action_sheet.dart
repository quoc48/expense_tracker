import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/recurring_expense.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/constants/app_spacing.dart';
import '../../theme/typography/app_typography.dart';
import '../common/grabber_bottom_sheet.dart';

/// Actions available for a recurring expense
enum RecurringExpenseAction {
  /// Edit the recurring expense details
  edit,

  /// Pause (or resume if already paused) the recurring expense
  pause,

  /// Delete the recurring expense permanently
  remove,
}

/// Bottom sheet showing actions for a recurring expense item
///
/// **Design Reference**: Figma node-id=78-4190
///
/// **Layout:**
/// - Header: Expense name centered + X close button
/// - 3 option cards in a row (same pattern as AddExpenseOptionsSheet):
///   - Edit (pencil icon)
///   - Pause/Resume (pause/play icon, depends on current state)
///   - Remove (trash icon, RED color)
///
/// **Usage:**
/// ```dart
/// final action = await showRecurringExpenseActionSheet(
///   context: context,
///   expense: expense,
/// );
///
/// switch (action) {
///   case RecurringExpenseAction.edit:
///     // Show edit sheet
///     break;
///   case RecurringExpenseAction.pause:
///     // Toggle active state
///     break;
///   case RecurringExpenseAction.remove:
///     // Delete expense
///     break;
///   case null:
///     // User dismissed
///     break;
/// }
/// ```
class RecurringExpenseActionSheet extends StatelessWidget {
  final RecurringExpense expense;

  const RecurringExpenseActionSheet({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with title and close button
        _buildHeader(context, textColor),

        const SizedBox(height: 24),

        // Action cards row
        Row(
          children: [
            // Edit option
            Expanded(
              child: _ActionCard(
                icon: PhosphorIconsRegular.pencilSimple,
                label: 'Edit',
                onTap: () =>
                    Navigator.pop(context, RecurringExpenseAction.edit),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMd),

            // Pause/Resume option (label changes based on state)
            Expanded(
              child: _ActionCard(
                icon: expense.isActive
                    ? PhosphorIconsRegular.pause
                    : PhosphorIconsRegular.play,
                label: expense.isActive ? 'Pause' : 'Resume',
                onTap: () =>
                    Navigator.pop(context, RecurringExpenseAction.pause),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMd),

            // Remove option (RED icon)
            Expanded(
              child: _ActionCard(
                icon: PhosphorIconsRegular.trash,
                label: 'Remove',
                iconColor: const Color(0xFFFF3B30), // iOS red
                onTap: () =>
                    Navigator.pop(context, RecurringExpenseAction.remove),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build header with expense name and close button
  Widget _buildHeader(BuildContext context, Color textColor) {
    return Row(
      children: [
        // Spacer to balance close button
        const SizedBox(width: 40),

        // Title (expense description, centered)
        Expanded(
          child: Text(
            expense.description,
            textAlign: TextAlign.center,
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Close button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              PhosphorIconsRegular.x,
              size: 24,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual action card with tap feedback
///
/// Reuses the same visual pattern as AddExpenseOptionsSheet _InputMethodCard
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Future<void> _handleTap() async {
    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);
    final isDark = AppColors.isDarkMode(context);
    final bgColor = isDark ? AppColors.neutral300Dark : AppColors.gray6;
    final pressedColor =
        isDark ? const Color(0xFF252525) : AppColors.getDivider(context);

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _isPressed ? pressedColor : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: widget.iconColor ?? textColor,
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              widget.label,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the recurring expense action sheet
///
/// Returns the selected action or null if dismissed
Future<RecurringExpenseAction?> showRecurringExpenseActionSheet({
  required BuildContext context,
  required RecurringExpense expense,
}) {
  return showGrabberBottomSheet<RecurringExpenseAction>(
    context: context,
    child: RecurringExpenseActionSheet(expense: expense),
  );
}
