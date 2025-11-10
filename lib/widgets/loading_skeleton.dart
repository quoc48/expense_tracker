import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/minimalist/minimalist_colors.dart';

/// Loading skeleton widgets with shimmer effect for better UX
///
/// **Purpose:**
/// Instead of showing blank screens or spinners during data loading,
/// we show skeleton screens that match the shape of actual content.
/// This creates a more polished, professional feel.
///
/// **Flutter Package: shimmer**
/// The shimmer package provides the animated gradient effect that
/// simulates content loading. It's a Material Design pattern for
/// progressive loading states.
///
/// **Phase 2 Enhancement:**
/// Created dedicated skeleton components for each major UI element:
/// - Card skeletons for summary cards
/// - List item skeletons for expense lists
/// - Chart skeletons for analytics views

/// Base shimmer wrapper that provides the animated gradient
///
/// **How Shimmer Works:**
/// Creates an animated linear gradient that moves across the child widget,
/// creating the illusion of "loading" content. The gradient moves from
/// left to right continuously.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MinimalistColors.gray300,      // Inactive borders - background color
      highlightColor: MinimalistColors.gray100,  // Card background - shimmer highlight color
      period: const Duration(milliseconds: 1500),  // Animation speed
      child: child,
    );
  }
}

/// Individual skeleton element (box/line)
///
/// Used as building blocks for more complex skeletons.
/// Creates a simple colored rectangle with rounded corners.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,  // Will be colored by Shimmer gradient
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton for summary cards (Monthly Overview, Type Breakdown, etc.)
///
/// **Layout Structure:**
/// - Header line (icon + title simulation)
/// - Large box (hero number simulation)
/// - Medium boxes (secondary stats)
/// - Progress bar (if needed)
class SkeletonCard extends StatelessWidget {
  final bool isPrimary;

  const SkeletonCard({
    super.key,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isPrimary ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPrimary ? 16.0 : 14.0),
        child: SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (icon + title)
              Row(
                children: [
                  SkeletonBox(width: 20, height: 20, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(width: 8),
                  const SkeletonBox(width: 120, height: 16),
                ],
              ),
              const SizedBox(height: 16),

              // Hero number
              SkeletonBox(width: 150, height: isPrimary ? 32 : 24),
              const SizedBox(height: 8),

              // Label
              const SkeletonBox(width: 100, height: 14),
              const SizedBox(height: 16),

              // Progress bar (for primary cards)
              if (isPrimary) ...[
                const SkeletonBox(width: double.infinity, height: 8, borderRadius: BorderRadius.all(Radius.circular(4))),
                const SizedBox(height: 12),
              ],

              // Secondary stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(width: 60, height: 12),
                      const SizedBox(height: 4),
                      SkeletonBox(width: 80, height: 18, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(width: 60, height: 12),
                      const SizedBox(height: 4),
                      SkeletonBox(width: 80, height: 18, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for expense list items
///
/// **Layout Structure:**
/// - Left: Category icon circle
/// - Middle: Title + category lines
/// - Right: Amount box
class SkeletonExpenseItem extends StatelessWidget {
  const SkeletonExpenseItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SkeletonShimmer(
        child: Row(
          children: [
            // Category icon circle
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),  // Circular
            ),
            const SizedBox(width: 12),

            // Title + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 150, height: 16),
                  const SizedBox(height: 6),
                  SkeletonBox(
                    width: 100,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),

            // Amount
            const SizedBox(width: 12),
            const SkeletonBox(width: 80, height: 18),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for chart area
///
/// **Layout Structure:**
/// - Title bar
/// - Large chart area with grid pattern
class SkeletonChart extends StatelessWidget {
  final double height;

  const SkeletonChart({
    super.key,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const SkeletonBox(width: 120, height: 18),
            const SizedBox(height: 16),

            // Chart area
            SkeletonBox(
              width: double.infinity,
              height: height,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper: Show skeleton list while loading
///
/// **Usage:**
/// ```dart
/// if (isLoading) {
///   return SkeletonList(itemCount: 5);
/// } else {
///   return ListView.builder(...);
/// }
/// ```
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonExpenseItem(),
    );
  }
}

/// Helper: Show skeleton grid for analytics cards
///
/// **Usage:**
/// ```dart
/// if (isLoading) {
///   return SkeletonGrid(cardCount: 4);
/// } else {
///   return GridView.count(...);
/// }
/// ```
class SkeletonGrid extends StatelessWidget {
  final int cardCount;
  final int crossAxisCount;

  const SkeletonGrid({
    super.key,
    this.cardCount = 4,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: cardCount,
      itemBuilder: (context, index) => SkeletonCard(isPrimary: index == 0),
    );
  }
}
