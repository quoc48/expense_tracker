import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SuccessOverlay
// ============================================================================
// A full-screen overlay with success message, shown after completing actions.
//
// Design Reference: Figma node-id=58-1964
//
// Layout:
// - Full-screen overlay: 80% black (rgba(0,0,0,0.8))
// - Centered popover: 200x200px, white, 34px radius
// - Content: Checkmark icon (40px) + message (16px Medium), 16px gap
// - Auto-dismisses after 3 seconds OR tap outside to close
// ============================================================================

/// A success overlay shown after completing an action.
///
/// **Design Reference**: Figma node-id=58-1964
///
/// **Specifications**:
/// - Overlay: 80% black background
/// - Popover: 200x200px, white, 34px border radius
/// - Icon: Checkmark bold, 40px, black
/// - Message: 16px Medium, black, centered
/// - Gap: 16px between icon and message
/// - Auto-close: 3 seconds OR tap outside
///
/// **Usage**:
/// ```dart
/// await showSuccessOverlay(
///   context: context,
///   message: 'Expense added.',
/// );
/// ```
class SuccessOverlay extends StatefulWidget {
  /// The success message to display.
  final String message;

  /// Duration to show the overlay before auto-dismissing.
  /// Defaults to 3 seconds.
  final Duration duration;

  const SuccessOverlay({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for fade + scale
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation
    _controller.forward();

    // Auto-dismiss after duration (3 seconds)
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;

    // Reverse animation before dismissing
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Background overlay (80% black per Figma)
            // Tap to dismiss immediately
            GestureDetector(
              onTap: _dismiss,
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),

            // Centered popover - inverted colors for visibility
            // Light mode: white bg, black content
            // Dark mode: black bg (#1A1A1A), white content
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Builder(
                  builder: (context) {
                    final isDark = AppColors.isDarkMode(context);
                    // Invert colors like snackbar/FAB for high contrast
                    final bgColor = isDark ? AppColors.neutral300Dark : AppColors.white;
                    final contentColor = isDark ? AppColors.white : AppColors.textBlack;

                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Checkmark icon (40px, bold)
                          Icon(
                            PhosphorIconsBold.check,
                            size: 40,
                            color: contentColor,
                          ),

                          // Gap (16px)
                          const SizedBox(height: 16),

                          // Success message
                          Text(
                            widget.message,
                            style: AppTypography.style(
                              fontSize: 16,
                              fontWeight: FontWeight.w500, // Medium
                              color: contentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a success overlay and returns after it's dismissed.
///
/// The overlay auto-closes after 3 seconds OR when user taps outside.
///
/// **Design Reference**: Figma node-id=58-1964
///
/// **Usage**:
/// ```dart
/// // Close form sheet first
/// Navigator.pop(context, expense);
///
/// // Then show success overlay on the underlying screen
/// await showSuccessOverlay(
///   context: context,
///   message: 'Expense added.',
/// );
/// ```
Future<void> showSuccessOverlay({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  return showDialog(
    context: context,
    barrierDismissible: false, // We handle dismiss via GestureDetector
    barrierColor: Colors.transparent, // We handle our own overlay color
    useSafeArea: false, // Cover full screen including safe areas (no bottom gap)
    builder: (context) => SuccessOverlay(
      message: message,
      duration: duration,
    ),
  );
}
