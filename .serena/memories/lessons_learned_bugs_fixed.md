# Lessons Learned & Bug Fixes

## Flutter Concepts Mastered

### Milestone 1
1. **StatefulWidget vs StatelessWidget**: When to use mutable state
2. **ListView.builder**: Efficient list rendering for large datasets
3. **Form validation**: TextFormField with validator functions
4. **Navigation**: MaterialPageRoute with data passing
5. **Material Design 3**: Theme configuration and component usage
6. **Extensions on enums**: Adding displayName, color, icon properties

### Milestone 2
1. **async/await**: Handling asynchronous operations
2. **Futures**: Representing values available later
3. **JSON serialization**: toMap/fromMap pattern in Dart
4. **SharedPreferences**: Simple key-value storage
5. **Service layer pattern**: Separating persistence from UI
6. **Loading states**: Managing UI during async operations
7. **Late initialization**: `late final` keyword usage

## Bugs Fixed

### Bug 1: SegmentedButton Assertion Error
**Error**: `'selected.length > 0 || emptySelectionAllowed': is not true`
**Cause**: No expense type selected initially, but empty selection not allowed
**Fix**: Added `emptySelectionAllowed: true` to SegmentedButton
**File**: lib/screens/add_expense_screen.dart:160
**Lesson**: SegmentedButton requires explicit empty selection configuration

### Bug 2: RenderFlex Overflow
**Error**: Yellow/black stripes (overflow indicator) on expense cards
**Cause**: Category and date text too long for fixed Row layout
**Fix**: Wrapped Text widgets in Flexible with `overflow: TextOverflow.ellipsis`
**File**: lib/screens/expense_list_screen.dart:158, 168
**Lesson**: Always use Flexible/Expanded for dynamic content in Row/Column

### Bug 3: Hot Reload Not Working
**Issue**: Code changes not applying automatically
**Cause**: Running in background mode prevents file watch triggers
**Solution**: Manual app restart for guaranteed updates
**Lesson**: iOS simulator limitations with background processes

## Best Practices Established

1. **Git commits**: Detailed messages explaining what and why
2. **Code comments**: Explain concepts for learning purposes
3. **File organization**: Service layer separate from UI
4. **Error handling**: Try-catch in loadExpenses with graceful fallback
5. **Memory cleanup**: Dispose controllers in dispose()
6. **Todo tracking**: Keep todo.md updated with progress
7. **Testing workflow**: Add expense → restart → verify persistence

## Common Patterns Used

### Async Loading Pattern
```dart
Future<void> _loadExpenses() async {
  setState(() { _isLoading = true; });
  final expenses = await _storageService.loadExpenses();
  setState(() {
    _expenses = expenses;
    _isLoading = false;
  });
}
```

### Navigation with Result Pattern
```dart
final result = await Navigator.push<Expense>(
  context,
  MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
);
if (result != null) {
  // Handle result
}
```

### JSON Serialization Pattern
```dart
// To JSON
Map<String, dynamic> toMap() => {
  'id': id,
  'description': description,
  // ...
};

// From JSON
factory Expense.fromMap(Map<String, dynamic> map) => Expense(
  id: map['id'],
  description: map['description'],
  // ...
);
```
