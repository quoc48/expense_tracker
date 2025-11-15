import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/scanning/scanned_item.dart';
import 'ocr_service.dart';

/// Service for parsing receipts using LLM (Language Model)
///
/// Uses AI to intelligently extract items, prices, taxes, and discounts
/// from OCR text, handling various Vietnamese receipt formats.
///
/// Benefits over rule-based parsing:
/// - Contextual understanding of items vs taxes/fees
/// - Better handling of discounts and special offers
/// - More robust against OCR errors and formatting variations
/// - Can adapt to new receipt formats without code changes
class LlmParserService {
  // API configuration for OpenAI
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String? _apiKey;

  // Model configuration
  static const String _model = 'gpt-3.5-turbo-1106'; // Cost-effective, supports JSON mode
  static const int _maxTokens = 4000;
  static const double _temperature = 0.1; // Low temperature for consistent parsing

  LlmParserService({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'];

  /// Parse receipt using LLM
  ///
  /// Returns list of ScannedItem objects extracted from the receipt
  /// Falls back to empty list if parsing fails
  Future<List<ScannedItem>> parseReceipt(OcrResult ocrResult) async {
    if (!isConfigured) {
      debugPrint('⚠️ LLM Parser: API key not configured, skipping LLM parsing');
      return [];
    }

    try {
      debugPrint('🤖 LLM Parser: Starting receipt parsing');
      final startTime = DateTime.now();

      // Prepare the prompt with OCR text
      final prompt = _buildPrompt(ocrResult);

      // Call LLM API
      final response = await _callLlmApi(prompt);

      // Parse the response
      final items = _parseResponse(response);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ LLM Parser: Extracted ${items.length} items in ${duration.inMilliseconds}ms');

      return items;
    } catch (e) {
      debugPrint('❌ LLM Parser: Error during parsing: $e');
      return [];
    }
  }

  /// Check if LLM service is configured
  bool get isConfigured => _apiKey != null && _apiKey.isNotEmpty;

  /// Build the prompt for LLM
  ///
  /// Creates a structured prompt that guides the LLM to:
  /// 1. Identify product items with prices
  /// 2. Recognize discounts and apply them
  /// 3. Separate taxes/fees from regular items
  /// 4. Return structured JSON output
  String _buildPrompt(OcrResult ocrResult) {
    final ocrText = ocrResult.allLines.join('\n');

    return '''
You are a receipt parser specialized in Vietnamese receipts. Extract items from the following OCR text.

IMPORTANT RULES:
1. Extract ALL product items with their prices
2. If an item has a discount (negative amount like -57,000), apply it to get the final price
3. CRITICAL: Identify taxes and fees:
   - Look for "VAT", "thuế", "tax" keywords
   - Small amounts (typically 14,493 and 28,808 for VAT 10%)
   - Usually appear near the end, before total
   - Mark these with is_tax=true
4. For Lotte-style receipts: items have codes (001-999), prices may be in summary section
5. Common tax amounts in Vietnam: 8% or 10% VAT
6. Return valid JSON only, no additional text

OCR TEXT:
$ocrText

OUTPUT FORMAT:
Return a JSON object with an "items" array. Each item must have:
{
  "items": [
    {
      "description": "Item name in Vietnamese",
      "amount": final price as number (after any discounts),
      "is_tax": true/false (true for VAT, taxes, fees),
      "confidence": 0.0-1.0 (your confidence in this extraction)
    }
  ]
}

Example:
{
  "items": [
    {"description": "Bánh mì", "amount": 20000, "is_tax": false, "confidence": 0.95},
    {"description": "Cà phê sữa", "amount": 35000, "is_tax": false, "confidence": 0.90},
    {"description": "VAT 8%", "amount": 4400, "is_tax": true, "confidence": 0.85}
  ]
}

Parse the receipt and return the JSON object:''';
  }

  /// Call the OpenAI API
  Future<String> _callLlmApi(String prompt) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = json.encode({
      'model': _model,
      'max_tokens': _maxTokens,
      'temperature': _temperature,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a receipt parser specialized in Vietnamese receipts. Extract items accurately and return ONLY valid JSON.',
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'response_format': {'type': 'json_object'}, // Force JSON response
    });

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // OpenAI returns the message in choices[0].message.content
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        debugPrint('❌ LLM API Error: ${response.statusCode} - ${response.body}');
        throw Exception('LLM API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ LLM API Request failed: $e');
      rethrow;
    }
  }

