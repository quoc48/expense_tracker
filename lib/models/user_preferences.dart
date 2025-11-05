/// User Preferences Model
///
/// Stores user-specific settings and preferences including budget configuration.
/// This model follows the same pattern as Expense model for consistency.
///
/// Key Design Decisions:
/// - Nullable future fields (language, theme, currency) for scalability
/// - Default values match Supabase table defaults
/// - Immutable (all fields final) with copyWith for updates
/// - fromMap/toMap for Supabase serialization
class UserPreferences {
  final String id;
  final String userId;

  // Budget Settings
  final double monthlyBudget; // Default: 20,000,000 VND

  // Future Settings (nullable for backwards compatibility)
  final String? language; // 'vi' or 'en'
  final String? theme; // 'light', 'dark', or 'system'
  final String? currency; // 'VND', 'USD', etc.

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.monthlyBudget,
    this.language,
    this.theme,
    this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating from Supabase row
  ///
  /// Maps Supabase column names to Dart fields.
  /// Provides sensible defaults if fields are missing.
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      monthlyBudget: (map['monthly_budget'] as num?)?.toDouble() ?? 20000000.0,
      language: map['language'] as String?,
      theme: map['theme'] as String?,
      currency: map['currency'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to Map for Supabase storage
  ///
  /// Returns only fields that should be sent to Supabase.
  /// The database handles id, timestamps, and defaults.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_budget': monthlyBudget,
      'language': language,
      'theme': theme,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Minimal Map for updates (only changed fields)
  ///
  /// Used when updating existing preferences.
  /// Only includes fields that can be modified by users.
  Map<String, dynamic> toUpdateMap() {
    return {
      'monthly_budget': monthlyBudget,
      'language': language,
      'theme': theme,
      'currency': currency,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with modified fields (immutable pattern)
  ///
  /// Allows updating individual fields without mutating the original object.
  /// This is the Flutter/Dart best practice for state management.
  ///
  /// Example:
  /// ```dart
  /// final updated = prefs.copyWith(monthlyBudget: 15000000);
  /// ```
  UserPreferences copyWith({
    String? id,
    String? userId,
    double? monthlyBudget,
    String? language,
    String? theme,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create default preferences for a new user
  ///
  /// Useful for initial setup or testing.
  factory UserPreferences.defaultPreferences(String userId) {
    final now = DateTime.now();
    return UserPreferences(
      id: '', // Will be set by Supabase
      userId: userId,
      monthlyBudget: 20000000.0, // 20M VND default
      language: 'vi',
      theme: 'system',
      currency: 'VND',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(id: $id, userId: $userId, monthlyBudget: $monthlyBudget, '
        'language: $language, theme: $theme, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreferences &&
        other.id == id &&
        other.userId == userId &&
        other.monthlyBudget == monthlyBudget &&
        other.language == language &&
        other.theme == theme &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        monthlyBudget.hashCode ^
        language.hashCode ^
        theme.hashCode ^
        currency.hashCode;
  }
}
