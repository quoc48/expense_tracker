import 'package:flutter/material.dart';

/// Alert banner shown at the top of expense list when approaching or exceeding budget
///
/// **Purpose:**
/// Provides immediate visual feedback when user's spending approaches budget limits
///
/// **Display Logic:**
/// - < 70%: No banner (all good)
/// - 70-90%: Warning (yellow/orange) - "Approaching budget limit"
/// - 90-100%: Critical (red) - "Near budget limit"
/// - > 100%: Over (dark red) - "Budget exceeded"
///
/// **User Control:**
/// - Dismissible with close button (✕)
/// - Reappears on app restart (stateless dismissal)
/// - Banner hidden when dismissed OR percentage < 70%
class BudgetAlertBanner extends StatefulWidget {
  /// Budget usage percentage (0-100+)
  final double budgetPercentage;

  const BudgetAlertBanner({
    super.key,
    required this.budgetPercentage,
  });

  @override
  State<BudgetAlertBanner> createState() => _BudgetAlertBannerState();
}

class _BudgetAlertBannerState extends State<BudgetAlertBanner> {
  /// Local state tracking whether user dismissed the banner
  bool _isDismissed = false;
  
  /// Track which alert level was active when user dismissed the banner
  /// Used to reset dismissal when alert level changes
  String? _dismissedAtLevel;

  /// Determine if banner should be shown
  /// Shows when: percentage >= 70% AND not dismissed
  bool get _shouldShow => widget.budgetPercentage >= 70 && !_isDismissed;

  /// Get alert level based on budget percentage
  /// Returns: 'warning' (70-90%), 'critical' (90-100%), 'over' (>100%)
  String get _alertLevel {
    if (widget.budgetPercentage >= 100) {
      return 'over';
    } else if (widget.budgetPercentage >= 90) {
      return 'critical';
    } else {
      return 'warning';
    }
  }

  /// Get background color based on alert level
  Color get _backgroundColor {
    switch (_alertLevel) {
      case 'over':
        return Colors.red.shade50;
      case 'critical':
        return Colors.red.shade50;
      case 'warning':
      default:
        return Colors.orange.shade50;
    }
  }

  /// Get border color based on alert level
  Color get _borderColor {
    switch (_alertLevel) {
      case 'over':
        return Colors.red.shade700;
      case 'critical':
        return Colors.red;
      case 'warning':
      default:
        return Colors.orange;
    }
  }

  /// Get icon based on alert level
  IconData get _icon {
    switch (_alertLevel) {
      case 'over':
        return Icons.error;
      case 'critical':
      case 'warning':
      default:
        return Icons.warning;
    }
  }

  /// Get message text based on alert level
  String get _message {
    switch (_alertLevel) {
      case 'over':
        return 'Budget exceeded';
      case 'critical':
        return 'Near budget limit';
      case 'warning':
      default:
        return 'Approaching budget limit';
    }
  }

  /// Handle dismiss button tap
  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
      _dismissedAtLevel = _alertLevel; // Remember which level was dismissed
    });
  }
  
  @override
  void didUpdateWidget(BudgetAlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if alert level changed
    // If user dismissed at 'warning' and now we're at 'critical', show banner again
    if (_isDismissed && _dismissedAtLevel != null) {
      final currentLevel = _alertLevel;
      if (currentLevel != _dismissedAtLevel) {
        // Alert level changed - reset dismissal so banner reappears
        setState(() {
          _isDismissed = false;
          _dismissedAtLevel = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't render anything if banner shouldn't be shown
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border(
          left: BorderSide(
            color: _borderColor,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Alert icon
          Icon(
            _icon,
            color: _borderColor,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Message text
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: _borderColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),

          // Close button
          InkWell(
            onTap: _handleDismiss,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: _borderColor.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
