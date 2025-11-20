import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sync_status_banner.dart';
import '../widgets/sync_queue_details_sheet.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';
import '../theme/typography/app_typography.dart';
import '../theme/colors/app_colors.dart';
import '../theme/constants/app_spacing.dart';
import '../theme/constants/app_constants.dart';
import '../theme/minimalist/minimalist_colors.dart';
import '../widgets/expandable_add_fab.dart';
import 'scanning/camera_capture_screen.dart';

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
    // Consumer2<ExpenseProvider, ThemeProvider>: Listens to BOTH providers and rebuilds when either changes
    // Why Consumer2 instead of Consumer?
    // - Expense data dependency: Rebuilds when expenses are added/edited/deleted
    // - Theme dependency: Rebuilds when user toggles light/dark mode (fixes stale colors bug)
    // - More explicit: Clearly shows which widgets depend on which data
    return Consumer2<ExpenseProvider, ThemeProvider>(
      builder: (context, expenseProvider, themeProvider, child) {
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
                icon: const Icon(PhosphorIconsLight.signOut),
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
          floatingActionButton: ExpandableAddFab(
            onManualAdd: () => _addExpenseManually(context),
            onScanReceipt: () => _scanReceipt(context),
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
    // Get sync status to show sync banner
    final syncProvider = Provider.of<SyncProvider>(context);

    // Get current theme brightness for ListView key
    // This forces ListView to rebuild visible items when theme changes
    final brightness = Theme.of(context).brightness;

    return ListView.builder(
      // Key based on brightness - ensures ListView rebuilds when toggling light/dark mode
      // Without this key, Flutter reuses existing Card widgets (causing invisible text bug)
      key: ValueKey('expense-list-$brightness'),
      // +1 for the sync banner (shown conditionally at index 0)
      itemCount: expenses.length + 1,
      itemBuilder: (context, index) {
        // First item: Sync Status Banner
        if (index == 0) {
          return SyncStatusBanner(
            syncState: syncProvider.syncState,
            pendingCount: syncProvider.pendingCount,
            onTap: () {
              // Show sync queue details sheet
              SyncQueueDetailsSheet.show(context);
            },
          );
        }
        
        // Remaining items: Expense cards (adjust index by -1)
        final expenseIndex = index - 1;
        final expense = expenses[expenseIndex];
        return ExpenseCard(
          expense: expense,
          onTap: () => _editExpense(context, expense),
          confirmDismiss: () => _showDeleteConfirmation(context, expense),
          onDismissed: () => _deleteExpense(context, expense, expenseIndex),
          enableSwipe: true,
          showWarning: false,
          showDate: true,
        );
      },
    );
  }

  /// Navigate to camera to scan receipt
  Future<void> _scanReceipt(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraCaptureScreen(),
      ),
    );
    // Note: Receipt review and batch save will be implemented in Phase 5
    // For now, the flow ends after OCR processing
  }

  /// Navigate to manual entry screen (existing flow)
  Future<void> _addExpenseManually(BuildContext context) async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    if (result == null || !context.mounted) {
      return;
    }

    // Access the provider without listening (we don't need rebuilds here)
    // listen: false tells Provider we just want to call a method, not listen to changes
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final success = await provider.addExpense(result);

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
