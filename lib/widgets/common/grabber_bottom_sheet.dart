import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/constants/app_spacing.dart';

/// A reusable iOS-style bottom sheet with optional grabber indicator.
///
/// Features:
/// - Semi-transparent overlay backdrop (tap to dismiss)
/// - Optional iOS-style grabber/drag indicator at top
/// - Slide-up animation
/// - Customizable content via [child] parameter
/// - 24px rounded top corners (matches iOS design)
/// - Support for full-screen mode (expands to fill available space)
///
/// Design Reference: Figma node-id=58-3460
///
/// Usage:
/// ```dart
/// showGrabberBottomSheet(
///   context: context,
///   child: YourContentWidget(),
/// );
/// ```
class GrabberBottomSheet extends StatelessWidget {
  /// The content to display inside the bottom sheet.
  final Widget child;

  /// Optional padding for the content area.
  /// Defaults to horizontal 16px, top 0px, bottom 40px.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to show the grabber indicator at the top.
  /// Defaults to true.
  final bool showGrabber;

  /// Whether the sheet should expand to fill available space.
  /// When true, the sheet will be near full-screen (below status bar).
  /// Defaults to false (sheet sizes to content).
  final bool isFullScreen;

  const GrabberBottomSheet({
    super.key,
    required this.child,
    this.contentPadding,
    this.showGrabber = true,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Grabber indicator (optional)
        if (showGrabber) const _GrabberIndicator(),

        // Content area with padding
        if (isFullScreen)
          Expanded(
            child: Padding(
              padding: contentPadding ?? _defaultPadding,
              child: child,
            ),
          )
        else
          Padding(
            padding: contentPadding ?? _defaultPadding,
            child: child,
          ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        // No shadow as per design requirement
      ),
      child: content,
    );
  }

  EdgeInsetsGeometry get _defaultPadding => const EdgeInsets.only(
        left: AppSpacing.spaceMd,
        right: AppSpacing.spaceMd,
        top: 0,
        bottom: 40,
      );
}

/// iOS-style grabber/drag indicator widget.
///
/// Specifications from Figma:
/// - Width: 36px
/// - Height: 5px
/// - Color: rgba(60,60,67,0.3) - AppColors.grabber
/// - Border radius: 2.5px (fully rounded)
/// - Top padding: 8px
/// - Bottom margin: 24px (gap before content)
class _GrabberIndicator extends StatelessWidget {
  const _GrabberIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 24,
      ),
      child: Container(
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.grabber,
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet with iOS-style grabber indicator.
///
/// The sheet slides up from the bottom with a semi-transparent overlay.
/// Tapping the overlay or dragging down dismisses the sheet.
///
/// Returns the result from [Navigator.pop] if any.
///
/// Parameters:
/// - [showGrabber]: Whether to show the grabber indicator. Defaults to true.
/// - [isFullScreen]: Whether to expand to near full-screen. Defaults to false.
/// - [useSafeArea]: Whether to respect safe area (status bar). Defaults to true for full-screen.
///
/// Example:
/// ```dart
/// final result = await showGrabberBottomSheet<String>(
///   context: context,
///   child: MyOptionsWidget(),
/// );
/// if (result != null) {
///   // Handle selection
/// }
/// ```
Future<T?> showGrabberBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? contentPadding,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showGrabber = true,
  bool isFullScreen = false,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Use transparent background so our custom Container shows
    backgroundColor: Colors.transparent,
    // Overlay color from design system
    barrierColor: AppColors.overlayDark,
    // Allow dismissing by tapping outside
    isDismissible: isDismissible,
    // Allow drag to dismiss
    enableDrag: enableDrag,
    // For full-screen mode, allow the sheet to expand
    isScrollControlled: isFullScreen,
    // Use safe area for full-screen sheets
    useSafeArea: isFullScreen && useSafeArea,
    // Prevent system bottom sheet shape
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) {
      Widget sheet = GrabberBottomSheet(
        contentPadding: contentPadding,
        showGrabber: showGrabber,
        isFullScreen: isFullScreen,
        child: child,
      );

      // For full-screen, wrap in a sized container
      if (isFullScreen) {
        // Get screen height minus status bar
        final screenHeight = MediaQuery.of(context).size.height;
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final sheetHeight = screenHeight - statusBarHeight;

        return SizedBox(
          height: sheetHeight,
          child: sheet,
        );
      }

      return sheet;
    },
  );
}
