import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/colors/app_colors.dart';

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
/// - On open: auto-focus, show placeholder "0", keyboard appears
/// - On typing: updates value, formats with thousand separators
/// - Cursor appears between number and "đ"
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
  bool _hasFocus = false;

  // Formatter for thousand separators (using comma)
  final _numberFormat = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

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
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  /// Format number with comma thousand separators
  /// e.g., 1000000 → "1,000,000"
  String _formatWithCommas(String rawNumber) {
    if (rawNumber.isEmpty) return '0';
    final number = int.tryParse(rawNumber);
    if (number == null || number == 0) return '0';
    return _numberFormat.format(number);
  }

  /// Get display text with thousand separators
  String get _displayText {
    return _formatWithCommas(widget.controller.text);
  }

  /// Check if showing placeholder (empty or 0)
  bool get _isPlaceholder {
    final text = widget.controller.text;
    return text.isEmpty || text == '0';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Number display with thousand separators
              Text(
                _displayText,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: _isPlaceholder ? AppColors.gray : AppColors.textBlack,
                ),
              ),

              // Cursor (only visible when focused)
              if (_hasFocus)
                Container(
                  width: 1,
                  height: 54,
                  color: AppColors.textBlack,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                ),

              // Spacing between number and currency (4px from Figma)
              const SizedBox(width: 4),

              // Currency symbol "đ"
              const Text(
                'đ',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),

          // Hidden TextField to capture keyboard input
          SizedBox(
            height: 0,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                // Use number keyboard for iOS
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12), // Max 12 digits (999,999,999,999)
                ],
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to update display
                  widget.onChanged?.call(value);
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
