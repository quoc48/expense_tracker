import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/sync_provider.dart';
import '../models/scanning/queued_receipt.dart';

/// Bottom sheet showing detailed view of sync queue
///
/// Displays pending and failed items with ability to:
/// - View all queued receipts
/// - Retry failed syncs
/// - Clear failed items
/// - See error details
class SyncQueueDetailsSheet extends StatelessWidget {
  const SyncQueueDetailsSheet({super.key});

  /// Show the sync queue details sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const SyncQueueDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: _buildContent(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build sheet header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.queue,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sync Queue',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.x),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  /// Build sheet content with tabs for pending/failed items
  Widget _buildContent(BuildContext context, ScrollController scrollController) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        final pendingCount = syncProvider.pendingCount;
        final failedCount = syncProvider.failedCount;
        final isOnline = syncProvider.isOnline;

        // Show empty state if no items
        if (pendingCount == 0 && failedCount == 0) {
          return _buildEmptyState(context);
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Tab bar
              TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pending'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed'),
                        if (failedCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$failedCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPendingTab(context, scrollController, syncProvider),
                    _buildFailedTab(context, scrollController, syncProvider),
                  ],
                ),
              ),

              // Bottom actions
              if (!isOnline)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.wifiSlash,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Device is offline. Items will sync when online.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build pending tab content
  Widget _buildPendingTab(
    BuildContext context,
    ScrollController scrollController,
    SyncProvider syncProvider,
  ) {
    // Get pending receipts from queue service
    final pendingReceipts = syncProvider.pendingCount > 0
        ? [] // TODO: Expose method to get actual receipts from QueueService
        : <QueuedReceipt>[];

    if (pendingReceipts.isEmpty) {
      return _buildEmptyTabState(
        context,
        icon: PhosphorIconsRegular.checkCircle,
        title: 'No pending items',
        subtitle: 'All items have been synced',
        color: Colors.green,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: pendingReceipts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final receipt = pendingReceipts[index];
        return _buildReceiptCard(context, receipt, isPending: true);
      },
    );
  }

  /// Build failed tab content
  Widget _buildFailedTab(
    BuildContext context,
    ScrollController scrollController,
    SyncProvider syncProvider,
  ) {
    // Get failed receipts from queue service
    final failedReceipts = syncProvider.failedCount > 0
        ? [] // TODO: Expose method to get actual receipts from QueueService
        : <QueuedReceipt>[];

    if (failedReceipts.isEmpty) {
      return _buildEmptyTabState(
        context,
        icon: PhosphorIconsRegular.checkCircle,
        title: 'No failed items',
        subtitle: 'All sync attempts successful',
        color: Colors.green,
      );
    }

    return Column(
      children: [
        // Retry all button
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: syncProvider.isOnline
                ? () => _retryAll(context, syncProvider)
                : null,
            icon: const Icon(PhosphorIconsRegular.arrowClockwise),
            label: const Text('Retry All Failed'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),

        // Failed receipts list
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: failedReceipts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final receipt = failedReceipts[index];
              return _buildReceiptCard(context, receipt, isPending: false);
            },
          ),
        ),
      ],
    );
  }

  /// Build receipt card
  Widget _buildReceiptCard(
    BuildContext context,
    QueuedReceipt receipt, {
    required bool isPending,
  }) {
    final theme = Theme.of(context);
    final statusColor = isPending ? theme.colorScheme.primary : Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(
                  isPending
                      ? PhosphorIconsRegular.clock
                      : PhosphorIconsRegular.warning,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${receipt.itemCount} item${receipt.itemCount > 1 ? 's' : ''}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatAmount(receipt.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Queued date
            Row(
              children: [
                Icon(
                  PhosphorIconsRegular.calendar,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Queued ${_formatRelativeTime(receipt.queuedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Error message for failed items
            if (!isPending && receipt.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.warning,
                      size: 14,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        receipt.errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Retry ${receipt.retryCount}/5',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build empty state when no items in queue
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.checkCircle,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'All synced!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No items waiting to sync',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for individual tabs
  Widget _buildEmptyTabState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retry all failed items
  Future<void> _retryAll(BuildContext context, SyncProvider syncProvider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await syncProvider.retryFailed();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success
                      ? PhosphorIconsRegular.checkCircle
                      : PhosphorIconsRegular.warning,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(success ? 'Retry successful' : 'Retry failed'),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format amount as Vietnamese currency
  String _formatAmount(double amount) {
    final amountStr = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    var count = 0;

    for (var i = amountStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amountStr[i]);
      count++;
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  /// Format relative time (e.g., "2 minutes ago")
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}
