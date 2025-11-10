import 'package:flutter/material.dart';
import '../../theme/constants/app_spacing.dart';

/// Base card widget for summary statistics with enhanced visual styling (Phase 2)
///
/// **Phase 2 Visual Enhancements:**
/// - Gradient backgrounds for primary cards (subtle, professional)
/// - Enhanced shadows with multiple layers for better depth
/// - Smooth entry animations (fade + scale)
/// - Increased border radius (16px) for modern look
/// - Improved padding hierarchy (16px primary, 14px regular)
///
/// **Flutter Concept: Widget Composition**
/// Instead of repeating card styling in 5 places, we create one reusable
/// base card that handles all the common styling (elevation, padding, shape).
/// Other cards just provide their unique content as a child.
///
/// **Material Design 3 Pattern**
/// Cards are surfaces that group related content. This base card follows MD3
/// guidelines with proper elevation, rounded corners, and padding.
///
/// **DRY Principle** (Don't Repeat Yourself)
/// Common styling in ONE place = easier to maintain and update.
class SummaryStatCard extends StatelessWidget {
  /// The content to display inside the card
  final Widget child;

  /// Whether this is a primary card (more prominent styling)
  /// Primary cards get:
  /// - Subtle gradient background (light theme accent)
  /// - Higher elevation (deeper shadow)
  /// - Slightly larger padding
  final bool isPrimary;

  /// Whether to animate the card entry
  /// Adds a subtle fade + scale animation when first displayed
  final bool animate;

  const SummaryStatCard({
    super.key,
    required this.child,
    this.isPrimary = false,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Card(
      // Match Expenses page card margins
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,  // 16px horizontal
        vertical: AppSpacing.spaceXs,     // 8px vertical
      ),
      
      // Elevation creates shadow depth (how high the card "floats")
      // Unified elevation: 6dp for all cards (consistent depth)
      elevation: 6,
      
      // Enhanced shadow for more depth perception
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),

      // Shape defines the card's border and corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),  // Larger radius = more modern (was 12)
      ),

      // Child content with consistent padding
      child: Padding(
        padding: EdgeInsets.all(isPrimary ? 16.0 : 14.0),  // More padding for primary cards
        child: child,
      ),
    );

    // Wrap with animation if requested
    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),  // Subtle scale from 95% to 100%
              child: child,
            ),
          );
        },
        child: card,
      );
    }

    return card;
  }
}
