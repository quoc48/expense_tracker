import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../services/supabase_service.dart';
import 'user_preferences_repository.dart';

/// Supabase implementation of UserPreferencesRepository
///
/// Manages user preferences using Supabase as the data source.
/// Uses Row Level Security (RLS) to ensure users can only access their own data.
///
/// Key Features:
/// - Upsert pattern (insert or update in one operation)
/// - Automatic timestamp management
/// - Error propagation (caller handles user-friendly messages)
/// - RLS ensures data isolation between users
class SupabaseUserPreferencesRepository implements UserPreferencesRepository {
  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    try {
      // Query user_preferences table for this user
      // RLS policy ensures we only get rows where user_id matches auth.uid()
      final response = await supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // Returns null if no row found

      // If no preferences exist yet, return null
      if (response == null) {
        debugPrint('No preferences found for user: $userId');
        return null;
      }

      // Convert database row to UserPreferences object
      return UserPreferences.fromMap(response);
    } catch (e) {
      debugPrint('Error getting preferences for user $userId: $e');
      rethrow; // Let caller handle the error
    }
  }

  @override
  Future<UserPreferences> updateBudget(String userId, double budget) async {
    try {
      // Upsert: Insert if not exists, update if exists
      // This is cleaner than checking existence first
      final response = await supabase
          .from('user_preferences')
          .upsert(
            {
              'user_id': userId,
              'monthly_budget': budget,
              'updated_at': DateTime.now().toIso8601String(),
            },
            // Return the updated row
            onConflict: 'user_id', // Use user_id as conflict resolution key
          )
          .select()
          .single();

      debugPrint('Budget updated for user $userId: $budget VND');
      return UserPreferences.fromMap(response);
    } catch (e) {
      debugPrint('Error updating budget for user $userId: $e');
      rethrow;
    }
  }

  @override
  Future<UserPreferences> updatePreferences(UserPreferences preferences) async {
    try {
      // Full preferences update (all fields)
      final response = await supabase
          .from('user_preferences')
          .upsert(
            preferences.toUpdateMap()
              ..['user_id'] = preferences.userId, // Ensure user_id is set
            onConflict: 'user_id',
          )
          .select()
          .single();

      debugPrint('Preferences updated for user ${preferences.userId}');
      return UserPreferences.fromMap(response);
    } catch (e) {
      debugPrint('Error updating preferences for user ${preferences.userId}: $e');
      rethrow;
    }
  }

  @override
  Future<UserPreferences> createDefaultPreferences(String userId) async {
    try {
      // Create default preferences for a new user
      final defaultPrefs = UserPreferences.defaultPreferences(userId);

      final response = await supabase
          .from('user_preferences')
          .insert({
            'user_id': userId,
            'monthly_budget': defaultPrefs.monthlyBudget,
            'language': defaultPrefs.language,
            'theme': defaultPrefs.theme,
            'currency': defaultPrefs.currency,
          })
          .select()
          .single();

      debugPrint('Default preferences created for user $userId');
      return UserPreferences.fromMap(response);
    } catch (e) {
      debugPrint('Error creating default preferences for user $userId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePreferences(String userId) async {
    try {
      await supabase
          .from('user_preferences')
          .delete()
          .eq('user_id', userId);

      debugPrint('Preferences deleted for user $userId');
    } catch (e) {
      debugPrint('Error deleting preferences for user $userId: $e');
      rethrow;
    }
  }

  /// Get preferences for currently logged-in user
  ///
  /// Convenience method that uses the current auth user's ID.
  /// Throws an exception if no user is logged in.
  Future<UserPreferences?> getCurrentUserPreferences() async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    return getPreferences(currentUser.id);
  }

  /// Update budget for currently logged-in user
  ///
  /// Convenience method that uses the current auth user's ID.
  /// Throws an exception if no user is logged in.
  Future<UserPreferences> updateCurrentUserBudget(double budget) async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    return updateBudget(currentUser.id, budget);
  }
}
