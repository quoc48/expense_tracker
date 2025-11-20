import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/learning/pattern_model.dart';

void main() {
  group('Pattern Matching Tests', () {
    late PatternModel patternModel;

    setUp(() {
      // Create test patterns based on common Vietnamese expense patterns
      final patterns = <String, CategoryPattern>{};

      // Coffee pattern
      patterns['Cà phê'] = CategoryPattern(
        categoryName: 'Cà phê',
        keywords: {'coffee', 'highlands', 'starbucks', 'trà', 'sữa'},
        merchantFrequency: {
          'highlands coffee': 10,
          'starbucks': 8,
          'the coffee house': 6,
        },
        totalCount: 30,
        confidence: 0.85,
      );

      // Food pattern
      patterns['Thực phẩm'] = CategoryPattern(
        categoryName: 'Thực phẩm',
        keywords: {'thịt', 'cá', 'rau', 'trái', 'bánh', 'mì', 'phở'},
        merchantFrequency: {
          'lotte mart': 15,
          'vinmart': 12,
          'bách hoá xanh': 10,
        },
        totalCount: 50,
        confidence: 0.90,
      );

      // Transportation pattern
      patterns['Đi lại'] = CategoryPattern(
        categoryName: 'Đi lại',
        keywords: {'grab', 'taxi', 'xăng', 'gas', 'uber'},
        merchantFrequency: {
          'grab': 20,
          'be': 15,
          'caltex': 8,
        },
        totalCount: 45,
        confidence: 0.88,
      );

      // Household/Groceries pattern
      patterns['Tạp hoá'] = CategoryPattern(
        categoryName: 'Tạp hoá',
        keywords: {'comfort', 'xà phòng', 'bột giặt', 'nước rửa', 'dầu gội'},
        merchantFrequency: {
          'guardian': 10,
          'watsons': 8,
        },
        totalCount: 25,
        confidence: 0.80,
      );

      patternModel = PatternModel(
        patterns: patterns,
        lastUpdated: DateTime.now(),
        totalExpenses: 150,
      );
    });

    test('Should match coffee items correctly', () {
      // Test merchant matching
      expect(
        patternModel.getBestMatch('highlands coffee americano'),
        equals('Cà phê'),
      );

      expect(
        patternModel.getBestMatch('Starbucks Latte'),
        equals('Cà phê'),
      );

      // Test keyword matching
      expect(
        patternModel.getBestMatch('Trà sữa trân châu'),
        equals('Cà phê'),
      );
    });

    test('Should match food items correctly', () {
      // Test merchant matching
      expect(
        patternModel.getBestMatch('Lotte Mart - Thịt heo'),
        equals('Thực phẩm'),
      );

      expect(
        patternModel.getBestMatch('VinMart - Rau cải'),
        equals('Thực phẩm'),
      );

      // Test keyword matching
      expect(
        patternModel.getBestMatch('Bánh mì thịt nướng'),
        equals('Thực phẩm'),
      );

      expect(
        patternModel.getBestMatch('Phở bò tái nạm'),
        equals('Thực phẩm'),
      );
    });

    test('Should match transportation items correctly', () {
      // Test merchant matching
      expect(
        patternModel.getBestMatch('Grab bike to office'),
        equals('Đi lại'),
      );

      expect(
        patternModel.getBestMatch('Be driver payment'),
        equals('Đi lại'),
      );

      // Test keyword matching
      expect(
        patternModel.getBestMatch('Taxi sân bay'),
        equals('Đi lại'),
      );

      expect(
        patternModel.getBestMatch('Xăng RON 95'),
        equals('Đi lại'),
      );
    });

    test('Should match household items correctly', () {
      // Test product name matching
      expect(
        patternModel.getBestMatch('XV Comfort concentrate'),
        equals('Tạp hoá'),
      );

      expect(
        patternModel.getBestMatch('Bột giặt OMO'),
        equals('Tạp hoá'),
      );

      // Test merchant matching
      expect(
        patternModel.getBestMatch('Guardian pharmacy'),
        equals('Tạp hoá'),
      );
    });

    test('Should return null for unmatched items', () {
      // Items that don't match any pattern strongly
      expect(
        patternModel.getBestMatch('Random text'),
        isNull,
      );

      expect(
        patternModel.getBestMatch('123456'),
        isNull,
      );
    });

    test('Should respect confidence threshold', () {
      // With default threshold (0.3)
      expect(
        patternModel.getBestMatch('coffee'),
        isNotNull,
      );

      // With high threshold (0.9) - should not match weak signals
      expect(
        patternModel.getBestMatch('coffee', threshold: 0.9),
        isNull,
      );
    });

    test('Should calculate confidence correctly', () {
      // Strong match (merchant name)
      final grabConfidence = patternModel.getConfidence(
        'Grab bike payment',
        'Đi lại',
      );
      expect(grabConfidence, greaterThan(0.5));

      // Weak match (only keyword)
      final coffeeConfidence = patternModel.getConfidence(
        'Some random coffee',
        'Cà phê',
      );
      expect(coffeeConfidence, lessThan(0.5));

      // No match
      final noMatchConfidence = patternModel.getConfidence(
        'Unrelated text',
        'Cà phê',
      );
      expect(noMatchConfidence, lessThan(0.1));
    });

    test('Pattern scoring should prioritize merchants over keywords', () {
      // Create a description that matches keywords from one category
      // but merchant from another
      final description = 'Grab - coffee delivery';

      // Should match 'Đi lại' (Grab merchant) over 'Cà phê' (coffee keyword)
      final match = patternModel.getBestMatch(description);
      expect(match, equals('Đi lại'));

      // Verify the confidence reflects merchant match
      final grabConfidence = patternModel.getConfidence(description, 'Đi lại');
      final coffeeConfidence = patternModel.getConfidence(description, 'Cà phê');
      expect(grabConfidence, greaterThan(coffeeConfidence));
    });

    test('JSON serialization should preserve all pattern data', () {
      // Convert to JSON and back
      final json = patternModel.toJson();
      final restored = PatternModel.fromJson(json);

      // Check that patterns are preserved
      expect(restored.patterns.length, equals(patternModel.patterns.length));
      expect(restored.totalExpenses, equals(patternModel.totalExpenses));

      // Check specific pattern details
      final coffeePattern = restored.patterns['Cà phê']!;
      expect(coffeePattern.keywords, equals({'coffee', 'highlands', 'starbucks', 'trà', 'sữa'}));
      expect(coffeePattern.merchantFrequency['highlands coffee'], equals(10));
      expect(coffeePattern.confidence, equals(0.85));
    });
  });
}