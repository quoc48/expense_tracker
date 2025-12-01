import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import 'tappable_icon.dart';

/// A header widget for bottom sheets with centered title and close button.
///
/// **Design Reference**: Figma node-id=56-2926
///
/// **Specifications**:
/// - Height: 24px
/// - Title: 16px SemiBold, centered, black
/// - Close button: 24x24, positioned at right edge
/// - Close icon: X mark
///
/// **Usage**:
/// ```dart
/// SheetHeader(
///   title: 'Add Expense',
///   onClose: () => Navigator.pop(context),
/// )
/// ```
class SheetHeader extends StatelessWidget {
  /// The title text displayed in the center.
  final String title;

  /// Callback when the close button is tapped.
  final VoidCallback onClose;

  const SheetHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          // Centered title
          Center(
            child: Text(
              title,
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
          ),

          // Close button at right with tap state feedback
          Positioned(
            right: 0,
            top: 0,
            child: TappableIcon(
              icon: PhosphorIconsRegular.x,
              onTap: onClose,
              iconSize: 24,
              iconColor: AppColors.textBlack,
              containerSize: 24,
              isCircular: true,
            ),
          ),
        ],
      ),
    );
  }
}
