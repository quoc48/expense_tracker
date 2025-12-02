import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors/app_colors.dart';

/// A reusable logout confirmation dialog component.
///
/// **Design Reference**: Consistent with Expense List page style
///
/// **Features**:
/// - MomoTrustSans font throughout
/// - Adaptive colors for dark mode support
/// - Cancel button (text) + Sign Out button (filled red)
/// - Handles sign out via AuthProvider
///
/// **Usage**:
/// ```dart
/// // Option 1: Use the helper function
/// await showLogoutConfirmationDialog(context);
///
/// // Option 2: Use in onTap directly
/// GestureDetector(
///   onTap: () => showLogoutConfirmationDialog(context),
///   child: Icon(PhosphorIconsRegular.signOut),
/// )
/// ```
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);
    final secondaryColor = AppColors.getTextSecondary(context);
    final dialogBgColor = AppColors.getSurface(context);

    return AlertDialog(
      backgroundColor: dialogBgColor,
      title: Text(
        'Sign Out',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      content: Text(
        'Are you sure you want to sign out?',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'MomoTrustSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'MomoTrustSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the logout confirmation dialog and handles sign out if confirmed.
///
/// Returns `true` if user signed out, `false` if cancelled.
///
/// **Usage**:
/// ```dart
/// await showLogoutConfirmationDialog(context);
/// ```
Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return const LogoutConfirmationDialog();
    },
  );

  if (confirmed == true && context.mounted) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    return true;
  }

  return false;
}
