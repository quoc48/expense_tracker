import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../utils/currency_formatter.dart';

/// CategoryCard displays a category with spending amount in a bar-chart style.
///
/// **Design Reference**: Figma node-id=5-1798, node-id=5-995
///
/// **Visual Design**:
/// - Rounded rectangle card with two-color fill system
/// - Solid color (100% opacity) from bottom = spent percentage
/// - Light color (20% opacity) fills the remaining top portion
/// - Centered sub-container with: icon (24px) + 8px gap + amount text
///
/// **Fill Logic** (Bar Chart Style):
/// - Zero-spend: Always 4px baseline fill
/// - With spending: 4px baseline + proportional fill based on percentage
/// - All cards share 100% of total spending (sum of fillPercentage = 1.0)
/// - Available fill space = cardHeight - 4px (baseline is always present)
///
/// **Tooltip Behavior**:
/// - On tap, shows a tooltip above the card with "CategoryName: X% of spending"
/// - Auto-dismisses after 2 seconds
/// - Uses OverlayEntry for proper layering above other widgets
///
/// **Typography** (from Figma):
/// - Font: Momo Trust Sans, 14px, weight 500
/// - Color: #000 (Black), center aligned
/// - Font features: 'liga' off, 'clig' off
class CategoryCard extends StatefulWidget {
  /// The category name (Vietnamese, e.g., "Thực phẩm")
  final String categoryName;

  /// The spending amount for this category
  final double amount;

  /// The fill percentage (0.0 to 1.0) representing this category's share of total spending
  /// Calculated as: categorySpent / totalSpent (all percentages sum to 1.0)
  final double fillPercentage;

  /// Baseline fill height in pixels (always present, even for zero-spend)
  static const double _baselineFillHeight = 4.0;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.fillPercentage,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  /// Key to get the card's position for tooltip placement
  final GlobalKey _cardKey = GlobalKey();

  /// Current overlay entry for the tooltip
  OverlayEntry? _overlayEntry;

