import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/budget_setting_tile.dart';

/// Settings screen with category-based organization
///
/// Organized into logical sections:
/// - Budget & Finance: Budget management, currency preferences
/// - Appearance: Theme, language (future)
/// - Advanced: Recurring expenses, data export (future)
///
/// Learning: Settings screens benefit from clear categorization
/// rather than a flat list of options. This improves discoverability
/// and creates a professional, organized feel.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // back button is automatically added by Flutter
      ),
      body: Consumer<UserPreferencesProvider>(
        builder: (context, prefsProvider, child) {
          // Show loading state while preferences are being fetched
          if (prefsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error state if loading failed
          if (prefsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsLight.warningCircle,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prefsProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => prefsProvider.loadPreferences(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Main settings list
          return ListView(
            children: [
              // Budget & Finance Section
              _buildSectionHeader(context, 'Budget & Finance'),
              BudgetSettingTile(
                currentBudget: prefsProvider.monthlyBudget,
                onBudgetChanged: (newBudget) async {
                  await prefsProvider.updateBudget(newBudget);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Budget updated successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              _buildPlaceholderTile(
                context,
                icon: PhosphorIconsLight.currencyCircleDollar,
                title: 'Currency',
                subtitle: 'VND (Vietnamese đồng)',
              ),
              const Divider(height: 32),

              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildPlaceholderTile(
                context,
                icon: PhosphorIconsLight.globe,
                title: 'Language',
                subtitle: 'Vietnamese',
              ),
              _buildThemeSelector(context),
              const Divider(height: 32),

              // Advanced Section
              _buildSectionHeader(context, 'Advanced'),
              _buildPlaceholderTile(
                context,
                icon: PhosphorIconsLight.repeat,
                title: 'Recurring Expenses',
                subtitle: 'Manage automatic expenses',
              ),
              _buildPlaceholderTile(
                context,
                icon: PhosphorIconsLight.downloadSimple,
                title: 'Export Data',
                subtitle: 'Download expenses as CSV',
              ),
            ],
          );
        },
      ),
    );
  }

  /// Section header widget with consistent styling
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  /// Placeholder tile for future features
  ///
  /// Learning: When building incrementally, it's valuable to show users
  /// what's coming next. These placeholders create a complete mental model
  /// of the app's structure and set expectations for future functionality.
  Widget _buildPlaceholderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        PhosphorIconsLight.caretRight,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      enabled: false, // Grayed out to indicate not yet implemented
    );
  }

  /// Theme selector with Light/Dark/System options
  ///
  /// Learning: Theme selection is implemented with a bottom sheet containing
  /// RadioListTiles. This pattern is common in settings screens because:
  /// 1. It shows all options at once (unlike a dialog)
  /// 2. It's familiar to users from system settings
  /// 3. RadioListTile provides built-in selection state management
  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get display text for current theme mode
        String getThemeText(ThemeMode mode) {
          switch (mode) {
            case ThemeMode.light:
              return 'Light';
            case ThemeMode.dark:
              return 'Dark';
            case ThemeMode.system:
              return 'System default';
          }
        }

        return ListTile(
          leading: Icon(
            PhosphorIconsLight.palette,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: const Text('Theme'),
          subtitle: Text(getThemeText(themeProvider.themeMode)),
          trailing: Icon(
            PhosphorIconsLight.caretRight,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            // Show bottom sheet with theme options
            showModalBottomSheet(
              context: context,
              builder: (BuildContext bottomSheetContext) {
                return Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIconsLight.palette,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Choose Theme',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Light theme option
                          RadioListTile<ThemeMode>(
                            title: const Text('Light'),
                            subtitle: const Text('Always use light theme'),
                            value: ThemeMode.light,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                                Navigator.pop(bottomSheetContext);
                              }
                            },
                          ),

                          // Dark theme option
                          RadioListTile<ThemeMode>(
                            title: const Text('Dark'),
                            subtitle: const Text('Always use dark theme'),
                            value: ThemeMode.dark,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                                Navigator.pop(bottomSheetContext);
                              }
                            },
                          ),

                          // System theme option
                          RadioListTile<ThemeMode>(
                            title: const Text('System default'),
                            subtitle: const Text('Follow device setting'),
                            value: ThemeMode.system,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                                Navigator.pop(bottomSheetContext);
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
