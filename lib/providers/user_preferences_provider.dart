import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';
import '../repositories/supabase_user_preferences_repository.dart';
import '../services/supabase_service.dart';

/// UserPreferencesProvider manages the global state for user preferences.
/// It extends ChangeNotifier which is part of Flutter's built-in state management.
///
/// Learning: This provider follows the same pattern as ExpenseProvider.
/// When preferences change (budget updated), we call notifyListeners() which
/// automatically rebuilds all widgets listening to this provider!
///
/// Example Usage in UI:
/// ```dart
/// // Listen to changes
/// final prefsProvider = Provider.of<UserPreferencesProvider>(context);
/// Text('Budget: ${prefsProvider.monthlyBudget} đ');
///
/// // Update budget
/// await prefsProvider.updateBudget(15000000);
/// // UI automatically rebuilds with new value!
/// ```
///
/// Why use Provider for preferences?
/// - Settings screen and Analytics screen can both access budget
/// - No need to pass data through widget tree
/// - Changes in Settings instantly update Analytics
/// - Clean separation: UI doesn't know about Supabase
class UserPreferencesProvider extends ChangeNotifier {
  // Private state - the underscore makes it inaccessible outside this class
  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _errorMessage;

  // Repository for data access (Supabase backend)
  final UserPreferencesRepository _repository =
      SupabaseUserPreferencesRepository();

  // Public getters - allow read-only access to private state
  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Convenience getters for commonly accessed values
  // Returns default 20M if preferences not loaded yet
  double get monthlyBudget => _preferences?.monthlyBudget ?? 20000000.0;
  String get language => _preferences?.language ?? 'vi';
  String get theme => _preferences?.theme ?? 'system';
  String get currency => _preferences?.currency ?? 'VND';

  // Check if preferences have been loaded
  bool get hasPreferences => _preferences != null;

  /// Load preferences for the currently logged-in user
  ///
  /// This should be called once when the app starts (after authentication).
  /// If user has no preferences yet, creates default ones automatically.
  ///
  /// Flow:
  /// 1. Set loading state
  /// 2. Get current user ID from Supabase auth
  /// 3. Try to fetch preferences from database
  /// 4. If not found, create default preferences
  /// 5. Update state and notify listeners
  Future<void> loadPreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // UI can show loading spinner

    try {
      // Get current logged-in user
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Try to fetch existing preferences
      _preferences = await _repository.getPreferences(currentUser.id);

      // If no preferences exist yet, create defaults
      if (_preferences == null) {
        debugPrint('No preferences found, creating defaults for user ${currentUser.id}');
        _preferences = await _repository.createDefaultPreferences(currentUser.id);
        debugPrint('Default preferences created: 20M VND budget');
      } else {
        debugPrint('Preferences loaded: ${_preferences!.monthlyBudget} VND budget');
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _errorMessage = 'Failed to load preferences: $e';
      // Set fallback default values even if load fails
      _preferences = null;
    } finally {
      _isLoading = false;
      notifyListeners(); // UI can stop showing loading spinner
    }
  }

  /// Update the monthly budget
  ///
  /// This is the most common preference update operation.
  /// Called from Settings screen when user changes budget.
  ///
  /// [newBudget] - The new monthly budget amount in VND
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool success = await prefsProvider.updateBudget(15000000);
  /// if (success) {
  ///   // Show success message
  /// }
  /// ```
  Future<bool> updateBudget(double newBudget) async {
    _errorMessage = null;

    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Optimistic update: Update UI immediately for better UX
      final oldBudget = _preferences?.monthlyBudget;
      if (_preferences != null) {
        _preferences = _preferences!.copyWith(
          monthlyBudget: newBudget,
          updatedAt: DateTime.now(),
        );
        notifyListeners(); // UI updates immediately
      }

      // Save to database
      _preferences = await _repository.updateBudget(currentUser.id, newBudget);

      debugPrint('Budget updated: $oldBudget → $newBudget VND');
      notifyListeners(); // Confirm with database result

      return true;
    } catch (e) {
      debugPrint('Error updating budget: $e');
      _errorMessage = 'Failed to update budget: $e';

      // Revert optimistic update if save failed
      await loadPreferences();

      return false;
    }
  }

  /// Update full preferences (all fields)
  ///
  /// Used when multiple preference fields need to be updated at once.
  /// For budget-only updates, use updateBudget() instead.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> updatePreferences(UserPreferences newPreferences) async {
    _errorMessage = null;

    try {
      // Save to database
      _preferences = await _repository.updatePreferences(newPreferences);

      debugPrint('Preferences updated for user ${newPreferences.userId}');
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      _errorMessage = 'Failed to update preferences: $e';
      notifyListeners();

      return false;
    }
  }

  /// Update language preference
  ///
  /// Future enhancement for multi-language support.
  /// Currently supports 'vi' (Vietnamese) and 'en' (English).
  Future<bool> updateLanguage(String language) async {
    if (_preferences == null) return false;

    final updated = _preferences!.copyWith(
      language: language,
      updatedAt: DateTime.now(),
    );

    return updatePreferences(updated);
  }

  /// Update theme preference
  ///
  /// Future enhancement for theme switching.
  /// Supports: 'light', 'dark', 'system'
  Future<bool> updateTheme(String theme) async {
    if (_preferences == null) return false;

    final updated = _preferences!.copyWith(
      theme: theme,
      updatedAt: DateTime.now(),
    );

    return updatePreferences(updated);
  }

  /// Clear error message
  ///
  /// Call this after showing error to user (e.g., in a SnackBar)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset to default preferences
  ///
  /// Useful for testing or if user wants to start fresh.
  Future<bool> resetToDefaults() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create default preferences
      final defaults = UserPreferences.defaultPreferences(currentUser.id);

      // Save to database
      _preferences = await _repository.updatePreferences(defaults);

      debugPrint('Preferences reset to defaults');
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error resetting preferences: $e');
      _errorMessage = 'Failed to reset preferences: $e';
      notifyListeners();

      return false;
    }
  }
}
