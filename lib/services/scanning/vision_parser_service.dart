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
  static const int _maxTokens = 8000; // Increased to handle receipts with 30+ items

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
Extract items from Vietnamese receipt using strict sequential state machine.

PROCESSING STATES:

STATE 1 - Item Header Detection:
  Pattern: Line starts with 3-digit number (NNN) followed by text
  Action: Extract code (NNN) and description (remaining text)
  Next: Advance to STATE 2

STATE 2 - Price Line Reading:
  Pattern: Line immediately after header, contains multiple numbers
  Rule: This line has format [barcode] [unit_price] [quantity] [TOTAL_AMOUNT]
  Action: Extract ONLY the RIGHTMOST number as base_price (ignore all other numbers)
  Note: For weighted items (qty ≠ 1), rightmost number is already calculated (unit_price × qty)
  Next: Advance to STATE 3

STATE 3 - Discount Detection:
  Check next line against these patterns:

  DISCOUNT LINE indicators (if ANY match, it's a discount):
    - Contains negative number (prefix with "-")
    - Contains keywords: STIKER, GIAM, M)DC, DISCOUNT
    - Contains percentage symbol (%)
    - Does NOT start with 3-digit number

  IF discount line detected:
    Action: Extract ONLY the RIGHTMOST negative number, take its absolute value as discount
    Note: Ignore all other numbers on the line, use only the rightmost one
    Next: Skip this line, return to STATE 1 for next item

  IF not discount line (starts with 3-digit number):
    Action: Set discount = 0 for current item
    Next: Return to STATE 1 WITHOUT skipping (reprocess this line)

CRITICAL RULES:
- Process in strict order: STATE 1 → STATE 2 → STATE 3 → back to STATE 1
- ALWAYS extract RIGHTMOST number from each line (ignore unit price, quantity, other numbers)
- Receipt format: [barcode] [unit_price] [qty] [TOTAL] → use TOTAL (rightmost)
- For discount lines: [text] [values] [DISCOUNT] → use DISCOUNT (rightmost negative number)
- Never look ahead beyond STATE 3
- Discount belongs to item IMMEDIATELY ABOVE it
- When uncertain about discount, default to 0
- Extract values only, never calculate

DATA EXTRACTION:
- code: First 3-digit number from item header line
- description: Text portion from item header line
- base_price: RIGHTMOST number from price line (column "so tien", NOT "dgia")
- discount: RIGHTMOST negative number from discount line (absolute value), or 0

IMPORTANT: Each line may have 3-5 numbers. ALWAYS use the RIGHTMOST one.

OUTPUT FORMAT:
{
  "items": [
    {
      "code": "3-digit-string",
      "description": "text",
      "base_price": number,
      "discount": number,
      "is_tax": false,
      "confidence": 0.0-1.0
    }
  ],
  "currency": "VND"
}

VALIDATION CHECKS:
- Item codes should increment sequentially
- All base_price > 0
- All discount >= 0
- No orphaned discount lines''';
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

          // Extract base_price and discount separately
          final basePrice = _parseAmount(item['base_price'] ?? item['amount']);
          final discount = _parseAmount(item['discount'] ?? 0);

          // Calculate final amount in Dart (not relying on AI to do math)
          final finalAmount = basePrice - discount;

          final isTax = item['is_tax'] == true;
          final confidence = _parseConfidence(item['confidence']);

          if (description.isNotEmpty && finalAmount > 0) {
            // Generate unique ID
            final id = 'vision_${DateTime.now().millisecondsSinceEpoch}_${items.length}';

            // Determine category
            final category = _categorizeItem(description, isTax);

            items.add(ScannedItem(
              id: id,
              description: description,
              amount: finalAmount,
              categoryNameVi: category,
              typeNameVi: isTax ? 'Phí' : 'Phải chi',
              confidence: confidence,
            ));

            // Log with discount info for debugging
            if (discount > 0) {
              debugPrint('📝 Vision Item: ${code.isNotEmpty ? "$code " : ""}$description → $basePriceđ - $discountđ = $finalAmountđ ${isTax ? "(TAX)" : ""}');
            } else {
              debugPrint('📝 Vision Item: ${code.isNotEmpty ? "$code " : ""}$description → $finalAmountđ ${isTax ? "(TAX)" : ""}');
            }
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
  /// 
  /// Returns one of 14 valid Supabase categories based on keywords
  /// in the item description. These categories match exactly with
  /// the categories stored in the Supabase database.
  String _categorizeItem(String description, bool isTax) {
    if (isTax) return 'Hoá đơn'; // Taxes go to Bills category
    
    final lower = description.toLowerCase();
    
    // Coffee & Beverages
    if (lower.contains('cà phê') || lower.contains('coffee') || 
        lower.contains('highlands') || lower.contains('starbucks') ||
        lower.contains('trà') || lower.contains('sữa')) {
      return 'Cà phê';
    }
    
    // Transportation
    if (lower.contains('grab') || lower.contains('taxi') || 
        lower.contains('uber') || lower.contains('xăng') || 
        lower.contains('gas')) {
      return 'Đi lại';
    }
    
    // Household/Groceries
    if (lower.contains('comfort') || lower.contains('xà phòng') ||
        lower.contains('bột giặt') || lower.contains('nước rửa')) {
      return 'Tạp hoá';
    }
    
    // Food items
    if (lower.contains('thịt') || lower.contains('heo') || 
        lower.contains('gà') || lower.contains('bò') ||
        lower.contains('cá') || lower.contains('tôm') ||
        lower.contains('rau') || lower.contains('cải') ||
        lower.contains('chuối') || lower.contains('trái') ||
        lower.contains('bánh') || lower.contains('mì') ||
        lower.contains('phở') || lower.contains('bún')) {
      return 'Thực phẩm';
    }
    
    // Health
    if (lower.contains('thuốc') || lower.contains('pharmacy') ||
        lower.contains('bệnh viện') || lower.contains('clinic')) {
      return 'Sức khỏe';
    }
    
    // Entertainment
    if (lower.contains('cinema') || lower.contains('cgv') ||
        lower.contains('game') || lower.contains('karaoke')) {
      return 'Giải trí';
    }
    
    // Fashion
    if (lower.contains('quần') || lower.contains('áo') ||
        lower.contains('giày') || lower.contains('uniqlo')) {
      return 'Thời trang';
    }
    
    // Default to Food category (most common for receipts)
    return 'Thực phẩm';
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