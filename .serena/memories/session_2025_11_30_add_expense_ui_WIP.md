# Session 2025-11-30: Add Expense UI Redesign (WIP ~60%)

## Branch: `feature/ui-redesign`

## Commits This Session
- `7f7ee74` - feat: Add iOS-style bottom sheet for expense input method selection

## Completed Tasks ✅

### 1. GrabberBottomSheet Enhanced
- Added `showGrabber` parameter (can hide grabber)
- Added `isFullScreen` parameter (near full-screen mode)
- Added `useSafeArea` parameter
- File: `lib/widgets/common/grabber_bottom_sheet.dart`

### 2. AddExpenseOptionsSheet ✅
- 3 options: Manual, Camera, Voice
- Manual triggers navigation
- Camera/Voice placeholders for future
- File: `lib/widgets/common/add_expense_options_sheet.dart`

### 3. Design System Updates ✅
- `AppColors`: `overlayDark`, `grabber` colors added
- `MinimalistIcons`: `inputManual`, `inputCamera`, `inputVoice` added

### 4. New Form Components (Partial) ✅
Created in `lib/widgets/common/`:

| Component | File | Status |
|-----------|------|--------|
| `SheetHeader` | `sheet_header.dart` | ✅ Complete |
| `AmountInputField` | `amount_input_field.dart` | ✅ Complete |
| `FormTextField` | `form_text_field.dart` | ✅ Complete |
| `FormSelectField` | `form_select_field.dart` | ✅ Complete |
| `FormDateField` | - | ⏳ Not started |
| `PrimaryButton` | - | ⏳ Not started |

## Remaining Tasks

1. **Create FormDateField** - Same styling as FormSelectField but with calendar icon
2. **Create PrimaryButton** - Black full-width button, 48px height, 12px radius
3. **Create AddExpenseSheet** - Integrate all components into the main sheet
4. **Update navigation** - Replace AddExpenseScreen with AddExpenseSheet modal
5. **Test on iPhone**

## Key Design Specs (from Figma node-id=55-1049)

### Add Expense Sheet Structure:
- Near full-screen modal (below status bar)
- Uses GrabberBottomSheet with `showGrabber: false`, `isFullScreen: true`
- 24px rounded top corners
- 16px padding all around

### Components Layout:
1. **SheetHeader**: "Add Expense" title + X close button
2. **AmountInputField**: Large "0 đ" with auto-focus, comma formatting
3. **Forms section** (24px gap between fields):
   - Description (FormTextField)
   - Category (FormSelectField) - picker TBD
   - Type (FormSelectField) - picker TBD
   - Date (FormDateField) - picker TBD
   - Note (FormTextField, optional)
4. **PrimaryButton**: "Add Expense" black button

### Spacing:
- Header to Amount: 32px
- Amount to Forms: 32px
- Between form fields: 24px
- Forms to Button: 32px

## Alignment Rules Established

1. **Design System First**: All colors from `AppColors`, icons from `MinimalistIcons`
2. **Reusable Components**: Create in `lib/widgets/common/`
3. **One-by-one Implementation**: Build and test each component before moving on
4. **Figma Specs**: Follow exact measurements (height, padding, radius, colors)
5. **No Hardcoding**: Connect everything to design system libraries

## Files Created This Session
```
lib/widgets/common/
├── grabber_bottom_sheet.dart (updated)
├── add_expense_options_sheet.dart
├── sheet_header.dart
├── amount_input_field.dart
├── form_text_field.dart
└── form_select_field.dart
```

## Next Session Quick Start
1. Create `FormDateField` component
2. Create `PrimaryButton` component
3. Create `AddExpenseSheet` (integrate all)
4. Test on iPhone
5. Get Figma for Category/Type/Date pickers
