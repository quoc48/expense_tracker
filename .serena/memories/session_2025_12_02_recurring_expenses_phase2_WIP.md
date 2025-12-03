# Session: Recurring Expenses Feature - December 2, 2025 (Phase 2 WIP)

## Status: Data Layer Complete, UI Layer In Progress

**Branch:** `feature/recurring-expenses`

---

## ✅ Completed - Phase 1: Data Layer (5 files)

| File | Purpose |
|------|---------|
| `lib/models/recurring_expense.dart` | Model with `needsCreationForMonth()` helper |
| `lib/repositories/recurring_expense_repository.dart` | Abstract interface |
| `lib/repositories/supabase_recurring_expense_repository.dart` | Database implementation |
| `lib/services/recurring_expense_service.dart` | Auto-creation business logic |
| `lib/providers/recurring_expense_provider.dart` | State management |

## ✅ Completed - Font Fix

Updated `lib/theme/typography/app_typography.dart`:
- Changed `createTextTheme()` to use local asset font instead of Google Fonts CDN
- Removed unused `google_fonts` import
- All buttons now consistently use MomoTrustSans

---

## 🔄 In Progress - Phase 2: UI Layer

### Files to Create:
1. `lib/widgets/settings/recurring_expenses_list_screen.dart` - **NEXT**
2. `lib/widgets/settings/add_recurring_expense_sheet.dart`
3. `lib/widgets/settings/recurring_expense_action_sheet.dart`

### Figma Specs Collected:

**Empty State (node 78-3867):**
- Background: `AppColors.getBackground(context)`
- Image: `assets/figma_exports/037e5545332078ef99fa8e97b09eb11a4d5b13d8.png` (180x180)
- Text: "There is nothing yet" - 14px Regular
- Button: "New Recurring Expense" - 220x48px, black bg, 12px radius

**List Screen (node 78-4062):**
- Header: Back button + "Recurring Expenses" (centered) + Plus button
- Buttons: 40x40px white circles
- Section headers: "ACTIVE (n)" / "INACTIVE (n)" - 12px gray `#8E8E93`
- Cards: white bg, 8px radius
- Card item: 32x32 icon circle + description (14px) + frequency (10px gray) + amount (14px)

**Action Sheet (node 78-4190):**
- Reuses GrabberBottomSheet pattern
- Header: Title centered (expense name), X close button
- 3 option cards: Edit / Pause / Remove (same as AddExpenseOptionsSheet)
- Remove icon is RED

**Add Sheet (node 78-3914):**
- Same pattern as BudgetEditSheet
- Amount input (40px bold) + 5 form fields
- Frequency field is READ-ONLY "Monthly (1st)"

---

## Remaining Tasks

1. Build RecurringExpensesListScreen (empty + list states)
2. Build AddRecurringExpenseSheet (bottom sheet form)
3. Build RecurringExpenseActionSheet (edit/pause/delete)
4. Wire up Settings screen navigation (enable the row)
5. Add RecurringExpenseProvider to main.dart
6. Add auto-creation trigger to AuthGate

---

## Key Patterns to Follow

- Use `GrabberBottomSheet` for bottom sheets
- Use `AppTypography.style()` for all text
- Use `AppColors.getXxx(context)` for dark mode support
- Follow `_InputMethodCard` pattern for action sheet options
- Follow `BudgetEditSheet` pattern for add/edit form

---

## Continuation Prompt

```
Continue Recurring Expenses feature - Phase 2 UI.

Read memory: session_2025_12_02_recurring_expenses_phase2_WIP
Branch: feature/recurring-expenses

Data layer complete (5 files). Now building UI:
1. RecurringExpensesListScreen (empty + list states) - START HERE
2. AddRecurringExpenseSheet
3. RecurringExpenseActionSheet
4. Wire up Settings + Provider + AuthGate trigger

Patterns: Use GrabberBottomSheet, AppTypography.style(), follow BudgetEditSheet
```
