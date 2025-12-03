import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/typography/app_typography.dart';
import '../widgets/settings/budget_edit_sheet.dart';
import '../widgets/settings/select_theme_sheet.dart';
import '../widgets/common/logout_confirmation_dialog.dart';
import '../widgets/common/success_overlay.dart';
import '../widgets/settings/recurring_expenses_list_screen.dart';

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
      backgroundColor: AppColors.getBackground(context),
      // Use same extendBody pattern as other screens for consistent layout
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        // Don't add bottom padding - let content scroll behind nav bar
        bottom: false,
        child: Consumer<UserPreferencesProvider>(
          builder: (context, prefsProvider, child) {
            // Show loading state while preferences are being fetched
            if (prefsProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.getTextPrimary(context)),
              );
            }

            // Show error state if loading failed
            if (prefsProvider.errorMessage != null) {
              return _buildErrorState(context, prefsProvider);
            }

            // Main settings content using CustomScrollView for consistent scrolling
            return CustomScrollView(
              slivers: [
                // App Bar - matches other screens
                _buildAppBar(context),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Budget & Finance Section
                      _buildSectionLabel('Budget & Finance'),
                      const SizedBox(height: 16),
                      _buildBudgetFinanceCard(context, prefsProvider),

                      const SizedBox(height: 24),

                      // Appearance Section
                      _buildSectionLabel('Appearance'),
                      const SizedBox(height: 16),
                      _buildAppearanceCard(context),

                      // Bottom padding for nav bar
                      const SizedBox(height: 120),
                    ]),
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
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prefsProvider.errorMessage!,
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.getTextSecondary(context),
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
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar with "Settings" title and sign-out icon
  ///
  /// **Design Reference**: Figma node-id=62-3352
  ///
  /// Uses SliverAppBar for consistent behavior with other screens
  Widget _buildAppBar(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return SliverAppBar(
      floating: false,
      pinned: true, // Sticky header - stays visible when scrolling
      backgroundColor: AppColors.getBackground(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56, // Match Home and ExpenseList pages
      automaticallyImplyLeading: false, // No back button
      title: Text(
        'Settings',
        style: TextStyle(
          fontFamily: 'MomoTrustSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFeatures: const [
            FontFeature.disable('liga'),
            FontFeature.disable('clig'),
          ],
        ),
      ),
      centerTitle: false, // Left-aligned title
      actions: [
        // Sign out button
        GestureDetector(
          onTap: () => showLogoutConfirmationDialog(context),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              PhosphorIconsRegular.signOut,
              size: 24,
              color: textColor,
            ),
          ),
        ),
      ],
    );
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
        color: AppColors.getSurface(context), // Adaptive surface for dark mode
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Monthly Budget row
          _buildBudgetRow(context, prefsProvider),

          // Divider - same style as expense_list_tile.dart
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.getDivider(context),
            ),
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
    final textColor = AppColors.getTextPrimary(context);

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
                      color: textColor,
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
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  PhosphorIconsRegular.pencilSimpleLine,
                  size: 18,
                  color: textColor,
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

      // Show success overlay after budget is updated
      if (context.mounted) {
        await showSuccessOverlay(
          context: context,
          message: 'Budget updated.',
        );
      }
    }
  }

  /// Navigate to Recurring Expenses list screen
  void _navigateToRecurringExpenses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecurringExpensesListScreen(),
      ),
    );
  }

  /// Build Recurring Expenses row
  ///
  /// **Design Reference**: Figma node-id=63-1487
  ///
  /// Layout: calendar icon + "Recurring Expenses" + subtitle | caret right
  Widget _buildRecurringRow(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return InkWell(
      onTap: () => _navigateToRecurringExpenses(context),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
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
                            color: textColor,
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
              color: textColor,
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
        color: AppColors.getSurface(context), // Adaptive surface for dark mode
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildThemeRow(context),
    );
  }

  /// Build Theme row
  ///
  /// **Design Reference**: Figma node-id=63-2176
  ///
  /// Layout: palette icon + "Theme" | current theme + caret right
  Widget _buildThemeRow(BuildContext context) {
    final textColor = AppColors.getTextPrimary(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get current theme mode and convert to AppThemeMode
        final currentAppTheme = _themeProviderToAppTheme(themeProvider.themeMode);

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
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Value + Caret icon
                Row(
                  children: [
                    Text(
                      currentAppTheme.shortLabel,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 18,
                      color: textColor,
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

  /// Convert ThemeMode to AppThemeMode
  AppThemeMode _themeProviderToAppTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }

  /// Convert AppThemeMode to ThemeMode
  ThemeMode _appThemeToThemeMode(AppThemeMode appTheme) {
    switch (appTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Show theme selector using the new SelectThemeSheet design
  ///
  /// **Design Reference**: Figma node-id=64-2286
  Future<void> _showThemeSelector(BuildContext context, ThemeProvider themeProvider) async {
    final currentAppTheme = _themeProviderToAppTheme(themeProvider.themeMode);

    final selectedTheme = await showSelectThemeSheet(
      context: context,
      selectedTheme: currentAppTheme,
    );

    if (selectedTheme != null && context.mounted) {
      // Convert back to ThemeMode and update
      themeProvider.setThemeMode(_appThemeToThemeMode(selectedTheme));
    }
  }
}
