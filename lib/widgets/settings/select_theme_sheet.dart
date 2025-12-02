import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../common/grabber_bottom_sheet.dart';
import '../common/selection_card.dart';
import '../common/tappable_icon.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectThemeSheet
// ============================================================================
// A bottom sheet for selecting app theme.
//
// Design Reference: Figma node-id=63-2136 (Sheet at node-id=64-2286)
//
// Layout:
// - GrabberBottomSheet with 24px padding (top 8px + 16px spacer), 40px bottom
// - Header: Gray title (left-aligned) + Close button (right)
// - Theme list using SelectionCardText (no icons)
// - Shows selected state for current theme
//
// Options:
// - Light mode (default)
// - Dark mode (not available yet)
// - System
// ============================================================================

/// Theme mode options for the app.
enum AppThemeMode {
  /// Light mode - always use light theme
  light,

  /// Dark mode - always use dark theme (not available yet)
  dark,

  /// System - follow device theme setting
  system,
}

/// Extension to get display labels for theme modes.
extension AppThemeModeExtension on AppThemeMode {
  /// Get the display label for this theme mode.
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Light mode';
      case AppThemeMode.dark:
        return 'Dark mode';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Get the short label for settings row display.
  String get shortLabel {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

/// A bottom sheet for selecting app theme.
///
/// **Design Reference**: Figma node-id=64-2286
///
/// **Specifications**:
/// - Padding: 24px sides, 24px top, 40px bottom
/// - Header: Title left-aligned, gray color, close button right
/// - Theme list: Uses [SelectionCardText] for each item (no icons)
/// - Selected state: Shows checkmark for current selection
///
/// **Usage**:
/// ```dart
/// final theme = await showSelectThemeSheet(
///   context: context,
///   selectedTheme: currentTheme,
/// );
/// if (theme != null) {
///   // Use selected theme
/// }
/// ```
class SelectThemeSheet extends StatelessWidget {
  /// Currently selected theme (for showing checkmark).
  final AppThemeMode selectedTheme;

  /// Callback when a theme is selected.
  final ValueChanged<AppThemeMode> onSelect;

  const SelectThemeSheet({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Theme options in display order per Figma
    const themes = [
      AppThemeMode.light,
      AppThemeMode.dark,
      AppThemeMode.system,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: Title (left) + Close Button (right)
        _buildHeader(context),

        // Gap between header and list (16px)
        const SizedBox(height: 16),

        // Theme List
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Build theme cards
            for (int i = 0; i < themes.length; i++)
              SelectionCardText(
                label: themes[i].label,
                isSelected: themes[i] == selectedTheme,
                showDivider: i < themes.length - 1, // No divider for last item
                onTap: () => onSelect(themes[i]),
              ),
          ],
        ),
      ],
    );
  }

  /// Build the header with gray title (left) and close button (right).
  ///
  /// **Design Reference**: Figma node-id=64-2287
  /// - Title: 16px Medium, gray (#8E8E93)
  /// - Close icon: 24px (no container wrapper)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title - left aligned, gray color
        Text(
          'Theme',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium weight per Figma
            color: AppColors.gray, // Gray per Figma design
          ),
        ),

        // Close button with tap state feedback
        TappableIcon(
          icon: PhosphorIconsRegular.x,
          onTap: () => Navigator.pop(context),
          iconSize: 24,
          iconColor: AppColors.textBlack,
          containerSize: 28, // Slightly larger for easier tapping
          isCircular: true,
        ),
      ],
    );
  }
}

/// Shows the Select Theme sheet and returns the selected theme.
///
/// Returns null if the user closes without selecting.
///
/// **Design Reference**: Figma node-id=64-2286
/// - No grabber indicator
/// - 24px padding sides/top, 40px bottom
/// - Header with gray title + close button
///
/// **Usage**:
/// ```dart
/// final theme = await showSelectThemeSheet(
///   context: context,
///   selectedTheme: currentTheme,
/// );
/// ```
Future<AppThemeMode?> showSelectThemeSheet({
  required BuildContext context,
  required AppThemeMode selectedTheme,
}) {
  return showGrabberBottomSheet<AppThemeMode>(
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
    child: SelectThemeSheet(
      selectedTheme: selectedTheme,
      onSelect: (theme) => Navigator.pop(context, theme),
    ),
  );
}
