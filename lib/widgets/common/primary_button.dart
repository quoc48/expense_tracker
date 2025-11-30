import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

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
/// - Loading: Shows CircularProgressIndicator instead of text
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
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity, // Full width
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.textBlack : const Color(0xFFC7C7CC),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFC7C7CC),
          disabledForegroundColor: Colors.white,
          elevation: 0, // Flat design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero, // We control height via SizedBox
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.32,
                ),
              ),
      ),
    );
  }
}
