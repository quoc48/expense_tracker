import 'dart:math';

import 'package:flutter/foundation.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import 'pattern_model.dart';
import 'pattern_storage.dart';

/// Service for learning patterns from historical expense data
///
/// This service analyzes existing expenses to build intelligent patterns
/// for automatic categorization. It learns from user behavior and improves
/// categorization accuracy over time.
class ExpensePatternService extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final PatternStorage _patternStorage;

  PatternModel? _patternModel;
  bool _isLearning = false;
  String? _learningStatus;
  double _learningProgress = 0.0;

  ExpensePatternService({
    required ExpenseRepository expenseRepository,
    PatternStorage? patternStorage,
  })  : _expenseRepository = expenseRepository,
        _patternStorage = patternStorage ?? PatternStorage();

  PatternModel? get patternModel => _patternModel;
  bool get isLearning => _isLearning;
  String? get learningStatus => _learningStatus;
  double get learningProgress => _learningProgress;

  /// Initialize the service and load existing patterns
  Future<void> initialize() async {
    try {
      _patternModel = await _patternStorage.loadPatterns();

      // If no patterns exist or they're old, learn from historical data
      if (_patternModel == null || _shouldUpdatePatterns()) {
        await learnFromHistoricalData();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing pattern service: $e');
    }
  }

  /// Check if patterns need updating (older than 7 days)
  bool _shouldUpdatePatterns() {
    if (_patternModel == null) return true;

    final daysSinceUpdate = DateTime.now()
        .difference(_patternModel!.lastUpdated)
        .inDays;

    return daysSinceUpdate >= 7;
  }

  /// Learn patterns from all historical expense data
  Future<void> learnFromHistoricalData() async {
    if (_isLearning) return;

    _isLearning = true;
    _learningProgress = 0.0;
    _learningStatus = 'Loading expenses...';
    notifyListeners();

    try {
      // Load all expenses from repository
      final expenses = await _expenseRepository.getAll();

      if (expenses.isEmpty) {
        _learningStatus = 'No expenses to learn from';
        _isLearning = false;
        notifyListeners();
        return;
      }

      _learningStatus = 'Analyzing ${expenses.length} expenses...';
      _learningProgress = 0.1;
      notifyListeners();

      // Group expenses by category
      final Map<String, List<Expense>> categoryGroups = {};
      for (final expense in expenses) {
        final category = expense.categoryNameVi;
        categoryGroups[category] ??= [];
        categoryGroups[category]!.add(expense);
      }

      _learningProgress = 0.2;
      notifyListeners();

      // Build patterns for each category
      final Map<String, CategoryPattern> patterns = {};
      int processedCategories = 0;

      for (final entry in categoryGroups.entries) {
        final categoryName = entry.key;
        final categoryExpenses = entry.value;

        _learningStatus = 'Learning "$categoryName" patterns...';
        notifyListeners();

        final pattern = _buildCategoryPattern(
          categoryName,
          categoryExpenses,
        );

        patterns[categoryName] = pattern;

        processedCategories++;
        _learningProgress = 0.2 + (0.7 * processedCategories / categoryGroups.length);
        notifyListeners();
      }

      // Create and save the pattern model
      _patternModel = PatternModel(
        patterns: patterns,
        lastUpdated: DateTime.now(),
        totalExpenses: expenses.length,
        version: 1,
      );

      await _patternStorage.savePatterns(_patternModel!);

      _learningProgress = 1.0;
      _learningStatus = 'Learning complete! Analyzed ${expenses.length} expenses';

      // Print summary for debugging
      _printLearningSummary();

      notifyListeners();

      // Clear learning status after a delay
      await Future.delayed(const Duration(seconds: 2));
      _isLearning = false;
      _learningStatus = null;
      notifyListeners();

    } catch (e) {
      debugPrint('Error learning from historical data: $e');
      _learningStatus = 'Learning failed: $e';
      _isLearning = false;
      notifyListeners();
    }
  }

  /// Build pattern for a specific category from its expenses
  CategoryPattern _buildCategoryPattern(
    String categoryName,
    List<Expense> expenses,
  ) {
    final pattern = CategoryPattern(
      categoryName: categoryName,
      totalCount: expenses.length,
    );

    // Extract keywords and merchants from descriptions
    final Map<String, int> wordFrequency = {};
    final Set<String> commonWords = _getCommonVietnameseWords();
    double totalAmount = 0.0;

    for (final expense in expenses) {
      final description = expense.description.toLowerCase();
      totalAmount += expense.amount;

      // Add as example (keep recent ones)
      pattern.addExample(expense.description);

      // Track expense type frequency
      final typeNameVi = expense.typeNameVi;
      pattern.typeFrequency[typeNameVi] = (pattern.typeFrequency[typeNameVi] ?? 0) + 1;

      // Extract potential merchant names (first 2-3 words often are merchant)
      final words = description.split(RegExp(r'[\s,\-–]+'));

      // Look for potential merchant patterns
      if (words.isNotEmpty) {
        // Check if first words look like a merchant name
        String potentialMerchant = '';

        for (int i = 0; i < min(3, words.length); i++) {
          final word = words[i];

          // Skip common words and numbers
          if (commonWords.contains(word) || _isNumber(word)) {
            break;
          }

          // Build potential merchant name
          if (potentialMerchant.isNotEmpty) {
            potentialMerchant += ' ';
          }
          potentialMerchant += word;

          // Common merchant patterns
          if (_looksLikeMerchant(potentialMerchant)) {
            pattern.addMerchant(potentialMerchant);
            break;
          }
        }
      }

      // Extract meaningful keywords (skip common words)
      for (final word in words) {
        if (word.length >= 3 &&
            !commonWords.contains(word) &&
            !_isNumber(word)) {
          wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
        }
      }
    }

    // Add top keywords (words that appear in at least 10% of expenses)
    final minFrequency = max(2, expenses.length ~/ 10);
    wordFrequency.forEach((word, count) {
      if (count >= minFrequency) {
        pattern.addKeyword(word);
      }
    });

    // Calculate average amount
    pattern.averageAmount = expenses.isNotEmpty
        ? totalAmount / expenses.length
        : 0.0;

    // Set initial confidence based on sample size
    pattern.confidence = _calculateConfidence(expenses.length);

    return pattern;
  }

  /// Calculate confidence score based on sample size
  double _calculateConfidence(int sampleSize) {
    // Logarithmic confidence growth
    // 10 samples = 0.5, 50 samples = 0.75, 100+ samples = 0.85+
    if (sampleSize <= 1) return 0.3;
    if (sampleSize <= 5) return 0.4;
    if (sampleSize <= 10) return 0.5;
    if (sampleSize <= 20) return 0.6;
    if (sampleSize <= 50) return 0.75;
    if (sampleSize <= 100) return 0.85;
    return 0.95;
  }

  /// Check if a string looks like a number
  bool _isNumber(String str) {
    return RegExp(r'^\d+([.,]\d+)?$').hasMatch(str);
  }

  /// Check if string looks like a merchant name
  bool _looksLikeMerchant(String str) {
    // Common merchant patterns in Vietnamese receipts
    final merchantPatterns = [
      'grab', 'be', 'shopee', 'lazada', 'tiki',
      'lotte', 'vinmart', 'circle k', 'family mart', '7-eleven',
      'highlands', 'starbucks', 'phuc long', 'gong cha',
      'pizza', 'burger', 'kfc', 'mcdonalds', 'jollibee',
      'cgv', 'galaxy', 'beta', 'lotte cinema',
      'phở', 'bún', 'cơm', 'bánh', 'cafe', 'coffee',
      'restaurant', 'quán', 'nhà hàng', 'mart', 'market',
    ];

    final lower = str.toLowerCase();

    // Check if contains known merchant keywords
    for (final pattern in merchantPatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    // Check if it's capitalized like a brand name
    if (str.isNotEmpty && str[0] == str[0].toUpperCase()) {
      return true;
    }

    return false;
  }

  /// Get common Vietnamese words to exclude from keywords
  Set<String> _getCommonVietnameseWords() {
    return {
      // Vietnamese common words
      'và', 'của', 'cho', 'với', 'trong', 'trên', 'dưới',
      'từ', 'đến', 'qua', 'về', 'được', 'không', 'có',
      'này', 'đó', 'kia', 'ở', 'tại', 'bằng', 'như',
      'mua', 'bán', 'tiền', 'thanh', 'toán', 'chi', 'trả',

      // English common words often in receipts
      'the', 'and', 'or', 'for', 'with', 'at', 'in', 'on',
      'to', 'from', 'by', 'of', 'is', 'was', 'are', 'were',
      'payment', 'paid', 'total', 'amount', 'bill', 'invoice',

      // Numbers and units
      'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín', 'mười',
      'vnd', 'đ', 'đồng', 'k', 'tr', 'triệu', 'ngàn',
      'kg', 'g', 'l', 'ml', 'cái', 'chiếc', 'bộ', 'hộp',
    };
  }

  /// Get best matching category for a description
  String? suggestCategory(String description) {
    if (_patternModel == null) return null;
    return _patternModel!.getBestMatch(description);
  }

  /// Get match confidence for a specific category
  double getCategoryConfidence(String description, String category) {
    if (_patternModel == null) return 0.0;
    return _patternModel!.getConfidence(description, category);
  }

  /// Suggest expense type based on category pattern
  /// Returns the most common type for the matched category
  String? suggestType(String description, {String? categoryNameVi}) {
    if (_patternModel == null) return null;

    // Use provided category or find best match
    final category = categoryNameVi ?? _patternModel!.getBestMatch(description);
    if (category == null) return null;

    // Get the pattern for this category
    final pattern = _patternModel!.patterns[category];
    if (pattern == null) return null;

    // Return the most common type for this category
    return pattern.getMostCommonType();
  }

  /// Manually update pattern when user corrects a categorization
  Future<void> updatePatternFromCorrection(
    String description,
    String correctCategory,
  ) async {
    if (_patternModel == null) return;

    final pattern = _patternModel!.patterns[correctCategory];
    if (pattern != null) {
      // Add this as a new example
      pattern.addExample(description);

      // Extract and add potential keywords
      final words = description.toLowerCase().split(RegExp(r'[\s,\-–]+'));
      for (final word in words) {
        if (word.length >= 3 && !_isNumber(word)) {
          // Add frequently corrected words as keywords
          if (pattern.exampleDescriptions
              .where((e) => e.toLowerCase().contains(word))
              .length >= 2) {
            pattern.addKeyword(word);
          }
        }
      }

      // Increase confidence slightly for user corrections
      pattern.confidence = min(0.99, pattern.confidence + 0.01);

      // Save updated patterns
      await _patternStorage.savePatterns(_patternModel!);
      notifyListeners();
    }
  }

  /// Print learning summary for debugging
  void _printLearningSummary() {
    if (_patternModel == null) return;

    debugPrint('\n=== Pattern Learning Summary ===');
    debugPrint('Total expenses analyzed: ${_patternModel!.totalExpenses}');
    debugPrint('Categories learned: ${_patternModel!.patterns.length}');

    for (final pattern in _patternModel!.patterns.values) {
      debugPrint('\n📂 ${pattern.categoryName}:');
      debugPrint('  - Samples: ${pattern.totalCount}');
      debugPrint('  - Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%');
      debugPrint('  - Avg amount: ${pattern.averageAmount.toStringAsFixed(0)}đ');

      if (pattern.keywords.isNotEmpty) {
        debugPrint('  - Keywords: ${pattern.keywords.take(5).join(", ")}');
      }

      if (pattern.merchantFrequency.isNotEmpty) {
        final topMerchants = pattern.merchantFrequency.entries
            .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
        debugPrint('  - Top merchants: ${topMerchants.take(3).map((e) => e.key).join(", ")}');
      }
    }
    debugPrint('===============================\n');
  }

  /// Clear all learned patterns
  Future<void> clearPatterns() async {
    _patternModel = null;
    await _patternStorage.clearPatterns();
    notifyListeners();
  }

}