import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/scanning/scanned_item.dart';

/// Vision-based receipt parser using GPT-4 Vision API
///
/// Directly processes receipt images without OCR step,
/// eliminating OCR errors and improving accuracy.
class VisionParserService {
  // API configuration
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String? _apiKey;

  // Model configuration
  // Vision-capable models (from most to least expensive):
  // - gpt-4-vision-preview: Best quality (~$0.025/receipt)
  // - gpt-4-turbo: Good balance (~$0.015/receipt)
  // - gpt-4o: Cost-effective (~$0.012/receipt)
  // - gpt-4o-mini: Most affordable (~$0.0003/receipt) - RECOMMENDED
  static const String model = 'gpt-4o-mini'; // Changed to most cost-effective
  static const int _maxTokens = 4000;

  VisionParserService({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'];

  /// Parse receipt image directly using Vision API
  ///
  /// Returns list of ScannedItem objects extracted from the receipt image
  Future<List<ScannedItem>> parseReceiptImage(File imageFile) async {
    if (!isConfigured) {
      debugPrint('⚠️ Vision Parser: API key not configured');
      return [];
    }

    try {
      debugPrint('👁️ Vision Parser: Starting image analysis');
      final startTime = DateTime.now();

      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Calculate image size for cost estimation
      final imageSizeKb = imageBytes.length / 1024;
      debugPrint('📸 Vision Parser: Image size: ${imageSizeKb.toStringAsFixed(1)} KB');

      // Build prompt for vision model
      final prompt = _buildVisionPrompt();

      // Call Vision API
      final response = await callVisionApi(prompt, base64Image);

      // Parse the response
      final items = parseResponse(response);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Vision Parser: Extracted ${items.length} items in ${duration.inMilliseconds}ms');

      // Estimate cost (rough estimate: $0.01 per 1MB)
      final estimatedCost = (imageSizeKb / 1024) * 0.01;
      debugPrint('💰 Vision Parser: Estimated cost: \$${estimatedCost.toStringAsFixed(4)}');

      return items;
    } catch (e) {
      debugPrint('❌ Vision Parser: Error during parsing: $e');
      return [];
    }
  }

  /// Check if Vision service is configured
  bool get isConfigured => _apiKey != null && _apiKey.isNotEmpty;

  /// Build the prompt for Vision model
  String _buildVisionPrompt() {
    return '''
Analyze this receipt image and extract ONLY PRODUCT ITEMS with their FINAL PRICES.

CRITICAL INSTRUCTIONS:
1. Extract ONLY product items (001-999), NOT VAT/tax lines
2. Use the FINAL AMOUNT from rightmost column (already includes tax)
3. For items with discounts: Subtract discount from base amount
4. IGNORE "% VAT" lines at bottom (tax already included in prices)
5. Item prices on receipt ALREADY INCLUDE TAX

LOTTE MART RECEIPT FORMAT:
- Product line: "001 PRODUCT NAME"
- Price line: "barcode  unit_price  quantity  FINAL_AMOUNT"
- Discount line (if any): "[M)DC]  amount  1  -amount" ← SUBTRACT THIS!

DISCOUNT HANDLING EXAMPLE:
Item 001 with discount:
  "001 XV COMFORT DIEU KY TUI 3.1L"
  "8934868173038  226500  1  226,500"  ← Base amount (with tax)
  "[M)DC]  57,000A  1  -57,000"         ← Discount on NEXT line
  → Final = 226,500 - 57,000 = 169,500đ

WEIGHTED ITEMS EXAMPLE:
  "007 CHUOI VANG DOLE"
  "2312890000007  39900  1.282  51,152"  ← Use 51,152 (rightmost)

DO NOT EXTRACT:
  ✗ "05 % VAT" lines (informational only, tax already in prices)
  ✗ "08 % VAT" lines (informational only, tax already in prices)
  ✗ "Tong cong" (total line)
  ✗ "giam gia" (discount summary)

EXPECTED OUTPUT:
{
  "items": [
    {
      "code": "001",
      "description": "XV COMFORT DIEU KY TUI 3.1L",
      "amount": 169500,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "002",
      "description": "CL-BAO TAY NHUA TU HUY SH 100C",
      "amount": 14900,
      "is_tax": false,
      "confidence": 0.95
    }
  ],
  "currency": "VND"
}

Extract ONLY the 13 product items (ignore VAT lines) and return JSON:''';
  }

  /// Call the OpenAI Vision API
  /// Protected method to allow override in tests
  Future<String> callVisionApi(String prompt, String base64Image) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = json.encode({
      'model': model,
      'max_tokens': _maxTokens,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a receipt parser specialized in Vietnamese receipts. Extract items accurately from images.',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
                'detail': 'high', // Use 'high' for better accuracy
              },
            },
          ],
        }
      ],
    });

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 60)); // Longer timeout for images

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        debugPrint('❌ Vision API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Vision API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Vision API Request failed: $e');
      rethrow;
    }
  }

  /// Parse Vision API response into ScannedItem objects
  /// Protected method to allow use in tests
  List<ScannedItem> parseResponse(String response) {
    try {
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch == null) {
        debugPrint('⚠️ Vision Parser: No JSON found in response');
        return [];
      }

      final jsonStr = jsonMatch.group(0)!;
      final Map<String, dynamic> jsonResponse = json.decode(jsonStr);

      // Get the items array
      final List<dynamic>? jsonItems = jsonResponse['items'];
      if (jsonItems == null || jsonItems.isEmpty) {
        debugPrint('⚠️ Vision Parser: No items found in response');
        return [];
      }

      // Get the total if available
      final receiptTotal = jsonResponse['total'];
      if (receiptTotal != null) {
        debugPrint('💰 Vision Parser: Receipt total: $receiptTotal VND');
      }

      final items = <ScannedItem>[];

      for (final item in jsonItems) {
        try {
          final code = item['code']?.toString() ?? '';
          final description = item['description']?.toString() ?? '';
          final amount = _parseAmount(item['amount']);
          final isTax = item['is_tax'] == true;
          final confidence = _parseConfidence(item['confidence']);

          if (description.isNotEmpty && amount > 0) {
            // Generate unique ID
            final id = 'vision_${DateTime.now().millisecondsSinceEpoch}_${items.length}';

            // Determine category
            final category = _categorizeItem(description, isTax);

            items.add(ScannedItem(
              id: id,
              description: description,
              amount: amount,
              categoryNameVi: category,
              typeNameVi: isTax ? 'Phí' : 'Phải chi',
              confidence: confidence,
            ));

            debugPrint('📝 Vision Item: ${code.isNotEmpty ? "$code " : ""}$description → ${amount}đ ${isTax ? "(TAX)" : ""}');
          }
        } catch (e) {
          debugPrint('⚠️ Vision Parser: Error parsing item: $e');
          continue;
        }
      }

      return items;
    } catch (e) {
      debugPrint('❌ Vision Parser: Error parsing response: $e');
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
    if (value == null) return 0.9; // Default high confidence for vision
    if (value is num) return value.toDouble().clamp(0.0, 1.0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.clamp(0.0, 1.0) ?? 0.9;
    }
    return 0.9;
  }

  /// Categorize item based on description
  String _categorizeItem(String description, bool isTax) {
    if (isTax) return 'Thuế & Phí';

    final lower = description.toLowerCase();

    // Food & Household categories
    if (lower.contains('comfort') || lower.contains('xà phòng')) {
      return 'Gia dụng';
    }
    if (lower.contains('sữa') || lower.contains('milk')) {
      return 'Đồ uống';
    }
    if (lower.contains('bánh') || lower.contains('mít')) {
      return 'Ăn vặt';
    }
    if (lower.contains('thịt') || lower.contains('heo') || lower.contains('nạc')) {
      return 'Thực phẩm';
    }
    if (lower.contains('rau') || lower.contains('cải') || lower.contains('xà lách')) {
      return 'Thực phẩm';
    }
    if (lower.contains('chuối') || lower.contains('trái')) {
      return 'Thực phẩm';
    }

    // Default
    return 'Mua sắm';
  }
}

/// Configuration for Vision parser
class VisionParserConfig {
  /// Model selection
  final String model;

  /// Image detail level ('low', 'high', 'auto')
  final String detailLevel;

  /// Maximum tokens for response
  final int maxTokens;

  /// Whether to include confidence scores
  final bool includeConfidence;

  /// Whether to extract receipt metadata (store, date, etc.)
  final bool extractMetadata;

  const VisionParserConfig({
    this.model = 'gpt-4-vision-preview',
    this.detailLevel = 'high',
    this.maxTokens = 4000,
    this.includeConfidence = true,
    this.extractMetadata = false,
  });

  /// Cost estimates per receipt image (approximate)
  static const Map<String, double> costEstimates = {
    'gpt-4-vision-preview': 0.025,  // Premium quality
    'gpt-4-turbo': 0.015,           // Good balance
    'gpt-4o': 0.012,                // Cost-effective
    'gpt-4o-mini': 0.0003,          // Most affordable (RECOMMENDED)
    'gpt-3.5-turbo': 0.0,           // Doesn't support vision
  };
}