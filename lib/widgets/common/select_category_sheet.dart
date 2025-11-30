import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import 'grabber_bottom_sheet.dart';
import 'selection_card.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectCategorySheet
// ============================================================================
// A bottom sheet for selecting expense categories.
//
// Design Reference: Figma node-id=56-3815
//
// Layout:
// - GrabberBottomSheet with 24px padding all sides
// - Header: Gray title (left-aligned) + Close button (right)
// - Category list using CategorySelectionCard
// - Shows selected state for current category
// ============================================================================

/// A bottom sheet for selecting expense categories.
///
/// **Design Reference**: Figma node-id=56-3815
///
/// **Specifications**:
/// - Padding: 24px all sides
/// - Header: Title left-aligned, gray color, close button right
/// - Category list: Uses [CategorySelectionCard] for each item
/// - Selected state: Shows checkmark for current selection
///
/// **Usage**:
/// ```dart
/// final category = await showSelectCategorySheet(
///   context: context,
///   categories: ['Thực phẩm', 'Tiền nhà', ...],
///   selectedCategory: currentCategory,
/// );
/// if (category != null) {
///   // Use selected category
/// }
/// ```
class SelectCategorySheet extends StatelessWidget {
  /// List of category names to display.
  final List<String> categories;

  /// Currently selected category (for showing checkmark).
  final String? selectedCategory;

  /// Callback when a category is selected.
  final ValueChanged<String> onSelect;

  const SelectCategorySheet({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: Title (left) + Close Button (right)
        _buildHeader(context),

        // Gap between header and list (16px)
        const SizedBox(height: 16),

        // Category List (scrollable if needed)
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Build category cards
                for (int i = 0; i < categories.length; i++)
                  CategorySelectionCard(
                    categoryName: categories[i],
                    isSelected: categories[i] == selectedCategory,
                    showDivider: i < categories.length - 1, // No divider for last item
                    onTap: () => onSelect(categories[i]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the header with gray title (left) and close button (right).
  ///
  /// **Design Reference**: Figma node-id=56-3816
  /// - Title: 16px Medium, gray (#8E8E93)
  /// - Close icon: 24px (no container wrapper)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title - left aligned, gray color
        Text(
          'Select Category',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium weight per Figma
            color: AppColors.gray, // Gray per Figma design
          ),
        ),

        // Close button - 24px icon directly (no container)
        // This aligns with the 24px checkmark icons in selection cards
        GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: const Icon(
            PhosphorIconsRegular.x,
            size: 24,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}

/// Shows the Select Category sheet and returns the selected category.
///
/// Returns null if the user closes without selecting.
///
/// **Design Reference**: Figma node-id=56-3815
/// - Height: 50% of screen
/// - No grabber indicator
/// - 24px padding all sides
/// - Header with gray title + close button
///
/// **Usage**:
/// ```dart
/// final category = await showSelectCategorySheet(
///   context: context,
///   categories: ['Thực phẩm', 'Tiền nhà', ...],
///   selectedCategory: currentCategory,
/// );
/// ```
Future<String?> showSelectCategorySheet({
  required BuildContext context,
  required List<String> categories,
  String? selectedCategory,
}) {
  return showGrabberBottomSheet<String>(
    context: context,
    showGrabber: false, // No grabber - using custom header with close button
    isDismissible: true,
    enableDrag: true,
    // Custom padding: 24px sides/bottom, 8px top (GrabberBottomSheet adds 16px spacer)
    // Total top = 16px (spacer) + 8px (padding) = 24px as per Figma
    contentPadding: const EdgeInsets.only(
      left: 24,
      right: 24,
      top: 8,
      bottom: 24,
    ),
    // Set height to 50% of screen to allow scrolling
    heightFactor: 0.5,
    child: SelectCategorySheet(
      categories: categories,
      selectedCategory: selectedCategory,
      onSelect: (category) => Navigator.pop(context, category),
    ),
  );
}