  /// Global reference to the currently active tooltip state
  /// Ensures only one tooltip is visible at a time across all CategoryCards
  static _CategoryCardState? _activeTooltipState;

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  /// Shows the tooltip above the card
  void _showTooltip() {
    // Dismiss any existing tooltip from other cards first
    if (_activeTooltipState != null && _activeTooltipState != this) {
      _activeTooltipState!._removeTooltip();
    }

    // Remove our own tooltip if already showing
    _removeTooltip();

    // Get the card's position on screen
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final cardPosition = renderBox.localToGlobal(Offset.zero);
    final cardSize = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate percentage for display (round to nearest integer)
    final percentDisplay = (widget.fillPercentage * 100).round();

    // Card center X position
    final cardCenterX = cardPosition.dx + (cardSize.width / 2);

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _TooltipPositioner(
          cardCenterX: cardCenterX,
          cardTop: cardPosition.dy,
          screenWidth: screenWidth,
          categoryName: widget.categoryName,
          percentage: percentDisplay,
        );
      },
    );

    // Mark this as the active tooltip
    _activeTooltipState = this;

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (_activeTooltipState == this) {
        _removeTooltip();
      }
    });
  }

  /// Removes the tooltip if it exists
  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_activeTooltipState == this) {
      _activeTooltipState = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the category color from our color system
    final categoryColor = AppColors.getCategoryColor(widget.categoryName);

    return GestureDetector(
      key: _cardKey,
      onTap: _showTooltip,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate fill height:
          // - Baseline: 4px (always present for all cards)
          // - Additional: proportional to fillPercentage of remaining space
          //
          // Formula: fillHeight = 4px + (fillPercentage × (cardHeight - 4px))
          // This ensures zero-spend cards show exactly 4px
          // and cards with spending show 4px + their proportional share
          final cardHeight = constraints.maxHeight;
          final availableSpace = cardHeight - CategoryCard._baselineFillHeight;
          final proportionalFill = availableSpace * widget.fillPercentage.clamp(0.0, 1.0);
          final fillHeight = CategoryCard._baselineFillHeight + proportionalFill;

          return Container(
            decoration: BoxDecoration(
              // 20% opacity background fills the entire card (unfilled portion)
              color: AppColors.getCategoryBackground(categoryColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Solid color fill from bottom (spent portion)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: fillHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: categoryColor,
                        // Only round bottom corners since fill starts from bottom
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Centered content: icon + amount in a sub-container
                  Center(
                    child: Builder(
                      builder: (context) {
                        // Adaptive text color for dark mode
                        final textColor = AppColors.getTextPrimary(context);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Filled icon - 24px as per Figma (adaptive for dark mode)
                            Icon(
                              MinimalistIcons.getCategoryIconFill(widget.categoryName),
                              size: 24,
                              color: textColor,
                            ),

                            // 8px spacing between icon and text
                            const SizedBox(height: 8),

                            // Amount text - Momo Trust Sans, 14px, w500 (adaptive for dark mode)
                            Text(
                              _formatAmount(widget.amount),
                              style: TextStyle(
                                fontFamily: 'MomoTrustSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                fontFeatures: const [
                                  FontFeature.disable('liga'),
                                  FontFeature.disable('clig'),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Format amount for display
  /// Zero shows as "0", otherwise use compact format
  String _formatAmount(double amount) {
    if (amount == 0) return '0';
    return CurrencyFormatter.formatCompact(amount);
  }
}

/// Positions the tooltip with smart edge detection.
///
/// **Positioning Logic**:
/// - Centers tooltip above the card by default
/// - If tooltip would overflow left edge: align left, arrow points to card center
/// - If tooltip would overflow right edge: align right, arrow points to card center
/// - Arrow always points to the card center regardless of tooltip position
class _TooltipPositioner extends StatefulWidget {
  final double cardCenterX;
  final double cardTop;
  final double screenWidth;
  final String categoryName;
  final int percentage;

  const _TooltipPositioner({
    required this.cardCenterX,
    required this.cardTop,
    required this.screenWidth,
    required this.categoryName,
    required this.percentage,
  });

  @override
  State<_TooltipPositioner> createState() => _TooltipPositionerState();
}

class _TooltipPositionerState extends State<_TooltipPositioner> {
  final GlobalKey _tooltipKey = GlobalKey();
  double? _tooltipWidth;

  @override
  void initState() {
    super.initState();
    // Measure tooltip width after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _tooltipKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        setState(() {
          _tooltipWidth = renderBox.size.width;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tooltipColor = AppColors.isDarkMode(context)
        ? const Color(0xFF2C2C2C)
        : const Color(0xFF1C1C1E);

    const edgePadding = 12.0;
    const arrowSize = Size(12, 6);
    const tooltipHeight = 40.0; // Approximate height for positioning

    // Calculate tooltip position
    double tooltipLeft;
    double arrowOffsetFromLeft;

    if (_tooltipWidth != null) {
      // We have measured width - calculate proper position
      final idealLeft = widget.cardCenterX - (_tooltipWidth! / 2);
      final idealRight = idealLeft + _tooltipWidth!;

      if (idealLeft < edgePadding) {
        // Would overflow left - align to left edge
        tooltipLeft = edgePadding;
        arrowOffsetFromLeft = widget.cardCenterX - edgePadding - (arrowSize.width / 2);
      } else if (idealRight > widget.screenWidth - edgePadding) {
        // Would overflow right - align to right edge
        tooltipLeft = widget.screenWidth - edgePadding - _tooltipWidth!;
        arrowOffsetFromLeft = widget.cardCenterX - tooltipLeft - (arrowSize.width / 2);
      } else {
        // Centered - no overflow
        tooltipLeft = idealLeft;
        arrowOffsetFromLeft = (_tooltipWidth! / 2) - (arrowSize.width / 2);
      }
    } else {
      // First render - use approximate positioning (will update after measure)
      tooltipLeft = widget.cardCenterX - 80; // Approximate half-width
      arrowOffsetFromLeft = 80 - (arrowSize.width / 2);
    }

    // Clamp arrow position to stay within tooltip bounds
    if (_tooltipWidth != null) {
      arrowOffsetFromLeft = arrowOffsetFromLeft.clamp(8.0, _tooltipWidth! - arrowSize.width - 8);
    }

    return Positioned(
      left: tooltipLeft,
      top: widget.cardTop - tooltipHeight - arrowSize.height - 4,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tooltip container
            Container(
              key: _tooltipKey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tooltipColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${widget.categoryName}: ${widget.percentage}% of spending',
                style: const TextStyle(
                  fontFamily: 'MomoTrustSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Arrow pointing down - positioned to point at card center
            Padding(
              padding: EdgeInsets.only(left: arrowOffsetFromLeft.clamp(0, double.infinity)),
              child: CustomPaint(
                size: arrowSize,
                painter: _TrianglePainter(color: tooltipColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a small triangle for the tooltip arrow
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A grid of CategoryCards for displaying category spending overview.
///
/// **Design Reference**: Figma node-id=5-939 (Category section)
///
/// **Layout**: 4 columns with consistent spacing
/// **Display**: Always shows all 14 categories, sorted by spending (descending)
///
/// **Fill Logic** (Bar Chart Style):
/// - All 14 categories together represent 100% of total spending
/// - Each card's fill = (categorySpent / totalSpent) × 100%
/// - This means all fill percentages sum to 100%
/// - Categories with 0 spent show 4px minimum fill
///
/// **Interaction**: Each card shows a tooltip on tap with percentage info
class CategoryCardGrid extends StatelessWidget {
  /// Map of category names to their spending amounts
  final Map<String, double> categorySpending;

  /// Monthly budget (kept for potential future use, not used in fill calculation)
  final double monthlyBudget;

  /// All category names in display order (matches Supabase)
  ///
  /// **IMPORTANT**: Must match EXACTLY with Supabase category names!
  /// Supabase is the source of truth for category spellings.
  static const List<String> _allCategories = [
    'Thực phẩm',      // Food
    'Tiền nhà',       // Housing
    'Biểu gia đình',  // Family (Biểu not Biếu!)
    'Cà phê',         // Coffee
    'Du lịch',        // Travel
    'Giáo dục',       // Education
    'Giải trí',       // Entertainment
    'Hoá đơn',        // Bills
    'Quà vật',        // Gifts
    'Sức khỏe',       // Health (khỏe not khoẻ!)
    'Thời trang',     // Fashion
    'Tạp hoá',        // Groceries
    'TẾT',            // Tet Holiday (uppercase TẾT!)
    'Đi lại',         // Transportation
  ];

  const CategoryCardGrid({
    super.key,
    required this.categorySpending,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    // Create list of all categories with their spending
    // Categories not in spending map default to 0
    final allCategoryData = _allCategories.map((name) {
      return MapEntry(name, categorySpending[name] ?? 0.0);
    }).toList();

    // Calculate total spending across all categories
    // This is the denominator for fill percentage calculation
    final totalSpent = allCategoryData.fold<double>(
      0.0,
      (sum, entry) => sum + entry.value,
    );

    // Sort by amount descending (highest spending first)
    // Categories with 0 spending will be at the end
    allCategoryData.sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      // Prevent GridView from scrolling independently
      // Parent (SingleChildScrollView or CustomScrollView) handles scrolling
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Slightly taller than wide for icon + text balance
        childAspectRatio: 0.85,
      ),
      itemCount: allCategoryData.length,
      itemBuilder: (context, index) {
        final entry = allCategoryData[index];
        final categoryName = entry.key;
        final amount = entry.value;

        // Calculate fill percentage: categorySpent / totalSpent
        // This creates a bar chart where all fills sum to 100%
        // If totalSpent is 0, all cards show 0% fill (handled by CategoryCard's 4px minimum)
        final fillPercent = totalSpent > 0
            ? (amount / totalSpent)
            : 0.0;

        return CategoryCard(
          categoryName: categoryName,
          amount: amount,
          fillPercentage: fillPercent,
        );
      },
    );
  }
}
