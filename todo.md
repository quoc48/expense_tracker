# Milestone 1: Basic UI with Dummy Data

## Phase 1.1: Project Setup & Models
- [ ] Review generated Flutter project structure
- [ ] Create expense model class (`lib/models/expense.dart`)
  - Fields: id, description, amount, category, type, date, note
  - Helper methods: toMap(), fromMap()
- [ ] Create enum for ExpenseType (mustHave, niceToHave, wasted)
- [ ] Create category constants or enum
- [ ] Generate dummy data (10-15 sample expenses)

**Learning**: Dart classes, enums, DateTime, data modeling

---

## Phase 1.2: Expense List Screen
- [ ] Create `lib/screens/expense_list_screen.dart`
- [ ] Design AppBar with title and add button
- [ ] Create expense list using ListView.builder
- [ ] Design expense list item widget
  - Show: description, amount, category, date
  - Add visual indicator for expense type (color coding)
- [ ] Handle empty state (no expenses message)

**Learning**: Stateful widgets, ListView, Flutter layout system

---

## Phase 1.3: Add Expense Form
- [ ] Create `lib/screens/add_expense_screen.dart`
- [ ] Build form with TextFormField widgets:
  - Description (required)
  - Amount (number input, required)
  - Category (dropdown/chips)
  - Type (radio buttons/segmented button)
  - Date (date picker)
  - Note (optional, multiline)
- [ ] Add form validation
- [ ] Create "Save" button
- [ ] Navigate back on save with new expense data

**Learning**: Forms, TextFormField, validation, navigation, date picker

---

## Phase 1.4: Integration & Navigation
- [ ] Set up navigation from list to add screen
- [ ] Pass dummy expense back to list screen
- [ ] Update list with new expense (in-memory only)
- [ ] Test adding multiple expenses
- [ ] Verify data displays correctly in list

**Learning**: Navigator, passing data between screens, setState

---

## Phase 1.5: UI Polish
- [ ] Apply Material Design 3 theme
- [ ] Add color scheme (primary, secondary colors)
- [ ] Format currency display (e.g., $1,234.56)
- [ ] Format date display (e.g., Jan 15, 2025)
- [ ] Add icons for categories
- [ ] Add type indicators (colors: green/yellow/red)
- [ ] Ensure responsive layout on different screen sizes

**Learning**: Themes, formatters, icons, responsive design

---

## Milestone 1 Completion Checklist
- [ ] Can view list of dummy expenses
- [ ] Can navigate to add expense screen
- [ ] Can fill out complete expense form
- [ ] Form validates required fields
- [ ] New expense appears in list (temporarily)
- [ ] UI follows Material Design 3
- [ ] Code is well-organized and commented
- [ ] Git commit: "Milestone 1 complete - Basic UI"

**Note**: Data will NOT persist after app restart (expected behavior for M1)

---

## 📂 Expected Project Structure After M1
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── expense.dart             # Expense data model
├── screens/
│   ├── expense_list_screen.dart # Home screen with expense list
│   └── add_expense_screen.dart  # Form to add new expense
└── widgets/                     # (Optional) Reusable widgets
    └── expense_card.dart        # Individual expense list item
```
