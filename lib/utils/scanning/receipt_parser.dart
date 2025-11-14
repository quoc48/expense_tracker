import 'package:flutter/foundation.dart';
import '../../services/scanning/ocr_service.dart';

/// Utility for parsing receipt text into structured item/amount pairs
///
/// Handles common Vietnamese receipt formats:
/// - Vertical lists: "Bánh mì 20.000"
/// - Tabular formats: "Cà phê sữa    35.000đ"
/// - Various number formats: 50.000, 50,000, 50000
///
/// Target accuracy: >70% for real Vietnamese receipts
class ReceiptParser {
  // =========================================================================
  // Amount Extraction Patterns
  // =========================================================================

  /// Vietnamese currency patterns in priority order
  /// Matches: 50.000đ, 50,000đ, 50000đ, 50.000 VND, etc.
  static final List<RegExp> _amountPatterns = [
    // Pattern 1: Dot-separated with currency (50.000đ, 50.000 đ, 50.000đ)
    RegExp(r'(\d{1,3}(?:\.\d{3})+)\s*[đdĐD](?:[^a-zA-Z]|$)', caseSensitive: false),

    // Pattern 2: Comma-separated with currency (50,000đ, 50,000 đ)
    RegExp(r'(\d{1,3}(?:,\d{3})+)\s*[đdĐD](?:[^a-zA-Z]|$)', caseSensitive: false),

    // Pattern 3: Plain number with currency (50000đ, 50000 đ)
    RegExp(r'(\d{4,})\s*[đdĐD](?:[^a-zA-Z]|$)', caseSensitive: false),

    // Pattern 4: Dot-separated with VND (50.000 VND, 50.000VND)
    RegExp(r'(\d{1,3}(?:\.\d{3})+)\s*VND\b', caseSensitive: false),

    // Pattern 5: Comma-separated with VND (50,000 VND)
    RegExp(r'(\d{1,3}(?:,\d{3})+)\s*VND\b', caseSensitive: false),

    // Pattern 6: Plain number with VND (50000 VND)
    RegExp(r'(\d{4,})\s*VND\b', caseSensitive: false),
  ];

  // =========================================================================
  // Noise Filtering Patterns
  // =========================================================================

  /// Keywords that indicate total/subtotal lines (not individual items)
  static final _totalKeywords = [
    'tổng',
    'tong',
    'total',
    'sum',
    'thành tiền',
    'thanh tien',
    'cộng',
    'cong',
    'subtotal',
  ];

  /// Keywords that indicate headers/footers/metadata (not items)
  static final _noiseKeywords = [
    'hoá đơn',
    'hoa don',
    'receipt',
    'invoice',
    'bill',
    'thank you',
    'cảm ơn',
    'cam on',
    'address',
    'địa chỉ',
    'dia chi',
    'phone',
    'tel',
    'website',
    'tax',
    'vat',
  ];

  // =========================================================================
  // Public API
  // =========================================================================

  /// Parse OCR result into structured receipt items
  ///
  /// Returns list of [ParsedReceiptItem] containing description and amount
  /// Filters out totals, headers, and noise
  static List<ParsedReceiptItem> parseReceipt(OcrResult ocrResult) {
    debugPrint('📄 Parser: Starting receipt parsing');
    debugPrint('📄 Parser: Input has ${ocrResult.allLines.length} lines');

    final items = <ParsedReceiptItem>[];
    final processedLines = <String>{};

    // Process each line from OCR result
    for (final line in ocrResult.allLines) {
      final trimmedLine = line.trim();

      // Skip empty lines
      if (trimmedLine.isEmpty) continue;

      // Skip already processed lines (duplicates)
      if (processedLines.contains(trimmedLine.toLowerCase())) continue;

      // Try to extract item from this line
      final item = _parseItemLine(trimmedLine);

      if (item != null) {
        items.add(item);
        processedLines.add(trimmedLine.toLowerCase());
        debugPrint('✅ Parser: Found item - ${item.description}: ${item.amount}đ');
      }
    }

    debugPrint('📊 Parser: Extracted ${items.length} items from ${ocrResult.allLines.length} lines');
    debugPrint('📊 Parser: Success rate: ${((items.length / ocrResult.allLines.length) * 100).toStringAsFixed(1)}%');

    return items;
  }

  // =========================================================================
  // Private Parsing Logic
  // =========================================================================

