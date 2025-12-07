import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';

/// A floating snackbar for undo actions, positioned above the nav bar.
///
/// **Design Reference**: Figma node-id=62-1695
///
/// **Specifications**:
/// - Background: Black (#000000)
/// - Border radius: 8px
/// - Padding: 16px horizontal, 12px vertical
/// - Shadow: 0px 16px 32px -8px rgba(12, 12, 13, 0.1)
/// - Width: Full width with 16px horizontal margin
/// - Position: 16px above nav bar (passed via bottomOffset)
/// - Text: 14px Regular, white
/// - Auto-dismiss after duration (default 3 seconds)
///
/// **Usage**:
/// ```dart
/// showUndoSnackbar(
///   context: context,
///   message: 'Expense removed.',
///   onUndo: () => restoreExpense(),
/// );
/// ```
class UndoSnackbar extends StatefulWidget {
  final String message;
  final VoidCallback? onUndo;
  final Duration duration;
  final double bottomOffset;

  const UndoSnackbar({
    super.key,
    required this.message,
    this.onUndo,
    this.duration = const Duration(seconds: 3),
    this.bottomOffset = 102, // 32px (nav bar bottom padding) + 54px (nav pill) + 16px gap
  });

  @override
  State<UndoSnackbar> createState() => _UndoSnackbarState();
}

class _UndoSnackbarState extends State<UndoSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted && !_dismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;

    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleUndo() {
    widget.onUndo?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    // No SafeArea - we use absolute positioning from screen bottom
    // The bottomOffset already accounts for the nav bar position
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: widget.bottomOffset,
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Builder(
                builder: (context) {
                  // Invert colors in dark mode so snackbar remains visible
                  final isDark = AppColors.isDarkMode(context);
                  final bgColor = isDark ? AppColors.white : AppColors.textBlack;
                  final textColor = isDark ? AppColors.textBlack : AppColors.white;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor, // Inverted for dark mode
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color.fromRGBO(255, 255, 255, 0.1)
                              : const Color.fromRGBO(12, 12, 13, 0.1),
                          offset: const Offset(0, 16),
                          blurRadius: 32,
                          spreadRadius: -8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Message text (left side, expands)
                        Expanded(
                          child: Text(
                            widget.message,
                            style: AppTypography.style(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: textColor, // Inverted for dark mode
                            ),
                          ),
                        ),

                        // Undo button (right side)
                        if (widget.onUndo != null)
                          GestureDetector(
                            onTap: _handleUndo,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                'Undo',
                                style: AppTypography.style(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: textColor, // Inverted for dark mode
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the undo snackbar as an overlay.
///
/// This creates a floating snackbar positioned above the nav bar that
/// auto-dismisses after [duration] or when the user taps Undo.
///
/// **Parameters**:
/// - [context]: Build context for showing the overlay
/// - [message]: The message to display (e.g., "Expense removed.")
/// - [onUndo]: Callback when user taps Undo
/// - [duration]: How long to show before auto-dismiss (default 3s)
/// - [bottomOffset]: Distance from bottom of screen (default 102px)
///
/// **Example**:
/// ```dart
/// showUndoSnackbar(
///   context: context,
///   message: 'Expense removed.',
///   onUndo: () async {
///     await provider.restoreExpense(deletedExpense, index);
///   },
/// );
/// ```
Future<void> showUndoSnackbar({
  required BuildContext context,
  required String message,
  VoidCallback? onUndo,
  Duration duration = const Duration(seconds: 3),
  double bottomOffset = 102,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent, // No overlay dimming
    useSafeArea: false,
    builder: (context) => UndoSnackbar(
      message: message,
      onUndo: onUndo,
      duration: duration,
      bottomOffset: bottomOffset,
    ),
  );
}
