/// Represents a single item extracted from a receipt via OCR
///
/// This is the in-memory model used during the review process.
/// After the user confirms, these items are converted to Expense objects.
class ScannedItem {
  /// Unique identifier for this item (generated during scanning)
  final String id;

  /// Description of the item (e.g., "Cà phê sữa đá")
  String description;

  /// Amount in VND (e.g., 35000.0)
  double amount;

  /// Category name in Vietnamese (e.g., "Cà phê")
  /// This is auto-matched using keyword dictionaries
  String categoryNameVi;

  /// Expense type in Vietnamese (default: "Phải chi")
  /// Options: "Phải chi", "Phát sinh", "Lãng phí"
  String typeNameVi;

  /// Optional note for this item
  String? note;

  /// OCR confidence score (0.0 to 1.0)
  /// Used internally for debugging, not shown to users
  final double confidence;

  ScannedItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryNameVi,
    this.typeNameVi = 'Phải chi', // Default expense type
    this.note,
    this.confidence = 1.0, // Default to max confidence for manual entries
  });

  /// Create a copy with modified fields
  ScannedItem copyWith({
    String? id,
    String? description,
    double? amount,
    String? categoryNameVi,
    String? typeNameVi,
    String? note,
    double? confidence,
  }) {
    return ScannedItem(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryNameVi: categoryNameVi ?? this.categoryNameVi,
      typeNameVi: typeNameVi ?? this.typeNameVi,
      note: note ?? this.note,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'categoryNameVi': categoryNameVi,
      'typeNameVi': typeNameVi,
      'note': note,
      'confidence': confidence,
    };
  }

  /// Create from JSON
  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    return ScannedItem(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryNameVi: json['categoryNameVi'] as String,
      typeNameVi: json['typeNameVi'] as String? ?? 'Phải chi',
      note: json['note'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  String toString() {
    return 'ScannedItem(id: $id, description: $description, amount: $amount, '
        'category: $categoryNameVi, type: $typeNameVi, confidence: $confidence)';
  }
}
