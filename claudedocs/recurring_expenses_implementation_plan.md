# Recurring Expenses Feature - Implementation Plan

## Overview

This plan details the implementation of the Recurring Expenses feature for the Flutter expense tracker app. The feature allows users to create monthly recurring expense templates that automatically generate actual expenses on the 1st of each month when the app is opened.

## Requirements Summary

| Requirement | Decision |
|-------------|----------|
| Frequency | Monthly only (1st of month) |
| Auto-create trigger | On app open (no background service) |
| UI Location | Settings > Budget & Finance section |
| Management | Simple CRUD (create from scratch, delete) |
| End date | None (perpetual until deleted) |
| Notifications | None |
| Pause/Resume | None |

---

## Phase 1: Data Layer

### 1.1 RecurringExpense Model

**File**: `lib/models/recurring_expense.dart` (NEW)

```dart
/// RecurringExpense model representing a monthly expense template
///
/// Architecture follows existing Expense model pattern:
/// - Vietnamese strings as source of truth (categoryNameVi, typeNameVi)
/// - Factory constructors for Supabase and Map conversions
/// - copyWith for immutable updates
class RecurringExpense {
  final String id;
  final String categoryNameVi;  // e.g., "Tiền nhà", "Hoá đơn"
  final String typeNameVi;      // e.g., "Phải chi", "Phát sinh"
  final String description;
  final double amount;
  final DateTime startDate;     // When template was created
  final DateTime? lastCreatedDate; // Last time expense was auto-created
  final String? note;
  
  // Constructor, factories, copyWith...
  
  factory RecurringExpense.fromSupabaseRow(Map<String, dynamic> row);
  factory RecurringExpense.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
  RecurringExpense copyWith({...});
}
```

### 1.2 Repository Interface

**File**: `lib/repositories/recurring_expense_repository.dart` (NEW)

```dart
/// Abstract interface for recurring expense operations
/// Follows existing ExpenseRepository pattern
abstract class RecurringExpenseRepository {
  /// Get all recurring expenses for current user
  Future<List<RecurringExpense>> getAll();
  
  /// Create a new recurring expense template
  Future<RecurringExpense> create(RecurringExpense recurring);
  
  /// Update a recurring expense (mainly for lastCreatedDate)
  Future<RecurringExpense> update(RecurringExpense recurring);
  
  /// Delete a recurring expense template
  Future<void> delete(String id);
  
  /// Get available categories (reuse from expense_repository)
  Future<List<String>> getCategories();
  
  /// Get available expense types (reuse from expense_repository)
  Future<List<String>> getExpenseTypes();
}
```

### 1.3 Supabase Repository Implementation

**File**: `lib/repositories/supabase_recurring_expense_repository.dart` (NEW)

```dart
/// Supabase implementation of RecurringExpenseRepository
/// 
/// Uses existing recurring_expenses table:
/// - Joins with categories and expense_types for Vietnamese names
/// - Caches category/type UUID mappings (same pattern as SupabaseExpenseRepository)
class SupabaseRecurringExpenseRepository implements RecurringExpenseRepository {
  Map<String, String>? _categoryIdMap;
  Map<String, String>? _typeIdMap;
  
  // Implementation follows SupabaseExpenseRepository pattern
}
```

**Key Query Patterns**:
```sql
-- Get all recurring expenses with category/type names
SELECT 
  id, description, amount, start_date, last_created_date, note,
  categories!inner(name_vi),
  expense_types!inner(name_vi)
FROM recurring_expenses
WHERE frequency = 'monthly' AND is_active = true
ORDER BY created_at DESC;

-- Update last_created_date after auto-creating expense
UPDATE recurring_expenses
SET last_created_date = '2025-12-01'
WHERE id = 'uuid';
```

---

## Phase 2: Auto-Creation Service

### 2.1 RecurringExpenseService

**File**: `lib/services/recurring_expense_service.dart` (NEW)

