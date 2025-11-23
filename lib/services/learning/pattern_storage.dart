import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pattern_model.dart';

/// Service for persisting learned patterns to local storage
///
/// Uses SharedPreferences to store pattern data locally so patterns
/// persist across app sessions. This allows the app to remember
/// what it has learned even after being closed.
class PatternStorage {
  static const String _patternKey = 'expense_patterns_v1';
  static const String _lastSyncKey = 'patterns_last_sync';

  /// Save patterns to local storage
  Future<void> savePatterns(PatternModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert model to JSON string
      final json = model.toJson();
      final jsonString = jsonEncode(json);

      // Save to SharedPreferences
      await prefs.setString(_patternKey, jsonString);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      debugPrint('Patterns saved successfully (${jsonString.length} bytes)');
    } catch (e) {
      debugPrint('Error saving patterns: $e');
      rethrow;
    }
  }

  /// Load patterns from local storage
  Future<PatternModel?> loadPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get JSON string from storage
      final jsonString = prefs.getString(_patternKey);
      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('No existing patterns found');
        return null;
      }

      // Parse JSON and create model
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = PatternModel.fromJson(json);

      // Check last sync time
      final lastSyncString = prefs.getString(_lastSyncKey);
      if (lastSyncString != null) {
        final lastSync = DateTime.parse(lastSyncString);
        final hoursSinceSync = DateTime.now().difference(lastSync).inHours;
        debugPrint('Patterns loaded (last sync: ${hoursSinceSync}h ago)');
      }

      debugPrint('Loaded patterns for ${model.patterns.length} categories');
      return model;
    } catch (e) {
      debugPrint('Error loading patterns: $e');
      // Return null if loading fails (will trigger re-learning)
      return null;
    }
  }

  /// Clear all stored patterns
  Future<void> clearPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_patternKey);
      await prefs.remove(_lastSyncKey);
      debugPrint('Patterns cleared from storage');
    } catch (e) {
      debugPrint('Error clearing patterns: $e');
    }
  }

  /// Check if patterns exist in storage
  Future<bool> hasPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_patternKey);
    } catch (e) {
      debugPrint('Error checking patterns: $e');
      return false;
    }
  }

  /// Get pattern statistics for debugging
  Future<Map<String, dynamic>?> getPatternStats() async {
    try {
      final model = await loadPatterns();
      if (model == null) return null;

      final stats = <String, dynamic>{
        'total_categories': model.patterns.length,
        'total_expenses_learned': model.totalExpenses,
        'last_updated': model.lastUpdated.toIso8601String(),
        'version': model.version,
        'categories': <String, Map<String, dynamic>>{},
      };

      // Add per-category stats
      for (final entry in model.patterns.entries) {
        final pattern = entry.value;
        stats['categories'][entry.key] = {
          'samples': pattern.totalCount,
          'keywords': pattern.keywords.length,
          'merchants': pattern.merchantFrequency.length,
          'examples': pattern.exampleDescriptions.length,
          'confidence': (pattern.confidence * 100).toStringAsFixed(0) + '%',
          'avg_amount': pattern.averageAmount.toStringAsFixed(0) + 'đ',
        };
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting pattern stats: $e');
      return null;
    }
  }

  /// Export patterns as JSON string (for debugging/backup)
  Future<String?> exportPatterns() async {
    try {
      final model = await loadPatterns();
      if (model == null) return null;

      final json = model.toJson();
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      debugPrint('Error exporting patterns: $e');
      return null;
    }
  }

  /// Import patterns from JSON string (for restore/testing)
  Future<bool> importPatterns(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = PatternModel.fromJson(json);
      await savePatterns(model);
      return true;
    } catch (e) {
      debugPrint('Error importing patterns: $e');
      return false;
    }
  }
}