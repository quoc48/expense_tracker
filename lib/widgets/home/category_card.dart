import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../utils/currency_formatter.dart';

/// CategoryCard displays a category with spending amount in a bar-chart style.
///
/// **Design Reference**: Figma node-id=5-1798
///
/// **Visual Design**:
/// - Rounded rectangle with 20% opacity category color background
/// - Solid color fill from bottom representing spending amount
/// - Filled icon centered in the upper portion
/// - Amount displayed at the bottom
///
/// **Learning: Custom Painter vs Stack**
/// We use a Stack with positioned containers because:
/// 1. The fill effect is a simple bottom-up rectangle (no complex shapes)
/// 2. Stack is more performant for simple layering
/// 3. Easier to add animations later (AnimatedContainer)
///
/// CustomPainter would be better for:
/// - Complex shapes (waves, curves)
/// - Multiple overlapping fills
/// - Performance-critical scenarios with many repaints
class CategoryCard extends StatelessWidget {
  /// The category name (Vietnamese, e.g., "Thực phẩm")
  final String categoryName;

  /// The spending amount for this category
  final double amount;

  /// The fill percentage (0.0 to 1.0) representing spending progress
  /// If null, defaults to a visual representation based on amount
  final double? fillPercentage;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.amount,
    this.fillPercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the category color from our color system
    final categoryColor = AppColors.getCategoryColor(categoryName);

    // Calculate fill height (default to 60% if no percentage provided)
    // This creates a nice visual balance in the grid
    final fill = fillPercentage ?? 0.6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Fixed aspect ratio for consistent grid layout
        // Width determined by parent (GridView), height maintains ratio
        decoration: BoxDecoration(
          // 20% opacity background as per Figma design
          color: AppColors.getCategoryBackground(categoryColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Solid color fill from bottom
              // Represents spending progress visually
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                // Fill height based on percentage
                child: FractionallySizedBox(
                  heightFactor: fill,
                  alignment: Alignment.bottomCenter,
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
              ),

              // Content overlay (icon + amount)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filled icon at top
                      // Using filled style for emphasis on colored background
                      Icon(
                        MinimalistIcons.getCategoryIconFill(categoryName),
                        size: 28,
                        color: AppColors.textBlack,
                      ),

                      // Amount at bottom - Momo Trust Sans as per Figma
                      Text(
                        CurrencyFormatter.formatCompact(amount),
                        style: const TextStyle(
                          fontFamily: 'MomoTrustSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A grid of CategoryCards for displaying category spending overview.
///
/// **Design Reference**: Figma node-id=5-939 (Category section)
///
/// **Layout**: 4 columns with consistent spacing
/// Uses SliverGrid for efficient rendering in scrollable contexts
class CategoryCardGrid extends StatelessWidget {
  /// Map of category names to their spending amounts
  final Map<String, double> categorySpending;

  /// Callback when a category card is tapped
  final void Function(String categoryName)? onCategoryTap;

  const CategoryCardGrid({
    super.key,
    required this.categorySpending,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort categories by amount (highest first) for better UX
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate max amount for fill percentage normalization
    final maxAmount = sortedCategories.isNotEmpty
        ? sortedCategories.first.value
        : 1.0;

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
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];

        // Normalize fill percentage relative to max spending
        // Minimum 30% fill so cards don't look empty
        final fillPercent = (entry.value / maxAmount).clamp(0.3, 1.0);

        return CategoryCard(
          categoryName: entry.key,
          amount: entry.value,
          fillPercentage: fillPercent,
          onTap: onCategoryTap != null
              ? () => onCategoryTap!(entry.key)
              : null,
        );
      },
    );
  }
}
