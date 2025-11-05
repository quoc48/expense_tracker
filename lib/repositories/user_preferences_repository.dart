import '../models/user_preferences.dart';

/// Abstract interface for user preferences data operations
///
/// This repository pattern provides a clean separation between
/// business logic and data sources. Implementations can use:
/// - Cloud storage (Supabase, Firebase)
/// - Local storage (SharedPreferences, SQLite)
/// - Mock data (for testing)
///
/// Benefits:
/// - Easy to switch between data sources
/// - Simple to test with mock repositories
/// - Clear contract for all implementations
abstract class UserPreferencesRepository {
  /// Get preferences for a specific user
  ///
  /// Returns the user's preferences if they exist, null otherwise.
  /// For first-time users, this will return null and caller should
  /// create default preferences.
  ///
  /// Throws an exception if there's a network/database error.
  Future<UserPreferences?> getPreferences(String userId);

  /// Update the monthly budget for a user
  ///
  /// If preferences don't exist yet, creates them with default values
  /// and the specified budget.
  ///
  /// [userId] - The user's unique identifier
  /// [budget] - The new monthly budget amount (in VND)
  ///
  /// Returns the updated preferences.
  /// Throws an exception if the update fails.
  Future<UserPreferences> updateBudget(String userId, double budget);

  /// Update user preferences (full update)
  ///
  /// Updates all preference fields. If preferences don't exist,
  /// creates new record with provided values.
  ///
  /// [preferences] - The complete preferences object to save
  ///
  /// Returns the updated preferences.
  /// Throws an exception if the update fails.
  Future<UserPreferences> updatePreferences(UserPreferences preferences);

  /// Create default preferences for a new user
  ///
  /// Called when a user signs up or first accesses preferences.
  /// Creates a new record with default values:
  /// - Monthly budget: 20,000,000 VND
  /// - Language: Vietnamese ('vi')
  /// - Theme: System default
  /// - Currency: VND
  ///
  /// [userId] - The user's unique identifier
  ///
  /// Returns the newly created preferences.
  /// Throws an exception if creation fails or preferences already exist.
  Future<UserPreferences> createDefaultPreferences(String userId);

  /// Delete user preferences
  ///
  /// Removes all preference data for a user.
  /// Typically only used when deleting user account.
  ///
  /// [userId] - The user's unique identifier
  ///
  /// Throws an exception if deletion fails.
  Future<void> deletePreferences(String userId);
}
