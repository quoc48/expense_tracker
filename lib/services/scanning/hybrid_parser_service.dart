import 'package:flutter/foundation.dart';
import '../../models/scanning/scanned_item.dart';
import '../../utils/scanning/receipt_parser.dart';
import 'ocr_service.dart';
import 'llm_parser_service.dart';

/// Hybrid receipt parsing service that combines LLM and rule-based approaches
///
/// Strategy:
/// 1. Primary: Use LLM for intelligent parsing when available
/// 2. Fallback: Use rule-based parser for offline/failure scenarios
/// 3. Validation: Cross-check results for consistency
///
/// This provides the best of both worlds:
/// - LLM accuracy for complex formats
/// - Rule-based reliability for simple cases
/// - Offline capability
class HybridParserService {
  final LlmParserService _llmParser;
  final bool _preferLlm;
  final bool _validateResults;

  /// Create hybrid parser with optional LLM API key
  ///
  /// If apiKey is not provided, will only use rule-based parsing
  HybridParserService({
    String? apiKey,
    bool preferLlm = true,
    bool validateResults = true,
  })  : _llmParser = LlmParserService(apiKey: apiKey),
        _preferLlm = preferLlm,
        _validateResults = validateResults;

  /// Parse receipt using hybrid approach
  ///
  /// Returns parsed items with confidence scores
  /// Automatically selects best parsing method based on:
  /// - LLM availability
  /// - Receipt complexity
  /// - User preferences
  Future<HybridParserResult> parseReceipt(OcrResult ocrResult) async {
    debugPrint('🔄 Hybrid Parser: Starting receipt parsing');
    final startTime = DateTime.now();

    // Detect receipt type
    final receiptType = _detectReceiptType(ocrResult);
    debugPrint('📋 Hybrid Parser: Detected receipt type: ${receiptType.name}');

    // Try LLM parsing if preferred and available
    List<ScannedItem>? llmItems;
    if (_preferLlm && _llmParser.isConfigured) {
      try {
        debugPrint('🤖 Hybrid Parser: Attempting LLM parsing...');
        llmItems = await _llmParser.parseReceipt(ocrResult);
        debugPrint('✅ Hybrid Parser: LLM extracted ${llmItems.length} items');
      } catch (e) {
        debugPrint('⚠️ Hybrid Parser: LLM parsing failed: $e');
      }
    }

    // Always run rule-based parser as backup/validation
    debugPrint('📏 Hybrid Parser: Running rule-based parsing...');
    final ruleBasedItems = _parseWithRules(ocrResult);
    debugPrint('✅ Hybrid Parser: Rules extracted ${ruleBasedItems.length} items');

    // Select best results
    final selectedItems = _selectBestResults(
      llmItems: llmItems,
      ruleItems: ruleBasedItems,
      receiptType: receiptType,
    );

    // Validate if requested
    if (_validateResults) {
      _validateParsedItems(selectedItems, ocrResult);
    }

    final duration = DateTime.now().difference(startTime);
    debugPrint('⏱️ Hybrid Parser: Completed in ${duration.inMilliseconds}ms');

    // Calculate confidence based on parsing method and agreement
    final confidence = _calculateOverallConfidence(
      llmItems: llmItems,
      ruleItems: ruleBasedItems,
      selectedItems: selectedItems,
    );

    return HybridParserResult(
      items: selectedItems,
      method: llmItems != null && selectedItems == llmItems
          ? ParsingMethod.llm
          : ParsingMethod.ruleBased,
      confidence: confidence,
      processingTimeMs: duration.inMilliseconds,
      receiptType: receiptType,
    );
  }

