import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../common/grabber_bottom_sheet.dart';
import '../common/tappable_icon.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectMonthSheet
// ============================================================================
// A bottom sheet for selecting a month from a calendar grid.
//
// Design Reference: Figma node-id=73-2603
//
// Layout:
// - GrabberBottomSheet with 24px padding (top 8px + 16px spacer), 40px bottom
// - Header: "Select Month" (gray, left-aligned) + Close button (right)
// - Year navigation: Left/right caret buttons (32px circular) + Year (center)
// - Month grid: 4 columns x 3 rows, 40px height per row, 8px gap
// - Selected month: Black background, white text, 12px rounded corners
// - Normal month: 14px Regular, black text
//
// Constraints:
// - Cannot select future months
// - First date: January 2020
// ============================================================================

/// Month abbreviations for the grid
const _monthLabels = [
  'Jan', 'Feb', 'Mar', 'Apr',
  'May', 'Jun', 'Jul', 'Aug',
  'Sep', 'Oct', 'Nov', 'Dec',
];

/// A bottom sheet for selecting a month with year navigation.
///
/// **Design Reference**: Figma node-id=73-2603
///
/// **Specifications**:
/// - Padding: 24px sides, 24px top (8px + 16px spacer), 40px bottom
/// - Header: "Select Month" gray + close button
/// - Year navigation: Circular buttons (32px) with gray border + year label
/// - Month grid: 4x3, 8px gap, 40px row height
/// - Selected state: Black background, white text, 12px rounded
///
/// **Usage**:
/// ```dart
/// final selectedMonth = await showSelectMonthSheet(
///   context: context,
///   selectedMonth: DateTime(2025, 1, 1),
/// );
/// ```
class SelectMonthSheet extends StatefulWidget {
  /// Currently selected month (for showing selected state).
  final DateTime selectedMonth;

  /// Callback when a month is selected.
  final ValueChanged<DateTime> onSelect;

  /// The earliest selectable month.
  final DateTime firstDate;

  /// The latest selectable month.
  final DateTime lastDate;

  const SelectMonthSheet({
    super.key,
    required this.selectedMonth,
    required this.onSelect,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<SelectMonthSheet> createState() => _SelectMonthSheetState();
}

class _SelectMonthSheetState extends State<SelectMonthSheet> {
  /// Currently displayed year
  late int _displayYear;

  @override
  void initState() {
    super.initState();
    _displayYear = widget.selectedMonth.year;
  }

  /// Whether the previous year button should be enabled
  bool get _canGoToPreviousYear => _displayYear > widget.firstDate.year;

  /// Whether the next year button should be enabled
  bool get _canGoToNextYear => _displayYear < widget.lastDate.year;

  /// Navigate to previous year
  void _goToPreviousYear() {
    if (_canGoToPreviousYear) {
      setState(() {
        _displayYear--;
      });
    }
  }

  /// Navigate to next year
  void _goToNextYear() {
    if (_canGoToNextYear) {
      setState(() {
        _displayYear++;
      });
    }
  }

  /// Check if a month can be selected (not in the future, not before firstDate)
  bool _canSelectMonth(int month) {
    final monthDate = DateTime(_displayYear, month, 1);
    return !monthDate.isAfter(widget.lastDate) &&
        !monthDate.isBefore(widget.firstDate);
  }

  /// Check if this month is currently selected
  bool _isSelectedMonth(int month) {
    return _displayYear == widget.selectedMonth.year &&
        month == widget.selectedMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: "Select Month" (left) + Close Button (right)
        _buildHeader(context),

        const SizedBox(height: 24),

        // Year Navigation Row
        _buildYearNavigation(),

        const SizedBox(height: 16),

        // Month Grid (4x3)
        _buildMonthGrid(),
      ],
    );
  }

