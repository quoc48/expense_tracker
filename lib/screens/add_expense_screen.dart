import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';
import '../utils/currency_formatter.dart';
import '../theme/typography/app_typography.dart';
import '../theme/minimalist/minimalist_icons.dart';
import '../theme/minimalist/minimalist_colors.dart';

/// AddExpenseScreen: Form for creating new expenses OR editing existing ones (SIMPLIFIED - Phase 5.5.1)
///
/// Architecture Change:
/// - BEFORE: Selected Vietnamese → converted to enums → passed alongside in ExpenseFormResult
/// - AFTER: Selected Vietnamese → directly stored in Expense object → returned as-is
///
/// Benefits:
/// - No ExpenseFormResult DTO needed
/// - No enum conversion
/// - Simpler data flow
///
/// Field Hiding:
/// - Use `hiddenFields` to hide specific fields (e.g., {'date'} for scan results)
/// - Hidden fields still use their default/existing values
class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final Set<String>? hiddenFields;

  const AddExpenseScreen({
    super.key,
    this.expense,
    this.hiddenFields,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Repository for fetching categories and types
  final ExpenseRepository _repository = SupabaseExpenseRepository();

  // Form field values (Vietnamese strings directly!)
  String? _selectedCategoryVi;
  String? _selectedTypeVi;
  DateTime _selectedDate = DateTime.now();

  // Lists loaded from Supabase
  List<String> _categories = [];
  List<String> _expenseTypes = [];
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    _loadOptionsAndInitialize();
  }

  /// Load options from Supabase and initialize form for edit mode
  Future<void> _loadOptionsAndInitialize() async {
    await _loadOptions();

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    // If editing, pre-populate the form
    if (widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = CurrencyFormatter.formatForInput(expense.amount);
      _noteController.text = expense.note ?? '';
      _selectedDate = expense.date;

      // NEW: Direct assignment, no mapping needed!
      _selectedCategoryVi = expense.categoryNameVi;
      _selectedTypeVi = expense.typeNameVi;

      debugPrint('Edit mode: Category = $_selectedCategoryVi, Type = $_selectedTypeVi');

      if (!mounted) return;
      setState(() {});
    }
  }

  /// Load categories and expense types from Supabase
  Future<void> _loadOptions() async {
    try {
      final categories = await _repository.getCategories();
      final types = await _repository.getExpenseTypes();

      debugPrint('Loaded categories from Supabase: $categories');
      debugPrint('Loaded types from Supabase: $types');

      if (!mounted) return;

      setState(() {
        _categories = categories.toSet().toList()..sort();
        _expenseTypes = types.toSet().toList();
        _isLoadingOptions = false;
      });
    } catch (e) {
      debugPrint('Error loading form options: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingOptions = false;
      });
    }
  }

  /// Get icon for a category (helper method for dropdown)
  IconData _getIconForCategory(String categoryNameVi) {
    // Use centralized Phosphor icon mapping
    return MinimalistIcons.getCategoryIcon(categoryNameVi);
  }

  /// Get color for expense type (helper method for segmented button)
  /// Updated for minimalist design: uses centralized grayscale colors
  Color _getColorForType(String typeNameVi) {
    switch (typeNameVi) {
      case 'Phải chi':  // Must have - darkest
        return MinimalistColors.gray850;  // Strong emphasis
      case 'Phát sinh': // Nice to have - medium
        return MinimalistColors.gray600;  // Labels
      case 'Lãng phí':  // Wasted - lightest
        return MinimalistColors.gray500;  // Secondary
      default:
        return MinimalistColors.gray400;  // Disabled
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g., Grocery shopping',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(PhosphorIconsLight.textT),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount Field (Vietnamese đồng - integer only, no decimals)
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount (${CurrencyFormatter.currencySymbol})',
                        hintText: '50000',  // Vietnamese đồng example
                        helperText: 'Enter amount in Vietnamese đồng',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(PhosphorIconsLight.currencyDollar),  // Currency icon
                      ),
                      keyboardType: TextInputType.number,  // Integer only, no decimals
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*')),  // Only digits
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(PhosphorIconsLight.tag),
                      ),
                      value: _selectedCategoryVi,
                      items: _categories.map((categoryName) {
                        return DropdownMenuItem(
                          value: categoryName,
                          child: Row(
                            children: [
                              Icon(_getIconForCategory(categoryName), size: 20),
                              const SizedBox(width: 8),
                              Text(categoryName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryVi = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Expense Type
                    Text(
                      'Expense Type',
                      style: ComponentTextStyles.fieldLabel(Theme.of(context).textTheme),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: _expenseTypes.map((typeName) {
                        return ButtonSegment(
                          value: typeName,
                          label: Text(typeName),
                          icon: Icon(
                            Icons.circle,
                            color: _getColorForType(typeName),
                            size: 12,
                          ),
                        );
                      }).toList(),
                      selected: _selectedTypeVi != null ? {_selectedTypeVi!} : {},
                      emptySelectionAllowed: true,
                      onSelectionChanged: (Set<String> selected) {
                        setState(() {
                          _selectedTypeVi = selected.isNotEmpty ? selected.first : null;
                        });
                      },
                    ),
                    if (_selectedTypeVi == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Please select an expense type',
                          style: ComponentTextStyles.fieldError(Theme.of(context).textTheme).copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    // Date Picker (conditional - hidden for scan results)
                    if (widget.hiddenFields?.contains('date') != true) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(PhosphorIconsLight.calendarBlank),
                          ),
                          child: Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate),
                            style: ComponentTextStyles.fieldInput(Theme.of(context).textTheme),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Note Field (Optional)
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText: 'Add additional details...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(PhosphorIconsLight.note),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    FilledButton(
                      onPressed: _saveExpense,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          isEditing ? 'Update Expense' : 'Save Expense',
                          // No explicit style - let FilledButton theme control colors for proper contrast
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTypeVi == null) {
      setState(() {});
      return;
    }

    // Create expense with Vietnamese strings directly
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryNameVi: _selectedCategoryVi!,
      typeNameVi: _selectedTypeVi!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Return the expense object directly
    Navigator.pop(context, expense);
  }
}