This service handles the auto-creation logic when the app opens.

```dart
/// Service to check and auto-create expenses from recurring templates
///
/// Logic:
/// 1. Called once on app startup (after authentication)
/// 2. Gets all active recurring expense templates
/// 3. For each template, checks if expense for current month exists
/// 4. Creates expense if needed, updates lastCreatedDate
class RecurringExpenseService {
  final RecurringExpenseRepository _recurringRepo;
  final ExpenseRepository _expenseRepo;
  
  /// Check and create expenses for current month
  /// Returns number of expenses created
  Future<int> processRecurringExpenses() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    
    final templates = await _recurringRepo.getAll();
    int created = 0;
    
    for (final template in templates) {
      // Skip if already created for current month
      if (_wasCreatedThisMonth(template.lastCreatedDate, currentMonth)) {
        continue;
      }
      
      // Skip if template was created this month (don't double-create)
      if (_isSameMonth(template.startDate, currentMonth)) {
        continue;
      }
      
      // Create expense from template
      final expense = Expense(
        id: const Uuid().v4(),
        description: template.description,
        amount: template.amount,
        categoryNameVi: template.categoryNameVi,
        typeNameVi: template.typeNameVi,
        date: currentMonth, // 1st of current month
        note: template.note,
      );
      
      await _expenseRepo.create(expense);
      
      // Update lastCreatedDate
      await _recurringRepo.update(
        template.copyWith(lastCreatedDate: currentMonth),
      );
      
      created++;
    }
    
    return created;
  }
  
  bool _wasCreatedThisMonth(DateTime? lastCreated, DateTime currentMonth) {
    if (lastCreated == null) return false;
    return lastCreated.year == currentMonth.year && 
           lastCreated.month == currentMonth.month;
  }
  
  bool _isSameMonth(DateTime date, DateTime currentMonth) {
    return date.year == currentMonth.year && 
           date.month == currentMonth.month;
  }
}
```

### 2.2 App Startup Integration

**File**: `lib/main.dart` (MODIFY)

The service should be called after:
1. Supabase is initialized
2. User is authenticated
3. ExpenseProvider has loaded

**Best approach**: Integrate into `AuthGate` or create a wrapper widget.

**File**: `lib/widgets/auth_gate.dart` (MODIFY)

```dart
// In AuthGate, after user is authenticated:
void _onAuthenticated() async {
  // Existing expense loading...
  
  // Process recurring expenses (silent, fire-and-forget)
  final recurringService = RecurringExpenseService(
    recurringRepo: SupabaseRecurringExpenseRepository(),
    expenseRepo: SupabaseExpenseRepository(),
  );
  
  try {
    final created = await recurringService.processRecurringExpenses();
    if (created > 0) {
      debugPrint('✅ Auto-created $created recurring expense(s)');
      // Refresh expense list to show new items
      context.read<ExpenseProvider>().loadExpenses();
    }
  } catch (e) {
    debugPrint('⚠️ Error processing recurring expenses: $e');
    // Silent fail - don't block user
  }
}
```

---

## Phase 3: State Management

### 3.1 RecurringExpenseProvider

**File**: `lib/providers/recurring_expense_provider.dart` (NEW)

```dart
/// Provider for recurring expense state management
/// Follows existing ExpenseProvider pattern
class RecurringExpenseProvider extends ChangeNotifier {
  List<RecurringExpense> _recurringExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  final RecurringExpenseRepository _repository = 
      SupabaseRecurringExpenseRepository();
  
  // Getters
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _recurringExpenses.length;
  
  /// Load all recurring expenses
  Future<void> loadRecurringExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _recurringExpenses = await _repository.getAll();
    } catch (e) {
      _errorMessage = 'Failed to load recurring expenses';
      debugPrint('Error loading recurring expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Add a new recurring expense
  Future<bool> addRecurringExpense(RecurringExpense expense) async {
    try {
      final created = await _repository.create(expense);
      _recurringExpenses.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding recurring expense: $e');
      return false;
    }
  }
  
  /// Delete a recurring expense
  Future<RecurringExpense?> deleteRecurringExpense(String id) async {
    try {
      final index = _recurringExpenses.indexWhere((e) => e.id == id);
      if (index == -1) return null;
      
      final deleted = _recurringExpenses.removeAt(index);
      await _repository.delete(id);
      notifyListeners();
      return deleted;
    } catch (e) {
      debugPrint('Error deleting recurring expense: $e');
      return null;
    }
  }
}
```

