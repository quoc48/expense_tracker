import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

/// ExpenseListScreen now uses Provider for state management instead of local state.
///
/// Learning: We've migrated from setState (local state) to Provider (app-level state).
/// Benefits:
/// - The expense data is now accessible from ANY screen (like the Analytics screen!)
/// - No need to pass data through constructors
/// - Separation of concerns: UI code here, business logic in ExpenseProvider
/// - Automatic rebuilds when data changes (no manual setState calls)
class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer<ExpenseProvider>: Listens to the provider and rebuilds when it changes
    // Why Consumer instead of Provider.of?
    // - More granular: Only rebuilds the Consumer widget, not the entire screen
    // - More explicit: Clearly shows which widgets depend on which data
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Tracker'),
          ),
          body: expenseProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : expenseProvider.expenses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildExpenseList(expenseProvider.expenses),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addExpense(context),
            tooltip: 'Add Expense',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildExpenseList(List<Expense> expenses) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(context, expense, index);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, expense);
      },
      onDismissed: (direction) {
        _deleteExpense(context, expense, index);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.type.color.withOpacity(0.2),
            child: Icon(
              expense.category.icon,
              color: expense.type.color,
            ),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
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
          onTap: () => _editExpense(context, expense),
        ),
      ),
    );
  }

  Future<void> _addExpense(BuildContext context) async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (result != null && context.mounted) {
      // Access the provider without listening (we don't need rebuilds here)
      // listen: false tells Provider we just want to call a method, not listen to changes
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await provider.addExpense(result);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${result.description}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Delete the just-added expense to undo
                await provider.deleteExpense(result.id);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _editExpense(BuildContext context, Expense expense) async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );

    if (result != null && context.mounted) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await provider.updateExpense(result);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated: ${result.description}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, Expense expense) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.description}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExpense(
      BuildContext context, Expense expense, int index) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final deletedExpense = await provider.deleteExpense(expense.id);

    if (deletedExpense != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted: ${expense.description}'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Restore the expense at its original position
              await provider.restoreExpense(deletedExpense, index);
            },
          ),
        ),
      );
    }
  }
}
