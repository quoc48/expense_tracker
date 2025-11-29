import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../utils/currency_formatter.dart';

/// CategoryCard displays a category with spending amount in a bar-chart style.
///
/// **Design Reference**: Figma node-id=5-1798, node-id=5-995
///
/// **Visual Design**:
/// - Rounded rectangle card with two-color fill system
/// - Solid color (100% opacity) from bottom = spent percentage
/// - Light color (20% opacity) fills the remaining top portion
/// - Centered sub-container with: icon (24px) + 8px gap + amount text
///
/// **Fill Logic** (Bar Chart Style):
/// - Zero-spend: Always 4px baseline fill
/// - With spending: 4px baseline + proportional fill based on percentage
/// - All cards share 100% of total spending (sum of fillPercentage = 1.0)
/// - Available fill space = cardHeight - 4px (baseline is always present)
///
/// **Typography** (from Figma):
/// - Font: Momo Trust Sans, 14px, weight 500
/// - Color: #000 (Black), center aligned
/// - Font features: 'liga' off, 'clig' off
class CategoryCard extends StatelessWidget {
  /// The category name (Vietnamese, e.g., "Thực phẩm")
  final String categoryName;

  /// The spending amount for this category
  final double amount;

  /// The fill percentage (0.0 to 1.0) representing this category's share of total spending
  /// Calculated as: categorySpent / totalSpent (all percentages sum to 1.0)
  final double fillPercentage;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Baseline fill height in pixels (always present, even for zero-spend)
  static const double _baselineFillHeight = 4.0;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.fillPercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the category color from our color system
    final categoryColor = AppColors.getCategoryColor(categoryName);

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate fill height:
          // - Baseline: 4px (always present for all cards)
          // - Additional: proportional to fillPercentage of remaining space
          //
          // Formula: fillHeight = 4px + (fillPercentage × (cardHeight - 4px))
          // This ensures zero-spend cards show exactly 4px
          // and cards with spending show 4px + their proportional share
          final cardHeight = constraints.maxHeight;
          final availableSpace = cardHeight - _baselineFillHeight;
          final proportionalFill = availableSpace * fillPercentage.clamp(0.0, 1.0);
          final fillHeight = _baselineFillHeight + proportionalFill;

          return Container(
            decoration: BoxDecoration(
              // 20% opacity background fills the entire card (unfilled portion)
              color: AppColors.getCategoryBackground(categoryColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Solid color fill from bottom (spent portion)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: fillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: categoryColor,
                        // Only round bottom corners since fill starts from bottom
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Centered content: icon + amount in a sub-container
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Filled icon - 24px as per Figma
                        Icon(
                          MinimalistIcons.getCategoryIconFill(categoryName),
                          size: 24,
                          color: AppColors.textBlack,
                        ),

                        // 8px spacing between icon and text
                        const SizedBox(height: 8),

                        // Amount text - Momo Trust Sans, 14px, w500
                        Text(
                          _formatAmount(amount),
                          style: const TextStyle(
                            fontFamily: 'MomoTrustSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            fontFeatures: [
                              FontFeature.disable('liga'),
                              FontFeature.disable('clig'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Format amount for display
  /// Zero shows as "0", otherwise use compact format
  String _formatAmount(double amount) {
    if (amount == 0) return '0';
    return CurrencyFormatter.formatCompact(amount);
  }
}

/// A grid of CategoryCards for displaying category spending overview.
///
/// **Design Reference**: Figma node-id=5-939 (Category section)
///
/// **Layout**: 4 columns with consistent spacing
/// **Display**: Always shows all 14 categories, sorted by spending (descending)
///
/// **Fill Logic** (Bar Chart Style):
/// - All 14 categories together represent 100% of total spending
/// - Each card's fill = (categorySpent / totalSpent) × 100%
/// - This means all fill percentages sum to 100%
/// - Categories with 0 spent show 4px minimum fill
class CategoryCardGrid extends StatelessWidget {
  /// Map of category names to their spending amounts
  final Map<String, double> categorySpending;

  /// Monthly budget (kept for potential future use, not used in fill calculation)
  final double monthlyBudget;

  /// Callback when a category card is tapped
  final void Function(String categoryName)? onCategoryTap;

  /// All category names in display order (matches design system)
  static const List<String> _allCategories = [
    'Thực phẩm',      // Food
    'Tiền nhà',       // Housing
    'Biếu gia đình',  // Family
    'Cà phê',         // Coffee
    'Du lịch',        // Travel
    'Giáo dục',       // Education
    'Giải trí',       // Entertainment
    'Hoá đơn',        // Bills
    'Quà vật',        // Gifts
    'Sức khoẻ',       // Health
    'Thời trang',     // Fashion
    'Tạp hoá',        // Groceries
    'Tết',            // Tet Holiday
    'Đi lại',         // Transportation
  ];

  const CategoryCardGrid({
    super.key,
    required this.categorySpending,
    required this.monthlyBudget,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create list of all categories with their spending
    // Categories not in spending map default to 0
    final allCategoryData = _allCategories.map((name) {
      return MapEntry(name, categorySpending[name] ?? 0.0);
    }).toList();

    // Calculate total spending across all categories
    // This is the denominator for fill percentage calculation
    final totalSpent = allCategoryData.fold<double>(
      0.0,
      (sum, entry) => sum + entry.value,
    );

    // Sort by amount descending (highest spending first)
    // Categories with 0 spending will be at the end
    allCategoryData.sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      // Prevent GridView from scrolling independently
      // Parent (SingleChildScrollView or CustomScrollView) handles scrolling
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Slightly taller than wide for icon + text balance
        childAspectRatio: 0.85,
      ),
      itemCount: allCategoryData.length,
      itemBuilder: (context, index) {
        final entry = allCategoryData[index];
        final categoryName = entry.key;
        final amount = entry.value;

        // Calculate fill percentage: categorySpent / totalSpent
        // This creates a bar chart where all fills sum to 100%
        // If totalSpent is 0, all cards show 0% fill (handled by CategoryCard's 4px minimum)
        final fillPercent = totalSpent > 0
            ? (amount / totalSpent)
            : 0.0;

        return CategoryCard(
          categoryName: categoryName,
          amount: amount,
          fillPercentage: fillPercent,
          onTap: onCategoryTap != null
              ? () => onCategoryTap!(categoryName)
              : null,
        );
      },
    );
  }
}
