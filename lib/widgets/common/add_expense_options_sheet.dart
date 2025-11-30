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
        // Manual option
        Expanded(
          child: _InputMethodCard(
            icon: MinimalistIcons.inputManual,
            label: 'Manual',
            onTap: () => Navigator.pop(context, AddExpenseInputMethod.manual),
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
      ],
    );
  }
}

/// Individual option card for input method selection.
///
/// Specifications from Figma:
/// - Height: 100px
/// - Background: gray6 (#F2F2F7)
/// - Border radius: 12px
/// - Icon size: 24px
/// - Label: 14px medium weight
/// - Gap between icon and label: 8px
class _InputMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InputMethodCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.gray6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              label,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
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
