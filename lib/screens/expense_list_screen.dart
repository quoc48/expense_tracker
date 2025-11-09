import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/budget_alert_banner.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';
import '../theme/typography/app_typography.dart';
import '../theme/colors/app_colors.dart';
import '../theme/constants/app_spacing.dart';
import '../theme/constants/app_constants.dart';
import '../theme/minimalist/minimalist_colors.dart';

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
            actions: [
              // Settings button
              IconButton(
                icon: const Icon(PhosphorIconsLight.gear),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              // Logout button
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: expenseProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : expenseProvider.expenses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildExpenseList(context, expenseProvider.expenses),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addExpense(context),
            tooltip: 'Add Expense',
            child: const Icon(PhosphorIconsRegular.plus), // Regular for FAB (slightly bolder)
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsLight.receipt,
            size: AppConstants.iconSize3xl * 1.5, // 72
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
          SizedBox(height: AppSpacing.spaceLg),
          Text(
            'No expenses yet',
            style: ComponentTextStyles.emptyTitle(theme.textTheme),
          ),
          SizedBox(height: AppSpacing.spaceXs),
          Text(
            'Tap + to add your first expense',
            style: ComponentTextStyles.emptyMessage(theme.textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, List<Expense> expenses) {
    // Get budget data to show alert banner
    final userPreferences = Provider.of<UserPreferencesProvider>(context);
    final budgetAmount = userPreferences.monthlyBudget;
    
    // Calculate current month's total spending
    final now = DateTime.now();
    final currentMonthExpenses = expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
    
    final totalSpending = currentMonthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    
    // Calculate budget percentage
    final budgetPercentage = budgetAmount > 0 ? (totalSpending / budgetAmount) * 100 : 0.0;

    return ListView.builder(
      // +1 for the alert banner (shown conditionally at index 0)
      itemCount: expenses.length + 1,
      itemBuilder: (context, index) {
        // First item: Budget Alert Banner
        if (index == 0) {
          return BudgetAlertBanner(
            budgetPercentage: budgetPercentage,
          );
        }
        
        // Remaining items: Expense cards (adjust index by -1)
        final expenseIndex = index - 1;
        final expense = expenses[expenseIndex];
        return _buildExpenseCard(context, expense, expenseIndex);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.spaceLg),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Icon(
          PhosphorIconsLight.trash,
          color: MinimalistColors.gray50,  // Main background - for delete icon on red background
          size: AppConstants.iconSizeLg,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, expense);
      },
      onDismissed: (direction) {
        _deleteExpense(context, expense, index);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.space2xs,  // 4px - creates 8px total gap between cards
        ),
        // Minimalist: Subtle elevation for depth
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  // Rounded corners
        ),
        child: ListTile(
          dense: true,  // Enable dense mode for tighter spacing
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,   // 16px
            vertical: AppSpacing.space2xs,    // 4px - ultra-compact
          ),
          minVerticalPadding: 0,  // Remove default ListTile vertical padding
          leading: CircleAvatar(
            backgroundColor: MinimalistColors.gray100,  // Card background
            radius: 20,
            child: Icon(
              expense.categoryIcon,
              color: MinimalistColors.gray800,  // Subheadings
              size: AppConstants.iconSizeSm,
            ),
          ),
          title: Text(
            expense.description,
            style: ComponentTextStyles.expenseTitleCompact(theme.textTheme),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: AppSpacing.space2xs),  // 4px minimal gap
            child: Text(
              dateFormat.format(expense.date),
              style: ComponentTextStyles.expenseDateCompact(theme.textTheme),
            ),
          ),
          trailing: Text(
            CurrencyFormatter.format(expense.amount, context: CurrencyContext.full),
            style: AppTypography.currencyMedium(
              color: MinimalistColors.gray900,  // Primary text
            ),
          ),
          onTap: () => _editExpense(context, expense),
        ),
      ),
    );
  }

  Future<void> _addExpense(BuildContext context) async {
    final result = await Navigator.push<Expense>(  // NEW: Return Expense directly
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (result != null && context.mounted) {
      // Access the provider without listening (we don't need rebuilds here)
      // listen: false tells Provider we just want to call a method, not listen to changes
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await provider.addExpense(result);  // NEW: Simplified API

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${result.description}'),  // Fixed: result IS the expense
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Delete the just-added expense to undo
                await provider.deleteExpense(result.id);  // Fixed: result IS the expense
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _editExpense(BuildContext context, Expense expense) async {
    final result = await Navigator.push<Expense>(  // NEW: Return Expense directly
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );

    if (result != null && context.mounted) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await provider.updateExpense(result);  // NEW: Simplified API

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated: ${result.description}'),  // Fixed: result IS the expense
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

  /// Show logout confirmation dialog
  ///
  /// Confirms the user wants to sign out before calling AuthProvider.signOut()
  /// After successful logout, AuthGate will automatically show LoginScreen
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    // If user confirmed, sign out
    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      // No need to navigate - AuthGate will automatically show LoginScreen
    }
  }
}
