import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../widgets/common/primary_button.dart';

/// Bottom sheet for editing monthly budget with Figma-accurate design
///
/// **Design Reference**: Figma node-id=63-1546
///
/// **Layout**:
/// - White background with 24px top rounded corners
/// - Header: "Monthly Budget" (gray) + X close button
/// - Large centered amount display (40px bold)
/// - "Set Budget" button (black, full width)
/// - Numeric keyboard auto-popup
///
/// **Amount Display**: "34,000 đ"
/// - Numbers: Black, 40px Bold
/// - Currency symbol (đ): Gray, 40px Bold
/// - Uses comma as thousand separator
class BudgetEditSheet extends StatefulWidget {
  final double initialBudget;

  const BudgetEditSheet({
    super.key,
    required this.initialBudget,
  });

  @override
  State<BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends State<BudgetEditSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  // Validation constants
  static const double _minBudget = 0;
  static const double _maxBudget = 1000000000; // 1 billion VND

  @override
  void initState() {
    super.initState();
    // Initialize with current budget value (raw number, no formatting)
    final initialValue = widget.initialBudget.toInt().toString();
    _controller = TextEditingController(text: initialValue);
    _focusNode = FocusNode();

    // Auto-focus after build to show numeric keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Format number with comma separators: "20000000" -> "20,000,000"
  String _formatWithCommas(String value) {
    if (value.isEmpty) return '0';

    // Remove any existing non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '0';

    final buffer = StringBuffer();
    final length = digitsOnly.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digitsOnly[i]);
    }

    return buffer.toString();
  }

  /// Handle save button press
  void _handleSave() {
    final text = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) {
      Navigator.pop(context, 0.0);
      return;
    }

    final budget = double.tryParse(text) ?? 0.0;

    // Validate bounds
    if (budget < _minBudget) {
      Navigator.pop(context, _minBudget);
      return;
    }
    if (budget > _maxBudget) {
      Navigator.pop(context, _maxBudget);
      return;
    }

    Navigator.pop(context, budget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: "Monthly Budget" + X close button
              _buildHeader(context),

              const SizedBox(height: 32),

              // Amount display (large centered)
              _buildAmountDisplay(),

              const SizedBox(height: 32),

              // "Set Budget" button
              PrimaryButton(
                label: 'Set Budget',
                onPressed: _handleSave,
              ),

              // Hidden text field for keyboard input
              _buildHiddenTextField(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title and close button
  ///
  /// **Design Reference**: Figma node-id=63-1613
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title - gray, medium weight
        Text(
          'Monthly Budget',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),

        // Close button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            PhosphorIconsRegular.x,
            size: 24,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  /// Build large centered amount display
  ///
  /// **Design Reference**: Figma node-id=63-1631
  ///
  /// Display format: "34,000 đ"
  /// - Number part: Black, 40px Bold
  /// - Currency part: Gray, 40px Bold
  Widget _buildAmountDisplay() {
    final formattedValue = _formatWithCommas(_controller.text);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Number part (black)
        Text(
          formattedValue,
          style: AppTypography.style(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),

        // Space + Currency symbol (gray)
        Text(
          ' đ',
          style: AppTypography.style(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }

  /// Hidden text field that captures keyboard input
  ///
  /// This invisible field handles the numeric keyboard input
  /// while the visible amount display shows formatted output.
  Widget _buildHiddenTextField() {
    return SizedBox(
      height: 0,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12), // Max 999,999,999,999
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          color: Colors.transparent,
          height: 0,
        ),
        cursorColor: Colors.transparent,
        showCursor: false,
        onChanged: (value) {
          // Trigger rebuild to update displayed amount
          setState(() {});
        },
        onSubmitted: (_) => _handleSave(),
      ),
    );
  }
}
