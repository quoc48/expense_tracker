/// Data models for expense pattern learning
///
/// These models represent learned patterns from historical expense data
/// to improve categorization accuracy over time.

class CategoryPattern {
  final String categoryName;
  final Set<String> keywords;
  final Map<String, int> merchantFrequency;
  final List<String> exampleDescriptions;
  double averageAmount;  // Made mutable for learning updates
  final int totalCount;
  double confidence;

  // Track expense type frequency for this category
  // e.g., {"Phải chi": 150, "Phát sinh": 30, "Lãng phí": 5}
  final Map<String, int> typeFrequency;

  CategoryPattern({
    required this.categoryName,
    Set<String>? keywords,
    Map<String, int>? merchantFrequency,
    List<String>? exampleDescriptions,
    Map<String, int>? typeFrequency,
    this.averageAmount = 0.0,
    this.totalCount = 0,
    this.confidence = 0.5,
  })  : keywords = keywords ?? {},
        merchantFrequency = merchantFrequency ?? {},
        exampleDescriptions = exampleDescriptions ?? [],
        typeFrequency = typeFrequency ?? {};

  /// Add a keyword to this category's pattern
  void addKeyword(String keyword) {
    keywords.add(keyword.toLowerCase());
  }

  /// Record a merchant for this category
  void addMerchant(String merchant) {
    final key = merchant.toLowerCase();
    merchantFrequency[key] = (merchantFrequency[key] ?? 0) + 1;
  }

  /// Add an example description
  void addExample(String description) {
    if (exampleDescriptions.length >= 20) {
      exampleDescriptions.removeAt(0); // Keep only recent 20
    }
    exampleDescriptions.add(description);
  }

  /// Get the most common expense type for this category
  /// Returns null if no type data is available
  String? getMostCommonType() {
    if (typeFrequency.isEmpty) return null;

    // Find the type with highest frequency
    String? mostCommonType;
    int maxCount = 0;

    for (final entry in typeFrequency.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommonType = entry.key;
      }
    }

    return mostCommonType;
  }

  /// Get confidence score for a specific expense type
  /// Returns 0.0 if category has no type data
  double getTypeConfidence(String typeName) {
    if (typeFrequency.isEmpty) return 0.0;

    final typeCount = typeFrequency[typeName] ?? 0;
    return typeCount / totalCount;
  }

  /// Check if description matches this pattern
  double matchScore(String description) {
    final lower = description.toLowerCase();
    double score = 0.0;

    // Check merchant match (highest weight - 60% of total)
    bool merchantMatched = false;
    for (final merchant in merchantFrequency.keys) {
      if (lower.contains(merchant)) {
        // Give full merchant weight when matched (don't divide by totalCount)
        score += 0.6;
        merchantMatched = true;
        break;
      }
    }

    // Check keyword matches (medium weight - 30% of total)
    if (!merchantMatched && keywords.isNotEmpty) {
      int keywordMatches = 0;
      for (final keyword in keywords) {
        if (lower.contains(keyword)) {
          keywordMatches++;
        }
      }
      if (keywordMatches > 0) {
        // Scale keyword score based on how many keywords matched
        score += 0.3 * (keywordMatches / keywords.length);
      }
    }

    // Check similarity to examples (lower weight - 10% of total)
    if (score < 0.3 && exampleDescriptions.isNotEmpty) {
      for (final example in exampleDescriptions) {
        if (_calculateSimilarity(lower, example.toLowerCase()) > 0.6) {
          score += 0.1;
          break;
        }
      }
    }

    return score * confidence;
  }

  /// Simple string similarity calculation
  double _calculateSimilarity(String s1, String s2) {
    final words1 = s1.split(RegExp(r'\s+'));
    final words2 = s2.split(RegExp(r'\s+'));

    int matches = 0;
    for (final word in words1) {
      if (words2.contains(word)) matches++;
    }

    if (words1.isEmpty || words2.isEmpty) return 0.0;
    return matches / ((words1.length + words2.length) / 2);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'keywords': keywords.toList(),
      'merchantFrequency': merchantFrequency,
      'exampleDescriptions': exampleDescriptions,
      'typeFrequency': typeFrequency,  // Added: expense type tracking
      'averageAmount': averageAmount,
      'totalCount': totalCount,
      'confidence': confidence,
    };
  }

  /// Create from JSON
  factory CategoryPattern.fromJson(Map<String, dynamic> json) {
    return CategoryPattern(
      categoryName: json['categoryName'] as String,
      keywords: Set<String>.from(json['keywords'] ?? []),
      merchantFrequency: Map<String, int>.from(json['merchantFrequency'] ?? {}),
      exampleDescriptions: List<String>.from(json['exampleDescriptions'] ?? []),
      typeFrequency: Map<String, int>.from(json['typeFrequency'] ?? {}),  // Added
      averageAmount: (json['averageAmount'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
      confidence: (json['confidence'] ?? 0.5).toDouble(),
    );
  }
}

/// Container for all learned patterns
class PatternModel {
  final Map<String, CategoryPattern> patterns;
  final DateTime lastUpdated;
  final int totalExpenses;
  final int version;

  PatternModel({
    required this.patterns,
    required this.lastUpdated,
    this.totalExpenses = 0,
    this.version = 1,
  });

  /// Get best matching category for a description
  String? getBestMatch(String description, {double threshold = 0.3}) {
    String? bestCategory;
    double bestScore = 0.0;

    for (final pattern in patterns.values) {
      final score = pattern.matchScore(description);
      if (score > bestScore && score >= threshold) {
        bestScore = score;
        bestCategory = pattern.categoryName;
      }
    }

    return bestCategory;
  }

  /// Get match confidence for a specific category
  double getConfidence(String description, String category) {
    final pattern = patterns[category];
    if (pattern == null) return 0.0;
    return pattern.matchScore(description);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'patterns': patterns.map((k, v) => MapEntry(k, v.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalExpenses': totalExpenses,
      'version': version,
    };
  }

  /// Create from JSON
  factory PatternModel.fromJson(Map<String, dynamic> json) {
    final patternsJson = json['patterns'] as Map<String, dynamic>;
    final patterns = patternsJson.map(
      (k, v) => MapEntry(k, CategoryPattern.fromJson(v as Map<String, dynamic>)),
    );

    return PatternModel(
      patterns: patterns,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      totalExpenses: json['totalExpenses'] ?? 0,
      version: json['version'] ?? 1,
    );
  }
}