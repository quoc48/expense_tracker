import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/supabase_expense_repository.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import 'grabber_bottom_sheet.dart';
import 'sheet_header.dart';
import 'amount_input_field.dart';
import 'form_input.dart';
import 'primary_button.dart';
import 'select_category_sheet.dart';

/// A full-screen bottom sheet for adding a new expense.
///
/// **Design Reference**: Figma node-id=55-1049
///
/// **Features**:
/// - Near full-screen modal (below status bar)
/// - Large centered amount input with auto-focus
/// - Form fields: Description, Category, Type, Date, Note
/// - Primary action button
/// - Loads categories and types from Supabase
/// - Offline fallback with cached data
/// - Tap outside form fields to dismiss keyboard
///
/// **Component Hierarchy**:
/// ```
/// GrabberBottomSheet (showGrabber: false, isFullScreen: true)
/// └── GestureDetector (dismiss keyboard on tap outside)
///     └── Column
///         ├── SheetHeader (title + close)
///         ├── AmountInputField (large "0 đ")
///         ├── Forms section (24px gap between fields)
///         │   ├── FormInput.text (Description)
///         │   ├── FormInput.select (Category)
///         │   ├── FormInput.select (Type)
///         │   ├── FormInput.date (Date)
///         │   └── FormInput.text (Note - optional)
///         └── PrimaryButton ("Add Expense")
/// ```
///
/// **Usage**:
/// ```dart
/// final expense = await showAddExpenseSheet(context: context);
/// if (expense != null) {
///   // Save expense
/// }
/// ```
class AddExpenseSheet extends StatefulWidget {
  /// Optional expense for edit mode (not yet implemented).
  final Expense? expense;

  const AddExpenseSheet({
    super.key,
    this.expense,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  // Controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();

  // Repository for fetching categories and types
  final ExpenseRepository _repository = SupabaseExpenseRepository();

  // Form field values
  String? _selectedCategoryVi;
  String? _selectedTypeVi;
  DateTime _selectedDate = DateTime.now();

  // Lists loaded from Supabase
  List<String> _categories = [];
  List<String> _expenseTypes = [];
  bool _isLoadingOptions = true;
  bool _isSaving = false;

  // Validation error messages for each field
  String? _amountError;
  String? _descriptionError;
  String? _categoryError;
  String? _typeError;

  // Fallback data for offline mode
  static const List<String> _fallbackCategories = [
    'Biểu gia đình',
    'Cà phê',
    'Du lịch',
    'Giáo dục',
    'Giải trí',
    'Hoá đơn',
    'Quà vật',
    'Sức khỏe',
    'TẾT',
    'Thời trang',
    'Thực phẩm',
    'Tiền nhà',
    'Tạp hoá',
    'Đi lại',
  ];

  static const List<String> _fallbackTypes = [
    'Phải chi',
    'Phát sinh',
    'Lãng phí',
  ];

  // Date formatter for display
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadOptionsAndInitialize();

    // Focus the amount field after the first frame renders.
    // Using WidgetsBinding ensures the widget tree is built before focusing.
    // This is preferred over autofocus: true because it only runs once,
    // preventing re-focus when returning from picker sheets.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.expense == null) {
        // Only auto-focus for new expenses, not when editing
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  /// Load options from Supabase and initialize form for edit mode
  Future<void> _loadOptionsAndInitialize() async {
    await _loadOptions();

    if (!mounted) return;

    // If editing, pre-populate the form
    if (widget.expense != null) {
      final expense = widget.expense!;
      _amountController.text = expense.amount.toInt().toString();
      _descriptionController.text = expense.description;
      _noteController.text = expense.note ?? '';
      _selectedDate = expense.date;
      _selectedCategoryVi = expense.categoryNameVi;
      _selectedTypeVi = expense.typeNameVi;

      if (mounted) setState(() {});
    }
  }

  /// Load categories and expense types from Supabase
  /// Categories are sorted by usage frequency in current month (highest first),
  /// with alphabetical order as tiebreaker.
  Future<void> _loadOptions() async {
    try {
      // Load categories, types, and current month expenses in parallel
      final categoriesFuture = _repository.getCategories()
          .timeout(const Duration(seconds: 5));
      final typesFuture = _repository.getExpenseTypes()
          .timeout(const Duration(seconds: 5));
      final expensesFuture = _getCurrentMonthExpenses();

      final results = await Future.wait([
        categoriesFuture,
        typesFuture,
        expensesFuture,
      ]);

      if (!mounted) return;

      final categories = (results[0] as List<String>).toSet().toList();
      final types = (results[1] as List<String>).toSet().toList();
      final currentMonthExpenses = results[2] as List<dynamic>;

      // Sort categories by usage frequency, then alphabetically
      final sortedCategories = _sortCategoriesByUsage(
        categories,
        currentMonthExpenses.cast(),
      );

      setState(() {
        _categories = sortedCategories;
        _expenseTypes = types;
        _isLoadingOptions = false;
      });
    } catch (e) {
      debugPrint('Error loading form options: $e');

      if (!mounted) return;

      // Use fallback data for offline mode (alphabetical order)
      setState(() {
        _categories = List.from(_fallbackCategories)..sort();
        _expenseTypes = List.from(_fallbackTypes);
        _isLoadingOptions = false;
      });
    }
  }

  /// Get expenses for the current month
  Future<List<Expense>> _getCurrentMonthExpenses() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return await _repository.getByDateRange(startOfMonth, endOfMonth)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error loading current month expenses: $e');
      return [];
    }
  }

