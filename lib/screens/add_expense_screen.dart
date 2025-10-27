import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_form_result.dart';
import '../repositories/expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';

// AddExpenseScreen: Form for creating new expenses OR editing existing ones
// StatefulWidget because we need to manage form state and user input
class AddExpenseScreen extends StatefulWidget {
  // Optional expense parameter - if provided, we're in edit mode
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // GlobalKey for form validation
  // This key gives us access to FormState methods like validate() and save()
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  // TextEditingController: Manages text input and allows us to read/modify the value
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Repository for fetching categories and types
  final ExpenseRepository _repository = SupabaseExpenseRepository();

  // Form field values (for dropdown and radio buttons)
  // Now using Vietnamese names (String) instead of enums
  String? _selectedCategory;
  String? _selectedType;
  DateTime _selectedDate = DateTime.now();

  // Lists loaded from Supabase
  List<String> _categories = [];
  List<String> _expenseTypes = [];
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();

    // Load categories and types from Supabase, then pre-populate form if editing
    _loadOptionsAndInitialize();
  }

  /// Load options from Supabase and initialize form for edit mode
  Future<void> _loadOptionsAndInitialize() async {
    // First load the options
    await _loadOptions();

    // If we're editing an existing expense, pre-populate the form
    if (widget.expense != null && mounted) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toString();
      _noteController.text = expense.note ?? '';
      _selectedDate = expense.date;

      // Find matching Supabase category and type
      // Note: The enum displayName might not match Supabase categories exactly
      // So we need to find a Supabase category that maps to the same enum
      _selectedCategory = _findMatchingSupabaseCategory(expense.category);
      _selectedType = _findMatchingSupabaseType(expense.type);

      debugPrint('Edit mode: Selected category = $_selectedCategory, type = $_selectedType');

      setState(() {}); // Update UI with pre-populated values
    }
  }

  /// Find a Supabase category name that maps to the given enum
  String? _findMatchingSupabaseCategory(Category category) {
    // Try to find a category in _categories that maps to this enum
    for (final categoryName in _categories) {
      if (_vietnameseToCategory(categoryName) == category) {
        return categoryName;
      }
    }
    // Fallback: return the first category if no match found
    return _categories.isNotEmpty ? _categories.first : null;
  }

  /// Find a Supabase expense type name that maps to the given enum
  String? _findMatchingSupabaseType(ExpenseType type) {
    // Try to find a type in _expenseTypes that maps to this enum
    for (final typeName in _expenseTypes) {
      if (_vietnameseToType(typeName) == type) {
        return typeName;
      }
    }
    // Fallback: return the first type if no match found
    return _expenseTypes.isNotEmpty ? _expenseTypes.first : null;
  }

  /// Load categories and expense types from Supabase
  Future<void> _loadOptions() async {
    try {
      final categories = await _repository.getCategories();
      final types = await _repository.getExpenseTypes();

      debugPrint('Loaded categories from Supabase: $categories');
      debugPrint('Loaded types from Supabase: $types');

      setState(() {
        // Ensure uniqueness (in case Supabase returns duplicates)
        _categories = categories.toSet().toList()..sort();
        _expenseTypes = types.toSet().toList();
        _isLoadingOptions = false;
      });
    } catch (e) {
      debugPrint('Error loading form options: $e');
      setState(() {
        _isLoadingOptions = false;
      });
    }
  }

  /// Helper: Convert Vietnamese name to Category enum
  /// Uses the repository's mapping to ensure consistency
  Category _vietnameseToCategory(String vietnameseName) {
    return SupabaseExpenseRepository.categoryMapping[vietnameseName] ??
           Category.other;
  }

  /// Helper: Convert Vietnamese name to ExpenseType enum
  /// Uses the repository's mapping to ensure consistency
  ExpenseType _vietnameseToType(String vietnameseName) {
    return SupabaseExpenseRepository.typeMapping[vietnameseName] ??
           ExpenseType.niceToHave;
  }

  @override
  void dispose() {
    // IMPORTANT: Dispose controllers to prevent memory leaks
    // Controllers keep listeners that need to be cleaned up
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in edit mode
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Form(
              // Form widget: Wraps form fields and provides validation
              key: _formKey,
              child: SingleChildScrollView(
                // SingleChildScrollView: Makes content scrollable (important for keyboards)
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
                  prefixIcon: Icon(Icons.description),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  // Validator: Returns error message if invalid, null if valid
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                // inputFormatters: Restrict input to valid decimal numbers
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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

              // Category Dropdown - Now loading from Supabase
              DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  // value: The currently selected category (Vietnamese name)
                  // Note: Using 'value' (not initialValue) because we manage state with setState
                  value: _selectedCategory,
                  items: _categories.map((categoryName) {
                    // Get icon from the mapped enum
                    final category = SupabaseExpenseRepository.categoryMapping[categoryName] ??
                                    Category.other;
                    final icon = category.icon;

                    return DropdownMenuItem(
                      value: categoryName,
                      child: Row(
                        children: [
                          Icon(icon, size: 20),
                          const SizedBox(width: 8),
                          Text(categoryName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
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

              // Expense Type (Must Have / Nice to Have / Wasted)
              const Text(
                'Expense Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // SegmentedButton: Material Design 3 component for mutually exclusive choices
              SegmentedButton<String>(
                  segments: _expenseTypes.map((typeName) {
                    // Get color from the mapped enum
                    final expenseType = SupabaseExpenseRepository.typeMapping[typeName] ??
                                       ExpenseType.niceToHave;
                    final color = expenseType.color;

                    return ButtonSegment(
                      value: typeName,
                      label: Text(typeName),
                      icon: Icon(
                        Icons.circle,
                        color: color,
                        size: 12,
                      ),
                    );
                  }).toList(),
                  selected: _selectedType != null ? {_selectedType!} : {},
                  // Allow empty selection (user hasn't selected yet)
                  emptySelectionAllowed: true,
                  onSelectionChanged: (Set<String> selected) {
                    setState(() {
                      // Handle empty selection (when user deselects)
                      _selectedType = selected.isNotEmpty ? selected.first : null;
                    });
                  },
                ),
              if (_selectedType == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select an expense type',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                // InkWell: Makes any widget tappable with Material ripple effect
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note Field (Optional)
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add additional details...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Save Button
              FilledButton(
                // FilledButton: Material Design 3's primary button
                onPressed: _saveExpense,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isEditing ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Earliest selectable date
      lastDate: DateTime.now(), // Latest selectable date (today)
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to save the expense (create new or update existing)
  void _saveExpense() {
    // Validate all form fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // Check if expense type is selected (not part of form validation)
    if (_selectedType == null) {
      setState(() {}); // Trigger rebuild to show error message
      return;
    }

    // Create or update expense object
    // Convert Vietnamese names back to enums
    final expense = Expense(
      // If editing, keep the original ID; otherwise generate a new UUID
      // UUID format: "550e8400-e29b-41d4-a716-446655440000" (required by Supabase)
      id: widget.expense?.id ?? const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _vietnameseToCategory(_selectedCategory!),
      type: _vietnameseToType(_selectedType!),
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Return both the expense and the original Vietnamese names
    // This preserves the exact category/type selected by the user
    final result = ExpenseFormResult(
      expense: expense,
      categoryNameVi: _selectedCategory!,
      typeNameVi: _selectedType!,
    );

    Navigator.pop(context, result);
  }
}
