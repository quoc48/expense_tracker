import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/constants/app_constants.dart';

/// Horizontal expandable FAB for adding expenses
///
/// Features:
/// - Smooth Material Design 3 animations (300ms)
/// - Horizontal expansion with staggered fade-in
/// - Three actions: Manual entry, Scan receipt, Close
/// - Theme-aware colors for light/dark mode
/// - Future-ready for glassmorphism effects
///
/// Learning: This is a custom animated widget using AnimationController
/// for precise control over animations. We use a Stack with Positioned
/// widgets to create the horizontal layout and animate each button independently.
class ExpandableAddFab extends StatefulWidget {
  /// Callback when user taps "Manual Entry" button
  final VoidCallback onManualAdd;

  /// Callback when user taps "Scan Receipt" button
  final VoidCallback onScanReceipt;

  /// Callback when the expanded state changes (for parent to track state)
  final ValueChanged<bool>? onExpandedChanged;

  const ExpandableAddFab({
    super.key,
    required this.onManualAdd,
    required this.onScanReceipt,
    this.onExpandedChanged,
  });

  @override
  State<ExpandableAddFab> createState() => ExpandableAddFabState();
}

/// State class for ExpandableAddFab (public to allow GlobalKey access from parent)
class ExpandableAddFabState extends State<ExpandableAddFab>
    with SingleTickerProviderStateMixin {
  /// Animation controller for smooth transitions
  late AnimationController _controller;

  /// Whether the FAB is currently expanded
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with Material 3 duration (300ms)
    _controller = AnimationController(
      duration: AppConstants.durationNormal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Toggle between expanded and collapsed states
  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    // Notify parent of state change
    widget.onExpandedChanged?.call(_isExpanded);
  }

  /// Collapse the FAB (called from parent via GlobalKey)
  void collapse() {
    if (_isExpanded) {
      _toggle();
    }
  }

  /// Handle manual entry action
  void _handleManualAdd() {
    _toggle(); // Collapse first
    // Delay callback to allow collapse animation to start
    Future.delayed(const Duration(milliseconds: 100), widget.onManualAdd);
  }

  /// Handle scan receipt action
  void _handleScanReceipt() {
    _toggle(); // Collapse first
    // Delay callback to allow collapse animation to start
    Future.delayed(const Duration(milliseconds: 100), widget.onScanReceipt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate button positions based on animation progress
        // When expanded (progress = 1.0), buttons are at their final positions
        // When collapsed (progress = 0.0), buttons are hidden under main FAB
        final double progress = _controller.value;

        // Fast fade-in for buttons (appear quickly, move smoothly)
        // Use emphasized curve for quicker appearance
        final double fadeProgress = Curves.easeOut.transform(progress);

        // Button spacing: 72px between each button (56px FAB + 16px gap)
        const double buttonSpacing = 72.0;

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            // FAB Buttons
            SizedBox(
              // Width: Main FAB (56) + 2 buttons (72 each) = 200px when fully expanded
              width: 56 + (buttonSpacing * 2 * progress),
              height: 56,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
              // Action Button 1: Manual Entry (leftmost when expanded)
              Positioned(
                right: buttonSpacing * 2 * progress,
                child: _buildPrimaryActionButton(
                  icon: PhosphorIconsRegular.pencilSimple,
                  label: 'Manual',
                  onPressed: _handleManualAdd,
                  // Use faster fade curve for quicker appearance
                  opacity: fadeProgress,
                ),
              ),

              // Action Button 2: Scan Receipt (center when expanded)
              Positioned(
                right: buttonSpacing * progress,
                child: _buildPrimaryActionButton(
                  icon: PhosphorIconsRegular.camera,
                  label: 'Scan',
                  onPressed: _handleScanReceipt,
                  // Use faster fade curve for quicker appearance
                  opacity: fadeProgress,
                ),
              ),

              // Main FAB: Close button (rightmost, always visible)
              // Uses transparent background when expanded, primary when collapsed
              Positioned(
                right: 0,
                child: FloatingActionButton(
                  onPressed: _toggle,
                  tooltip: _isExpanded ? 'Close' : 'Add Expense',
                  elevation: _isExpanded ? AppConstants.elevation4 : AppConstants.elevation6,
                  backgroundColor: _isExpanded
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                      : null, // Use default FAB color when collapsed
                  foregroundColor: _isExpanded
                      ? colorScheme.onSurface
                      : null, // Use default icon color when collapsed
                  // Rotate the plus icon 45° to make it look like X when expanded
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0.0, // 45° (0.125 turns) when expanded
                    duration: AppConstants.durationFast,
                    curve: AppConstants.curveEmphasized,
                    child: const Icon(PhosphorIconsRegular.plus),
                  ),
                ),
              ),
                ],
              ),
            ), // Close SizedBox
          ],
        ); // Close outer Stack
      },
    );
  }

  /// Build a primary action button (Manual Entry or Scan Receipt)
  /// Uses high-contrast primary colors for better visibility in both themes
  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double opacity,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: opacity,
      child: FloatingActionButton(
        onPressed: opacity > 0.3 ? onPressed : null, // Clickable earlier due to fast fade
        tooltip: label,
        heroTag: label, // Unique tag to avoid hero animation conflicts
        elevation: AppConstants.elevation6,
        // Use primary color for high contrast in both light and dark modes
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Icon(
          icon,
          size: AppConstants.iconSizeMd,
        ),
      ),
    );
  }
}