### 3.2 Provider Registration

**File**: `lib/main.dart` (MODIFY)

Add to MultiProvider:
```dart
ChangeNotifierProvider(
  create: (context) => RecurringExpenseProvider(),
),
```

---

## Phase 4: UI Components

### 4.1 File Structure

```
lib/
├── widgets/
│   └── settings/
│       ├── budget_edit_sheet.dart (existing)
│       ├── recurring_expenses_list_screen.dart (NEW)
│       └── add_recurring_expense_sheet.dart (NEW)
└── screens/
    └── settings_screen.dart (MODIFY)
```

### 4.2 Settings Screen Modification

**File**: `lib/screens/settings_screen.dart` (MODIFY)

Update `_buildRecurringRow` to be interactive:

```dart
Widget _buildRecurringRow(BuildContext context) {
  final textColor = AppColors.getTextPrimary(context);
  
  return Consumer<RecurringExpenseProvider>(
    builder: (context, provider, child) {
      return InkWell(
        onTap: () => _navigateToRecurringExpenses(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left: Icon + Labels
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsFill.calendarCheck,
                      size: 24,
                      color: AppColors.gray,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recurring Expenses',
                            style: AppTypography.style(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage automatic expenses',
                            style: AppTypography.style(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right: Count badge + Caret icon
              Row(
                children: [
                  if (provider.count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.count}',
                        style: AppTypography.style(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 18,
                    color: textColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _navigateToRecurringExpenses(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RecurringExpensesListScreen(),
    ),
  );
}
```

### 4.3 Recurring Expenses List Screen

**File**: `lib/widgets/settings/recurring_expenses_list_screen.dart` (NEW)

```dart
/// List screen showing all recurring expense templates
///
/// **Design**: Similar to ExpenseListScreen pattern
/// - App bar with back button + title
/// - List of recurring expense cards
/// - Empty state when no templates
/// - FAB to add new template
class RecurringExpensesListScreen extends StatelessWidget {
  const RecurringExpensesListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Consumer<RecurringExpenseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildLoadingState(context);
            }
            
            if (provider.recurringExpenses.isEmpty) {
              return _buildEmptyState(context);
            }
            
            return _buildList(context, provider);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: AppColors.getBackground(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(
          PhosphorIconsRegular.caretLeft,
          size: 24,
          color: AppColors.getTextPrimary(context),
        ),
      ),
      title: Text(
        'Recurring Expenses',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextPrimary(context),
        ),
      ),
      centerTitle: false,
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.calendarCheck,
                  size: 48,
                  color: AppColors.gray,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recurring expenses',
                  style: AppTypography.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first template',
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildList(BuildContext context, RecurringExpenseProvider provider) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildRecurringCard(
                context,
                provider.recurringExpenses[index],
              ),
              childCount: provider.recurringExpenses.length,
            ),
          ),
        ),
        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
  
  Widget _buildRecurringCard(BuildContext context, RecurringExpense recurring) {
    // Card showing: description, amount, category icon
    // Swipe to delete or tap-hold menu
    return Dismissible(
      key: Key(recurring.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context, recurring),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Category icon
            Icon(
              MinimalistIcons.getCategoryIcon(recurring.categoryNameVi),
              size: 24,
              color: MinimalistIcons.categoryColors[recurring.categoryNameVi],
            ),
            const SizedBox(width: 12),
            
            // Description + Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recurring.description,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recurring.categoryNameVi} • Monthly',
                    style: AppTypography.style(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              _formatAmount(recurring.amount),
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool> _confirmDelete(BuildContext context, RecurringExpense recurring) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${recurring.description}"? This will not affect already created expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecurringExpenseProvider>().deleteRecurringExpense(recurring.id);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _showAddSheet(BuildContext context) async {
    final result = await showAddRecurringExpenseSheet(context: context);
    if (result != null && context.mounted) {
      await context.read<RecurringExpenseProvider>().addRecurringExpense(result);
    }
  }
}
```

