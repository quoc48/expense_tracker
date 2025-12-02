import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// A styled select/dropdown field with label for forms.
///
/// **Design Reference**: Figma node-id=56-3279
///
/// **Specifications**:
/// - Label: 14px Regular, black, above input
/// - Gap between label and input: 8px
/// - Input container: 48px height, gray6 (#F2F2F7) background, 12px radius
/// - Input padding: 16px horizontal
/// - Text: 14px Regular, black when has value, gray2 when placeholder
/// - Caret-down icon: 20x20, right side
/// - Letter spacing: 0.28px
///
/// **Behavior**:
/// - Tappable - calls [onTap] callback
/// - Shows placeholder when [value] is null
/// - Shows value text when [value] is provided
///
/// **Usage**:
/// ```dart
/// FormSelectField(
///   label: 'Category',
///   placeholder: 'Select one',
///   value: selectedCategory,
///   onTap: () => _showCategoryPicker(),
/// )
/// ```
class FormSelectField extends StatelessWidget {
  /// The label text displayed above the input.
  final String label;

  /// Placeholder text shown when value is null.
  final String placeholder;

  /// The current selected value (displayed as text).
  final String? value;

  /// Callback when the field is tapped.
  final VoidCallback? onTap;

  const FormSelectField({
    super.key,
    required this.label,
    this.placeholder = 'Select one',
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    // Adaptive colors for dark mode
    final textColor = AppColors.getTextPrimary(context);
    final inputBgColor = AppColors.getCardBackground(context);
    final placeholderColor = AppColors.getPlaceholder(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: AppTypography.style(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor, // Adaptive for dark mode
            height: 20 / 14, // line-height: 20px
          ),
        ),

        // Gap between label and input (8px from Figma)
        const SizedBox(height: 8),

        // Input container (tappable)
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputBgColor, // Adaptive for dark mode
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Value or placeholder text
                Expanded(
                  child: Text(
                    hasValue ? value! : placeholder,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: hasValue
                          ? textColor // Adaptive for dark mode
                          : placeholderColor, // Adaptive for dark mode
                      letterSpacing: 0.28,
                      height: 24 / 14,
                    ),
                  ),
                ),

                // Caret-down icon
                Icon(
                  PhosphorIconsRegular.caretDown,
                  size: 20,
                  color: textColor, // Adaptive for dark mode
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