  /// Sort categories by usage frequency in current month (descending),
  /// with alphabetical order as tiebreaker for same frequency.
  List<String> _sortCategoriesByUsage(
    List<String> categories,
    List<Expense> currentMonthExpenses,
  ) {
    // Count category usage in current month
    final usageCount = <String, int>{};
    for (final expense in currentMonthExpenses) {
      final category = expense.categoryNameVi;
      usageCount[category] = (usageCount[category] ?? 0) + 1;
    }

    // Sort: highest usage first, then alphabetically for ties
    categories.sort((a, b) {
      final countA = usageCount[a] ?? 0;
      final countB = usageCount[b] ?? 0;

      // Compare by count (descending)
      if (countA != countB) {
        return countB.compareTo(countA);
      }

      // Same count: sort alphabetically (ascending)
      return a.compareTo(b);
    });

    return categories;
  }

  /// Dismiss keyboard by unfocusing
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// Validate form and return true if valid
  /// Shows error on each invalid field
  bool _validateForm() {
    bool isValid = true;

    // Reset all errors first
    setState(() {
      _amountError = null;
      _descriptionError = null;
      _categoryError = null;
      _typeError = null;
    });

    // Validate amount
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _amountError = 'Please enter a valid amount';
      isValid = false;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      _descriptionError = 'Please enter a description';
      isValid = false;
    }

    // Validate category
    if (_selectedCategoryVi == null) {
      _categoryError = 'Please select a category';
      isValid = false;
    }

    // Validate type
    if (_selectedTypeVi == null) {
      _typeError = 'Please select an expense type';
      isValid = false;
    }

    // Update UI with errors
    if (!isValid) {
      setState(() {});
    }

