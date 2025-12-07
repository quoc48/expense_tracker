import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';

/// A styled text input field with label for forms.
///
/// **Design Reference**: Figma node-id=56-3131
///
/// **Specifications**:
/// - Label: 14px Regular, black, above input
/// - Gap between label and input: 8px
/// - Input container: 48px height, gray6 (#F2F2F7) background, 12px radius
/// - Input padding: 16px horizontal, 12px vertical
/// - Input text: 14px Regular, black
/// - Placeholder text: 14px Regular, gray2 (#AEAEB2)
/// - Letter spacing: 0.28px
///
/// **Usage**:
/// ```dart
/// FormTextField(
///   label: 'Description',
///   placeholder: 'e.g Đi chợ',
///   controller: _descriptionController,
/// )
/// ```
class FormTextField extends StatelessWidget {
  /// The label text displayed above the input.
  final String label;

  /// Placeholder text shown when input is empty.
  final String? placeholder;

  /// Controller for the text input.
  final TextEditingController? controller;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Focus node for managing focus.
  final FocusNode? focusNode;

  /// Text capitalization mode.
  final TextCapitalization textCapitalization;

  /// Maximum number of lines (default 1 for single-line input).
  final int maxLines;

  const FormTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Adaptive colors for dark mode
    final textColor = AppColors.getTextPrimary(context);
    // Use input field background - lighter than sheet in dark mode for visibility
    final inputBgColor = AppColors.getInputFieldBackground(context);
    final placeholderColor = AppColors.getPlaceholder(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor, // Adaptive for dark mode
            height: 20 / 14, // line-height: 20px
          ),
        ),

        // Gap between label and input (8px from Figma)
        const SizedBox(height: 8),

        // Input container
        Container(
          height: maxLines > 1 ? null : 48,
          decoration: BoxDecoration(
            color: inputBgColor, // Adaptive for dark mode
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onChanged: onChanged,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor, // Adaptive for dark mode
              letterSpacing: 0.28,
              height: 24 / 14, // line-height: 24px
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: placeholderColor, // Adaptive for dark mode
                letterSpacing: 0.28,
                height: 24 / 14,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 12 : 0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              // Center the text vertically for single-line
              isCollapsed: maxLines == 1,
            ),
          ),
        ),
      ],
    );
  }
}
