import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

// AddExpenseScreen: Form for creating new expenses
// StatefulWidget because we need to manage form state and user input
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

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

  // Form field values (for dropdown and radio buttons)
  Category? _selectedCategory;
  ExpenseType? _selectedType;
  DateTime _selectedDate = DateTime.now();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Form(
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

              // Category Dropdown
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(category.displayName),
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
                  if (value == null) {
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
              SegmentedButton<ExpenseType>(
                segments: ExpenseType.values.map((type) {
                  return ButtonSegment(
                    value: type,
                    label: Text(type.displayName),
                    icon: Icon(
                      Icons.circle,
                      color: type.color,
                      size: 12,
                    ),
                  );
                }).toList(),
                selected: _selectedType != null ? {_selectedType!} : {},
                onSelectionChanged: (Set<ExpenseType> selected) {
                  setState(() {
                    _selectedType = selected.first;
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Save Expense',
                    style: TextStyle(fontSize: 16),
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

  // Method to save the expense
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

    // Create new expense object
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory!,
      type: _selectedType!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Return the expense to the previous screen
    // Navigator.pop with result sends data back
    Navigator.pop(context, expense);
  }
}
