import 'package:uuid/uuid.dart';
import 'scanned_item.dart';

/// Represents a complete scanned receipt with all extracted items
///
/// This is the main model used during the receipt scanning workflow.
/// It holds all items extracted from a single receipt photo.
class ScannedReceipt {
  /// Unique identifier for this receipt scan
  final String id;

  /// When this receipt was scanned
  final DateTime scanDate;

  /// List of items extracted from the receipt
  final List<ScannedItem> items;

  /// Total amount of all items
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Number of items in this receipt
  int get itemCount => items.length;

  /// Processing status
  /// Used to track the scan workflow state
  ScanStatus status;

  /// Error message if scanning failed
  String? errorMessage;

  /// Processing time in milliseconds (for analytics)
  int? processingTimeMs;

  ScannedReceipt({
    String? id,
    DateTime? scanDate,
    required this.items,
    this.status = ScanStatus.pending,
    this.errorMessage,
    this.processingTimeMs,
  })  : id = id ?? const Uuid().v4(),
        scanDate = scanDate ?? DateTime.now();

  /// Create an empty receipt (used when starting a scan)
  factory ScannedReceipt.empty() {
    return ScannedReceipt(items: []);
  }

  /// Add an item to the receipt
  void addItem(ScannedItem item) {
    items.add(item);
  }

  /// Remove an item by ID
  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  /// Update an item
  void updateItem(String itemId, ScannedItem updatedItem) {
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  /// Create a copy with modified fields
  ScannedReceipt copyWith({
    String? id,
    DateTime? scanDate,
    List<ScannedItem>? items,
    ScanStatus? status,
    String? errorMessage,
    int? processingTimeMs,
  }) {
    return ScannedReceipt(
      id: id ?? this.id,
      scanDate: scanDate ?? this.scanDate,
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scanDate': scanDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.name,
      'errorMessage': errorMessage,
      'processingTimeMs': processingTimeMs,
    };
  }

  /// Create from JSON
  factory ScannedReceipt.fromJson(Map<String, dynamic> json) {
    return ScannedReceipt(
      id: json['id'] as String,
      scanDate: DateTime.parse(json['scanDate'] as String),
      items: (json['items'] as List)
          .map((item) => ScannedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: ScanStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ScanStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      processingTimeMs: json['processingTimeMs'] as int?,
    );
  }

  @override
  String toString() {
    return 'ScannedReceipt(id: $id, scanDate: $scanDate, '
        'itemCount: $itemCount, totalAmount: $totalAmount, status: $status)';
  }
}

/// Status of the receipt scanning process
enum ScanStatus {
  /// Waiting to be processed
  pending,

  /// Currently processing OCR
  processing,

  /// OCR completed, ready for review
  reviewReady,

  /// User is reviewing/editing items
  reviewing,

  /// Saving to database
  saving,

  /// Successfully saved
  completed,

  /// Failed during any stage
  failed,
}