  /// Parse LLM response into ScannedItem objects
  List<ScannedItem> _parseResponse(String response) {
    try {
      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response);

      // Get the items array
      final List<dynamic>? jsonItems = jsonResponse['items'];
      if (jsonItems == null || jsonItems.isEmpty) {
        debugPrint('⚠️ LLM Parser: No items found in response');
        return [];
      }

      final items = <ScannedItem>[];

      for (final item in jsonItems) {
        try {
          final description = item['description']?.toString() ?? '';
          final amount = _parseAmount(item['amount']);
          final isTax = item['is_tax'] == true;
          final confidence = _parseConfidence(item['confidence']);

          if (description.isNotEmpty && amount > 0) {
            // Generate unique ID
            final id = 'llm_${DateTime.now().millisecondsSinceEpoch}_${items.length}';

            // Determine category based on keywords or default
            final category = _categorizeItem(description, isTax);

            items.add(ScannedItem(
              id: id,
              description: description,
              amount: amount,
              categoryNameVi: category,
              typeNameVi: isTax ? 'Phí' : 'Phải chi',
              confidence: confidence,
            ));

            debugPrint('📝 LLM Item: $description → ${amount}đ (${isTax ? "tax" : "item"})');
          }
        } catch (e) {
          debugPrint('⚠️ LLM Parser: Error parsing item: $e');
          continue;
        }
      }

      return items;
    } catch (e) {
      debugPrint('❌ LLM Parser: Error parsing response: $e');
      return [];
    }
  }

  /// Parse amount from various formats
  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove currency symbols and separators
      final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// Parse confidence score
  double _parseConfidence(dynamic value) {
    if (value == null) return 0.8; // Default confidence
    if (value is num) return value.toDouble().clamp(0.0, 1.0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.clamp(0.0, 1.0) ?? 0.8;
    }
    return 0.8;
  }

  /// Categorize item based on description
  ///
  /// Uses keyword matching to assign categories
  /// This can be enhanced with more sophisticated categorization
  String _categorizeItem(String description, bool isTax) {
    if (isTax) return 'Thuế & Phí';

    final lower = description.toLowerCase();

    // Food & Drink categories
    if (lower.contains('cà phê') || lower.contains('cafe') || lower.contains('coffee')) {
      return 'Cà phê';
    }
    if (lower.contains('trà') || lower.contains('tea')) {
      return 'Đồ uống';
    }
    if (lower.contains('bánh') || lower.contains('cake')) {
      return 'Ăn vặt';
    }
    if (lower.contains('cơm') || lower.contains('phở') || lower.contains('bún')) {
      return 'Ăn uống';
    }

    // Household items
    if (lower.contains('dầu gội') || lower.contains('xà phòng') || lower.contains('comfort')) {
      return 'Gia dụng';
    }
    if (lower.contains('giấy') || lower.contains('tissue')) {
      return 'Gia dụng';
    }

    // Groceries
    if (lower.contains('thịt') || lower.contains('cá') || lower.contains('tôm')) {
      return 'Thực phẩm';
    }
    if (lower.contains('rau') || lower.contains('củ') || lower.contains('quả')) {
      return 'Thực phẩm';
    }

    // Default category
    return 'Mua sắm';
  }
}

/// Configuration for LLM parser service
///
/// Can be used to customize the LLM behavior
class LlmParserConfig {
  /// API endpoint URL
  final String apiUrl;

  /// Model to use for parsing
  final String model;

  /// Maximum tokens for response
  final int maxTokens;

  /// Temperature for generation (0.0 = deterministic, 1.0 = creative)
  final double temperature;

  /// Whether to include confidence scores
  final bool includeConfidence;

  /// Whether to categorize items automatically
  final bool autoCategorize;

  const LlmParserConfig({
    this.apiUrl = 'https://api.anthropic.com/v1/messages',
    this.model = 'claude-3-haiku-20240307',
    this.maxTokens = 4000,
    this.temperature = 0.1,
    this.includeConfidence = true,
    this.autoCategorize = true,
  });
}