### 4.4 Add Recurring Expense Sheet

**File**: `lib/widgets/settings/add_recurring_expense_sheet.dart` (NEW)

```dart
/// Bottom sheet for adding a new recurring expense template
///
/// **Design**: Follows AddExpenseSheet pattern
/// - Full-screen bottom sheet
/// - AmountInputField for large amount display
/// - FormInput components for description, category, type, note
/// - No date field (always monthly on 1st)
class AddRecurringExpenseSheet extends StatefulWidget {
  const AddRecurringExpenseSheet({super.key});
  
  @override
  State<AddRecurringExpenseSheet> createState() => _AddRecurringExpenseSheetState();
}

class _AddRecurringExpenseSheetState extends State<AddRecurringExpenseSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();
  
  final ExpenseRepository _repository = SupabaseExpenseRepository();
  
  String? _selectedCategoryVi;
  String? _selectedTypeVi;
  
  List<String> _categories = [];
  List<String> _expenseTypes = [];
  bool _isLoadingOptions = true;
  bool _isSaving = false;
  
  // Validation errors
  String? _amountError;
  String? _descriptionError;
  String? _categoryError;
  String? _typeError;
  
  @override
  void initState() {
    super.initState();
    _loadOptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _amountFocusNode.requestFocus();
    });
  }
  
  Future<void> _loadOptions() async {
    // Same pattern as AddExpenseSheet
    try {
      final categories = await _repository.getCategories();
      final types = await _repository.getExpenseTypes();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _expenseTypes = types;
          _isLoadingOptions = false;
        });
      }
    } catch (e) {
      // Fallback data
    }
  }
  
  bool _validateForm() {
    // Same validation as AddExpenseSheet (without date)
    // ...
  }
  
  Future<void> _save() async {
    if (!_validateForm()) return;
    
    setState(() => _isSaving = true);
    
    final amountText = _amountController.text.replaceAll(',', '');
    
    final recurring = RecurringExpense(
      id: const Uuid().v4(),
      description: _descriptionController.text.trim(),
      amount: double.parse(amountText),
      categoryNameVi: _selectedCategoryVi!,
      typeNameVi: _selectedTypeVi!,
      startDate: DateTime.now(),
      lastCreatedDate: null, // Not created yet
      note: _noteController.text.trim().isEmpty 
          ? null 
          : _noteController.text.trim(),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.pop(context, recurring);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SheetHeader(
            title: 'New Recurring Expense',
            onClose: () => Navigator.pop(context),
          ),
          
          Expanded(
            child: _isLoadingOptions
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        
                        // Amount
                        AmountInputField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                        ),
                        if (_amountError != null) ...[
                          const SizedBox(height: 8),
                          Text(_amountError!, style: TextStyle(color: Colors.red)),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Description
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Description',
                          placeholder: 'e.g. Tiền nhà tháng',
                          controller: _descriptionController,
                          errorText: _descriptionError,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Category
                        FormInput(
                          variant: FormInputVariant.select,
                          label: 'Category',
                          placeholder: 'Select category',
                          value: _selectedCategoryVi,
                          onTap: _showCategoryPicker,
                          errorText: _categoryError,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Type
                        FormInput(
                          variant: FormInputVariant.select,
                          label: 'Type',
                          placeholder: 'Select type',
                          value: _selectedTypeVi,
                          onTap: _showTypePicker,
                          errorText: _typeError,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Frequency indicator (read-only)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.gray.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIconsRegular.calendarCheck),
                              const SizedBox(width: 12),
                              Text('Created monthly on the 1st'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Note (optional)
                        FormInput(
                          variant: FormInputVariant.text,
                          label: 'Note (Optional)',
                          placeholder: 'e.g. Thanh toán qua MoMo',
                          controller: _noteController,
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Save button
                        PrimaryButton(
                          label: 'Create Template',
                          isLoading: _isSaving,
                          onPressed: _save,
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

/// Helper function to show the sheet
Future<RecurringExpense?> showAddRecurringExpenseSheet({
  required BuildContext context,
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
    child: const AddRecurringExpenseSheet(),
  );
}
```

