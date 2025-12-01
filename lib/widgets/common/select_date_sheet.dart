import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import 'grabber_bottom_sheet.dart';
import 'tappable_icon.dart';

// ============================================================================
// DESIGN SYSTEM COMPONENT: SelectDateSheet
// ============================================================================
// A bottom sheet for selecting expense dates with a custom calendar.
//
// Design Reference: Figma node-id=58-1198
//
// Layout:
// - GrabberBottomSheet with 24px padding, 40px bottom (same as Type sheet)
// - Header: Gray title (left-aligned) + Close button (right)
// - Custom calendar with:
//   - Month navigation: Left/right carets + "Month, Year" label
//   - Weekday row: Mo Tu We Th Fri Sa Su (starts Monday)
//   - Day grid: 40px row height, 12px rounded corners
//   - Selected day: Black background, white text
//   - Out-of-month days: Gray3 text (#C7C7CC)
// ============================================================================

/// A bottom sheet for selecting expense dates.
///
/// **Design Reference**: Figma node-id=58-1198
///
/// **Specifications**:
/// - Padding: 24px sides, 24px top (8px + 16px spacer), 40px bottom
/// - Header: Title left-aligned, gray color, close button right
/// - Calendar: Custom styled TableCalendar
/// - Week starts Monday (not Sunday)
///
/// **Usage**:
/// ```dart
/// final date = await showSelectDateSheet(
///   context: context,
///   selectedDate: currentDate,
/// );
/// if (date != null) {
///   // Use selected date
/// }
/// ```
class SelectDateSheet extends StatefulWidget {
  /// Currently selected date.
  final DateTime? selectedDate;

  /// Callback when a date is selected.
  final ValueChanged<DateTime> onSelect;

  const SelectDateSheet({
    super.key,
    this.selectedDate,
    required this.onSelect,
  });

  @override
  State<SelectDateSheet> createState() => _SelectDateSheetState();
}

class _SelectDateSheetState extends State<SelectDateSheet> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    _focusedDay = widget.selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: Title (left) + Close Button (right)
        _buildHeader(context),

        // Gap between header and calendar (16px)
        const SizedBox(height: 16),

        // Custom Calendar
        _buildCalendar(),
      ],
    );
  }

  /// Build the header with gray title (left) and close button (right).
  ///
  /// **Design Reference**: Figma node-id=58-1199
  /// - Title: 16px Medium, gray (#8E8E93)
  /// - Close icon: 24px (no container wrapper)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title - left aligned, gray color
        Text(
          'Select Date',
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

  /// Build the custom styled calendar.
  ///
  /// **Design Reference**: Figma node-id=58-1545
  /// - Month header with navigation buttons
  /// - Weekday row: 12px SemiBold, black
  /// - Day cells: 40px height, 12px radius
  /// - Selected: black bg, white text, SemiBold
  /// - Out-of-month: gray3 (#C7C7CC)
  Widget _buildCalendar() {
    return TableCalendar(
      // Date boundaries
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,

      // Selected day configuration
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      // Week starts on Monday per Figma design
      startingDayOfWeek: StartingDayOfWeek.monday,

      // Hide default header (we'll use custom)
      headerVisible: false,

      // Day of week height
      daysOfWeekHeight: 40,

      // Row height
      rowHeight: 40,

      // Calendar format - always month view
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},

      // Callbacks
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        // Auto-select and close
        widget.onSelect(selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },

      // Custom builders for Figma-exact styling
      calendarBuilders: CalendarBuilders(
        // Weekday header builder (Mo, Tu, We, etc.)
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day).substring(0, 2);
          // Capitalize first letter, lowercase second
          final label =
              text[0].toUpperCase() + (text.length > 1 ? text[1].toLowerCase() : '');

          return Center(
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 12,
                fontWeight: FontWeight.w600, // SemiBold
                color: AppColors.textBlack,
                letterSpacing: 0.24,
              ),
            ),
          );
        },

        // Default day builder (current month days)
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: false,
            isOutside: false,
          );
        },

        // Selected day builder
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: true,
            isOutside: false,
          );
        },

        // Today builder (if not selected, style like default)
        todayBuilder: (context, day, focusedDay) {
          final isSelected = isSameDay(_selectedDay, day);
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: isSelected,
            isOutside: false,
          );
        },

        // Outside days (previous/next month)
        outsideBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: false,
            isOutside: true,
          );
        },
      ),

      // Custom header (month navigation)
      calendarStyle: const CalendarStyle(
        // Remove default styling - we handle everything in builders
        outsideDaysVisible: true,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
      ),

      // Days of week style (handled in builder, but need base config)
      daysOfWeekStyle: const DaysOfWeekStyle(
        dowTextFormatter: null, // We use custom builder
      ),
    );
  }

  /// Build a single day cell with consistent styling.
  ///
  /// **Design Reference**: Figma node-id=58-1564 (normal), 58-1568 (selected)
  /// - Cell: flexible width, 40px height
  /// - Normal text: 14px Regular, black, 0.28 letter-spacing
  /// - Selected: black background, white text, 14px SemiBold, 12px radius
  /// - Outside: 14px Regular, gray3 (#C7C7CC)
  Widget _buildDayCell({
    required String day,
    required bool isSelected,
    required bool isOutside,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.textBlack : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          day,
          style: AppTypography.style(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : isOutside
                    ? AppColors.gray3
                    : AppColors.textBlack,
            letterSpacing: isSelected ? 0 : 0.28,
          ),
        ),
      ),
    );
  }
}

