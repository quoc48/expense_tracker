import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing theme mode (light/dark/system)
/// Persists theme preference using SharedPreferences
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Constructor - loads saved theme preference on initialization
  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load theme preference from SharedPreferences
  /// Defaults to system theme if no preference is saved
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString('theme_mode') ?? 'system';

      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } catch (e) {
      // If loading fails, keep default system theme
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Set theme mode and persist the preference
  /// Automatically notifies listeners to rebuild UI
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;

      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        default:
          themeModeString = 'system';
      }

      await prefs.setString('theme_mode', themeModeString);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggle between light and dark mode (skips system mode)
  /// Useful for quick theme switching with a single button
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if currently using dark mode (either explicit dark or system dark)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
