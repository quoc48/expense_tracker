# Session: Add Expense UI Redesign Part 2 - December 1, 2025

## Status: WIP (95% Complete)

## Completed Work This Session

### 1. Date Picker (SelectDateSheet) ✅
- Created `lib/widgets/common/select_date_sheet.dart`
- Uses `table_calendar` package with custom styling
- Added `gray3` and `gray5` colors to AppColors
- Upgraded `intl` package to ^0.20.2

### 2. Category Icon in Form Field ✅
- Added `leadingWidget` parameter to `FormInput` component
- Category field displays icon + text when selected

### 3. Success Overlay ✅
- Created `lib/widgets/common/success_overlay.dart`
- 80% black overlay, 200x200px white popover with checkmark
- Auto-close in 3s OR tap outside to close
- `useSafeArea: false` for full screen coverage

### 4. Add/Edit Expense Flow ✅
- 1-second loading spinner delay on button
- `CupertinoActivityIndicator` for reliable animation
- Button stays black during loading
- Edit mode: button label "Update", success message "Expense updated."
- Amount field formats with comma on initial display (`_formatAmountWithCommas`)

### 5. Input Method Order ✅
- Reordered: Voice → Camera → Manual

### 6. Currency Formatter ✅
- Changed thousand separator: period (.) → comma (,)
- Uses `NumberFormat('#,##0', 'en_US')` + manual symbol append
- Symbol "đ" correctly positioned after number

### 7. Undo Delete Snackbar ⏳ (NEEDS FIX)
- Created `lib/widgets/common/undo_snackbar.dart`
- Black floating snackbar with "Expense removed." + "Undo"
- **ISSUE**: Spacing from nav bar appears larger than 16px
- Need to debug `bottomOffset` calculation

## Current Issue to Fix
The `UndoSnackbar` has too much spacing from the nav bar:
- Current `bottomOffset`: 86px (54px nav + 16px gap + 16px safe area)
- May need to investigate actual nav bar height and safe area
- Check for hidden elements affecting positioning

## Key Files
- `lib/widgets/common/undo_snackbar.dart` - needs bottomOffset fix
- `lib/screens/expense_list_screen.dart` - uses showUndoSnackbar()
- `lib/widgets/home/floating_nav_bar.dart` - check actual height

## Figma Reference
- Undo Snackbar: node-id=62-1695 (16px above nav bar)
