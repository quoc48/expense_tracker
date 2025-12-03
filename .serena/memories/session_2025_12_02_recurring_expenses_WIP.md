# Session: Recurring Expenses Feature - December 2, 2025 (WIP)

## Status: Planning Complete, Figma Specs Gathered, Ready for Implementation

**Branch:** `feature/recurring-expenses`
**Plan File:** `/Users/quocphan/.claude/plans/abundant-wiggling-naur.md`

---

## Feature Requirements (User Confirmed)

| Requirement | Decision |
|-------------|----------|
| Frequency | Monthly only (1st of month) |
| Auto-create trigger | On app open (no background service) |
| UI Location | Settings > Budget & Finance section |
| Management | Full CRUD (create, read, update, delete) |
| Active/Inactive | Yes - grouped list with pause/resume |
| End date | None (perpetual until deleted) |

---

## Figma Designs Collected

### 1. Empty State (node-id: 78-3867)
- Background: `#EDEFF1` (use `AppColors.getBackground(context)`)
- Empty image: `/assets/figma_exports/037e5545332078ef99fa8e97b09eb11a4d5b13d8.png` (180x180)
- Text: "There is nothing yet" - MomoTrustSans Regular 14px
- Button: "New Recurring Expense" - 220x48px, black bg, 12px radius

### 2. List with Items (node-id: 78-4062)
- Header: Back button (left) + "Recurring Expenses" (center) + Plus button (right)
- Buttons: 40x40px white circles
- Section headers: "ACTIVE (n)" / "INACTIVE (n)" - 12px gray `#8E8E93`
- Section gap: 24px
- Items container: White bg, 8px radius
- Card layout:
  - Icon: 32x32px circle (active: category color 10% opacity, inactive: `#F2F2F7`)
  - Icon inner: 18x18px filled icon
  - Description: MomoTrustSans Regular 14px black
  - Frequency: "Monthly (1st)" - 10px gray
  - Amount: MomoTrustSans Regular 14px black (right side)
  - Divider: `#F2F2F7`
  - Padding: 16px horizontal, 12px vertical

### 3. New Recurring Expense Sheet (node-id: 78-3914)
- Sheet: White bg, 24px top radius, shadow `0px 20px 76px rgba(0,0,0,0.2)`
- Overlay: `rgba(0,0,0,0.2)`
- Header: "New Recurring Expense" - 16px SemiBold, X close button 24px
- Amount: MomoTrustSans Bold 40px, centered, cursor 54px
- Form fields (5 total):
  1. Description - text input, placeholder "e.g Đi chợ"
  2. Category - select with caret-down
  3. Type - select with caret-down
  4. Frequency - **READ-ONLY**, shows "Monthly (1st)" (no tap action)
  5. Note (Optional) - text input, placeholder "e.g Với công ty"
- Field specs: 48px height, `#F2F2F7` bg, 12px radius, 24px gap between fields
- Button: "Create" - 48px, black bg, 12px radius

### 4. Action Sheet - **PENDING** (need Figma from user)
- Shows when tapping a card
- Options: Edit / Pause (or Resume) / Delete

---

## Implementation Plan (7 new files, 3 modified)

### New Files:
1. `lib/models/recurring_expense.dart`
2. `lib/repositories/recurring_expense_repository.dart`
3. `lib/repositories/supabase_recurring_expense_repository.dart`
4. `lib/services/recurring_expense_service.dart`
5. `lib/providers/recurring_expense_provider.dart`
6. `lib/widgets/settings/recurring_expenses_list_screen.dart`
7. `lib/widgets/settings/add_recurring_expense_sheet.dart`

### Modified Files:
1. `lib/main.dart` - Add RecurringExpenseProvider
2. `lib/screens/settings_screen.dart` - Enable recurring row
3. `lib/widgets/auth_gate.dart` - Add auto-creation trigger

---

## RecurringExpense Model Fields
```dart
String id
String categoryNameVi
String typeNameVi
String description
double amount
DateTime startDate
DateTime? lastCreatedDate  // Tracks auto-creation
bool isActive              // For pause/resume
String? note
```

---

## Dark Mode Helpers to Use
- `AppColors.getBackground(context)` - Screen background
- `AppColors.getSurface(context)` - Cards/sheets
- `AppColors.getTextPrimary(context)` - Primary text
- `AppColors.getDivider(context)` - Dividers
- `AppColors.gray` - Secondary text

---

## Database
Supabase `recurring_expenses` table already exists with all required fields.

---

## Next Steps
1. Get Action Sheet Figma design from user
2. Start Phase 1: Data Layer implementation
3. Follow todo list in order

---

## Continuation Prompt
```
Continue Recurring Expenses feature implementation.

Branch: feature/recurring-expenses
Memory: session_2025_12_02_recurring_expenses_WIP

Status: Planning complete, Figma specs collected (empty state, list, add sheet)
Missing: Action Sheet Figma design (Edit/Pause/Delete options)

Todo list has 11 tasks ready. Start with Phase 1 (Data Layer) after getting Action Sheet design.
```
