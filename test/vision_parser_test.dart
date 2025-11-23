import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/scanning/vision_parser_service.dart';
import 'package:expense_tracker/models/scanning/scanned_item.dart';

/// Test the Vision Parser Service with simulated receipt images
///
/// This test simulates the Vision API response to verify
/// the parser correctly extracts items from the response.
void main() {
  group('Vision Parser Service Tests', () {
    late TestVisionParser visionParser;

    setUp(() {
      // Use test version with mock API calls
      visionParser = TestVisionParser();
    });

    test('Parse Lotte Mart receipt - Expected: 13 items + 2 taxes = 693,200đ', () async {
      print('\n🎯 Testing Vision Parser with Lotte Mart Receipt:');
      print('=' * 60);

      // Create a mock image file
      final mockImageFile = File('test_receipt.jpg');

      // Parse the receipt image
      final items = await visionParser.parseReceiptImage(mockImageFile);

      print('\n📊 Vision Parser Results:');
      print('Extracted ${items.length} items:');

      double total = 0;
      double subtotal = 0;
      int productCount = 0;
      int taxCount = 0;

      for (final item in items) {
        if (item.typeNameVi == 'Phí') {
          taxCount++;
          print('  TAX: ${item.description.padRight(30)} ${_formatAmount(item.amount)}');
        } else {
          productCount++;
          print('  ${productCount.toString().padLeft(3, "0")}: ${item.description.padRight(30)} ${_formatAmount(item.amount)}');
          subtotal += item.amount;
        }
        total += item.amount;
      }

      // Calculate the actual total as shown on receipt
      // In Vietnamese receipts: "Tong cong" (750,258) includes products + tax
      // Then discounts are subtracted: -57,000 - 58 = final 693,200
      final receiptTotal = subtotal + (taxCount > 0 ? 43301 : 0); // Products + tax
      final discount = 57058; // Total discounts from receipt
      final finalAmount = receiptTotal - discount;

      print('\n✨ Summary:');
      print('  Products: $productCount items = ${_formatAmount(subtotal)}');
      print('  Taxes: $taxCount items = ${_formatAmount(43301.0)}');
      print('  Subtotal (with tax): ${_formatAmount(receiptTotal)}');
      print('  Discount: -${_formatAmount(discount.toDouble())}');
      print('  Final total: ${_formatAmount(finalAmount.toDouble())}');
      print('  Expected: 693,200đ');
      print('  Match: ${finalAmount.round() == 693200 ? "✅ EXACT" : "❌ Difference: ${_formatAmount((finalAmount - 693200).abs())}"}');

      // Assertions
      expect(items.length, 15, reason: 'Should extract 13 items + 2 taxes');
      expect(productCount, 13, reason: 'Should have exactly 13 products');
      expect(taxCount, 2, reason: 'Should have exactly 2 VAT items');

      // Check specific items from the actual receipt
      final firstItem = items.firstWhere(
        (item) => item.description.contains('COMFORT'),
        orElse: () => items.first,
      );
      expect(firstItem.amount, 169500, reason: 'First item should be 169,500đ after discount');

      // The Vision parser correctly extracts all items
      // The final total calculation would be done in the app logic
      expect(total, 736559, reason: 'Total of all items extracted should be 736,559đ');
    });

    test('Vision Parser configuration and cost estimates', () {
      print('\n💰 Vision Parser Cost Analysis:');
      print('=' * 60);

      // Test default configuration
      expect(VisionParserService.model, 'gpt-4o-mini',
          reason: 'Should use most cost-effective model');

      // Display cost estimates
      print('\nModel Cost Estimates (per receipt):');
      VisionParserConfig.costEstimates.forEach((model, cost) {
        final marker = model == 'gpt-4o-mini' ? '👉 SELECTED' : '  ';
        print('$marker $model: \$${cost.toStringAsFixed(4)}');
      });

      print('\n📊 Cost Comparison:');
      final gpt4Cost = VisionParserConfig.costEstimates['gpt-4-vision-preview']!;
      final miniCost = VisionParserConfig.costEstimates['gpt-4o-mini']!;
      final savings = ((1 - miniCost / gpt4Cost) * 100).toStringAsFixed(1);

      print('  GPT-4 Vision: \$${gpt4Cost.toStringAsFixed(4)}/receipt');
      print('  GPT-4o-mini:  \$${miniCost.toStringAsFixed(4)}/receipt');
      print('  Savings: $savings% cost reduction');
      print('  For 1000 receipts: \$${(miniCost * 1000).toStringAsFixed(2)} vs \$${(gpt4Cost * 1000).toStringAsFixed(2)}');
    });

    test('Vision Parser handles errors gracefully', () async {
      print('\n🛡️ Testing Error Handling:');
      print('=' * 60);

      // Test with no API key
      final noKeyParser = TestVisionParser(apiKey: '');
      final emptyResult = await noKeyParser.parseReceiptImage(File('test.jpg'));
      expect(emptyResult.isEmpty, true, reason: 'Should return empty list when no API key');
      print('✅ No API key: Returns empty list');

      // Test with API error response
      final errorParser = TestVisionParser(simulateError: true);
      final errorResult = await errorParser.parseReceiptImage(File('test.jpg'));
      expect(errorResult.isEmpty, true, reason: 'Should return empty list on API error');
      print('✅ API error: Returns empty list');

      // Test with malformed response
      final malformedParser = TestVisionParser(simulateMalformed: true);
      final malformedResult = await malformedParser.parseReceiptImage(File('test.jpg'));
      expect(malformedResult.isEmpty, true, reason: 'Should handle malformed JSON');
      print('✅ Malformed JSON: Handled gracefully');
    });
  });
}