  /// Detect receipt type from OCR text
  ReceiptType _detectReceiptType(OcrResult ocrResult) {
    final text = ocrResult.rawText.toLowerCase();
    final lines = ocrResult.allLines;

    // Lotte Mart detection
    if (lines.any((line) =>
        line.toLowerCase().contains('lotte') ||
        line.toLowerCase().contains('ma sp') ||
        line.toLowerCase().contains('mã sp'))) {
      return ReceiptType.lotteMart;
    }

    // Supermarket detection
    if (text.contains('siêu thị') ||
        text.contains('supermarket') ||
        text.contains('mart') ||
        text.contains('bigc') ||
        text.contains('coopmart') ||
        text.contains('vinmart')) {
      return ReceiptType.supermarket;
    }

    // Restaurant/Cafe detection
    if (text.contains('cafe') ||
        text.contains('cà phê') ||
        text.contains('coffee') ||
        text.contains('quán') ||
        text.contains('restaurant') ||
        text.contains('nhà hàng')) {
      return ReceiptType.restaurant;
    }

    // Online/Delivery detection
    if (text.contains('grab') ||
        text.contains('shopee') ||
        text.contains('lazada') ||
        text.contains('giao hàng') ||
        text.contains('delivery')) {
      return ReceiptType.online;
    }

    return ReceiptType.generic;
  }

  /// Parse using rule-based approach
  List<ScannedItem> _parseWithRules(OcrResult ocrResult) {
    // Use existing ReceiptParser
    final parsedItems = ReceiptParser.parseReceipt(ocrResult);

    // Convert ParsedReceiptItem to ScannedItem
    return parsedItems.map((item) {
      final id = 'rule_${DateTime.now().millisecondsSinceEpoch}_${parsedItems.indexOf(item)}';

      return ScannedItem(
        id: id,
        description: item.description,
        amount: item.amount,
        categoryNameVi: _categorizeByRules(item.description),
        typeNameVi: item.isReadonly ? 'Phí' : 'Phải chi',
        confidence: 0.7, // Default confidence for rule-based
      );
    }).toList();
  }

  /// Categorize item using rule-based keywords
  String _categorizeByRules(String description) {
    final lower = description.toLowerCase();

    // Tax/Fee detection
    if (lower.contains('vat') ||
        lower.contains('thuế') ||
        lower.contains('phí')) {
      return 'Thuế & Phí';
    }

    // Food categories
    if (lower.contains('cà phê') || lower.contains('cafe')) {
      return 'Cà phê';
    }
    if (lower.contains('bánh') || lower.contains('cake')) {
      return 'Ăn vặt';
    }
    if (lower.contains('cơm') ||
        lower.contains('phở') ||
        lower.contains('bún') ||
        lower.contains('mì')) {
      return 'Ăn uống';
    }

    // Beverages
    if (lower.contains('nước') ||
        lower.contains('trà') ||
        lower.contains('sữa') ||
        lower.contains('bia')) {
      return 'Đồ uống';
    }

    // Household
    if (lower.contains('giấy') ||
        lower.contains('comfort') ||
        lower.contains('xà phòng') ||
        lower.contains('dầu gội')) {
      return 'Gia dụng';
    }

    // Groceries
    if (lower.contains('thịt') ||
        lower.contains('cá') ||
        lower.contains('tôm') ||
        lower.contains('rau') ||
        lower.contains('củ')) {
      return 'Thực phẩm';
    }

    // Default
    return 'Mua sắm';
  }

  /// Select best parsing results
  List<ScannedItem> _selectBestResults({
    List<ScannedItem>? llmItems,
    required List<ScannedItem> ruleItems,
    required ReceiptType receiptType,
  }) {
    // If no LLM results, use rule-based
    if (llmItems == null || llmItems.isEmpty) {
      debugPrint('📊 Hybrid Parser: Using rule-based results (no LLM)');
      return ruleItems;
    }

    // If no rule-based results, use LLM
    if (ruleItems.isEmpty) {
      debugPrint('📊 Hybrid Parser: Using LLM results (no rules matched)');
      return llmItems;
    }

    // Compare totals
    final llmTotal = llmItems.fold<double>(0, (sum, item) => sum + item.amount);
    final ruleTotal = ruleItems.fold<double>(0, (sum, item) => sum + item.amount);
    final difference = (llmTotal - ruleTotal).abs();
    final percentDiff = difference / ((llmTotal + ruleTotal) / 2) * 100;

    debugPrint('💰 Hybrid Parser: LLM total: ${llmTotal}đ, Rule total: ${ruleTotal}đ');
    debugPrint('💰 Hybrid Parser: Difference: ${difference}đ (${percentDiff.toStringAsFixed(1)}%)');

    // For complex receipts (Lotte, supermarket), prefer LLM if available
    if (receiptType == ReceiptType.lotteMart ||
        receiptType == ReceiptType.supermarket) {
      debugPrint('📊 Hybrid Parser: Complex receipt - preferring LLM results');
      return llmItems;
    }

    // If totals are very different (>20%), prefer the one with more items
    if (percentDiff > 20) {
      if (llmItems.length > ruleItems.length) {
        debugPrint('📊 Hybrid Parser: Large difference - LLM has more items');
        return llmItems;
      } else {
        debugPrint('📊 Hybrid Parser: Large difference - Rules have more items');
        return ruleItems;
      }
    }

    // Default to LLM if similar results (it's usually more accurate)
    debugPrint('📊 Hybrid Parser: Similar results - preferring LLM');
    return llmItems;
  }

