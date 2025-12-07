import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/sync_provider.dart';
import '../theme/constants/app_spacing.dart';

/// Banner showing offline queue sync status
///
/// Replaces the Budget banner at the top of expense list.
/// Shows sync status: pending, syncing, synced, or error.
/// Tappable to view queue details.
///
/// Display Logic:
/// - Idle (no pending items): No banner (returns SizedBox.shrink)
/// - Pending (1+ items queued): Blue accent, "X items pending sync"
/// - Syncing (processing queue): Blue with spinner, "Syncing..."
/// - Error (sync failed): Red accent, "Sync failed - Tap to retry"
/// - Synced (just completed): Green accent, "✓ Synced" (temporary, 2 seconds)
class SyncStatusBanner extends StatelessWidget {
  final SyncState syncState;
  final int pendingCount;
  final VoidCallback? onTap;

  const SyncStatusBanner({
    super.key,
    required this.syncState,
    required this.pendingCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final config = _getBannerConfig(syncState, isDarkMode);

    // Determine if banner should be visible
    final isVisible = !(syncState == SyncState.idle && pendingCount == 0);

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: isVisible
            ? _buildBanner(context, config)
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Build the actual banner widget
  Widget _buildBanner(BuildContext context, _BannerConfig config) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(syncState), // Key ensures animation on state change
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.spaceMd,
          AppSpacing.spaceXs,
          AppSpacing.spaceMd,
          AppSpacing.spaceXs,
        ),
        child: Material(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.spaceXs),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.spaceXs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.spaceSm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: config.accentColor,
                    width: 4,
                  ),
                ),
                borderRadius: BorderRadius.circular(AppSpacing.spaceXs),
              ),
              child: Row(
                children: [
                  // Icon (with animation for syncing state)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: syncState == SyncState.syncing
                        ? SizedBox(
                            key: const ValueKey('spinner'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(config.iconColor),
                            ),
                          )
                        : Icon(
                            key: ValueKey(config.icon),
                            config.icon,
                            size: 20,
                            color: config.iconColor,
                          ),
                  ),

                  const SizedBox(width: AppSpacing.spaceSm),

                  // Message text
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: config.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      child: Text(_getMessage()),
                    ),
                  ),

                  // Arrow indicator (if tappable)
                  if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.spaceSm),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 16,
                      color: config.iconColor.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get message text based on state
  String _getMessage() {
    switch (syncState) {
      case SyncState.pending:
        return pendingCount == 1
            ? '1 item pending sync'
            : '$pendingCount items pending sync';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.synced:
        return '✓ Synced successfully';
      case SyncState.error:
        return 'Sync failed - Tap to retry';
      case SyncState.idle:
        return '';
    }
  }

  /// Get banner visual configuration based on state
  _BannerConfig _getBannerConfig(SyncState state, bool isDarkMode) {
    switch (state) {
      case SyncState.pending:
        return _BannerConfig(
          accentColor: const Color(0xFF2196F3), // Blue
          backgroundColor: isDarkMode
              ? const Color(0xFF2196F3).withValues(alpha: 0.15)
              : const Color(0xFF2196F3).withValues(alpha: 0.08),
          iconColor: const Color(0xFF2196F3),
          textColor: isDarkMode
              ? const Color(0xFFE3F2FD)
              : const Color(0xFF0D47A1),
          icon: PhosphorIconsRegular.clockClockwise,
        );

      case SyncState.syncing:
        return _BannerConfig(
          accentColor: const Color(0xFF2196F3), // Blue
          backgroundColor: isDarkMode
              ? const Color(0xFF2196F3).withValues(alpha: 0.15)
              : const Color(0xFF2196F3).withValues(alpha: 0.08),
          iconColor: const Color(0xFF2196F3),
          textColor: isDarkMode
              ? const Color(0xFFE3F2FD)
              : const Color(0xFF0D47A1),
          icon: PhosphorIconsRegular.arrowsClockwise,
        );

      case SyncState.synced:
        return _BannerConfig(
          accentColor: const Color(0xFF4CAF50), // Green
          backgroundColor: isDarkMode
              ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
              : const Color(0xFF4CAF50).withValues(alpha: 0.08),
          iconColor: const Color(0xFF4CAF50),
          textColor: isDarkMode
              ? const Color(0xFFE8F5E9)
              : const Color(0xFF1B5E20),
          icon: PhosphorIconsRegular.checkCircle,
        );

      case SyncState.error:
        return _BannerConfig(
          accentColor: const Color(0xFFE76F51), // Coral red
          backgroundColor: isDarkMode
              ? const Color(0xFFE76F51).withValues(alpha: 0.15)
              : const Color(0xFFE76F51).withValues(alpha: 0.08),
          iconColor: const Color(0xFFE76F51),
          textColor: isDarkMode
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFB71C1C),
          icon: PhosphorIconsRegular.warningCircle,
        );

      case SyncState.idle:
        return _BannerConfig(
          accentColor: Colors.grey,
          backgroundColor: Colors.transparent,
          iconColor: Colors.grey,
          textColor: Colors.grey,
          icon: PhosphorIconsRegular.check,
        );
    }
  }
}

/// Internal configuration for banner styling
class _BannerConfig {
  final Color accentColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _BannerConfig({
    required this.accentColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
