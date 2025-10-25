import 'expense.dart';

// Dummy data for testing the UI
// In Milestone 2, we'll replace this with real data from storage
List<Expense> getDummyExpenses() {
  return [
    Expense(
      id: '1',
      description: 'Grocery shopping at Whole Foods',
      amount: 127.50,
      category: Category.food,
      type: ExpenseType.mustHave,
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Weekly groceries',
    ),
    Expense(
      id: '2',
      description: 'Uber to office',
      amount: 15.00,
      category: Category.transportation,
      type: ExpenseType.mustHave,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Expense(
      id: '3',
      description: 'Movie tickets',
      amount: 28.00,
      category: Category.entertainment,
      type: ExpenseType.niceToHave,
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: 'Watched the new Marvel movie',
    ),
    Expense(
      id: '4',
      description: 'Monthly electricity bill',
      amount: 85.00,
      category: Category.utilities,
      type: ExpenseType.mustHave,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Expense(
      id: '5',
      description: 'Impulse buy - gadget',
      amount: 45.00,
      category: Category.shopping,
      type: ExpenseType.wasted,
      date: DateTime.now().subtract(const Duration(days: 7)),
      note: "Didn't really need this",
    ),
    Expense(
      id: '6',
      description: 'Gym membership',
      amount: 50.00,
      category: Category.health,
      type: ExpenseType.niceToHave,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Expense(
      id: '7',
      description: 'Online course subscription',
      amount: 39.99,
      category: Category.education,
      type: ExpenseType.niceToHave,
      date: DateTime.now().subtract(const Duration(days: 12)),
      note: 'Flutter development course',
    ),
    Expense(
      id: '8',
      description: 'Restaurant dinner',
      amount: 75.00,
      category: Category.food,
      type: ExpenseType.niceToHave,
      date: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Expense(
      id: '9',
      description: 'Gas for car',
      amount: 60.00,
      category: Category.transportation,
      type: ExpenseType.mustHave,
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Expense(
      id: '10',
      description: 'Unused app subscription',
      amount: 9.99,
      category: Category.other,
      type: ExpenseType.wasted,
      date: DateTime.now().subtract(const Duration(days: 20)),
      note: 'Forgot to cancel this!',
    ),
  ];
}
