import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/learning/pattern_model.dart';

void main() {
  test('Simple pattern matching test', () {
    // Create a simple coffee pattern
    final coffeePattern = CategoryPattern(
      categoryName: 'Cà phê',
      keywords: {'coffee', 'highlands'},
      merchantFrequency: {'highlands coffee': 10},
      totalCount: 30,
      confidence: 0.85,
    );

    // Test the pattern directly
    final score1 = coffeePattern.matchScore('highlands coffee americano');
    print('Score for "highlands coffee americano": $score1');
    expect(score1, greaterThan(0.3), reason: 'Should match merchant');

    final score2 = coffeePattern.matchScore('just coffee');
    print('Score for "just coffee": $score2');
    expect(score2, greaterThan(0.0), reason: 'Should match keyword');

    // Now test with PatternModel
    final model = PatternModel(
      patterns: {'Cà phê': coffeePattern},
      lastUpdated: DateTime.now(),
      totalExpenses: 30,
    );

    final match1 = model.getBestMatch('highlands coffee americano');
    print('Best match for "highlands coffee americano": $match1');
    expect(match1, equals('Cà phê'));

    final match2 = model.getBestMatch('just coffee');
    print('Best match for "just coffee": $match2');
    // This should be null because keyword score is too low (< 0.3 threshold)
    expect(match2, isNull);

    final match3 = model.getBestMatch('just coffee', threshold: 0.05);
    print('Best match for "just coffee" with low threshold: $match3');
    expect(match3, equals('Cà phê'));
  });
}