  /// Build the header with gray title (left) and close button (right).
  ///
  /// **Design Reference**: Figma node-id=73-2603
  /// - Title: 16px Medium, gray (#8E8E93)
  /// - Close icon: 24px
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title - left aligned, adaptive gray color for dark mode
        Text(
          'Select Month',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextSecondary(context),
          ),
        ),

        // Close button with tap state feedback (adaptive for dark mode)
        TappableIcon(
          icon: PhosphorIconsRegular.x,
          onTap: () => Navigator.pop(context),
          iconSize: 24,
          iconColor: AppColors.getTextPrimary(context),
          containerSize: 28,
          isCircular: true,
        ),
      ],
    );
  }

  /// Build year navigation with left/right buttons and year display.
  ///
  /// **Design Reference**: Figma node-id=73-2603
  /// - Full width row with buttons at edges
  /// - Buttons: 32px circular, gray border (#C7C7CC), caret icons 20px
  /// - Year: 14px SemiBold, black, centered
  Widget _buildYearNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left arrow button
        _buildNavigationButton(
          context: context,
          icon: PhosphorIconsRegular.caretLeft,
          onTap: _canGoToPreviousYear ? _goToPreviousYear : null,
          isEnabled: _canGoToPreviousYear,
        ),

        // Year label (centered via spaceBetween) - adaptive for dark mode
        Text(
          _displayYear.toString(),
          style: AppTypography.style(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),

        // Right arrow button
        _buildNavigationButton(
          context: context,
          icon: PhosphorIconsRegular.caretRight,
          onTap: _canGoToNextYear ? _goToNextYear : null,
          isEnabled: _canGoToNextYear,
        ),
      ],
    );
  }

  /// Build a circular navigation button with border.
  ///
  /// **Design Reference**: Figma node-id=73-2603
  /// - Size: 32px circular
  /// - Border: 1px gray (#C7C7CC)
  /// - Icon: 20px, black when enabled, gray when disabled
  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    // Adaptive colors for dark mode
    final borderColor = AppColors.getNeutral400(context);
    final enabledIconColor = AppColors.getTextPrimary(context);
    final disabledIconColor = AppColors.getTextSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? enabledIconColor : disabledIconColor,
          ),
        ),
      ),
    );
  }

  /// Build the month grid (4 columns x 3 rows).
  ///
  /// **Design Reference**: Figma node-id=73-2603
  /// - Grid: 4 columns, 3 rows
  /// - Gap: 8px horizontal and vertical
  /// - Row height: 40px
  /// - Selected: Black background, white text, 12px rounded
  /// - Normal: 14px Regular, black text
  /// - Disabled: 14px Regular, gray text
  Widget _buildMonthGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Jan, Feb, Mar, Apr
        _buildMonthRow([1, 2, 3, 4]),
        const SizedBox(height: 8),
        // Row 2: May, Jun, Jul, Aug
        _buildMonthRow([5, 6, 7, 8]),
        const SizedBox(height: 8),
        // Row 3: Sep, Oct, Nov, Dec
        _buildMonthRow([9, 10, 11, 12]),
      ],
    );
  }

  /// Build a row of month cells.
  Widget _buildMonthRow(List<int> months) {
    return Row(
      children: months.map((month) {
        final isSelected = _isSelectedMonth(month);
        final canSelect = _canSelectMonth(month);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: month == months.first ? 0 : 4,
              right: month == months.last ? 0 : 4,
            ),
            child: _buildMonthCell(
              label: _monthLabels[month - 1],
              isSelected: isSelected,
              isEnabled: canSelect,
              onTap: canSelect
                  ? () => widget.onSelect(DateTime(_displayYear, month, 1))
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build a single month cell.
  ///
  /// **Design Reference**: Figma node-id=73-2603
  /// - Height: 40px
  /// - Selected: Black background (#000), white text, 12px rounded corners
  ///   (inverts in dark mode: white bg, black text)
  /// - Normal: Transparent background, black text (#000)
  /// - Disabled: Transparent background, gray text (#8E8E93)
  Widget _buildMonthCell({
    required String label,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        // Determine colors based on state - adaptive for dark mode
        // Selected state inverts like buttons: black/white → white/black in dark mode
        final isDark = AppColors.isDarkMode(context);
        final backgroundColor = isSelected
            ? (isDark ? AppColors.white : AppColors.black)
            : Colors.transparent;
        final textColor = isSelected
            ? (isDark ? AppColors.black : AppColors.white) // Inverted for selected
            : (isEnabled
                ? AppColors.getTextPrimary(context) // Adaptive text
                : AppColors.getTextSecondary(context)); // Dimmed for disabled

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows the Select Month sheet and returns the selected month.
///
/// Returns null if the user closes without selecting.
///
/// **Design Reference**: Figma node-id=73-2603
/// - No grabber indicator
/// - 24px padding sides/top, 40px bottom
/// - Header with gray title + close button
/// - Year navigation + month grid
///
/// **Parameters**:
/// - [selectedMonth]: Currently selected month to show as selected
/// - [firstDate]: Earliest selectable date (defaults to Jan 2020)
/// - [lastDate]: Latest selectable date (defaults to current month)
///
/// **Usage**:
/// ```dart
/// final month = await showSelectMonthSheet(
///   context: context,
///   selectedMonth: currentMonth,
/// );
/// if (month != null) {
///   setState(() => _selectedMonth = month);
/// }
/// ```
Future<DateTime?> showSelectMonthSheet({
  required BuildContext context,
  required DateTime selectedMonth,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  final effectiveFirstDate = firstDate ?? DateTime(2020, 1, 1);
  final effectiveLastDate = lastDate ?? DateTime(now.year, now.month, 1);

  return showGrabberBottomSheet<DateTime>(
    context: context,
    showGrabber: false, // No grabber - using custom header with close button
    isDismissible: true,
    enableDrag: true,
    // Custom padding: 24px sides, 8px top (+ 16px spacer = 24px), 40px bottom
    contentPadding: const EdgeInsets.only(
      left: 24,
      right: 24,
      top: 8,
      bottom: 40,
    ),
    child: SelectMonthSheet(
      selectedMonth: selectedMonth,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      onSelect: (month) => Navigator.pop(context, month),
    ),
  );
}
