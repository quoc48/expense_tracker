import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/supabase_service.dart';
import 'expense_repository.dart';

/// Supabase implementation of ExpenseRepository (SIMPLIFIED - Phase 5.5.1)
///
/// Architecture Change:
/// - BEFORE: Complex Vietnamese ↔ English enum mappings, data loss issues
/// - AFTER: Use Vietnamese strings directly from Supabase, zero mappings!
///
/// Benefits:
/// - Simpler code (no mapping dictionaries)
/// - Zero data loss (Cà phê stays Cà phê)
/// - Supabase is the single source of truth
/// - Future-proof (add categories in Supabase without code changes)
///
/// **SINGLETON PATTERN** - All usages share the same cached mappings!
/// This ensures category/type ID caches persist across all screens.
class SupabaseExpenseRepository implements ExpenseRepository {
  // Singleton instance
  static final SupabaseExpenseRepository _instance = SupabaseExpenseRepository._internal();

  // Factory constructor returns singleton
  factory SupabaseExpenseRepository() => _instance;

  // Private constructor for singleton
  SupabaseExpenseRepository._internal();

  // Cache for category/type UUIDs (to avoid repeated lookups)
  // Now shared across ALL usages thanks to singleton pattern!
  Map<String, String>? _categoryIdMap; // Vietnamese name → UUID
  Map<String, String>? _typeIdMap;     // Vietnamese name → UUID

  // Lock to prevent multiple parallel loads of mappings (race condition fix)
  Future<void>? _mappingsLoadFuture;

  // UUID generator for creating new expense IDs
  final _uuid = const Uuid();

  /// Initialize category and type ID mappings from Supabase
  ///
  /// This fetches the categories and expense_types tables once
  /// and caches the UUID mappings for future use.
  ///
  /// Performance: Uses Future.wait for parallel fetching instead of sequential.
  /// Race condition fix: Uses _mappingsLoadFuture lock to prevent duplicate loads.
  Future<void> _ensureMappingsLoaded() async {
    // Already cached - instant return
    if (_categoryIdMap != null && _typeIdMap != null) {
      return;
    }

    // Another load in progress - wait for it instead of starting a new one
    if (_mappingsLoadFuture != null) {
      debugPrint('📊 [PERF] _ensureMappingsLoaded: waiting for existing load...');
      await _mappingsLoadFuture;
      return;
    }

    // Start new load and store the future for others to wait on
    _mappingsLoadFuture = _doLoadMappings();
    await _mappingsLoadFuture;
    _mappingsLoadFuture = null; // Clear after completion
  }

  /// Internal method that actually loads the mappings
  Future<void> _doLoadMappings() async {
    final stopwatch = Stopwatch()..start();

    // OPTIMIZATION: Parallel fetch using Future.wait instead of sequential
    final results = await Future.wait([
      supabase.from('categories').select('id, name_vi'),
      supabase.from('expense_types').select('id, name_vi'),
    ]);

    final categoriesResponse = results[0];
    final typesResponse = results[1];

    _categoryIdMap = {};
    for (final cat in categoriesResponse) {
      _categoryIdMap![cat['name_vi'] as String] = cat['id'] as String;
    }

    _typeIdMap = {};
    for (final type in typesResponse) {
      _typeIdMap![type['name_vi'] as String] = type['id'] as String;
    }

    stopwatch.stop();
    debugPrint('📊 [PERF] _ensureMappingsLoaded: ${stopwatch.elapsedMilliseconds}ms '
        '(categories: ${_categoryIdMap!.length}, types: ${_typeIdMap!.length})');
  }

