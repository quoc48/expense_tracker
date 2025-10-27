import '../models/expense.dart';
import '../services/supabase_service.dart';
import 'expense_repository.dart';

/// Supabase implementation of ExpenseRepository
///
/// This repository fetches expense data from Supabase cloud database.
/// It handles:
/// - UUID-based references to categories and types
/// - Vietnamese → English mapping for categories/types
/// - Row Level Security (user-specific data)
/// - Real-time updates (future enhancement)
class SupabaseExpenseRepository implements ExpenseRepository {
  // Category mapping: Vietnamese names → English enums
  // These match the Vietnamese names in the Supabase categories table
  // Made public so the form screen can use the same mapping
  static const Map<String, Category> categoryMapping = {
    'Thực phẩm': Category.food,
    'Đi lại': Category.transportation,
    'Hoá đơn': Category.utilities,
    'Giải trí': Category.entertainment,
    'Tạp hoá': Category.shopping,
    'Thời trang': Category.shopping,
    'Sức khỏe': Category.health,
    'Giáo dục': Category.education,
    'Cà phê': Category.food,
    'Du lịch': Category.entertainment,
    'Tiền nhà': Category.utilities,
    'Quà vật': Category.other,
    'Biểu gia đình': Category.other,
    'TẾT': Category.other,
  };

  // Reverse mapping: English enums → Vietnamese names (for creating expenses)
  static const Map<Category, String> _reverseCategoryMapping = {
    Category.food: 'Thực phẩm',
    Category.transportation: 'Đi lại',
    Category.utilities: 'Hoá đơn',
    Category.entertainment: 'Giải trí',
    Category.shopping: 'Tạp hoá',
    Category.health: 'Sức khỏe',
    Category.education: 'Giáo dục',
    Category.other: 'Quà vật',
  };

  // Type mapping: Vietnamese names → English enums
  // Made public so the form screen can use the same mapping
  static const Map<String, ExpenseType> typeMapping = {
    'Phải chi': ExpenseType.mustHave,
    'Phát sinh': ExpenseType.niceToHave,
    'Lãng phí': ExpenseType.wasted,
  };

  // Reverse mapping: English enums → Vietnamese names
  static const Map<ExpenseType, String> _reverseTypeMapping = {
    ExpenseType.mustHave: 'Phải chi',
    ExpenseType.niceToHave: 'Phát sinh',
    ExpenseType.wasted: 'Lãng phí',
  };

  // Cache for category/type UUIDs (to avoid repeated lookups)
  Map<String, String>? _categoryIdMap; // Vietnamese name → UUID
  Map<String, String>? _typeIdMap; // Vietnamese name → UUID

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

  /// Convert Supabase row to Expense model
  ///
  /// Maps Vietnamese category/type names to English enums
  Expense _fromSupabaseRow(Map<String, dynamic> row) {
    // Extract category and type Vietnamese names
    // (Supabase query should join the tables to get these)
    final categoryVi = row['categories']?['name_vi'] as String? ?? '';
    final typeVi = row['expense_types']?['name_vi'] as String? ?? '';

    // Map to English enums (with fallback)
    final category =
        categoryMapping[categoryVi] ?? Category.other;
    final type = typeMapping[typeVi] ?? ExpenseType.niceToHave;

    return Expense(
      id: row['id'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      category: category,
      type: type,
      date: DateTime.parse(row['date'] as String),
      note: row['note'] as String?,
    );
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
        .map((row) => _fromSupabaseRow(row as Map<String, dynamic>))
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
    return _fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<Expense> create(Expense expense, {String? categoryNameVi, String? typeNameVi}) async {
    await _ensureMappingsLoaded();

    // Use provided Vietnamese names if available, otherwise fall back to reverse mapping
    final categoryVi = categoryNameVi ?? (_reverseCategoryMapping[expense.category] ?? 'Quà vật');
    final typeVi = typeNameVi ?? (_reverseTypeMapping[expense.type] ?? 'Phát sinh');

    // Get UUIDs
    final categoryId = _categoryIdMap![categoryVi];
    final typeId = _typeIdMap![typeVi];

    if (categoryId == null || typeId == null) {
      throw Exception('Category or type not found in Supabase');
    }

    // Get current user ID
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Insert into Supabase
    final response = await supabase
        .from('expenses')
        .insert({
          'id': expense.id,
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

    return _fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<Expense> update(Expense expense, {String? categoryNameVi, String? typeNameVi}) async {
    await _ensureMappingsLoaded();

    // Use provided Vietnamese names if available, otherwise fall back to reverse mapping
    final categoryVi = categoryNameVi ?? (_reverseCategoryMapping[expense.category] ?? 'Quà vật');
    final typeVi = typeNameVi ?? (_reverseTypeMapping[expense.type] ?? 'Phát sinh');

    // Get UUIDs
    final categoryId = _categoryIdMap![categoryVi];
    final typeId = _typeIdMap![typeVi];

    if (categoryId == null || typeId == null) {
      throw Exception('Category or type not found in Supabase');
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

    return _fromSupabaseRow(response as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('expenses').delete().eq('id', id);
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
        .map((row) => _fromSupabaseRow(row as Map<String, dynamic>))
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
