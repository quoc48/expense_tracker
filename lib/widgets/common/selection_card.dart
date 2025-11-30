import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectionCard
// ============================================================================
// A reusable list item for selection sheets (Category, Type, etc.)
//
// Design Reference: Figma node-id=56-3670 (Selected), node-id=56-3653 (Normal)
//
// Two states:
// - Normal: Icon + Label
// - Selected: Icon + Label + Checkmark
// ============================================================================

/// A reusable selection card for picker sheets.
///
/// **Design Reference**: Figma node-id=56-3670
///
/// **Specifications**:
/// - Icon container: 32px circle with 10% opacity background
/// - Icon: 18px, filled style, custom color
/// - Label: 14px Regular, black
/// - Selected state: Shows checkmark icon (24px) on right
/// - Padding: 16px vertical
/// - Gap: 12px between icon and label
///
/// **Usage**:
/// ```dart
/// SelectionCard(
///   icon: PhosphorIconsFill.forkKnife,
///   iconColor: Color(0xFFFF8D28),
///   label: 'Thực phẩm',
///   isSelected: selectedCategory == 'Thực phẩm',
///   onTap: () => onSelect('Thực phẩm'),
/// )
/// ```
class SelectionCard extends StatelessWidget {
  /// The icon to display (should be a Fill variant).
  final IconData icon;

  /// The color for the icon and background tint.
  final Color iconColor;

  /// The label text.
  final String label;

  /// Whether this card is currently selected.
  final bool isSelected;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show divider below this card.
  final bool showDivider;

  const SelectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card content
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Icon container (32px circle with 10% opacity background)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 18,
                      color: iconColor,
                    ),
                  ),
                ),

                // Gap between icon and label (12px)
                const SizedBox(width: 12),

                // Label (expands to fill available space)
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),

                // Checkmark for selected state
                if (isSelected)
                  const Icon(
                    PhosphorIconsFill.checkCircle,
                    size: 24,
                    color: AppColors.textBlack,
                  ),
              ],
            ),
          ),
        ),

        // Divider
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray6,
          ),
      ],
    );
  }
}

/// A selection card specifically for expense categories.
///
/// Automatically uses the correct icon and color from MinimalistIcons.
///
/// **Usage**:
/// ```dart
/// CategorySelectionCard(
///   categoryName: 'Thực phẩm',
///   isSelected: selectedCategory == 'Thực phẩm',
///   onTap: () => onSelect('Thực phẩm'),
/// )
/// ```
class CategorySelectionCard extends StatelessWidget {
  /// The category name (Vietnamese).
  final String categoryName;

  /// Whether this card is currently selected.
  final bool isSelected;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show divider below this card.
  final bool showDivider;

  const CategorySelectionCard({
    super.key,
    required this.categoryName,
    this.isSelected = false,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    // Import here to avoid circular dependency
    // ignore: depend_on_referenced_packages
    final iconData = _getCategoryIconFill(categoryName);
    final iconColor = _getCategoryColor(categoryName);

    return SelectionCard(
      icon: iconData,
      iconColor: iconColor,
      label: categoryName,
      isSelected: isSelected,
      onTap: onTap,
      showDivider: showDivider,
    );
  }

  // Local category icon mapping (to avoid import issues)
  IconData _getCategoryIconFill(String name) {
    const icons = {
      'Thực phẩm': PhosphorIconsFill.forkKnife,
      'Tiền nhà': PhosphorIconsFill.house,
      'Biểu gia đình': PhosphorIconsFill.usersThree,
      'Cà phê': PhosphorIconsFill.coffee,
      'Du lịch': PhosphorIconsFill.airplaneTilt,
      'Giáo dục': PhosphorIconsFill.graduationCap,
      'Giải trí': PhosphorIconsFill.popcorn,
      'Hoá đơn': PhosphorIconsFill.invoice,
      'Quà vật': PhosphorIconsFill.gift,
      'Sức khỏe': PhosphorIconsFill.heartbeat,
      'Thời trang': PhosphorIconsFill.shoppingBag,
      'Tạp hoá': PhosphorIconsFill.shoppingCart,
      'TẾT': PhosphorIconsFill.flower,
      'Đi lại': PhosphorIconsFill.motorcycle,
    };
    return icons[name] ?? PhosphorIconsFill.warning;
  }

  Color _getCategoryColor(String name) {
    const colors = {
      'Thực phẩm': Color(0xFFFF8D28),
      'Tiền nhà': Color(0xFFFFCC00),
      'Biểu gia đình': Color(0xFF34C759),
      'Cà phê': Color(0xFFAC7F5E),
      'Du lịch': Color(0xFF00C8B3),
      'Giáo dục': Color(0xFF00C3D0),
      'Giải trí': Color(0xFF00C0E8),
      'Hoá đơn': Color(0xFFFF2D55),
      'Quà vật': Color(0xFF0088FF),
      'Sức khỏe': Color(0xFF6155F5),
      'Thời trang': Color(0xFFCB30E0),
      'Tạp hoá': Color(0xFFFFCC00),
      'TẾT': Color(0xFFFF2D55),
      'Đi lại': Color(0xFF34C759),
    };
    return colors[name] ?? const Color(0xFF8E8E93);
  }
}
