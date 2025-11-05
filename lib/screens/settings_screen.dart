import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prefsProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                icon: Icons.currency_exchange,
                title: 'Currency',
                subtitle: 'VND (Vietnamese đồng)',
              ),
              const Divider(height: 32),

              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildPlaceholderTile(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Vietnamese',
              ),
              _buildPlaceholderTile(
                context,
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'System default',
              ),
              const Divider(height: 32),

              // Advanced Section
              _buildSectionHeader(context, 'Advanced'),
              _buildPlaceholderTile(
                context,
                icon: Icons.repeat,
                title: 'Recurring Expenses',
                subtitle: 'Manage automatic expenses',
              ),
              _buildPlaceholderTile(
                context,
                icon: Icons.file_download,
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
              color: Theme.of(context).colorScheme.primary,
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
      leading: Icon(icon, color: Colors.grey[400]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      enabled: false, // Grayed out to indicate not yet implemented
    );
  }
}
