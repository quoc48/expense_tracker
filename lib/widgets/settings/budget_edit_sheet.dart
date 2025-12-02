import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/amount_input_field.dart';

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
    // Initialize with current budget value (formatted with commas)
    // AmountInputField handles the formatting internally
    final initialValue = _formatInitialValue(widget.initialBudget.toInt());
    _controller = TextEditingController(text: initialValue);
    _focusNode = FocusNode();

    // Auto-focus after build to show numeric keyboard
    // This matches the behavior in AddExpenseSheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Format initial value with comma separators
  String _formatInitialValue(int value) {
    if (value == 0) return '0';

    final str = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle save button press
  void _handleSave() {
    // Remove commas to get raw value (same pattern as AddExpenseSheet)
    final text = _controller.text.replaceAll(',', '');
    if (text.isEmpty || text == '0') {
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
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Wrap in Material to prevent visual artifacts
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            // 32px spacing between button and keyboard per Figma
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: "Monthly Budget" + X close button
              _buildHeader(context),

              const SizedBox(height: 32),

              // Amount input - reusing the same component as AddExpenseSheet
              // This ensures consistent behavior: cursor, formatting, keyboard
              AmountInputField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false, // We handle focus manually in initState
              ),

              const SizedBox(height: 32),

              // "Set Budget" button
              PrimaryButton(
                label: 'Set Budget',
                onPressed: _handleSave,
              ),
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
    // Adaptive icon color for dark mode
    final iconColor = AppColors.getTextPrimary(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title - gray, medium weight (always gray for secondary label)
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
          child: Icon(
            PhosphorIconsRegular.x,
            size: 24,
            color: iconColor, // Adaptive for dark mode
          ),
        ),
      ],
    );
  }
}
