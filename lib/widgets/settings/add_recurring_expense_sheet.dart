import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/recurring_expense.dart';
import '../../repositories/recurring_expense_repository.dart';
import '../../repositories/supabase_recurring_expense_repository.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../theme/typography/app_typography.dart';
import '../common/grabber_bottom_sheet.dart';
import '../common/sheet_header.dart';
import '../common/amount_input_field.dart';
import '../common/form_input.dart';
import '../common/primary_button.dart';
import '../common/select_category_sheet.dart';
import '../common/select_type_sheet.dart';

/// Bottom sheet for adding/editing a recurring expense template
///
/// **Design Reference**: Figma node-id=78-3914
///
/// **Key Differences from AddExpenseSheet:**
/// - No Date field (recurring expenses create on 1st of each month)
/// - Frequency field is READ-ONLY showing "Monthly (1st)"
/// - Returns RecurringExpense instead of Expense
///
/// **Form Fields:**
/// 1. Amount (large input, auto-focused)
/// 2. Description (text input)
/// 3. Category (select picker)
/// 4. Type (select picker)
/// 5. Frequency (read-only, always "Monthly (1st)")
/// 6. Note (optional text input)
///
/// **Usage:**
/// ```dart
/// final recurring = await showAddRecurringExpenseSheet(context: context);
/// if (recurring != null) {
///   await provider.createRecurringExpense(recurring);
/// }
/// ```
class AddRecurringExpenseSheet extends StatefulWidget {
  /// Optional existing expense for edit mode
  final RecurringExpense? existingExpense;

  const AddRecurringExpenseSheet({
    super.key,
    this.existingExpense,
  });

  @override
  State<AddRecurringExpenseSheet> createState() =>
      _AddRecurringExpenseSheetState();
}

class _AddRecurringExpenseSheetState extends State<AddRecurringExpenseSheet> {
  // Controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();

  // Repository for fetching categories and types
  final RecurringExpenseRepository _repository =
      SupabaseRecurringExpenseRepository();

  // Form field values
  String? _selectedCategoryVi;
  String? _selectedTypeVi;

  // Lists loaded from repository
  List<String> _categories = [];
  List<String> _expenseTypes = [];
  bool _isLoadingOptions = true;
  bool _isSaving = false;

  // Validation error messages
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

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    _loadOptionsAndInitialize();

    // Auto-focus amount field for new expenses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isEditing) {
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

  /// Load dropdown options and pre-populate for edit mode
  Future<void> _loadOptionsAndInitialize() async {
    await _loadOptions();

    if (!mounted) return;

    // Pre-populate form for edit mode
    if (_isEditing) {
      final expense = widget.existingExpense!;
      _amountController.text = _formatAmountWithCommas(expense.amount.toInt());
      _descriptionController.text = expense.description;
      _noteController.text = expense.note ?? '';
      _selectedCategoryVi = expense.categoryNameVi;
      _selectedTypeVi = expense.typeNameVi;

      if (mounted) setState(() {});
    }
  }

