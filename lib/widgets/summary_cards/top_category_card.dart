import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';
import 'summary_stat_card.dart';

/// Card showing the top spending category this month
///
/// **Why This Card Exists**
/// Quick insight: "Where did most of my money go?"
/// Instead of scrolling to the chart, see it immediately.
///
/// **Flutter Concept: Finding Max Value**
/// We use categoryBreakdown.entries.reduce() to find the entry with
/// the highest amount. This is a functional programming pattern.
///
/// **Learning: Helper Methods**
/// _getCategoryIcon() is a private helper method (starts with _)
/// It maps Vietnamese category names to appropriate icons.
class TopCategoryCard extends StatelessWidget {
  /// Map of category (Vietnamese) to total amount
  final Map<String, double> categoryBreakdown;

  const TopCategoryCard({
    super.key,
    required this.categoryBreakdown,
  });

  /// Helper method to get icon for Vietnamese category name
  /// This is the same logic as in Expense.categoryIcon getter
  IconData _getCategoryIcon(String categoryNameVi) {
    switch (categoryNameVi) {
      case 'Thực phẩm':
      case 'Cà phê':
        return Icons.restaurant;
      case 'Đi lại':
        return Icons.directions_car;
      case 'Hoá đơn':
      case 'Tiền nhà':
        return Icons.lightbulb;
      case 'Giải trí':
      case 'Du lịch':
        return Icons.movie;
      case 'Tạp hoá':
      case 'Thời trang':
        return Icons.shopping_bag;
      case 'Sức khỏe':
        return Icons.medical_services;
      case 'Giáo dục':
        return Icons.school;
      case 'Quà vật':
      case 'TẾT':
      case 'Biểu gia đình':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no categories, show empty state
    if (categoryBreakdown.isEmpty) {
      return SummaryStatCard(
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No expenses yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Find the category with the highest spending
    // reduce() compares entries and keeps the one with higher value
    final topEntry = categoryBreakdown.entries.reduce(
      (a, b) => a.value > b.value ? a : b,  // Keep entry with larger value
    );

    final categoryNameVi = topEntry.key;
    final amount = topEntry.value;

    // Get icon for this category using our helper method
    final categoryIcon = _getCategoryIcon(categoryNameVi);

    return SummaryStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Top Category',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category display with icon
          Row(
            children: [
              // Category icon in a colored circle
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,  // Light background
                  shape: BoxShape.circle,  // Circular container
                ),
                child: Icon(
                  categoryIcon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Category name and amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name
                    Text(
                      categoryNameVi,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Amount spent in this category
                    Text(
                      CurrencyFormatter.format(amount, context: CurrencyContext.full),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
