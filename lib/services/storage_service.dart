import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TOP-LEVEL FUNCTION FOR compute() ISOLATE
// ═══════════════════════════════════════════════════════════════════════════════
//
// Why top-level? Flutter's compute() requires a top-level or static function.
// It can't use closures or instance methods because isolates don't share memory.
//
// This function runs in a SEPARATE ISOLATE (background thread), so:
// - Main thread (UI) stays responsive
// - Expensive DateTime.parse() calls don't block animations
// - User sees instant loading while parsing happens in background
List<Expense> _parseExpensesJson(String json) {
  final List<dynamic> list = jsonDecode(json);
  return list.map((e) => Expense.fromMap(e as Map<String, dynamic>)).toList();
}

// StorageService: Handles all data persistence operations
// This is a "Service" - a class that handles business logic separate from UI
//
// **SINGLETON PATTERN** - Pre-initialize at app startup for instant cache access
//
// **PERFORMANCE OPTIMIZATION** (Dec 2025):
// - Pre-parse cache during splash screen using compute() isolate
// - Store parsed expenses in memory for instant access
// - Expense.fromMap() is slow in debug mode (~8ms each due to DateTime.parse)
// - By pre-parsing, we move the cost to startup and get <5ms access later
class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructor returns singleton
  factory StorageService() => _instance;

  // Private constructor for singleton
  StorageService._internal();

  // Key used to store expenses in shared_preferences
  // Making it static const means it's the same across all instances
  static const String _expensesKey = 'expenses';

  // Keys for current month expense cache (Performance Optimization)
  static const String _currentMonthCacheKey = 'cached_current_month_expenses';
  static const String _cacheTimestampKey = 'cache_timestamp';

  // SharedPreferences instance - initialized once, shared across app
  SharedPreferences? _prefs;

  // Memory cache for pre-parsed expenses (instant access after preload)
  List<Expense>? _memoryCache;

  // Initialize the storage service
  // This must be called before using save/load methods
  // async: This operation takes time (disk access)
  Future<void> initialize() async {
    // Skip if already initialized (singleton pattern optimization)
    if (_prefs != null) return;

    // SharedPreferences.getInstance() returns a Future
    // await: Wait for it to complete before continuing
    _prefs = await SharedPreferences.getInstance();
  }

  /// Pre-parse cache during app startup (called from main.dart)
  ///
  /// This moves the expensive JSON parsing + DateTime.parse() to the splash screen,
  /// so when ExpenseProvider calls getCachedCurrentMonthExpenses(), it returns instantly.
  ///
  /// Uses compute() to run parsing in a background isolate, keeping UI responsive.
  Future<void> preloadCache() async {
    if (_prefs == null) {
      await initialize();
    }

    // Check if cache is stale (different month)
    if (!isCacheFromCurrentMonth()) {
      debugPrint('📊 [PRELOAD] Cache stale or missing, skipping preload');
      return;
    }

    final json = _prefs!.getString(_currentMonthCacheKey);
    if (json == null) {
      debugPrint('📊 [PRELOAD] No cache to preload');
      return;
    }

    final stopwatch = Stopwatch()..start();

    // Use compute() to parse in background isolate
    // This keeps the splash screen animations smooth
    _memoryCache = await compute(_parseExpensesJson, json);

    stopwatch.stop();
    debugPrint('📊 [PRELOAD] Pre-parsed ${_memoryCache!.length} expenses in ${stopwatch.elapsedMilliseconds}ms (isolate)');
  }

  /// Clear memory cache (called when cache is updated)
  void invalidateMemoryCache() {
    _memoryCache = null;
  }

  // Save expenses to local storage
  // Future<void>: Returns nothing, but takes time (async operation)
  Future<void> saveExpenses(List<Expense> expenses) async {
    // Make sure we're initialized
    if (_prefs == null) {
      await initialize();
    }

    // Convert list of Expense objects to list of Maps
    // Each expense.toMap() converts one Expense to a Map<String, dynamic>
    final List<Map<String, dynamic>> expenseMaps =
        expenses.map((expense) => expense.toMap()).toList();

    // Convert the list of maps to a JSON string
    // jsonEncode: Dart's built-in JSON serializer
    // Example: [{"id": "1", "description": "Food"...}, {"id": "2"...}]
    final String jsonString = jsonEncode(expenseMaps);

    // Save the JSON string to shared_preferences
    // setString returns a Future<bool> (true if successful)
    await _prefs!.setString(_expensesKey, jsonString);

    // The ! after _prefs tells Dart "I know this is not null"
    // We can safely use it because we checked/initialized above
  }

  // Load expenses from local storage
  // Future<List<Expense>>: Returns a list of expenses (eventually)
  Future<List<Expense>> loadExpenses() async {
    // Make sure we're initialized
    if (_prefs == null) {
      await initialize();
    }

    // Try to get the saved JSON string
    // getString returns null if the key doesn't exist (first time)
    final String? jsonString = _prefs!.getString(_expensesKey);

    // If no data saved yet, return empty list
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      // Decode the JSON string back to a list of maps
      // jsonDecode: Dart's built-in JSON deserializer
      // The result is dynamic, so we cast it to List<dynamic>
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert each map back to an Expense object
      // We iterate through the list and use Expense.fromMap
      final List<Expense> expenses = jsonList
          .map((json) => Expense.fromMap(json as Map<String, dynamic>))
          .toList();

      return expenses;
    } catch (e) {
      // If there's an error (corrupted data, etc.), return empty list
      // In production, you might want to log this error
      debugPrint('❌ Error loading expenses: $e');
      return [];
    }
  }

  // Clear all saved expenses (useful for testing/debugging)
  Future<void> clearExpenses() async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs!.remove(_expensesKey);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CURRENT MONTH CACHE (Performance Optimization)
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Cache current month expenses for instant loading on next launch (~30ms vs ~1500ms)
  // Only stores current month to minimize storage (~25KB for 50 expenses)

  /// Cache current month expenses for instant loading on next launch
  Future<void> cacheCurrentMonthExpenses(List<Expense> expenses) async {
    if (_prefs == null) {
      await initialize();
    }

    // Update memory cache immediately (for subsequent reads in this session)
    _memoryCache = expenses;

    // Persist to disk for next app launch
    final json = jsonEncode(expenses.map((e) => e.toMap()).toList());
    await _prefs!.setString(_currentMonthCacheKey, json);
    await _prefs!.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('💾 Cached ${expenses.length} current month expenses (memory + disk)');
  }

  /// Get cached current month expenses (returns null if no cache)
  ///
  /// PERFORMANCE: If preloadCache() was called at startup, this returns
  /// from memory cache in <1ms. Otherwise falls back to parsing (slower).
  Future<List<Expense>?> getCachedCurrentMonthExpenses() async {
    // Fast path: Return pre-parsed memory cache (instant!)
    if (_memoryCache != null) {
      debugPrint('  📊 [CACHE] Memory cache hit: ${_memoryCache!.length} expenses (instant)');
      return _memoryCache;
    }

    // Slow path: Parse from disk (fallback if preload wasn't called)
    if (_prefs == null) {
      await initialize();
    }

    final json = _prefs!.getString(_currentMonthCacheKey);
    if (json == null) return null;

    try {
      debugPrint('  ⚠️ [CACHE] Memory cache miss - parsing from disk...');
      final stopwatch = Stopwatch()..start();

      // Parse in isolate to avoid blocking UI
      _memoryCache = await compute(_parseExpensesJson, json);

      stopwatch.stop();
      debugPrint('  📊 [CACHE] Parsed ${_memoryCache!.length} expenses in ${stopwatch.elapsedMilliseconds}ms');

      return _memoryCache;
    } catch (e) {
      debugPrint('❌ Error loading cached expenses: $e');
      return null;
    }
  }

  /// Check if cache is from current month (stale if month changed)
  bool isCacheFromCurrentMonth() {
    final timestamp = _prefs?.getInt(_cacheTimestampKey);
    if (timestamp == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return cacheDate.year == now.year && cacheDate.month == now.month;
  }

  /// Clear expense cache (called on logout or data reset)
  Future<void> clearExpenseCache() async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs!.remove(_currentMonthCacheKey);
    await _prefs!.remove(_cacheTimestampKey);
    debugPrint('🗑️ Expense cache cleared');
  }
}