  /// Validate parsed items for consistency
  void _validateParsedItems(List<ScannedItem> items, OcrResult ocrResult) {
    if (items.isEmpty) {
      debugPrint('⚠️ Hybrid Parser: No items extracted from ${ocrResult.allLines.length} lines');
      return;
    }

    // Check for reasonable prices
    for (final item in items) {
      if (item.amount < 0) {
        debugPrint('⚠️ Hybrid Parser: Negative amount detected: ${item.description}');
      }
      if (item.amount > 10000000) { // > 10 million VND
        debugPrint('⚠️ Hybrid Parser: Unusually large amount: ${item.amount}đ for ${item.description}');
      }
    }

    // Check for duplicate descriptions
    final descriptions = items.map((i) => i.description.toLowerCase()).toList();
    final uniqueDescriptions = descriptions.toSet();
    if (uniqueDescriptions.length < descriptions.length) {
      debugPrint('⚠️ Hybrid Parser: Duplicate items detected');
    }
  }

  /// Calculate overall confidence score
  double _calculateOverallConfidence({
    List<ScannedItem>? llmItems,
    required List<ScannedItem> ruleItems,
    required List<ScannedItem> selectedItems,
  }) {
    // If only one method was used
    if (llmItems == null) {
      return 0.7; // Rule-based only
    }
    if (ruleItems.isEmpty) {
      return 0.85; // LLM only
    }

    // Calculate agreement between methods
    final llmTotal = llmItems.fold<double>(0, (sum, item) => sum + item.amount);
    final ruleTotal = ruleItems.fold<double>(0, (sum, item) => sum + item.amount);
    final difference = (llmTotal - ruleTotal).abs();
    final avgTotal = (llmTotal + ruleTotal) / 2;

    if (avgTotal == 0) return 0.5;

    final agreement = 1.0 - (difference / avgTotal);
    final confidence = agreement.clamp(0.5, 0.95);

    debugPrint('🎯 Hybrid Parser: Confidence score: ${(confidence * 100).toStringAsFixed(1)}%');
    return confidence;
  }
}

/// Result of hybrid parsing
class HybridParserResult {
  /// Extracted items
  final List<ScannedItem> items;

  /// Method used for final results
  final ParsingMethod method;

  /// Overall confidence (0.0 to 1.0)
  final double confidence;

  /// Processing time in milliseconds
  final int processingTimeMs;

  /// Detected receipt type
  final ReceiptType receiptType;

  const HybridParserResult({
    required this.items,
    required this.method,
    required this.confidence,
    required this.processingTimeMs,
    required this.receiptType,
  });

  /// Calculate total amount
  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.amount);

  /// Get item count (excluding taxes/fees)
  int get itemCount =>
      items.where((item) => item.typeNameVi != 'Phí').length;

  /// Get tax/fee count
  int get taxCount =>
      items.where((item) => item.typeNameVi == 'Phí').length;
}

/// Parsing method used
enum ParsingMethod {
  llm('LLM (AI)'),
  ruleBased('Rule-based'),
  hybrid('Hybrid');

  final String displayName;
  const ParsingMethod(this.displayName);
}

/// Receipt type classification
enum ReceiptType {
  generic('Generic'),
  supermarket('Supermarket'),
  restaurant('Restaurant'),
  lotteMart('Lotte Mart'),
  online('Online/Delivery');

  final String displayName;
  const ReceiptType(this.displayName);
}