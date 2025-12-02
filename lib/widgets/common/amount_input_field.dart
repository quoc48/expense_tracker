import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// A large centered amount input field with currency symbol.
///
/// **Design Reference**: Figma node-id=56-2932
///
/// **Specifications**:
/// - Number and "đ" are separate elements with 4px spacing
/// - Number: 40px Bold, gray (#8E8E93) when 0, black when has value
/// - Currency symbol "đ": 40px Bold, gray (#8E8E93)
/// - Auto-focuses when widget is built
/// - Shows iOS numeric keyboard
/// - Centered horizontally
/// - Auto-formats with comma thousand separators (e.g., 1,000,000)
///
/// **Behavior**:
/// - On open: show "0" (gray), cursor appears AFTER the 0, keyboard appears
/// - On first digit: replaces the 0, text turns black
/// - On subsequent typing: appends digits with thousand separators
///
/// **Usage**:
/// ```dart
/// AmountInputField(
///   controller: _amountController,
///   focusNode: _amountFocusNode,
///   onChanged: (value) => print('Amount: $value'),
/// )
/// ```
class AmountInputField extends StatefulWidget {
  /// Controller for the amount value.
  /// The controller's text will contain the raw number without formatting.
  final TextEditingController controller;

  /// Focus node for managing focus state.
  final FocusNode? focusNode;

  /// Callback when the amount value changes.
  /// Returns the raw numeric string without formatting.
  final ValueChanged<String>? onChanged;

  /// Whether to auto-focus when the widget is built.
  final bool autofocus;

  const AmountInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.autofocus = true,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize with "0" and position cursor at end
    if (widget.controller.text.isEmpty) {
      widget.controller.text = '0';
      // Position cursor at end (after the 0)
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }

    // Auto-focus after build
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// Check if showing placeholder value (0)
  bool get _isZero {
    final text = widget.controller.text.replaceAll(',', '');
    return text.isEmpty || text == '0';
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive colors for dark mode
    final textColor = AppColors.getTextPrimary(context);
    final secondaryColor = AppColors.getTextSecondary(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Visible TextField styled as large number display
        // Uses IntrinsicWidth to size to content
        IntrinsicWidth(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            // Use number keyboard for iOS
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [
              _AmountInputFormatter(), // Custom formatter that handles 0 replacement
            ],
            onChanged: (value) {
              setState(() {}); // Rebuild to update color
              // Remove commas to get raw value for callback
              final rawValue = value.replaceAll(',', '');
              widget.onChanged?.call(rawValue);
            },
            textAlign: TextAlign.center,
            style: AppTypography.style(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              // Gray when 0, primary color otherwise (adaptive for dark mode)
              color: _isZero ? secondaryColor : textColor,
            ),
            // Adaptive cursor color for dark mode
            cursorColor: textColor,
            cursorWidth: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),

        // Spacing between number and currency (4px from Figma)
        const SizedBox(width: 4),

        // Currency symbol "đ" - always secondary color
        Text(
          'đ',
          style: AppTypography.style(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}

/// Custom TextInputFormatter for amount input.
///
/// Handles:
/// 1. Only digits allowed
/// 2. When text is "0" and user types a digit, replace 0 with that digit
/// 3. Thousand separator formatting (commas)
/// 4. Max 12 digits
/// 5. Never allows empty - minimum is "0"
class _AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get raw digits only from new value
    String rawNew = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String rawOld = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If user deleted everything, show "0"
    if (rawNew.isEmpty) {
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // If old value was "0" and user typed a digit, replace 0 with new digit
    if (rawOld == '0' && rawNew.length == 2 && rawNew.startsWith('0')) {
      rawNew = rawNew.substring(1); // Remove leading 0
    }

    // Remove leading zeros (except single 0)
    while (rawNew.length > 1 && rawNew.startsWith('0')) {
      rawNew = rawNew.substring(1);
    }

    // Limit to 12 digits
    if (rawNew.length > 12) {
      rawNew = rawNew.substring(0, 12);
    }

    // Parse as integer
    final number = int.tryParse(rawNew);
    if (number == null) {
      return oldValue;
    }

    // Format with thousand separators
    final formatted = _formatWithCommas(number);

    // Position cursor at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithCommas(int number) {
    if (number == 0) return '0';

    final str = number.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }
}
