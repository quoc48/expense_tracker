import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/sync_status_banner.dart';
import '../widgets/sync_queue_details_sheet.dart';
import '../widgets/expenses/expense_list_tile.dart';
import 'add_expense_screen.dart';
import '../theme/colors/app_colors.dart';
import '../theme/constants/app_spacing.dart';

/// ExpenseListScreen - Displays list of expenses with flat row design.
///
/// **Design Reference**: Figma node-id=5-2165
///
/// **Visual Design**:
/// - SliverAppBar matching Analytics page (same structure, no calendar icon)
/// - Flat list with ExpenseListTile rows
/// - Dividers between items
/// - White background
/// - RefreshIndicator for pull-to-refresh
///
/// **Learning**: This screen uses the same SliverAppBar structure as HomeScreen
/// to ensure consistent header height and positioning across tabs.
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  /// Track previous sync state to detect completion
  SyncState? _previousSyncState;

  @override
  Widget build(BuildContext context) {
    // Consumer2: Listen to ExpenseProvider AND SyncProvider
    return Consumer2<ExpenseProvider, SyncProvider>(
      builder: (context, expenseProvider, syncProvider, child) {
        // Detect sync completion and reload expenses from Supabase
        if (_previousSyncState == SyncState.syncing &&
            syncProvider.syncState == SyncState.synced) {
          debugPrint('🔄 Sync completed, reloading expenses from Supabase...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            expenseProvider.loadExpenses();
          });
        }
        _previousSyncState = syncProvider.syncState;

        return Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            bottom: false, // Let content extend behind nav bar
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenseProvider.expenses.isEmpty
                    ? _buildEmptyState(context, expenseProvider)
                    : _buildExpenseList(
                        context,
                        expenseProvider.expenses,
                        syncProvider,
                      ),
          ),
        );
      },
    );
  }

  /// Builds the custom app bar matching Analytics page structure
  ///
  /// **Design Reference**: Same as HomeScreen (node-id=5-940) but without calendar
  /// - Title: "Expenses" - Momo Trust Sans, 14px, 600 weight, #000
  /// - Icon: Sign-out only (no calendar for Expenses page)
  /// - toolbarHeight: 56 (matches Analytics)
  /// - titleSpacing: 20 (matches Analytics)
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: false,
      pinned: true, // Sticky header - stays visible when scrolling
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56, // Match Analytics page
      titleSpacing: 20, // Match Analytics page
      title: const Text(
        'Expenses',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
          fontFeatures: [
            FontFeature.disable('liga'),
            FontFeature.disable('clig'),
          ],
        ),
      ),
      actions: [
        // Sign-out icon only (no calendar for Expenses page)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Icon(
              PhosphorIconsRegular.signOut,
              size: 24,
              color: AppColors.textBlack,
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state with refresh button
  Widget _buildEmptyState(BuildContext context, ExpenseProvider expenseProvider) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverFillRemaining(
          child: RefreshIndicator(
            onRefresh: () async {
              await expenseProvider.loadExpenses();
            },
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsLight.arrowClockwise,
                          size: 72,
                          color: AppColors.gray,
                        ),
                        SizedBox(height: AppSpacing.spaceLg),
                        const Text(
                          'No expenses loaded',
                          style: TextStyle(
                            fontFamily: 'MomoTrustSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                        ),
                        SizedBox(height: AppSpacing.spaceXs),
                        Text(
                          'Tap Refresh to load your expenses',
                          style: TextStyle(
                            fontFamily: 'MomoTrustSans',
                            fontSize: 14,
                            color: AppColors.gray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.spaceLg),
                        FilledButton.icon(
                          onPressed: () async {
                            await expenseProvider.loadExpenses();
                          },
                          icon: const Icon(PhosphorIconsLight.arrowClockwise, size: 20),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the flat expense list with ExpenseListTile rows
  Widget _buildExpenseList(
    BuildContext context,
    List<Expense> expenses,
    SyncProvider syncProvider,
  ) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () async {
        await expenseProvider.loadExpenses();
      },
      child: CustomScrollView(
        slivers: [
          // App Bar (matches Analytics page structure)
          _buildAppBar(context),

          // Sync Status Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SyncStatusBanner(
                syncState: syncProvider.syncState,
                pendingCount: syncProvider.pendingCount,
                onTap: () {
                  SyncQueueDetailsSheet.show(context);
                },
              ),
            ),
          ),

          // Expense List
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 160, // Space for floating nav bar
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final expense = expenses[index];
                  final isLastItem = index == expenses.length - 1;

                  return DismissibleExpenseListTile(
                    expense: expense,
                    onTap: () => _editExpense(context, expense),
                    confirmDismiss: () => _showDeleteConfirmation(context, expense),
                    onDismissed: () => _deleteExpense(context, expense, index),
                    showDivider: !isLastItem, // No divider on last item
                  );
                },
                childCount: expenses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to edit expense screen
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

  /// Show delete confirmation dialog
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Delete expense and show undo snackbar
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
              await provider.restoreExpense(deletedExpense, index);
            },
          ),
        ),
      );
    }
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}
