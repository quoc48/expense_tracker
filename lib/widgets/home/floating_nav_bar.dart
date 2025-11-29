import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';

/// FloatingNavBar is a pill-shaped bottom navigation bar with shadow.
///
/// **Design Reference**: Figma node-id=5-939 (Bottom navigation)
///
/// **Visual Design**:
/// - Pill-shaped container (stadium border radius)
/// - White background with subtle shadow
/// - 3 navigation items: Expenses, History, Settings
/// - Icons only (no labels) for minimal look
/// - Selected state: filled icon
///
/// **Learning: Custom Navigation vs NavigationBar**
/// We're building a custom navigation instead of using Material's NavigationBar
/// because the Figma design requires:
/// 1. Pill shape (NavigationBar is full-width)
/// 2. Floating position (not attached to bottom edge)
/// 3. Icon-only design (NavigationBar requires labels)
///
/// The trade-off is we lose built-in accessibility features,
/// so we manually add semantics and tooltips.
class FloatingNavBar extends StatelessWidget {
  /// Currently selected navigation index
  final int selectedIndex;

  /// Callback when a navigation item is tapped
  final ValueChanged<int> onDestinationSelected;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Position above the bottom edge
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Container(
          // Intrinsic width based on content
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            // Stadium/pill shape
            borderRadius: BorderRadius.circular(32),
            // Subtle shadow for floating effect
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expenses/Home - Regular for unselected, Fill for selected
              _NavItem(
                icon: PhosphorIconsRegular.receipt,
                selectedIcon: PhosphorIconsFill.receipt,
                label: 'Expenses',
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),

              // History/Analytics
              _NavItem(
                icon: PhosphorIconsRegular.chartBar,
                selectedIcon: PhosphorIconsFill.chartBar,
                label: 'History',
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),

              // Settings
              _NavItem(
                icon: PhosphorIconsRegular.gear,
                selectedIcon: PhosphorIconsFill.gear,
                label: 'Settings',
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item within the FloatingNavBar.
///
/// **Accessibility**:
/// - Semantic label for screen readers
/// - Tooltip on long press
/// - Minimum touch target size (48x48)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            // Minimum touch target 48x48 for accessibility
            width: 56,
            height: 48,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                size: 24,
                // Selected: black, Unselected: gray (as per Figma)
                color: isSelected ? AppColors.textBlack : AppColors.gray,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scaffold wrapper that includes the FloatingNavBar.
///
/// **Usage**:
/// ```dart
/// FloatingNavBarScaffold(
///   selectedIndex: _currentIndex,
///   onDestinationSelected: (index) => setState(() => _currentIndex = index),
///   body: _screens[_currentIndex],
/// )
/// ```
///
/// This provides the floating nav bar positioned at the bottom
/// while allowing the body content to extend behind it.
class FloatingNavBarScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? floatingActionButton;

  const FloatingNavBarScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend body behind the nav bar for seamless look
      extendBody: true,
      body: body,
      // Use bottomNavigationBar slot for proper positioning
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