  @override
  Future<List<Expense>> getAll() async {
    final totalStopwatch = Stopwatch()..start();

    // OPTIMIZATION: Fire-and-forget mappings load
    // getAll() uses SQL joins for category/type names, so doesn't need mappings
    // Mappings are only needed for create/update operations
    // Starting load now so they're ready when user adds an expense
    _ensureMappingsLoaded(); // No await - runs in background

    // Query expenses with joined category and type names
    final queryStopwatch = Stopwatch()..start();
    final response = await supabase
        .from('expenses')
        .select('''
          id,
          description,
          amount,
          date,
          note,
          categories!inner(name_vi),
          expense_types!inner(name_vi)
        ''')
        .order('date', ascending: false);
    queryStopwatch.stop();

    final expenses = (response as List)
        .map((row) => Expense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();

    totalStopwatch.stop();
    debugPrint('📊 [PERF] getAll: ${totalStopwatch.elapsedMilliseconds}ms '
        '(query: ${queryStopwatch.elapsedMilliseconds}ms, count: ${expenses.length})');

    return expenses;
  }

  @override
  Future<Expense?> getById(String id) async {
    await _ensureMappingsLoaded();

    final response = await supabase
        .from('expenses')
        .select('''
          id,
          description,
          amount,
          date,
          note,
          categories!inner(name_vi),
          expense_types!inner(name_vi)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Expense.fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<Expense> create(Expense expense, {String? categoryNameVi, String? typeNameVi}) async {
    await _ensureMappingsLoaded();

    // Use the Vietnamese names from the expense object
    // (categoryNameVi/typeNameVi parameters are now redundant but kept for compatibility)
    final categoryVi = expense.categoryNameVi;
    final typeVi = expense.typeNameVi;

    // Get UUIDs
    final categoryId = _categoryIdMap![categoryVi];
    final typeId = _typeIdMap![typeVi];

    if (categoryId == null || typeId == null) {
      throw Exception('Category "$categoryVi" or type "$typeVi" not found in Supabase');
    }

    // Get current user ID
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Insert into Supabase
    // Generate a new UUID if the expense doesn't have an ID
    final expenseId = expense.id.isNotEmpty ? expense.id : _uuid.v4();

    final response = await supabase
        .from('expenses')
        .insert({
          'id': expenseId,
          'user_id': user.id,
          'category_id': categoryId,
          'type_id': typeId,
          'description': expense.description,
          'amount': expense.amount,
          'date': expense.date.toIso8601String().split('T')[0], // Date only
          'note': expense.note,
        })
        .select('''
          id,
          description,
          amount,
          date,
          note,
          categories!inner(name_vi),
          expense_types!inner(name_vi)
        ''')
        .single();

    return Expense.fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<Expense> update(Expense expense, {String? categoryNameVi, String? typeNameVi}) async {
    await _ensureMappingsLoaded();

    // Use the Vietnamese names from the expense object
    final categoryVi = expense.categoryNameVi;
    final typeVi = expense.typeNameVi;

    // Get UUIDs
    final categoryId = _categoryIdMap![categoryVi];
    final typeId = _typeIdMap![typeVi];

    if (categoryId == null || typeId == null) {
      throw Exception('Category "$categoryVi" or type "$typeVi" not found in Supabase');
    }

    // Update in Supabase
    final response = await supabase
        .from('expenses')
        .update({
          'category_id': categoryId,
          'type_id': typeId,
          'description': expense.description,
          'amount': expense.amount,
          'date': expense.date.toIso8601String().split('T')[0],
          'note': expense.note,
        })
        .eq('id', expense.id)
        .select('''
          id,
          description,
          amount,
          date,
          note,
          categories!inner(name_vi),
          expense_types!inner(name_vi)
        ''')
        .single();

    return Expense.fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('🔍 Repository: Attempting to delete expense: $id');

    final response = await supabase
        .from('expenses')
        .delete()
        .eq('id', id)
        .select();  // Add select() to get the deleted row back

    debugPrint('🔍 Repository: Delete response: $response');

    // Check if anything was actually deleted
    if ((response as List).isEmpty) {
      debugPrint('⚠️ WARNING: Delete returned empty - likely blocked by RLS!');
      throw Exception('Delete failed - Row Level Security may be blocking delete operations');
    }

    debugPrint('✅ Repository: Successfully deleted expense from database');
  }

  @override
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final stopwatch = Stopwatch()..start();

    // OPTIMIZATION: Fire-and-forget mappings load
    // getByDateRange uses SQL JOINs for names, doesn't need mappings
    // Mappings only needed for create/update operations
    _ensureMappingsLoaded(); // No await - runs in background

    final response = await supabase
        .from('expenses')
        .select('''
          id,
          description,
          amount,
          date,
          note,
          categories!inner(name_vi),
          expense_types!inner(name_vi)
        ''')
        .gte('date', start.toIso8601String().split('T')[0])
        .lte('date', end.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    final expenses = (response as List)
        .map((row) => Expense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();

    stopwatch.stop();
    debugPrint('📊 [PERF] getByDateRange: ${stopwatch.elapsedMilliseconds}ms '
        '(${expenses.length} expenses, ${start.month}/${start.year} - ${end.month}/${end.year})');

    return expenses;
  }

  @override
  Future<int> getCount() async {
    final response = await supabase
        .from('expenses')
        .select('id');

    return (response as List).length;
  }

  @override
  Future<List<String>> getCategories() async {
    await _ensureMappingsLoaded();

    // Return all Vietnamese category names sorted alphabetically
    final categories = _categoryIdMap!.keys.toList()..sort();
    return categories;
  }

  @override
  Future<List<String>> getExpenseTypes() async {
    await _ensureMappingsLoaded();

    // Return Vietnamese expense type names
    return _typeIdMap!.keys.toList();
  }
}