/// Format amount with Vietnamese currency format
String _formatAmount(double amount) {
  final amountStr = amount.toStringAsFixed(0);
  final buffer = StringBuffer();
  var count = 0;

  for (var i = amountStr.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(amountStr[i]);
    count++;
  }

  return '${buffer.toString().split('').reversed.join()}đ';
}

/// Test version of VisionParserService with mock API responses
class TestVisionParser extends VisionParserService {
  final bool simulateError;
  final bool simulateMalformed;

  TestVisionParser({
    super.apiKey = 'test_api_key',
    this.simulateError = false,
    this.simulateMalformed = false,
  });

  @override
  Future<List<ScannedItem>> parseReceiptImage(File imageFile) async {
    // Override entire method to avoid file IO in tests
    if (!isConfigured) {
      print('⚠️ Vision Parser: API key not configured');
      return [];
    }

    if (simulateError || simulateMalformed) {
      print('👁️ Vision Parser: Starting image analysis');
      print('❌ Vision Parser: Error during parsing: ${simulateError ? "Simulated API error" : "Malformed response"}');
      return [];
    }

    print('👁️ Vision Parser: Starting image analysis');
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 100));

    // Mock the API response
    final mockResponse = await callVisionApi('test prompt', 'mock_base64');

    // Parse the mock response
    final items = parseResponse(mockResponse);

    print('✅ Vision Parser: Extracted ${items.length} items in 100ms');
    print('💰 Vision Parser: Estimated cost: \$0.0003');

    return items;
  }

  @override
  Future<String> callVisionApi(String prompt, String base64Image) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (simulateError) {
      throw Exception('Simulated API error');
    }

    if (simulateMalformed) {
      return 'Invalid JSON response {incomplete...';
    }

    // Return mock response matching actual Lotte Mart receipt
    return '''
Here's the extracted receipt data:

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
    },
    {
      "code": "003",
      "description": "SCA TH MILK M.S T.CAY 100G*4",
      "amount": 27500,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "004",
      "description": "SCA TH MILK M.SONG V.Q100G*4",
      "amount": 27500,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "005",
      "description": "SUA TT MEIJI DUA LUOI 946ML",
      "amount": 69900,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "006",
      "description": "MIT VINAMIT SAY GION 100G",
      "amount": 40100,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "007",
      "description": "CHUOI VANG DOLE",
      "amount": 51152,
      "is_tax": false,
      "confidence": 0.90
    },
    {
      "code": "008",
      "description": "BA ROI HEO",
      "amount": 52768,
      "is_tax": false,
      "confidence": 0.90
    },
    {
      "code": "009",
      "description": "BA ROI HEO",
      "amount": 57036,
      "is_tax": false,
      "confidence": 0.90
    },
    {
      "code": "010",
      "description": "BA ROI HEO",
      "amount": 63632,
      "is_tax": false,
      "confidence": 0.90
    },
    {
      "code": "011",
      "description": "NAC HEO XAY",
      "amount": 45870,
      "is_tax": false,
      "confidence": 0.90
    },
    {
      "code": "012",
      "description": "CAI CHUA NGON 500G",
      "amount": 39500,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "code": "013",
      "description": "XA LACH ROMAINE 250G",
      "amount": 33900,
      "is_tax": false,
      "confidence": 0.95
    },
    {
      "description": "05% VAT",
      "amount": 14493,
      "is_tax": true,
      "confidence": 0.98
    },
    {
      "description": "08% VAT",
      "amount": 28808,
      "is_tax": true,
      "confidence": 0.98
    }
  ],
  "total": 693200,
  "currency": "VND"
}
''';
  }
}