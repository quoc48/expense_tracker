import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/currency_formatter.dart';
import '../../theme/typography/app_typography.dart';
import 'budget_edit_sheet.dart';

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
      leading: Icon(
        PhosphorIconsLight.wallet,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Monthly Budget'),
      subtitle: Text(
        CurrencyFormatter.format(
          currentBudget,
          context: CurrencyContext.full,
        ),
        style: AppTypography.currencyMedium(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        PhosphorIconsLight.pencilSimple,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showBudgetDialog(context),
    );
  }

  /// Show budget edit bottom sheet
  ///
  /// Learning: Bottom sheets are perfect for mobile form editing.
  /// They slide up from the bottom, provide natural entry/exit animations,
  /// and are more thumb-friendly than centered dialogs. This matches the
  /// Material Design pattern used throughout the app (e.g., theme selector).
  Future<void> _showBudgetDialog(BuildContext context) async {
    final newBudget = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true, // Allow sheet to size to content + keyboard
      builder: (context) => BudgetEditSheet(
        initialBudget: currentBudget,
      ),
    );

    // If user saved (not cancelled), call the callback
    if (newBudget != null) {
      onBudgetChanged(newBudget);
    }
  }
}
