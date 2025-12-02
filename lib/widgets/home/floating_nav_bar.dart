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
          // Gradient overlay for better contrast - adapts to theme
          Positioned.fill(
            child: IgnorePointer(
              child: Builder(
                builder: (context) {
                  final bgColor = AppColors.getBackground(context);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          bgColor.withValues(alpha: 0), // 0% opacity
                          bgColor.withValues(alpha: 0.8), // 80% opacity
                          bgColor, // 100% solid
                        ],
                      ),
                    ),
                  );
                },
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
        // Use nav bar specific color for layered depth in dark mode
        // Creates hierarchy: bg (#000) → cards (#141414) → nav bar (#1A1A1A)
        color: AppColors.getNavBarBackground(context),
        // Full pill shape (stadium)
        borderRadius: BorderRadius.circular(100),
        // Shadow from Figma: 0px 16px 32px -8px rgba(12,12,13,0.1)
        boxShadow: [
          AppColors.getCardShadow(context),
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
/// - Background: Black (white in dark mode)
/// - Icon: White + (plus-bold), 28px (black in dark mode)
class _FabButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FabButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    // FAB inverts colors in dark mode for visibility
    final fabBgColor = AppColors.isDarkMode(context) ? AppColors.white : AppColors.black;
    final fabIconColor = AppColors.isDarkMode(context) ? AppColors.black : AppColors.white;

    return Semantics(
      label: 'Add expense',
      button: true,
      child: Material(
        color: fabBgColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              PhosphorIconsBold.plus,
              color: fabIconColor,
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors adapt for dark mode
    final selectedColor = AppColors.getTextPrimary(context);
    final unselectedColor = AppColors.getNeutral400(context);

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
              // Selected: primary text, Unselected: neutral gray
              color: isSelected ? selectedColor : unselectedColor,
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