  /// Format integer amount with comma thousand separators
  String _formatAmountWithCommas(int amount) {
    if (amount == 0) return '0';

    final str = amount.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Load categories and expense types from repository
  Future<void> _loadOptions() async {
    try {
      final categoriesFuture =
          _repository.getCategories().timeout(const Duration(seconds: 5));
      final typesFuture =
          _repository.getExpenseTypes().timeout(const Duration(seconds: 5));

      final results = await Future.wait([categoriesFuture, typesFuture]);

      if (!mounted) return;

      setState(() {
        _categories = results[0].toSet().toList()..sort();
        _expenseTypes = _sortTypesInDisplayOrder(results[1]);
        _isLoadingOptions = false;
      });
    } catch (e) {
      debugPrint('Error loading form options: $e');

      if (!mounted) return;

      // Use fallback data for offline mode
      setState(() {
        _categories = List.from(_fallbackCategories)..sort();
        _expenseTypes = List.from(_fallbackTypes);
        _isLoadingOptions = false;
      });
    }
  }

  /// Sort expense types in fixed display order
  List<String> _sortTypesInDisplayOrder(List<String> types) {
    final displayOrder = ['Phải chi', 'Phát sinh', 'Lãng phí'];
    final result = <String>[];

    for (final type in displayOrder) {
      if (types.contains(type)) {
        result.add(type);
      }
    }

    // Add any remaining types
    for (final type in types) {
      if (!result.contains(type)) {
        result.add(type);
      }
    }

    return result;
  }

  /// Dismiss keyboard by unfocusing
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// Validate form and return true if valid
  bool _validateForm() {
    bool isValid = true;

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

  /// Save recurring expense with loading feedback
  Future<void> _saveRecurringExpense() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    final amountText = _amountController.text.replaceAll(',', '');

    final recurring = RecurringExpense(
      id: widget.existingExpense?.id ?? const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(amountText),
      categoryNameVi: _selectedCategoryVi!,
      typeNameVi: _selectedTypeVi!,
      startDate: widget.existingExpense?.startDate ?? DateTime.now(),
      lastCreatedDate: widget.existingExpense?.lastCreatedDate,
      isActive: widget.existingExpense?.isActive ?? true,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Brief loading state before closing (prevents double-tap, shows feedback)
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    Navigator.pop(context, recurring);
  }

  /// Show category picker sheet
  Future<void> _showCategoryPicker() async {
    _dismissKeyboard();

    final category = await showSelectCategorySheet(
      context: context,
      categories: _categories,
      selectedCategory: _selectedCategoryVi,
    );

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    if (category != null) {
      setState(() => _selectedCategoryVi = category);
    }
  }

  /// Show type picker sheet
  Future<void> _showTypePicker() async {
    _dismissKeyboard();

    final type = await showSelectTypeSheet(
      context: context,
      types: _expenseTypes,
      selectedType: _selectedTypeVi,
    );

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    if (type != null) {
      setState(() => _selectedTypeVi = type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Header
          SheetHeader(
            title: _isEditing ? 'Edit Recurring Expense' : 'Add Recurring Expense',
            onClose: () => Navigator.pop(context),
          ),

          // Content
          Expanded(
            child: _isLoadingOptions
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getTextPrimary(context),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        // Amount Input
                        Column(
                          children: [
                            AmountInputField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              autofocus: false,
                              onChanged: (_) => _clearAmountError(),
                            ),
                            if (_amountError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _amountError!,
                                style: AppTypography.style(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Description
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Description',
                          placeholder: 'e.g. Netflix, Rent, Insurance',
                          controller: _descriptionController,
                          errorText: _descriptionError,
                          onChanged: (_) => _clearDescriptionError(),
                        ),

                        const SizedBox(height: 24),

                        // Category
                        FormInput(
                          variant: FormInputVariant.select,
                          label: 'Category',
                          placeholder: 'Select category',
                          value: _selectedCategoryVi,
                          leadingWidget: _selectedCategoryVi != null
                              ? Icon(
                                  MinimalistIcons.categoryIconsFill[
                                          _selectedCategoryVi] ??
                                      MinimalistIcons
                                          .categoryIconsFill.values.first,
                                  size: 20,
                                  color: MinimalistIcons
                                          .categoryColors[_selectedCategoryVi] ??
                                      AppColors.gray,
                                )
                              : null,
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

                        // Frequency (READ-ONLY)
                        // Per Figma: This field shows "Monthly (1st)" and is not editable
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Frequency',
                          value: 'Monthly (1st)',
                          controller: TextEditingController(text: 'Monthly (1st)'),
                          readOnly: true,
                        ),

                        const SizedBox(height: 24),

                        // Note (optional)
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Note (Optional)',
                          placeholder: 'e.g. Shared with roommate',
                          controller: _noteController,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        PrimaryButton(
                          label: _isEditing ? 'Update' : 'Add Recurring Expense',
                          isLoading: _isSaving,
                          onPressed: _saveRecurringExpense,
                        ),

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

/// Shows the Add Recurring Expense sheet
///
/// Returns null if user cancels, or the created/updated RecurringExpense
///
/// **Usage:**
/// ```dart
/// // Add new
/// final recurring = await showAddRecurringExpenseSheet(context: context);
///
/// // Edit existing
/// final updated = await showAddRecurringExpenseSheet(
///   context: context,
///   existingExpense: expense,
/// );
/// ```
Future<RecurringExpense?> showAddRecurringExpenseSheet({
  required BuildContext context,
  RecurringExpense? existingExpense,
}) {
  return showGrabberBottomSheet<RecurringExpense>(
    context: context,
    showGrabber: false,
    isFullScreen: true,
    isDismissible: true,
    enableDrag: true,
    contentPadding: const EdgeInsets.only(
      left: 16,
      right: 16,
      top: 0,
      bottom: 16,
    ),
    child: AddRecurringExpenseSheet(
      existingExpense: existingExpense,
    ),
  );
}
