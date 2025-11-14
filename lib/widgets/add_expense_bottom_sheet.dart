import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Bottom sheet with 2 options for adding expenses
///
/// Shows:
/// - Manual entry (existing flow)
/// - Scan receipt (new OCR flow)
class AddExpenseBottomSheet extends StatelessWidget {
  final VoidCallback onManualAdd;
  final VoidCallback onScanReceipt;

  const AddExpenseBottomSheet({
    super.key,
    required this.onManualAdd,
    required this.onScanReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Thêm chi tiêu',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Manual entry option
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                PhosphorIconsRegular.pencilSimple,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('Nhập thủ công'),
            subtitle: const Text('Nhập chi tiết chi tiêu'),
            onTap: () {
              Navigator.pop(context);
              onManualAdd();
            },
          ),

          const SizedBox(height: 8),

          // Scan receipt option
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                PhosphorIconsRegular.camera,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Quét hóa đơn'),
            subtitle: const Text('Tự động trích xuất từ ảnh'),
            onTap: () {
              Navigator.pop(context);
              onScanReceipt();
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
