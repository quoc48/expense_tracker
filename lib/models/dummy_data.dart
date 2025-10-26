import 'expense.dart';

/// Dummy data for testing the app during development
/// This file contains sample expenses spanning multiple months
/// to demonstrate analytics features like trends and comparisons.
///
/// Learning: Having realistic test data is crucial for development!
/// It helps you see how the app looks with real content and catch UI issues early.
class DummyData {
  static List<Expense> getExpenses() {
    final now = DateTime.now();

    // Helper to create dates relative to current month
    DateTime monthsAgo(int months, int day) {
      return DateTime(now.year, now.month - months, day);
    }

    return [
      // ========== CURRENT MONTH (This Month) ==========
      // Mix of categories and types to show variety

      Expense(
        id: 'exp_current_1',
        description: 'Weekly Groceries',
        amount: 125.50,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(0, 5),
        note: 'Whole Foods shopping',
      ),
      Expense(
        id: 'exp_current_2',
        description: 'Gas Station',
        amount: 65.00,
        category: Category.transportation,
        type: ExpenseType.mustHave,
        date: monthsAgo(0, 8),
      ),
      Expense(
        id: 'exp_current_3',
        description: 'Netflix Subscription',
        amount: 15.99,
        category: Category.entertainment,
        type: ExpenseType.niceToHave,
        date: monthsAgo(0, 10),
        note: 'Monthly streaming',
      ),
      Expense(
        id: 'exp_current_4',
        description: 'Coffee Shop',
        amount: 28.50,
        category: Category.food,
        type: ExpenseType.wasted,
        date: monthsAgo(0, 12),
        note: 'Daily coffee runs - should make at home!',
      ),
      Expense(
        id: 'exp_current_5',
        description: 'Electric Bill',
        amount: 89.00,
        category: Category.utilities,
        type: ExpenseType.mustHave,
        date: monthsAgo(0, 15),
      ),
      Expense(
        id: 'exp_current_6',
        description: 'Dinner with Friends',
        amount: 75.00,
        category: Category.food,
        type: ExpenseType.niceToHave,
        date: monthsAgo(0, 18),
        note: 'Birthday celebration',
      ),
      Expense(
        id: 'exp_current_7',
        description: 'New Running Shoes',
        amount: 120.00,
        category: Category.shopping,
        type: ExpenseType.niceToHave,
        date: monthsAgo(0, 20),
      ),
      Expense(
        id: 'exp_current_8',
        description: 'Uber Rides',
        amount: 42.00,
        category: Category.transportation,
        type: ExpenseType.wasted,
        date: monthsAgo(0, 22),
        note: 'Could have taken bus',
      ),

      // ========== LAST MONTH (1 month ago) ==========
      // Similar spending pattern but slightly less

      Expense(
        id: 'exp_m1_1',
        description: 'Rent',
        amount: 1200.00,
        category: Category.other,
        type: ExpenseType.mustHave,
        date: monthsAgo(1, 1),
      ),
      Expense(
        id: 'exp_m1_2',
        description: 'Groceries',
        amount: 180.00,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(1, 7),
      ),
      Expense(
        id: 'exp_m1_3',
        description: 'Internet Bill',
        amount: 60.00,
        category: Category.utilities,
        type: ExpenseType.mustHave,
        date: monthsAgo(1, 10),
      ),
      Expense(
        id: 'exp_m1_4',
        description: 'Movie Tickets',
        amount: 35.00,
        category: Category.entertainment,
        type: ExpenseType.niceToHave,
        date: monthsAgo(1, 14),
      ),
      Expense(
        id: 'exp_m1_5',
        description: 'Gas',
        amount: 55.00,
        category: Category.transportation,
        type: ExpenseType.mustHave,
        date: monthsAgo(1, 18),
      ),
      Expense(
        id: 'exp_m1_6',
        description: 'Gym Membership',
        amount: 45.00,
        category: Category.health,
        type: ExpenseType.niceToHave,
        date: monthsAgo(1, 20),
      ),
      Expense(
        id: 'exp_m1_7',
        description: 'Impulse Online Shopping',
        amount: 85.00,
        category: Category.shopping,
        type: ExpenseType.wasted,
        date: monthsAgo(1, 25),
        note: 'Items still in box...',
      ),

      // ========== 2 MONTHS AGO ==========

      Expense(
        id: 'exp_m2_1',
        description: 'Rent',
        amount: 1200.00,
        category: Category.other,
        type: ExpenseType.mustHave,
        date: monthsAgo(2, 1),
      ),
      Expense(
        id: 'exp_m2_2',
        description: 'Groceries',
        amount: 165.00,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(2, 8),
      ),
      Expense(
        id: 'exp_m2_3',
        description: 'Dentist Appointment',
        amount: 150.00,
        category: Category.health,
        type: ExpenseType.mustHave,
        date: monthsAgo(2, 12),
        note: 'Cleaning and checkup',
      ),
      Expense(
        id: 'exp_m2_4',
        description: 'Car Insurance',
        amount: 95.00,
        category: Category.transportation,
        type: ExpenseType.mustHave,
        date: monthsAgo(2, 15),
      ),
      Expense(
        id: 'exp_m2_5',
        description: 'Concert Tickets',
        amount: 120.00,
        category: Category.entertainment,
        type: ExpenseType.niceToHave,
        date: monthsAgo(2, 22),
      ),

      // ========== 3 MONTHS AGO ==========

      Expense(
        id: 'exp_m3_1',
        description: 'Rent',
        amount: 1200.00,
        category: Category.other,
        type: ExpenseType.mustHave,
        date: monthsAgo(3, 1),
      ),
      Expense(
        id: 'exp_m3_2',
        description: 'Groceries',
        amount: 145.00,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(3, 10),
      ),
      Expense(
        id: 'exp_m3_3',
        description: 'Utilities',
        amount: 78.00,
        category: Category.utilities,
        type: ExpenseType.mustHave,
        date: monthsAgo(3, 15),
      ),
      Expense(
        id: 'exp_m3_4',
        description: 'Fast Food',
        amount: 65.00,
        category: Category.food,
        type: ExpenseType.wasted,
        date: monthsAgo(3, 20),
        note: 'Too much takeout this week',
      ),

      // ========== 4 MONTHS AGO ==========

      Expense(
        id: 'exp_m4_1',
        description: 'Rent',
        amount: 1200.00,
        category: Category.other,
        type: ExpenseType.mustHave,
        date: monthsAgo(4, 1),
      ),
      Expense(
        id: 'exp_m4_2',
        description: 'Groceries',
        amount: 155.00,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(4, 12),
      ),
      Expense(
        id: 'exp_m4_3',
        description: 'Phone Bill',
        amount: 50.00,
        category: Category.utilities,
        type: ExpenseType.mustHave,
        date: monthsAgo(4, 18),
      ),

      // ========== 5 MONTHS AGO ==========

      Expense(
        id: 'exp_m5_1',
        description: 'Rent',
        amount: 1200.00,
        category: Category.other,
        type: ExpenseType.mustHave,
        date: monthsAgo(5, 1),
      ),
      Expense(
        id: 'exp_m5_2',
        description: 'Groceries',
        amount: 170.00,
        category: Category.food,
        type: ExpenseType.mustHave,
        date: monthsAgo(5, 8),
      ),
      Expense(
        id: 'exp_m5_3',
        description: 'Birthday Gift',
        amount: 80.00,
        category: Category.shopping,
        type: ExpenseType.niceToHave,
        date: monthsAgo(5, 15),
      ),
    ];
  }
}
