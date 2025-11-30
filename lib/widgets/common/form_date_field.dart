import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// A styled date picker field with label for forms.
///
/// **Design Reference**: Figma node-id=56-3279 (same as FormSelectField)
///
/// **Specifications**:
/// - Label: 14px Regular, black, above input
/// - Gap between label and input: 8px
/// - Input container: 48px height, gray6 (#F2F2F7) background, 12px radius
/// - Input padding: 16px horizontal
/// - Text: 14px Regular, black when has value, gray2 when placeholder
/// - Calendar icon: 20x20, right side (differs from FormSelectField's caret)
/// - Letter spacing: 0.28px
///
/// **Behavior**:
/// - Tappable - calls [onTap] callback to show date picker
/// - Shows placeholder when [value] is null
/// - Shows formatted date text when [value] is provided
///
/// **Usage**:
/// ```dart
/// FormDateField(
///   label: 'Date',
///   placeholder: 'Select date',
///   value: formattedDate,
///   onTap: () => _showDatePicker(),
/// )
/// ```
class FormDateField extends StatelessWidget {
  /// The label text displayed above the input.
  final String label;

  /// Placeholder text shown when value is null.
  final String placeholder;

  /// The current selected value (displayed as formatted date text).
  final String? value;

  /// Callback when the field is tapped.
  final VoidCallback? onTap;

  const FormDateField({
    super.key,
    required this.label,
    this.placeholder = 'Select date',
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

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
            color: AppColors.textBlack,
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
              color: AppColors.gray6,
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
                          ? AppColors.textBlack
                          : const Color(0xFFAEAEB2), // gray2
                      letterSpacing: 0.28,
                      height: 24 / 14,
                    ),
                  ),
                ),

                // Calendar icon (the key difference from FormSelectField)
                const Icon(
                  PhosphorIconsRegular.calendarDots,
                  size: 20,
                  color: AppColors.textBlack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
