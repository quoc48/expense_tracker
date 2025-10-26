import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import 'add_expense_screen.dart';

// ExpenseListScreen is a StatefulWidget because it manages changing data (the expense list)
// StatefulWidget = Widget that can change over time (has mutable state)
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

// The State class holds the mutable data and build logic
// The underscore (_) makes this class private to this file
class _ExpenseListScreenState extends State<ExpenseListScreen> {
  // State: The list of expenses (can be modified)
  List<Expense> _expenses = [];

  // Storage service instance for saving/loading expenses
  // late: This will be initialized before first use (in initState)
  late final StorageService _storageService;

  // Loading state to show progress indicator
  bool _isLoading = true;

  @override
  void initState() {
    // initState() is called once when the widget is first created
    // Perfect place for initial data loading
    super.initState();
    _storageService = StorageService();
    _loadExpenses();
  }

  // Load expenses from storage (async operation)
  // Future<void>: This returns nothing but takes time
  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // await: Wait for expenses to be loaded from storage
    final expenses = await _storageService.loadExpenses();

    setState(() {
      _expenses = expenses;
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: Top bar with title and actions
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        // We'll add filter/sort actions here later
      ),

      // Body: Main content area
      body: _expenses.isEmpty
          ? _buildEmptyState()
          : _buildExpenseList(),

      // FloatingActionButton: Material Design's prominent action button
      // Typically placed bottom-right for primary action
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget for empty state (when no expenses exist)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first expense',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  // Widget for displaying the list of expenses
  Widget _buildExpenseList() {
    return ListView.builder(
      // ListView.builder: Efficiently builds list items on-demand
      // Only creates widgets for visible items (great for performance)
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  // Individual expense card widget
  Widget _buildExpenseCard(Expense expense) {
    // DateFormat from intl package for nice date formatting
    final dateFormat = DateFormat('MMM dd, yyyy');
    // NumberFormat for currency display
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      // Card: Material Design elevated container
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // ListTile: Pre-built widget for list items with leading/title/subtitle/trailing

        // Leading: Icon representing the category
        leading: CircleAvatar(
          backgroundColor: expense.type.color.withOpacity(0.2),
          child: Icon(
            expense.category.icon,
            color: expense.type.color,
          ),
        ),

        // Title: Expense description
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        // Subtitle: Category and date
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    expense.category.displayName,
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    dateFormat.format(expense.date),
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (expense.note != null) ...[
              const SizedBox(height: 4),
              Text(
                expense.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),

        // Trailing: Amount and type indicator
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: expense.type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: expense.type.color.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                expense.type.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: expense.type.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // onTap: What happens when you tap the card
        // For now, just a placeholder - we'll add edit functionality later
        onTap: () {
          // TODO: Navigate to edit screen
        },
      ),
    );
  }

  // Function to add a new expense
  Future<void> _addExpense() async {
    // Navigator.push: Navigate to a new screen
    // await: Wait for the screen to return a result
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    // If user saved an expense (didn't just go back), add it to the list
    if (result != null) {
      setState(() {
        _expenses.add(result);
        // Sort expenses by date (newest first)
        _expenses.sort((a, b) => b.date.compareTo(a.date));
      });

      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${result.description}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _expenses.remove(result);
                });
              },
            ),
          ),
        );
      }
    }
  }
}
