import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/learning/pattern_model.dart';

void main() {
  test('Debug pattern scoring', () {
    // Create a simple test pattern
    final pattern = CategoryPattern(
      categoryName: 'Cà phê',
      keywords: {'coffee', 'highlands', 'starbucks'},
      merchantFrequency: {'highlands coffee': 10},
      totalCount: 30,
      confidence: 0.85,
    );

    // Test various descriptions
    final testCases = {
      'Highlands Coffee Americano': 'Should match merchant',
      'Just some coffee': 'Should match keyword',
      'Random text': 'Should not match',
      'highlands': 'Should match partial merchant',
    };

    for (final entry in testCases.entries) {
      final score = pattern.matchScore(entry.key);
      print('Description: "${entry.key}"');
      print('  Expected: ${entry.value}');
      print('  Score: $score');
      print('  Confidence: ${pattern.confidence}');
      print('---');
    }

    // Check specific expected scores
    expect(pattern.matchScore('Highlands Coffee Americano'),
           greaterThan(0.3),
           reason: 'Merchant match should score > 0.3');

    expect(pattern.matchScore('Just some coffee'),
           greaterThan(0.0),
           reason: 'Keyword match should score > 0');

    expect(pattern.matchScore('Random text'),
           equals(0.0),
           reason: 'No match should score 0');
  });
}