/// Custom month header widget for the calendar.
///
/// **Design Reference**: Figma node-id=58-1546
/// - Left button: 32px circle, gray5 border, caret-left icon 18px
/// - Month label: 14px SemiBold, black, center
/// - Right button: 32px circle, gray5 border, caret-right icon 18px
class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const _CalendarHeader({
    required this.focusedDay,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat('MMMM, yyyy').format(focusedDay);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left navigation button
        _buildNavButton(
          icon: PhosphorIconsRegular.caretLeft,
          onTap: onLeftTap,
        ),

        // Month, Year label (centered, flexible width)
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                monthYear,
                style: AppTypography.style(
                  fontSize: 14,
                  fontWeight: FontWeight.w600, // SemiBold
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
        ),

        // Right navigation button
        _buildNavButton(
          icon: PhosphorIconsRegular.caretRight,
          onTap: onRightTap,
        ),
      ],
    );
  }

  /// Build a navigation button (left/right arrows) with tap state feedback.
  ///
  /// **Design Reference**: Figma node-id=58-1547
  /// - Size: 32x32px
  /// - Border: 1px gray5 (#E5E5EA)
  /// - Icon: 18px, black
  /// - Shape: Circle (99px radius)
  /// - Tap state: Light gray highlight
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _TappableNavButton(
      icon: icon,
      onTap: onTap,
    );
  }
}

/// A tappable navigation button for calendar month navigation.
///
/// Provides visual feedback on tap with a subtle highlight effect.
class _TappableNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TappableNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_TappableNavButton> createState() => _TappableNavButtonState();
}

class _TappableNavButtonState extends State<_TappableNavButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
          border: Border.all(
            color: AppColors.gray5,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 18,
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }
}

/// Shows the Select Date sheet and returns the selected date.
///
/// Returns null if the user closes without selecting.
///
/// **Design Reference**: Figma node-id=58-1198
/// - No grabber indicator
/// - 24px padding sides/top, 40px bottom (same as Type sheet)
/// - Header with gray title + close button
/// - Custom styled calendar
///
/// **Usage**:
/// ```dart
/// final date = await showSelectDateSheet(
///   context: context,
///   selectedDate: currentDate,
/// );
/// ```
Future<DateTime?> showSelectDateSheet({
  required BuildContext context,
  DateTime? selectedDate,
}) {
  return showGrabberBottomSheet<DateTime>(
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
    child: _SelectDateSheetWithHeader(
      selectedDate: selectedDate,
    ),
  );
}

/// Internal wrapper that includes the calendar header.
/// This is needed because TableCalendar doesn't allow custom header positioning.
class _SelectDateSheetWithHeader extends StatefulWidget {
  final DateTime? selectedDate;

  const _SelectDateSheetWithHeader({
    this.selectedDate,
  });

  @override
  State<_SelectDateSheetWithHeader> createState() =>
      _SelectDateSheetWithHeaderState();
}

class _SelectDateSheetWithHeaderState
    extends State<_SelectDateSheetWithHeader> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    _focusedDay = widget.selectedDate ?? DateTime.now();
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sheet Header: Title (left) + Close Button (right)
        _buildSheetHeader(context),

        // Gap between header and calendar section (16px)
        const SizedBox(height: 16),

        // Calendar section with 16px top padding per Figma (node-id=58-1545)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month navigation header
              _CalendarHeader(
                focusedDay: _focusedDay,
                onLeftTap: _goToPreviousMonth,
                onRightTap: _goToNextMonth,
              ),

              // Calendar body
              _buildCalendar(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the sheet header with gray title (left) and close button (right).
  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select Date',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.gray,
          ),
        ),
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

  /// Build the custom styled calendar.
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false, // We use custom header
      daysOfWeekHeight: 40,
      rowHeight: 40,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        // Auto-select and close
        Navigator.pop(context, selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day).substring(0, 2);
          final label =
              text[0].toUpperCase() + (text.length > 1 ? text[1].toLowerCase() : '');

          return Center(
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
                letterSpacing: 0.24,
              ),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: false,
            isOutside: false,
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: true,
            isOutside: false,
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final isSelected = isSameDay(_selectedDay, day);
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: isSelected,
            isOutside: false,
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day.day.toString(),
            isSelected: false,
            isOutside: true,
          );
        },
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        dowTextFormatter: null,
      ),
    );
  }

  Widget _buildDayCell({
    required String day,
    required bool isSelected,
    required bool isOutside,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.textBlack : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          day,
          style: AppTypography.style(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : isOutside
                    ? AppColors.gray3
                    : AppColors.textBlack,
            letterSpacing: isSelected ? 0 : 0.28,
          ),
        ),
      ),
    );
  }
}
