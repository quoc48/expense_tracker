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
class SupabaseExpenseRepository implements ExpenseRepository {
  // Cache for category/type UUIDs (to avoid repeated lookups)
  Map<String, String>? _categoryIdMap; // Vietnamese name → UUID
  Map<String, String>? _typeIdMap;     // Vietnamese name → UUID

  // UUID generator for creating new expense IDs
  final _uuid = const Uuid();

  /// Initialize category and type ID mappings from Supabase
  ///
  /// This fetches the categories and expense_types tables once
  /// and caches the UUID mappings for future use.
  Future<void> _ensureMappingsLoaded() async {
    if (_categoryIdMap != null && _typeIdMap != null) {
      return; // Already loaded
    }

    // Fetch categories
    final categoriesResponse =
        await supabase.from('categories').select('id, name_vi');

    _categoryIdMap = {};
    for (final cat in categoriesResponse) {
      _categoryIdMap![cat['name_vi'] as String] = cat['id'] as String;
    }

    // Fetch expense types
    final typesResponse =
        await supabase.from('expense_types').select('id, name_vi');

    _typeIdMap = {};
    for (final type in typesResponse) {
      _typeIdMap![type['name_vi'] as String] = type['id'] as String;
    }
  }

  @override
  Future<List<Expense>> getAll() async {
    await _ensureMappingsLoaded();

    // Query expenses with joined category and type names
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

    return (response as List)
        .map((row) => Expense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();
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
        .gte('date', start.toIso8601String().split('T')[0])
        .lte('date', end.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    return (response as List)
        .map((row) => Expense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();
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
