# Session: Add Expense UI Redesign - COMPLETE
**Date**: 2025-11-30
**Branch**: feature/ui-redesign
**Last Commit**: 153b9b6

## ✅ Completed Components

### 1. AddExpenseSheet (`lib/widgets/common/add_expense_sheet.dart`)
- Full-screen modal bottom sheet for expense entry
- Fields: Amount, Description, Category, Type, Date, Note
- Per-field validation with error states
- Keyboard dismissal fixes using `FocusManager.instance.primaryFocus?.unfocus()`
- Smart category sorting by usage frequency in current month

### 2. SelectCategorySheet (`lib/widgets/common/select_category_sheet.dart`)
- 50% height of screen (`heightFactor: 0.5`)
- No grabber indicator (`showGrabber: false`)
- Header: Gray title (16px Medium) + Close button (24px X icon)
- Uses `CategorySelectionCard` with icons
- Categories sorted by usage frequency in current month

### 3. SelectTypeSheet (`lib/widgets/common/select_type_sheet.dart`)
- Similar to CategorySheet but with text-only cards
- Bottom padding: 40px (vs 24px for category)
- Fixed display order: Phải chi → Phát sinh → Lãng phí
- Uses `SelectionCardText` (no icons)

### 4. Selection Card Components (`lib/widgets/common/selection_card.dart`)
- `SelectionCard`: With icon container (32px circle, 10% opacity background)
- `SelectionCardText`: Text-only variant (no icon)
- `CategorySelectionCard`: Wrapper with category icon/color mapping

### 5. GrabberBottomSheet (`lib/widgets/common/grabber_bottom_sheet.dart`)
- Added `heightFactor` parameter for custom height
- Supports: no grabber, custom padding, full-screen mode

## Key Design Patterns

### Sheet Configuration
```dart
showGrabberBottomSheet<String>(
  context: context,
  showGrabber: false,
  contentPadding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24/40),
  heightFactor: 0.5, // For category sheet
  child: ...
);
```

### Keyboard Dismissal Pattern
```dart
void _showPicker() async {
  _dismissKeyboard();
  final result = await showSelectSheet(...);
  if (!mounted) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) FocusManager.instance.primaryFocus?.unfocus();
  });
  if (result != null) setState(() => _selectedValue = result);
}
```

### Smart Category Sorting
```dart
List<String> _sortCategoriesByUsage(List<String> categories, List<Expense> expenses) {
  final usageCount = <String, int>{};
  for (final expense in expenses) {
    usageCount[expense.categoryNameVi] = (usageCount[expense.categoryNameVi] ?? 0) + 1;
  }
  categories.sort((a, b) {
    final countA = usageCount[a] ?? 0;
    final countB = usageCount[b] ?? 0;
    if (countA != countB) return countB.compareTo(countA);
    return a.compareTo(b); // Alphabetical tiebreaker
  });
  return categories;
}
```

## Next: Date Picker UI
- Ask user for Figma link for Date picker design
- Will likely follow similar sheet pattern as Category/Type

## Recent Commits
- 153b9b6 refactor: Use AddExpenseSheet in main navigation
- ffa5ec1 feat: Add Type selection sheet with Figma design
- f806fb5 feat: Complete Add Expense screen with Category selection UI