---

## Phase 5: Implementation Sequence

### Step 1: Data Layer (Files to Create)
1. `lib/models/recurring_expense.dart`
2. `lib/repositories/recurring_expense_repository.dart`
3. `lib/repositories/supabase_recurring_expense_repository.dart`

### Step 2: Service Layer (Files to Create)
4. `lib/services/recurring_expense_service.dart`

### Step 3: State Management (Files to Create/Modify)
5. `lib/providers/recurring_expense_provider.dart`
6. `lib/main.dart` - Add provider to MultiProvider

### Step 4: UI Components (Files to Create/Modify)
7. `lib/widgets/settings/recurring_expenses_list_screen.dart`
8. `lib/widgets/settings/add_recurring_expense_sheet.dart`
9. `lib/screens/settings_screen.dart` - Update recurring row

### Step 5: App Startup Integration (Files to Modify)
10. `lib/widgets/auth_gate.dart` - Add auto-creation trigger

---

## Edge Cases to Handle

### Auto-Creation Logic
1. **App opened multiple times same day**: Check `lastCreatedDate` has same year/month before skipping
2. **Template created in current month**: Don't auto-create for the month it was created (user just manually set it up)
3. **First day of month**: Still works because we compare year/month, not exact date
4. **Timezone issues**: Use local timezone for all date comparisons
5. **Failed creation**: Log error but continue with other templates (don't block entire process)

### UI Edge Cases
1. **Empty state**: Show helpful message with icon
2. **Loading state**: Show spinner while fetching
3. **Delete confirmation**: Always confirm before delete
4. **Network failure on save**: Show error message, keep sheet open
5. **Dark mode**: All colors use adaptive AppColors methods

### Data Integrity
1. **Orphaned templates**: If category/type is deleted from Supabase, handle gracefully
2. **User logout**: Clear provider state
3. **Duplicate prevention**: Check lastCreatedDate before creating

---

## Testing Checklist

### Manual Testing
- [ ] Create recurring expense template
- [ ] See template in list
- [ ] Delete template via swipe
- [ ] Close and reopen app on 1st of month
- [ ] Verify expense auto-created
- [ ] Verify expense shows in expense list
- [ ] Test dark mode appearance
- [ ] Test offline behavior

### Scenarios to Test
1. Create template on Dec 1st, reopen app Dec 2nd - should create expense
2. Create template on Dec 15th, reopen app Dec 15th - should NOT create
3. Create template on Dec 15th, wait until Jan 1st - should create expense
4. Delete template - should not create future expenses
5. Multiple templates - all should create expenses

---

## Critical Files for Implementation

| File | Reason |
|------|--------|
| `lib/models/expense.dart` | Reference for model pattern (Vietnamese strings, factories) |
| `lib/repositories/supabase_expense_repository.dart` | Reference for repository pattern |
| `lib/widgets/common/add_expense_sheet.dart` | Reference for bottom sheet form pattern |
| `lib/screens/settings_screen.dart` | Modification target for settings row |
| `lib/main.dart` | Provider registration location |

