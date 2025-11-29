import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';

/// FloatingNavBar is a full-width bottom bar containing navigation pill and FAB.
///
/// **Design Reference**: Figma node-id=5-1095 (Nav bar)
///
/// **Structure** (from Figma):
/// - Full-width container with 16px horizontal padding
/// - Left: Navigation pill (white, rounded, shadow) with 3 icons
/// - Right: FAB button (black circle with + icon)
/// - Auto spacing between nav pill and FAB
///
/// **Navigation Icons**:
/// - Analytics (default selected) - presentation chart icon
/// - Expenses - receipt icon
/// - Settings - gear icon
///
/// **Selected State**: Light cyan background pill behind selected icon
///
/// **Learning: Full-width vs Centered Navigation**
/// The Figma design shows the nav bar spans the full width with the FAB
/// integrated as part of the same bar, not as a separate floating element.
/// This creates a cohesive bottom bar experience.
class FloatingNavBar extends StatelessWidget {
  /// Currently selected navigation index
  final int selectedIndex;

  /// Callback when a navigation item is tapped
  final ValueChanged<int> onDestinationSelected;

  /// Callback when FAB is tapped
  final VoidCallback? onFabTap;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Fixed height from Figma: 98px for gradient overlay area
      height: 98,
      child: Stack(
        children: [
          // Gradient overlay for better contrast
          // background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.8) 50%, rgba(255,255,255,0.9) 100%)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                    colors: [
                      Color(0x00FFFFFF), // 0% opacity
                      Color(0xCCFFFFFF), // 80% opacity (0xCC = 204 = 80%)
                      Color(0xFFFFFFFF), // 100% solid white
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Nav bar content positioned at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left: Navigation pill
                _NavigationPill(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                ),

                // Auto spacing between nav and FAB
                const Spacer(),

                // Right: FAB button
                _FabButton(onTap: onFabTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The navigation pill containing the 3 page icons.
///
/// **Figma Specs** (node-id=5-1096):
/// - Width: Hug (174px based on content)
/// - Height: Fixed 54px
/// - White background with rounded-[100px] (full pill)
/// - Shadow: 0px 16px 32px -8px rgba(12,12,13,0.1)
/// - Padding: 16px horizontal, 10px vertical
/// - Gap between icons: 29px
/// - Icon size: 28px
class _NavigationPill extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NavigationPill({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fixed height 54px from Figma, width hugs content
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        // Full pill shape (stadium)
        borderRadius: BorderRadius.circular(100),
        // Shadow from Figma: 0px 16px 32px -8px rgba(12,12,13,0.1)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C0C0D).withValues(alpha: 0.1),
            blurRadius: 32,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Analytics (default home page) - presentation chart
          _NavItem(
            icon: PhosphorIconsFill.presentationChart,
            label: 'Analytics',
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),

          const SizedBox(width: 29), // Gap from Figma

          // Expenses - receipt icon
          _NavItem(
            icon: PhosphorIconsFill.receipt,
            label: 'Expenses',
            isSelected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),

          const SizedBox(width: 29), // Gap from Figma

          // Settings - gear icon
          _NavItem(
            icon: PhosphorIconsFill.gear,
            label: 'Settings',
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
        ],
      ),
    );
  }
}

/// FAB button (black circle with + icon).
///
/// **Figma Specs** (node-id=5-1100):
/// - Size: 50x50
/// - Background: Black
/// - Icon: White + (plus-bold), 28px
class _FabButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FabButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Add expense',
      button: true,
      child: Material(
        color: Colors.black,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              PhosphorIconsBold.plus,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item within the navigation pill.
///
/// **Figma Specs**:
/// - Icon size: 28px
/// - Selected: Black filled icon
/// - Unselected: Gray filled icon (#B1B1B1)
///
/// **Accessibility**:
/// - Semantic label for screen readers
/// - Tooltip on long press
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  // Colors from Figma
  static const Color _unselectedColor = Color(0xFFB1B1B1);

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            // Icon container size 28x28
            width: 28,
            height: 28,
            child: Icon(
              icon,
              size: 28,
              // Selected: black, Unselected: light gray
              color: isSelected ? AppColors.textBlack : _unselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// A scaffold wrapper that includes the FloatingNavBar with integrated FAB.
///
/// **Design Reference**: Figma node-id=5-1095
///
/// **Usage**:
/// ```dart
/// FloatingNavBarScaffold(
///   selectedIndex: _currentIndex,
///   onDestinationSelected: (index) => setState(() => _currentIndex = index),
///   onFabTap: () => _addExpense(),
///   body: _screens[_currentIndex],
/// )
/// ```
///
/// **Learning: Integrated vs Separate FAB**
/// The Figma design shows the FAB as part of the bottom bar, not as a
/// separate floating element. This creates a cohesive UI where the
/// primary action (add expense) is always accessible alongside navigation.
class FloatingNavBarScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final VoidCallback? onFabTap;

  const FloatingNavBarScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use Stack to overlay nav bar without any background
    // The bottomNavigationBar slot adds a default background, so we avoid it
    return Stack(
      children: [
        // Main body content
        body,

        // Floating nav bar positioned at bottom
        // No SafeArea - the 32px padding in FloatingNavBar handles positioning
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingNavBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            onFabTap: onFabTap,
          ),
        ),
      ],
    );
  }
}
