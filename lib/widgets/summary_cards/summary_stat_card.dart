import 'package:flutter/material.dart';

/// Base card widget for summary statistics
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
  /// Primary cards get higher elevation and can be larger
  final bool isPrimary;

  const SummaryStatCard({
    super.key,
    required this.child,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Elevation creates shadow depth (how high the card "floats")
      // Primary cards float higher (more important) = bigger shadow
      elevation: isPrimary ? 4 : 2,

      // Shape defines the card's border and corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),  // Rounded corners (MD3 style)
      ),

      // Child content with consistent padding
      child: Padding(
        padding: const EdgeInsets.all(16.0),  // 16px padding on all sides
        child: child,  // The unique content each card provides
      ),
    );
  }
}
