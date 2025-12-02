import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/constants/app_spacing.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../theme/typography/app_typography.dart';
import 'grabber_bottom_sheet.dart';

// ============================================================================
// DESIGN SYSTEM RULE: Typography
// ============================================================================
// Always use AppTypography.style() for all text in custom components.
// This ensures consistent "MomoTrustSans" font across the app.
//
// Example:
//   style: AppTypography.style(
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: AppColors.textBlack,
//   )
//
// DO NOT use raw TextStyle() with hardcoded fontFamily.
// ============================================================================

/// The input method options for adding an expense.
enum AddExpenseInputMethod {
  /// Manual text entry
  manual,

  /// Camera/receipt scanning
  camera,

  /// Voice input (future feature)
  voice,
}

/// Bottom sheet that shows input method options for adding an expense.
///
/// Displays three options:
/// - Manual: Opens manual expense entry form
/// - Camera: Opens receipt scanning (existing feature)
/// - Voice: Future feature (currently does nothing)
///
/// Design Reference: Figma node-id=58-3460
///
/// Usage:
/// ```dart
/// final method = await showAddExpenseOptionsSheet(context: context);
/// if (method == AddExpenseInputMethod.manual) {
///   // Navigate to manual entry
/// }
/// ```
class AddExpenseOptionsSheet extends StatelessWidget {
  const AddExpenseOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Voice option (future feature - does nothing for now)
        Expanded(
          child: _InputMethodCard(
            icon: MinimalistIcons.inputVoice,
            label: 'Voice',
            onTap: () {
              // Future feature - do nothing for now
              // Could show a "Coming soon" message if desired
            },
          ),
        ),
        const SizedBox(width: AppSpacing.spaceMd),

        // Camera option
        Expanded(
          child: _InputMethodCard(
            icon: MinimalistIcons.inputCamera,
            label: 'Camera',
            onTap: () => Navigator.pop(context, AddExpenseInputMethod.camera),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceMd),

        // Manual option
        Expanded(
          child: _InputMethodCard(
            icon: MinimalistIcons.inputManual,
            label: 'Manual',
            onTap: () => Navigator.pop(context, AddExpenseInputMethod.manual),
          ),
        ),
      ],
    );
  }
}

/// Individual option card for input method selection with tap state feedback.
///
/// Specifications from Figma:
/// - Height: 100px
/// - Background: gray6 (#F2F2F7)
/// - Border radius: 12px
/// - Icon size: 24px
/// - Label: 14px medium weight
/// - Gap between icon and label: 8px
/// - Tap state: Slightly darker background
class _InputMethodCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InputMethodCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_InputMethodCard> createState() => _InputMethodCardState();
}

class _InputMethodCardState extends State<_InputMethodCard> {
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

  /// Handle tap with visual feedback delay
  Future<void> _handleTap() async {
    // Keep pressed state visible briefly before executing action
    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive colors for dark mode
    final textColor = AppColors.getTextPrimary(context);
    final isDark = AppColors.isDarkMode(context);
    // In dark mode: cards should be LIGHTER than sheet background (#161616)
    // Use #1E1E1E (neutral300Dark) for cards, #252525 for pressed state
    final bgColor = isDark ? AppColors.neutral300Dark : AppColors.gray6;
    final pressedColor = isDark ? const Color(0xFF252525) : AppColors.getDivider(context);

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          // Use adaptive pressed state color
          color: _isPressed ? pressedColor : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: textColor, // Adaptive for dark mode
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              widget.label,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor, // Adaptive for dark mode
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the add expense options bottom sheet.
///
/// Returns the selected [AddExpenseInputMethod] or null if dismissed.
///
/// Example:
/// ```dart
/// final method = await showAddExpenseOptionsSheet(context: context);
/// switch (method) {
///   case AddExpenseInputMethod.manual:
///     // Open manual entry form
///     break;
///   case AddExpenseInputMethod.camera:
///     // Open camera for receipt scanning
///     break;
///   case AddExpenseInputMethod.voice:
///   case null:
///     // Do nothing
///     break;
/// }
/// ```
Future<AddExpenseInputMethod?> showAddExpenseOptionsSheet({
  required BuildContext context,
}) {
  return showGrabberBottomSheet<AddExpenseInputMethod>(
    context: context,
    child: const AddExpenseOptionsSheet(),
  );
}
