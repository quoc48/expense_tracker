import 'package:flutter/material.dart';
import '../theme/typography/app_typography.dart';

/// Alert banner shown at the top of expense list when approaching or exceeding budget
/// **Phase 2 Enhanced** with gradients and animations
///
/// **Purpose:**
/// Provides immediate visual feedback when user's spending approaches budget limits
///
/// **Phase 2 Visual Enhancements:**
/// - Gradient backgrounds (warning: orange→yellow, critical/over: red→orange)
/// - Pulse animation when budget exceeded (continuous subtle scale effect)
/// - Enhanced shadows for better depth perception
/// - Softer border radius (8px) for modern aesthetic
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

  /// Get gradient background based on alert level
  /// Phase 2: Using gradients instead of flat colors for more visual interest
  LinearGradient get _backgroundGradient {
    switch (_alertLevel) {
      case 'over':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade100,
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        );
      case 'critical':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade100,
            Colors.red.shade50,
          ],
        );
      case 'warning':
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade50,
            Colors.yellow.shade50,
          ],
        );
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

    // Pulse animation for critical alerts (over budget)
    final shouldPulse = _alertLevel == 'over';
    
    final banner = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: _backgroundGradient,  // Gradient background instead of flat color
        border: Border(
          left: BorderSide(
            color: _borderColor,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),  // Softer corners (was 4)
        // Add subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: _borderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              style: ComponentTextStyles.alertMessage(Theme.of(context).textTheme).copyWith(
                color: _borderColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
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

    // Wrap with pulse animation for "over budget" state
    if (shouldPulse) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          // Pulse effect: scale slightly (subtle breathing effect)
          final scale = 1.0 + (0.02 * (0.5 + 0.5 * (1.0 - value.clamp(0.0, 1.0))));
          
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        onEnd: () {
          // Restart animation for continuous pulse
          if (mounted) {
            setState(() {});
          }
        },
        child: banner,
      );
    }

    return banner;
  }
}
