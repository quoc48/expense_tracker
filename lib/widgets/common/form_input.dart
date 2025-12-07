import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// Design System Rule: Always use Regular weight icons (not Light)
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// Enum for form input variants
enum FormInputVariant {
  /// Text input field (editable)
  text,

  /// Select field (tappable, shows dropdown icon)
  select,

  /// Date field (tappable, shows calendar icon)
  date,
}

/// A unified form input component with consistent styling across variants.
///
/// **Design Reference**: Figma node-id=56-3131, 56-3279
///
/// **Variants**:
/// - `text`: Editable text input with optional keyboard
/// - `select`: Tappable field with caret-down icon, calls onTap
/// - `date`: Tappable field with calendar icon, calls onTap
///
/// **Specifications** (consistent across all variants):
/// - Label: 14px Regular, black, above input
/// - Gap between label and input: 8px
/// - Input container: 48px height (single line), gray6 background, 12px radius
/// - Input padding: 16px horizontal
/// - Text: 14px Regular, black when has value, gray2 (#AEAEB2) when placeholder
/// - Letter spacing: 0.28px
///
/// **Usage**:
/// ```dart
/// // Text input
/// FormInput(
///   variant: FormInputVariant.text,
///   label: 'Description',
///   placeholder: 'e.g. Đi chợ',
///   controller: _controller,
/// )
///
/// // Select input
/// FormInput(
///   variant: FormInputVariant.select,
///   label: 'Category',
///   placeholder: 'Select category',
///   value: selectedCategory,
///   onTap: () => _showCategoryPicker(),
/// )
///
/// // Date input
/// FormInput(
///   variant: FormInputVariant.date,
///   label: 'Date',
///   placeholder: 'Select date',
///   value: formattedDate,
///   onTap: () => _showDatePicker(),
/// )
/// ```
class FormInput extends StatelessWidget {
  /// The input variant type.
  final FormInputVariant variant;

  /// The label text displayed above the input.
  final String label;

  /// Placeholder text shown when empty.
  final String? placeholder;

  /// For text variant: controller for the text input.
  final TextEditingController? controller;

  /// For select/date variants: the current displayed value.
  final String? value;

  /// For select/date variants: callback when tapped.
  final VoidCallback? onTap;

  /// For text variant: callback when text changes.
  final ValueChanged<String>? onChanged;

  /// For text variant: maximum number of lines.
  final int maxLines;

  /// For text variant: text capitalization mode.
  final TextCapitalization textCapitalization;

  /// For text variant: keyboard type.
  final TextInputType? keyboardType;

  /// For text variant: focus node.
  final FocusNode? focusNode;

  /// For text variant: whether field is read-only.
  final bool readOnly;

  /// Error message to display below the input.
  /// When provided, the input shows a red border and error text below.
  final String? errorText;

  /// Optional leading widget (e.g., category icon) for select variant.
  /// Displayed before the value text with 8px gap.
  final Widget? leadingWidget;

  const FormInput({
    super.key,
    required this.variant,
    required this.label,
    this.placeholder,
    this.controller,
    this.value,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType,
    this.focusNode,
    this.readOnly = false,
    this.errorText,
    this.leadingWidget,
  });

  // Design constants
  static const double _inputHeight = 48.0;
  static const double _borderRadius = 12.0;
  static const double _horizontalPadding = 16.0;
  static const double _labelGap = 8.0;
  static const double _fontSize = 16.0;
  static const double _letterSpacing = 0.28;
  // Note: Placeholder color is now adaptive via AppColors.getPlaceholder(context)
  static const Color _errorColor = Color(0xFFFF3B30); // iOS red

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    // Adaptive text color for dark mode
    final textColor = AppColors.getTextPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: AppTypography.style(
            fontSize: _fontSize,
            fontWeight: FontWeight.w400,
            color: hasError ? _errorColor : textColor, // Adaptive for dark mode
            height: 20 / _fontSize,
          ),
        ),

        // Gap between label and input
        const SizedBox(height: _labelGap),

        // Input container (varies by type)
        _buildInputContainer(hasError),

        // Error text
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _errorColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputContainer(bool hasError) {
    switch (variant) {
      case FormInputVariant.text:
        return _buildTextInput(hasError);
      case FormInputVariant.select:
        return _buildSelectInput(PhosphorIconsRegular.caretDown, hasError);
      case FormInputVariant.date:
        return _buildSelectInput(PhosphorIconsRegular.calendarDots, hasError);
    }
  }

  /// Build text input variant
  Widget _buildTextInput(bool hasError) {
    final isMultiLine = maxLines > 1;

    return Builder(
      builder: (context) {
        // Adaptive colors for dark mode
        // Use input field background - lighter than sheet in dark mode for visibility
        final inputBgColor = AppColors.getInputFieldBackground(context);
        final textColor = AppColors.getTextPrimary(context);
        final placeholderColor = AppColors.getPlaceholder(context);

        return Container(
          height: isMultiLine ? null : _inputHeight,
          constraints: isMultiLine
              ? const BoxConstraints(minHeight: _inputHeight)
              : null,
          decoration: BoxDecoration(
            color: inputBgColor, // Adaptive for dark mode
            borderRadius: BorderRadius.circular(_borderRadius),
            border: hasError
                ? Border.all(color: _errorColor, width: 1)
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onChanged: onChanged,
            textCapitalization: textCapitalization,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTypography.style(
              fontSize: _fontSize,
              fontWeight: FontWeight.w400,
              color: textColor, // Adaptive for dark mode
              letterSpacing: _letterSpacing,
              height: 24 / _fontSize,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTypography.style(
                fontSize: _fontSize,
                fontWeight: FontWeight.w400,
                color: placeholderColor, // Adaptive for dark mode
                letterSpacing: _letterSpacing,
                height: 24 / _fontSize,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: isMultiLine ? 12 : (_inputHeight - 24) / 2,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        );
      },
    );
  }

  /// Build select/date input variant with icon
  Widget _buildSelectInput(IconData icon, bool hasError) {
    final hasValue = value != null && value!.isNotEmpty;

    return Builder(
      builder: (context) {
        // Adaptive colors for dark mode
        // Use input field background - lighter than sheet in dark mode for visibility
        final inputBgColor = AppColors.getInputFieldBackground(context);
        final textColor = AppColors.getTextPrimary(context);
        final placeholderColor = AppColors.getPlaceholder(context);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            decoration: BoxDecoration(
              color: inputBgColor, // Adaptive for dark mode
              borderRadius: BorderRadius.circular(_borderRadius),
              border: hasError
                  ? Border.all(color: _errorColor, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Leading widget (e.g., category icon) - only show when has value
                if (leadingWidget != null && hasValue) ...[
                  leadingWidget!,
                  const SizedBox(width: 8), // Gap between icon and text
                ],

                // Value or placeholder text
                Expanded(
                  child: Text(
                    hasValue ? value! : (placeholder ?? ''),
                    style: AppTypography.style(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w400,
                      color: hasValue ? textColor : placeholderColor, // Adaptive for dark mode
                      letterSpacing: _letterSpacing,
                      height: 24 / _fontSize,
                    ),
                  ),
                ),

                // Trailing icon (caret or calendar)
                Icon(
                  icon,
                  size: 20,
                  color: textColor, // Adaptive for dark mode
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
