# Next Session: Tasks & Context

## User Decision Required

The user needs to choose between:

### Option 1: Complete CRUD Operations (Recommended First)
**Why**: Makes the app fully functional for daily use
**Tasks**:
1. Add **edit expense** functionality
   - Make expense cards tappable
   - Navigate to edit screen (reuse AddExpenseScreen or create new)
   - Pre-populate form with existing data
   - Update expense in list and storage
   - Show confirmation message

2. Add **delete expense** functionality
   - Add delete button/swipe gesture
   - Show confirmation dialog
   - Remove from list and storage
   - Show undo option (like add expense)

**Estimated effort**: 1-2 hours
**Files to modify**: 
- lib/screens/expense_list_screen.dart (add onTap, delete logic)
- lib/screens/add_expense_screen.dart (optional: make editable)

### Option 2: Start Milestone 3 (Analytics & Charts)
**Why**: More exciting visual features
**Tasks**:
1. Install fl_chart package
2. Add Provider for state management
3. Create analytics screen with monthly summary
4. Implement category breakdown chart
5. Add date filtering

**Estimated effort**: 3-4 hours
**New files needed**: lib/screens/analytics_screen.dart, lib/providers/*

## Technical Debt to Address

1. **Loading indicator**: _isLoading exists but not shown in UI
   - Add CircularProgressIndicator when loading
   - File: lib/screens/expense_list_screen.dart:64

2. **Empty onTap**: Expense card tap does nothing
   - Currently placeholder at expense_list_screen.dart:230
   - Should navigate to edit screen

3. **Dummy data file**: No longer used
   - Consider removing lib/models/dummy_data.dart
   - Keep for reference or delete to clean up

## Code Quality Improvements (Optional)

1. **Error messages**: Add user-friendly error handling
2. **Constants**: Extract strings to constants file
3. **Themes**: Consider dark mode support
4. **Accessibility**: Add semantic labels for screen readers
5. **Input validation**: More robust amount validation

## Session Start Checklist

When starting next session:
1. ✅ Read all memories (especially this one)
2. ✅ Check git status and current branch
3. ✅ Review todo.md for current tasks
4. ✅ Ask user which option they prefer (CRUD vs Analytics)
5. ✅ Create TodoWrite list for chosen path
6. ✅ Start implementation

## Important Reminders

- User is learning Flutter, provide explanations
- Use explanatory style with insights
- No "Claude Code" in commit messages
- Update todo.md with checkmarks
- Test on iOS simulator: iPhone 16
- Hot reload limited, use manual restart
- User prefers professional, honest feedback
