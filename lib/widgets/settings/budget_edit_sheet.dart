import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/currency_formatter.dart';

/// Bottom sheet for editing monthly budget with validation
///
/// Validation rules:
/// - Minimum: 0 VND (can't be negative)
/// - Maximum: 1,000,000,000 VND (1 billion - reasonable upper limit)
/// - Required: Can't save empty value
///
/// Learning: Bottom sheets are more mobile-friendly than dialogs for forms.
/// They slide up from the bottom and provide a natural entry/exit animation.
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
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    PhosphorIconsLight.wallet,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Monthly Budget',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Helpful hint text
              Text(
                'Set your monthly spending limit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Return null (cancelled)
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),

                  // Save button
                  FilledButton(
                    onPressed: _handleSave,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
