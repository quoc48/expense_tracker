import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/supabase_expense_repository.dart';

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
class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

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
      _amountController.text = expense.amount.toString();
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
    // Reuse the same logic as Expense.categoryIcon
    switch (categoryNameVi) {
      case 'Thực phẩm':
      case 'Cà phê':
        return Icons.restaurant;
      case 'Đi lại':
        return Icons.directions_car;
      case 'Hoá đơn':
      case 'Tiền nhà':
        return Icons.lightbulb;
      case 'Giải trí':
      case 'Du lịch':
        return Icons.movie;
      case 'Tạp hoá':
      case 'Thời trang':
        return Icons.shopping_bag;
      case 'Sức khỏe':
        return Icons.medical_services;
      case 'Giáo dục':
        return Icons.school;
      case 'Quà vật':
      case 'TẾT':
      case 'Biểu gia đình':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }

  /// Get color for expense type (helper method for segmented button)
  Color _getColorForType(String typeNameVi) {
    switch (typeNameVi) {
      case 'Phải chi':
        return Colors.green;
      case 'Phát sinh':
        return Colors.orange;
      case 'Lãng phí':
        return Colors.red;
      default:
        return Colors.grey;
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
                        prefixIcon: Icon(Icons.description),
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

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
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
                    const Text(
                      'Expense Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

    // NEW: Create expense with Vietnamese strings directly!
    // No enum conversion, no ExpenseFormResult DTO
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryNameVi: _selectedCategoryVi!,  // Direct assignment!
      typeNameVi: _selectedTypeVi!,          // Direct assignment!
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Return the expense object directly (no wrapper needed)
    Navigator.pop(context, expense);
  }
}