    return isValid;
  }

  /// Clear specific field error when user interacts
  void _clearAmountError() {
    if (_amountError != null) {
      setState(() => _amountError = null);
    }
  }

  void _clearDescriptionError() {
    if (_descriptionError != null) {
      setState(() => _descriptionError = null);
    }
  }

  void _clearCategoryError() {
    if (_categoryError != null) {
      setState(() => _categoryError = null);
    }
  }

  void _clearTypeError() {
    if (_typeError != null) {
      setState(() => _typeError = null);
    }
  }

  void _saveExpense() {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    // Remove commas from amount before parsing
    final amountText = _amountController.text.replaceAll(',', '');

    // Create expense with Vietnamese strings directly
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(amountText),
      categoryNameVi: _selectedCategoryVi!,
      typeNameVi: _selectedTypeVi!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Return the expense object
    Navigator.pop(context, expense);
  }

  Future<void> _pickDate() async {
    _dismissKeyboard();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.textBlack,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    // Ensure keyboard stays dismissed after picker closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker() async {
    _dismissKeyboard();

    // Use the new SelectCategorySheet with proper design system styling
    final category = await showSelectCategorySheet(
      context: context,
      categories: _categories,
      selectedCategory: _selectedCategoryVi,
    );

    if (!mounted) return;

    // Ensure keyboard stays dismissed after sheet closes
    // Using postFrameCallback to run AFTER Flutter's internal focus restoration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    if (category != null) {
      setState(() => _selectedCategoryVi = category);
    }
  }

  void _showTypePicker() async {
    _dismissKeyboard();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildPickerSheet(
        title: 'Select Type',
        items: _expenseTypes,
        selectedItem: _selectedTypeVi,
        onSelect: (value) {
          setState(() => _selectedTypeVi = value);
          Navigator.pop(context);
        },
      ),
    );

    if (!mounted) return;

    // Ensure keyboard stays dismissed after sheet closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  /// Build a simple picker sheet for Type selection (no icons).
  /// Note: Category selection now uses SelectCategorySheet instead.
  Widget _buildPickerSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required ValueChanged<String> onSelect,
  }) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.grabber,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
          ),

          // Items
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;

                return ListTile(
                  title: Text(
                    item,
                    style: AppTypography.style(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textBlack,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.textBlack,
                          size: 20,
                        )
                      : null,
                  onTap: () => onSelect(item),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    // GestureDetector to dismiss keyboard when tapping outside form fields
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Header
          SheetHeader(
            title: isEditing ? 'Edit Expense' : 'Add Expense',
            onClose: () => Navigator.pop(context),
          ),

          // Content (scrollable)
          Expanded(
            child: _isLoadingOptions
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textBlack,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Gap: Header to Amount (32px from Figma)
                        const SizedBox(height: 32),

                        // Amount Input (large centered)
                        // Note: autofocus removed to prevent re-focusing when returning
                        // from picker sheets. Initial focus is handled in initState.
                        Column(
                          children: [
                            AmountInputField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              autofocus: false,
                              onChanged: (_) => _clearAmountError(),
                            ),
                            // Amount error message
                            if (_amountError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _amountError!,
                                style: AppTypography.style(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Gap: Amount to Forms (32px from Figma)
                        const SizedBox(height: 32),

                        // Form Fields using unified FormInput component

                        // Description
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Description',
                          placeholder: 'e.g. Đi chợ',
                          controller: _descriptionController,
                          errorText: _descriptionError,
                          onChanged: (_) => _clearDescriptionError(),
                        ),

                        // Gap between form fields (24px from Figma)
                        const SizedBox(height: 24),

                        // Category
                        FormInput(
                          variant: FormInputVariant.select,
                          label: 'Category',
                          placeholder: 'Select category',
                          value: _selectedCategoryVi,
                          onTap: () {
                            _clearCategoryError();
                            _showCategoryPicker();
                          },
                          errorText: _categoryError,
                        ),

                        const SizedBox(height: 24),

                        // Type
                        FormInput(
                          variant: FormInputVariant.select,
                          label: 'Type',
                          placeholder: 'Select type',
                          value: _selectedTypeVi,
                          onTap: () {
                            _clearTypeError();
                            _showTypePicker();
                          },
                          errorText: _typeError,
                        ),

                        const SizedBox(height: 24),

                        // Date
                        FormInput(
                          variant: FormInputVariant.date,
                          label: 'Date',
                          placeholder: 'Select date',
                          value: _dateFormat.format(_selectedDate),
                          onTap: _pickDate,
                        ),

                        const SizedBox(height: 24),

                        // Note (optional)
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Note (Optional)',
                          placeholder: 'e.g. Với công ty',
                          controller: _noteController,
                          maxLines: 3,
                        ),

                        // Gap: Forms to Button (32px from Figma)
                        const SizedBox(height: 32),

                        // Save Button
                        PrimaryButton(
                          label: isEditing ? 'Update Expense' : 'Add Expense',
                          isLoading: _isSaving,
                          onPressed: _saveExpense,
                        ),

                        // Bottom padding for safe area
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shows the Add Expense sheet and returns the created expense.
///
/// Returns null if the user cancels or closes the sheet.
///
/// **Usage**:
/// ```dart
/// final expense = await showAddExpenseSheet(context: context);
/// if (expense != null) {
///   await repository.addExpense(expense);
/// }
/// ```
Future<Expense?> showAddExpenseSheet({
  required BuildContext context,
  Expense? expense,
}) {
  return showGrabberBottomSheet<Expense>(
    context: context,
    showGrabber: false,
    isFullScreen: true,
    isDismissible: true,   // Allow tap outside to close
    enableDrag: true,      // Allow drag to dismiss
    // Custom padding for full-screen sheet (16px bottom instead of default 40px)
    contentPadding: const EdgeInsets.only(
      left: 16,
      right: 16,
      top: 0,
      bottom: 16,
    ),
    child: AddExpenseSheet(expense: expense),
  );
}
