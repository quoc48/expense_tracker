import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/typography/app_typography.dart';
import '../widgets/settings/budget_edit_sheet.dart';

/// Settings screen with Figma-based design
///
/// **Design Reference**: Figma node-id=62-3350
///
/// **Layout**:
/// - Background: Light gray (#EDEFF1)
/// - Header: "Settings" title + Sign out icon
/// - Sections: "Budget & Finance" and "Appearance"
/// - Items in white cards with 8px rounded corners
///
/// **Features**:
/// - Monthly Budget (editable)
/// - Recurring Expenses (coming soon)
/// - Theme selection (Light mode default, Dark mode not available yet)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF1), // Light gray background per Figma
      body: SafeArea(
        child: Consumer<UserPreferencesProvider>(
          builder: (context, prefsProvider, child) {
            // Show loading state while preferences are being fetched
            if (prefsProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.textBlack),
              );
            }

            // Show error state if loading failed
            if (prefsProvider.errorMessage != null) {
              return _buildErrorState(context, prefsProvider);
            }

            // Main settings content
            return Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget & Finance Section
                        _buildSectionLabel('Budget & Finance'),
                        const SizedBox(height: 16),
                        _buildBudgetFinanceCard(context, prefsProvider),

                        const SizedBox(height: 24),

                        // Appearance Section
                        _buildSectionLabel('Appearance'),
                        const SizedBox(height: 16),
                        _buildAppearanceCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build error state UI
  Widget _buildErrorState(BuildContext context, UserPreferencesProvider prefsProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsRegular.warningCircle,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading settings',
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prefsProvider.errorMessage!,
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.gray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => prefsProvider.loadPreferences(),
            child: Text(
              'Retry',
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header with "Settings" title and sign-out icon
  ///
  /// **Design Reference**: Figma node-id=62-3352
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'Settings',
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),

          // Sign out button
          GestureDetector(
            onTap: () => _handleSignOut(context),
            child: const Icon(
              PhosphorIconsRegular.signOut,
              size: 24,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle sign out action
  Future<void> _handleSignOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sign Out',
          style: AppTypography.style(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.style(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.gray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Sign Out',
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }

  /// Build section label
  ///
  /// **Design Reference**: 12px gray text (#8E8E93)
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.gray,
      ),
    );
  }

  /// Build Budget & Finance card with Monthly Budget and Recurring items
  ///
  /// **Design Reference**: Figma node-id=63-1512
  Widget _buildBudgetFinanceCard(BuildContext context, UserPreferencesProvider prefsProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Monthly Budget row
          _buildBudgetRow(context, prefsProvider),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: const Color(0xFFF2F2F7),
          ),

          // Recurring Expenses row (coming soon)
          _buildRecurringRow(context),
        ],
      ),
    );
  }

  /// Build Monthly Budget row
  ///
  /// **Design Reference**: Figma node-id=62-3360
  ///
  /// Layout: wallet icon + "Monthly Budget" | value + pencil icon
  Widget _buildBudgetRow(BuildContext context, UserPreferencesProvider prefsProvider) {
    return InkWell(
      onTap: () => _showBudgetEditSheet(context, prefsProvider),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Left: Icon + Label
            Expanded(
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.wallet,
                    size: 24,
                    color: AppColors.gray,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Monthly Budget',
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Value + Pencil icon
            Row(
              children: [
                Text(
                  _formatBudgetValue(prefsProvider.monthlyBudget),
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  PhosphorIconsRegular.pencilSimpleLine,
                  size: 18,
                  color: AppColors.textBlack,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format budget value as "20,000,000" (comma separator, no currency symbol)
  String _formatBudgetValue(double value) {
    final intValue = value.toInt();
    final str = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Show budget edit bottom sheet
  Future<void> _showBudgetEditSheet(BuildContext context, UserPreferencesProvider prefsProvider) async {
    final newBudget = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetEditSheet(
        initialBudget: prefsProvider.monthlyBudget,
      ),
    );

    if (newBudget != null && context.mounted) {
      await prefsProvider.updateBudget(newBudget);
    }
  }

  /// Build Recurring Expenses row (disabled/coming soon)
  ///
  /// **Design Reference**: Figma node-id=63-1487
  ///
  /// Layout: calendar icon + "Recurring Expenses" + subtitle | caret right
  Widget _buildRecurringRow(BuildContext context) {
    return Opacity(
      opacity: 0.5, // Disabled state
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Left: Icon + Labels
            Expanded(
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.calendarCheck,
                    size: 24,
                    color: AppColors.gray,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recurring Expenses',
                          style: AppTypography.style(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage automatic expenses',
                          style: AppTypography.style(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right: Caret icon
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: AppColors.textBlack,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Appearance card with Theme row
  ///
  /// **Design Reference**: Figma node-id=63-1513
  Widget _buildAppearanceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildThemeRow(context),
    );
  }

  /// Build Theme row
  ///
  /// **Design Reference**: Figma node-id=63-1516
  ///
  /// Layout: palette icon + "Theme" | "Light" + caret right
  Widget _buildThemeRow(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // For now, only Light mode is available
        const themeText = 'Light';

        return InkWell(
          onTap: () => _showThemeSelector(context, themeProvider),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Left: Icon + Label
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.palette,
                        size: 24,
                        color: AppColors.gray,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Theme',
                        style: AppTypography.style(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Value + Caret icon
                Row(
                  children: [
                    Text(
                      themeText,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 18,
                      color: AppColors.textBlack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show theme selector (only Light available for now)
  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32), // Spacer
                    Text(
                      'Theme',
                      style: AppTypography.style(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(bottomSheetContext),
                      child: const Icon(
                        PhosphorIconsRegular.x,
                        size: 24,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Light theme option (selected)
              _buildThemeOption(
                context: bottomSheetContext,
                label: 'Light',
                subtitle: 'Always use light theme',
                isSelected: true,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.pop(bottomSheetContext);
                },
              ),

              // Dark theme option (not available)
              _buildThemeOption(
                context: bottomSheetContext,
                label: 'Dark',
                subtitle: 'Coming soon',
                isSelected: false,
                isDisabled: true,
                onTap: null,
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Build theme option row
  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required String subtitle,
    required bool isSelected,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.textBlack : AppColors.gray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textBlack,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.style(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
