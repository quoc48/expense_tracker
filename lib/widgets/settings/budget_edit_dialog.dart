import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/currency_formatter.dart';
import '../../theme/minimalist/minimalist_colors.dart';

/// Dialog for editing monthly budget with validation
///
/// Validation rules:
/// - Minimum: 0 VND (can't be negative)
/// - Maximum: 1,000,000,000 VND (1 billion - reasonable upper limit)
/// - Required: Can't save empty value
///
/// Learning: Input validation should be both immediate (as user types)
/// and at submit (when saving). This provides the best UX:
/// - Immediate feedback prevents invalid input
/// - Submit validation catches edge cases and ensures data integrity
class BudgetEditDialog extends StatefulWidget {
  final double initialBudget;

  const BudgetEditDialog({
    super.key,
    required this.initialBudget,
  });

  @override
  State<BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<BudgetEditDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  // Validation constants
  static const double _minBudget = 0;
  static const double _maxBudget = 1000000000; // 1 billion VND

  @override
  void initState() {
    super.initState();
    // Initialize with current budget (formatted without currency symbol)
    _controller = TextEditingController(
      text: widget.initialBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Monthly Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Helpful hint text
            Text(
              'Set your monthly spending limit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MinimalistColors.gray600,  // Labels - subtle hint
                  ),
            ),
            const SizedBox(height: 16),
            
            // Budget input field
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                hintText: '20000000',
                suffixText: 'đ',
                prefixIcon: Icon(PhosphorIconsLight.wallet, color: MinimalistColors.gray700),  // Body text
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                // Only allow digits (no decimals or negative signs)
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: _validateBudget,
              autofocus: true,
              // Clear error when user starts typing
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            
            // Budget range hint
            Text(
              'Range: ${CurrencyFormatter.format(_minBudget, context: CurrencyContext.compact)} - ${CurrencyFormatter.format(_maxBudget, context: CurrencyContext.compact)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MinimalistColors.gray600,  // Labels - subtle hint
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Return null (cancelled)
          },
          style: TextButton.styleFrom(
            foregroundColor: MinimalistColors.gray600,  // Labels - subtle
          ),
          child: const Text('Cancel'),
        ),

        // Save button
        FilledButton(
          onPressed: _handleSave,
          style: FilledButton.styleFrom(
            backgroundColor: MinimalistColors.gray900,  // Primary text - strong
            foregroundColor: MinimalistColors.gray50,  // Main background - white text
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// Validate budget input
  ///
  /// Returns error message if invalid, null if valid.
  String? _validateBudget(String? value) {
    // Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a budget amount';
    }

    // Try to parse as number
    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Please enter a valid number';
    }

    // Check minimum
    if (budget < _minBudget) {
      return 'Budget cannot be negative';
    }

    // Check maximum
    if (budget > _maxBudget) {
      return 'Budget cannot exceed ${CurrencyFormatter.format(_maxBudget, context: CurrencyContext.compact)}';
    }

    return null; // Valid!
  }

  /// Handle save button press with validation
  void _handleSave() {
    // Clear any existing errors
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      // Parse the validated value
      final newBudget = double.parse(_controller.text);
      
      // Return the new budget value
      Navigator.pop(context, newBudget);
    }
  }
}
