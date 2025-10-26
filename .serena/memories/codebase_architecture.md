# Expense Tracker - Codebase Architecture

## Project Structure
```
lib/
├── main.dart                           # App entry, Material Design 3 theme
├── models/
│   ├── expense.dart                    # Expense model with enums, extensions
│   └── dummy_data.dart                 # Test data (now replaced by storage)
├── screens/
│   ├── expense_list_screen.dart        # Main screen with list + storage
│   └── add_expense_screen.dart         # Form for adding expenses
└── services/
    └── storage_service.dart            # Persistence layer
```

## Key Files & Responsibilities

### lib/models/expense.dart
- **Expense class**: id, description, amount, category, type, date, note
- **ExpenseType enum**: mustHave, niceToHave, wasted (with color extensions)
- **Category enum**: food, transportation, utilities, entertainment, shopping, health, education, other (with icon extensions)
- **Methods**: toMap(), fromMap(), copyWith()
- **Extensions**: displayName, color, icon

### lib/services/storage_service.dart
- **StorageService class**: Handles all persistence
- **Key constant**: `_expensesKey = 'expenses'`
- **Methods**:
  - `initialize()`: Gets SharedPreferences instance
  - `saveExpenses(List<Expense>)`: JSON encode → save
  - `loadExpenses()`: Load → JSON decode → List<Expense>
  - `clearExpenses()`: For testing/debugging

### lib/screens/expense_list_screen.dart
- **State variables**:
  - `_expenses`: List of expenses
  - `_storageService`: Storage instance
  - `_isLoading`: Loading state (not yet displayed in UI)
- **Lifecycle**:
  - `initState()`: Initialize storage, load expenses
  - `_loadExpenses()`: Async load from storage
  - `_addExpense()`: Navigate to form, save result
- **UI methods**:
  - `_buildEmptyState()`: No expenses message
  - `_buildExpenseList()`: ListView.builder
  - `_buildExpenseCard()`: Individual expense card

### lib/screens/add_expense_screen.dart
- **Form fields**: Description, Amount, Category, Type, Date, Note
- **Controllers**: TextEditingController for text inputs
- **Validation**: All required fields validated
- **Date picker**: showDatePicker (2020 to today)
- **Return**: Navigator.pop with Expense object

## State Management
- Current: setState (local state)
- Future (M3): Provider for global state

## Data Persistence
- Package: shared_preferences ^2.2.2
- Format: JSON string
- Location: Device local storage
- Pattern: Service layer separation

## Navigation
- Pattern: Navigator.push/pop with result passing
- Type safety: Navigator.push<Expense>()

## Theming
- Material Design 3: useMaterial3: true
- Color scheme: Teal (Color(0xFF00897B))
- Custom themes: Card, AppBar, InputDecoration