  /// Parse a single line into item + amount
  ///
  /// Returns null if line is noise, total, or doesn't contain valid item
  static ParsedReceiptItem? _parseItemLine(String line) {
    // Filter noise and totals first
    if (_isNoiseLine(line)) {
      debugPrint('⏭️  Parser: Skipping noise - "$line"');
      return null;
    }

    if (_isTotalLine(line)) {
      debugPrint('⏭️  Parser: Skipping total line - "$line"');
      return null;
    }

    // Try to extract amount from line
    final amount = _extractAmount(line);
    if (amount == null) {
      debugPrint('⏭️  Parser: No amount found - "$line"');
      return null;
    }

    // Extract description (everything before the amount)
    final description = _extractDescription(line, amount);
    if (description.isEmpty) {
      debugPrint('⏭️  Parser: Empty description - "$line"');
      return null;
    }

    return ParsedReceiptItem(
      description: description,
      amount: amount,
      rawLine: line,
    );
  }

  /// Extract amount from line using pattern matching
  ///
  /// Returns parsed amount as double, or null if no valid amount found
  static double? _extractAmount(String line) {
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final amountStr = match.group(1)!;
        // Remove separators (dots, commas) and parse
        final cleanAmount = amountStr.replaceAll(RegExp(r'[,.]'), '');
        final amount = double.tryParse(cleanAmount);

        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    return null;
  }

  /// Extract description from line (text before amount)
  ///
  /// Cleans up the description by removing:
  /// - The amount and currency symbols
  /// - Extra whitespace
  /// - Common prefixes (quantity indicators, etc.)
  static String _extractDescription(String line, double amount) {
    // Find where amount appears in the line
    var description = line;

    // Remove amount patterns from description
    for (final pattern in _amountPatterns) {
      description = description.replaceAll(pattern, '');
    }

    // Clean up description
    description = description
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces → single space
        .replaceAll(RegExp(r'[đdĐDvV]{1,3}\s*$'), '') // Remove trailing currency
        .replaceAll(RegExp(r'^\d+\s*x\s*', caseSensitive: false), '') // Remove quantity (2x, 3x)
        .replaceAll(RegExp(r'^\d+\s*'), '') // Remove leading numbers
        .trim();

    return description;
  }

  /// Check if line is a total/subtotal line
  static bool _isTotalLine(String line) {
    final lowerLine = line.toLowerCase();
    return _totalKeywords.any((keyword) => lowerLine.contains(keyword));
  }

  /// Check if line is noise (header, footer, metadata)
  static bool _isNoiseLine(String line) {
    final lowerLine = line.toLowerCase();

    // Check for noise keywords
    if (_noiseKeywords.any((keyword) => lowerLine.contains(keyword))) {
      return true;
    }

    // Lines that are too short (< 3 characters) are likely noise
    if (line.trim().length < 3) {
      return true;
    }

    // Lines with only numbers and special chars (no letters) are likely noise
    if (RegExp(r'^[^a-zA-Zàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]+$').hasMatch(line)) {
      return true;
    }

    return false;
  }

  // =========================================================================
  // Statistical Helpers
  // =========================================================================

  /// Calculate total amount from parsed items
  static double calculateTotal(List<ParsedReceiptItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Get items sorted by amount (descending)
  static List<ParsedReceiptItem> sortByAmount(List<ParsedReceiptItem> items) {
    final sorted = List<ParsedReceiptItem>.from(items);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }
}

// ============================================================================
// Data Models
// ============================================================================

/// A single item extracted from a receipt
class ParsedReceiptItem {
  /// Item description (e.g., "Bánh mì", "Cà phê sữa đá")
  final String description;

  /// Item amount in Vietnamese Dong (e.g., 20000.0)
  final double amount;

  /// Original line from OCR (for debugging)
  final String rawLine;

  const ParsedReceiptItem({
    required this.description,
    required this.amount,
    required this.rawLine,
  });

  /// Format amount as Vietnamese currency string
  String get formattedAmount {
    final amountStr = amount.toStringAsFixed(0);
    // Add thousand separators: 50000 → 50.000
    final buffer = StringBuffer();
    var count = 0;

    for (var i = amountStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amountStr[i]);
      count++;
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  @override
  String toString() {
    return 'ParsedReceiptItem(description: "$description", amount: $formattedAmount, raw: "$rawLine")';
  }
}
