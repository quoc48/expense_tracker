import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// Button variant enum for different button styles
enum ButtonVariant {
  /// Primary filled button (black background, white text)
  primary,

  /// Secondary text button (transparent background, black text, optional icon)
  secondary,
}

/// A primary action button with consistent styling.
///
/// **Design Reference**: Figma node-id=55-1049
///
/// **Specifications**:
/// - Height: 48px
/// - Background: Black (#000000) when enabled, gray when disabled
/// - Border radius: 12px
/// - Full width (expands to parent width)
/// - Text: 16px SemiBold, white, centered
/// - Letter spacing: 0.32px
///
/// **States**:
/// - Enabled: Black background, tappable
/// - Disabled: Gray background (#C7C7CC), not tappable
/// - Loading: Shows CupertinoActivityIndicator (iOS-style spinner)
///
/// **Usage**:
/// ```dart
/// PrimaryButton(
///   label: 'Add Expense',
///   onPressed: _handleAddExpense,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// Callback when the button is pressed. Pass null to disable the button.
  final VoidCallback? onPressed;

  /// Whether to show a loading indicator instead of the label.
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled only when no callback provided (not during loading)
    final isDisabled = onPressed == null;
    // Not tappable during loading or when disabled
    final isTappable = onPressed != null && !isLoading;

    // Background: black when enabled/loading, gray only when truly disabled
    // Dark mode: white when enabled, darker gray when disabled
    final backgroundColor = isDisabled
        ? AppColors.getNeutral400(context)
        : (AppColors.isDarkMode(context) ? AppColors.white : AppColors.textBlack);

    // Foreground: white on black, black on white
    final foregroundColor = AppColors.isDarkMode(context) && !isDisabled
        ? AppColors.black
        : AppColors.white;

    return SizedBox(
      width: double.infinity, // Full width
      height: 48,
      child: ElevatedButton(
        onPressed: isTappable ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor, // Keep same color when loading
          disabledForegroundColor: foregroundColor,
          elevation: 0, // Flat design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero, // We control height via SizedBox
        ),
        child: isLoading
            ? CupertinoActivityIndicator(
                color: foregroundColor,
                radius: 10,
              )
            : Text(
                label,
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                  letterSpacing: 0.32,
                ),
              ),
      ),
    );
  }
}

/// A secondary text button with transparent background.
///
/// **Specifications**:
/// - Height: 48px
/// - Background: Transparent
/// - Border: None
/// - Full width (expands to parent width)
/// - Text: 14px Medium, black, centered
/// - Optional leading icon
///
/// **Usage**:
/// ```dart
/// SecondaryButton(
///   label: 'New Item',
///   icon: PhosphorIconsRegular.plus,
///   onPressed: _handleAddItem,
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Callback when the button is pressed. Pass null to disable the button.
  final VoidCallback? onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    // Adaptive text color for dark mode
    final textColor = isDisabled
        ? AppColors.getTextSecondary(context)
        : AppColors.getTextPrimary(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.style(
                fontSize: 16,
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
