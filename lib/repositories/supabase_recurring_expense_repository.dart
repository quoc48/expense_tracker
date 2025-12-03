import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/recurring_expense.dart';
import '../services/supabase_service.dart';
import 'recurring_expense_repository.dart';

/// Supabase implementation of RecurringExpenseRepository
///
/// **Database Schema:**
/// The `recurring_expenses` table mirrors the `expenses` table structure
/// with additional fields for recurring logic:
///
/// ```sql
/// CREATE TABLE recurring_expenses (
///   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   user_id UUID REFERENCES auth.users(id) NOT NULL,
///   category_id UUID REFERENCES categories(id) NOT NULL,
///   type_id UUID REFERENCES expense_types(id) NOT NULL,
///   description TEXT NOT NULL,
///   amount NUMERIC NOT NULL,
///   start_date DATE NOT NULL DEFAULT CURRENT_DATE,
///   last_created_date DATE,  -- NULL means never created
///   is_active BOOLEAN NOT NULL DEFAULT true,
///   note TEXT,
///   created_at TIMESTAMPTZ DEFAULT NOW()
/// );
/// ```
///
/// **Row Level Security (RLS):**
/// Same as expenses table - users can only access their own recurring expenses.
class SupabaseRecurringExpenseRepository implements RecurringExpenseRepository {
  // Cache for category/type UUIDs (to avoid repeated lookups)
  Map<String, String>? _categoryIdMap; // Vietnamese name → UUID
  Map<String, String>? _typeIdMap; // Vietnamese name → UUID

  // UUID generator for creating new IDs
  final _uuid = const Uuid();

  /// Initialize category and type ID mappings from Supabase
  ///
  /// **Why cache these?**
  /// Categories and expense types rarely change, so fetching once
  /// and caching avoids repeated database calls when creating/updating.
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

    debugPrint('📦 Loaded ${_categoryIdMap!.length} categories and ${_typeIdMap!.length} types');
  }

  /// Standard select query with joined category and type names
  static const String _selectQuery = '''
    id,
    description,
    amount,
    start_date,
    last_created_date,
    is_active,
    note,
    categories!inner(name_vi),
    expense_types!inner(name_vi)
  ''';

  @override
  Future<List<RecurringExpense>> getAll() async {
    await _ensureMappingsLoaded();

    final response = await supabase
        .from('recurring_expenses')
        .select(_selectQuery)
        .order('is_active', ascending: false) // Active first
        .order('description', ascending: true);

    return (response as List)
        .map((row) => RecurringExpense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecurringExpense>> getActive() async {
    await _ensureMappingsLoaded();

    final response = await supabase
        .from('recurring_expenses')
        .select(_selectQuery)
        .eq('is_active', true)
        .order('description', ascending: true);

    return (response as List)
        .map((row) => RecurringExpense.fromSupabaseRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RecurringExpense?> getById(String id) async {
    await _ensureMappingsLoaded();

    final response = await supabase
        .from('recurring_expenses')
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return RecurringExpense.fromSupabaseRow(response);
  }

  @override
  Future<RecurringExpense> create(RecurringExpense expense) async {
    await _ensureMappingsLoaded();

    // Get UUIDs for category and type
    final categoryId = _categoryIdMap![expense.categoryNameVi];
    final typeId = _typeIdMap![expense.typeNameVi];

    if (categoryId == null || typeId == null) {
      throw Exception(
          'Category "${expense.categoryNameVi}" or type "${expense.typeNameVi}" not found');
    }

    // Get current user
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Generate ID if not provided
    final expenseId = expense.id.isNotEmpty ? expense.id : _uuid.v4();

    final response = await supabase
        .from('recurring_expenses')
        .insert({
          'id': expenseId,
          'user_id': user.id,
          'category_id': categoryId,
          'type_id': typeId,
          'description': expense.description,
          'amount': expense.amount,
          'start_date': expense.startDate.toIso8601String().split('T')[0],
          'last_created_date': expense.lastCreatedDate?.toIso8601String().split('T')[0],
          'is_active': expense.isActive,
          'note': expense.note,
        })
        .select(_selectQuery)
        .single();

    debugPrint('✅ Created recurring expense: ${expense.description}');
    return RecurringExpense.fromSupabaseRow(response);
  }

  @override
  Future<RecurringExpense> update(RecurringExpense expense) async {
    await _ensureMappingsLoaded();

    // Get UUIDs for category and type
    final categoryId = _categoryIdMap![expense.categoryNameVi];
    final typeId = _typeIdMap![expense.typeNameVi];

    if (categoryId == null || typeId == null) {
      throw Exception(
          'Category "${expense.categoryNameVi}" or type "${expense.typeNameVi}" not found');
    }

    final response = await supabase
        .from('recurring_expenses')
        .update({
          'category_id': categoryId,
          'type_id': typeId,
          'description': expense.description,
          'amount': expense.amount,
          'is_active': expense.isActive,
          'note': expense.note,
        })
        .eq('id', expense.id)
        .select(_selectQuery)
        .single();

    debugPrint('✅ Updated recurring expense: ${expense.description}');
    return RecurringExpense.fromSupabaseRow(response);
  }

  @override
  Future<RecurringExpense> toggleActive(String id, bool isActive) async {
    final response = await supabase
        .from('recurring_expenses')
        .update({'is_active': isActive})
        .eq('id', id)
        .select(_selectQuery)
        .single();

    debugPrint('✅ Toggled recurring expense active=$isActive');
    return RecurringExpense.fromSupabaseRow(response);
  }

  @override
  Future<void> updateLastCreatedDate(String id, DateTime date) async {
    await supabase
        .from('recurring_expenses')
        .update({
          'last_created_date': date.toIso8601String().split('T')[0],
        })
        .eq('id', id);

    debugPrint('✅ Updated last_created_date for recurring expense $id');
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('🗑️ Deleting recurring expense: $id');

    final response = await supabase
        .from('recurring_expenses')
        .delete()
        .eq('id', id)
        .select();

    if ((response as List).isEmpty) {
      debugPrint('⚠️ WARNING: Delete returned empty - likely blocked by RLS!');
      throw Exception(
          'Delete failed - Row Level Security may be blocking delete operations');
    }

    debugPrint('✅ Successfully deleted recurring expense');
  }

  @override
  Future<List<String>> getCategories() async {
    await _ensureMappingsLoaded();
    final categories = _categoryIdMap!.keys.toList()..sort();
    return categories;
  }

  @override
  Future<List<String>> getExpenseTypes() async {
    await _ensureMappingsLoaded();
    return _typeIdMap!.keys.toList();
  }
}
