import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import '../../theme/typography/app_typography.dart';
import 'budget_edit_dialog.dart';

/// Budget setting tile that displays current budget and opens edit dialog
///
/// This is the only active tile in Settings Phase 2. It demonstrates:
/// - Clean ListTile pattern with icon, title, subtitle, trailing
/// - Currency formatting in display context
/// - Dialog-based editing workflow
/// - Callback pattern for parent updates
class BudgetSettingTile extends StatelessWidget {
  final double currentBudget;
  final Function(double) onBudgetChanged;

  const BudgetSettingTile({
    super.key,
    required this.currentBudget,
    required this.onBudgetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.account_balance_wallet,
        color: Colors.green,
      ),
      title: const Text('Monthly Budget'),
      subtitle: Text(
        CurrencyFormatter.format(
          currentBudget,
          context: CurrencyContext.full,
        ),
        style: AppTypography.currencyMedium(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: const Icon(Icons.edit, color: Colors.grey),
      onTap: () => _showBudgetDialog(context),
    );
  }

  /// Show budget edit dialog
  ///
  /// Learning: Dialogs are perfect for focused editing tasks.
  /// They keep the user's attention on a single field while
  /// maintaining context of where they came from. The alternative
  /// (navigating to a new screen) would feel heavyweight for
  /// editing a single number.
  Future<void> _showBudgetDialog(BuildContext context) async {
    final newBudget = await showDialog<double>(
      context: context,
      builder: (context) => BudgetEditDialog(
        initialBudget: currentBudget,
      ),
    );

    // If user saved (not cancelled), call the callback
    if (newBudget != null) {
      onBudgetChanged(newBudget);
    }
  }
}
