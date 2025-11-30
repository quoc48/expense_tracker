import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import 'grabber_bottom_sheet.dart';
import 'selection_card.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectTypeSheet
// ============================================================================
// A bottom sheet for selecting expense types.
//
// Design Reference: Figma node-id=56-4416
//
// Layout:
// - GrabberBottomSheet with 24px padding (top 8px + 16px spacer), 40px bottom
// - Header: Gray title (left-aligned) + Close button (right)
// - Type list using SelectionCardText (no icons)
// - Shows selected state for current type
// ============================================================================

/// A bottom sheet for selecting expense types.
///
/// **Design Reference**: Figma node-id=56-4416
///
/// **Specifications**:
/// - Padding: 24px sides, 24px top, 40px bottom
/// - Header: Title left-aligned, gray color, close button right
/// - Type list: Uses [SelectionCardText] for each item (no icons)
/// - Selected state: Shows checkmark for current selection
///
/// **Usage**:
/// ```dart
/// final type = await showSelectTypeSheet(
///   context: context,
///   types: ['Phải chi', 'Phát sinh', 'Lãng phí'],
///   selectedType: currentType,
/// );
/// if (type != null) {
///   // Use selected type
/// }
/// ```
class SelectTypeSheet extends StatelessWidget {
  /// List of type names to display.
  final List<String> types;

  /// Currently selected type (for showing checkmark).
  final String? selectedType;

  /// Callback when a type is selected.
  final ValueChanged<String> onSelect;

  const SelectTypeSheet({
    super.key,
    required this.types,
    this.selectedType,
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

        // Type List
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Build type cards
            for (int i = 0; i < types.length; i++)
              SelectionCardText(
                label: types[i],
                isSelected: types[i] == selectedType,
                showDivider: i < types.length - 1, // No divider for last item
                onTap: () => onSelect(types[i]),
              ),
          ],
        ),
      ],
    );
  }

  /// Build the header with gray title (left) and close button (right).
  ///
  /// **Design Reference**: Figma node-id=58-1003
  /// - Title: 16px Medium, gray (#8E8E93)
  /// - Close icon: 24px (no container wrapper)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title - left aligned, gray color
        Text(
          'Select Type',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium weight per Figma
            color: AppColors.gray, // Gray per Figma design
          ),
        ),

        // Close button - 24px icon directly (no container)
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

/// Shows the Select Type sheet and returns the selected type.
///
/// Returns null if the user closes without selecting.
///
/// **Design Reference**: Figma node-id=56-4416
/// - No grabber indicator
/// - 24px padding sides/top, 40px bottom
/// - Header with gray title + close button
///
/// **Usage**:
/// ```dart
/// final type = await showSelectTypeSheet(
///   context: context,
///   types: ['Phải chi', 'Phát sinh', 'Lãng phí'],
///   selectedType: currentType,
/// );
/// ```
Future<String?> showSelectTypeSheet({
  required BuildContext context,
  required List<String> types,
  String? selectedType,
}) {
  return showGrabberBottomSheet<String>(
    context: context,
    showGrabber: false, // No grabber - using custom header with close button
    isDismissible: true,
    enableDrag: true,
    // Custom padding: 24px sides, 8px top (+ 16px spacer = 24px), 40px bottom per Figma
    contentPadding: const EdgeInsets.only(
      left: 24,
      right: 24,
      top: 8,
      bottom: 40,
    ),
    child: SelectTypeSheet(
      types: types,
      selectedType: selectedType,
      onSelect: (type) => Navigator.pop(context, type),
    ),
  );
}
