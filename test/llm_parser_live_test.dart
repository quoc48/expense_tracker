import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/scanning/ocr_service.dart';
import 'package:expense_tracker/services/scanning/llm_parser_service.dart';
import 'package:expense_tracker/services/scanning/hybrid_parser_service.dart';

/// Live test using actual OpenAI API
///
/// Setup:
/// 1. Add your OpenAI API key to .env file:
///    OPENAI_API_KEY=sk-...
///
/// 2. Run with: flutter test test/llm_parser_live_test.dart
///
/// Note: This test file is for local testing only.
/// Never commit API keys to version control!
void main() {
  // TODO: Load API key from environment variable
  // For now, manually paste your key here for local testing only
  // NEVER commit this file with a real API key!
  const apiKey = 'YOUR_API_KEY_HERE';

  group('LLM Parser Live Tests', () {
    test('Parse Lotte Mart receipt using OpenAI GPT-4', () async {
      // Create mock OCR result for Lotte Mart receipt
      final mockOcrResult = _createLotteMartOcrResult();

      print('\n🤖 Testing LLM Parser with OpenAI GPT-4:');
      print('=' * 60);

      // Test LLM parser directly
      final llmParser = LlmParserService(apiKey: apiKey);
      final llmItems = await llmParser.parseReceipt(mockOcrResult);

      print('📊 LLM Extracted ${llmItems.length} items:');
      double llmTotal = 0;
      int itemCount = 0;
      int taxCount = 0;

      for (var i = 0; i < llmItems.length; i++) {
        final item = llmItems[i];
        final isTax = item.typeNameVi == 'Phí';

        if (isTax) {
          taxCount++;
        } else {
          itemCount++;
        }

        print('  ${i + 1}. ${item.description}: ${item.amount}đ '
              '[${item.categoryNameVi}] ${isTax ? "(TAX)" : ""} '
              '(confidence: ${(item.confidence * 100).toStringAsFixed(0)}%)');
        llmTotal += item.amount;
      }

      print('\n💰 Summary:');
      print('  - Total: ${llmTotal.toStringAsFixed(0)}đ');
      print('  - Items: $itemCount');
      print('  - Taxes: $taxCount');
      print('  - Expected: 750,258đ (13 items + 2 taxes)');

      // Assertions
      expect(llmItems.length, greaterThanOrEqualTo(13)); // At least 13 items
      expect(llmTotal, greaterThan(500000)); // Reasonable total
    });

    test('Parse Lotte receipt with Hybrid Parser (LLM + Rule-based)', () async {
      final mockOcrResult = _createLotteMartOcrResult();

      print('\n🔄 Testing Hybrid Parser (LLM primary, Rule-based fallback):');
      print('=' * 60);

      // Create hybrid parser with API key
      final hybridParser = HybridParserService(
        apiKey: apiKey,
        preferLlm: true,
        validateResults: true,
      );

      final result = await hybridParser.parseReceipt(mockOcrResult);

      print('📊 Results:');
      print('  - Method: ${result.method.displayName}');
      print('  - Receipt Type: ${result.receiptType.displayName}');
      print('  - Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
      print('  - Processing Time: ${result.processingTimeMs}ms');
      print('  - Total Items: ${result.items.length} (${result.itemCount} items + ${result.taxCount} taxes)');
      print('  - Total Amount: ${result.totalAmount.toStringAsFixed(0)}đ');

      print('\n📝 Items:');
      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        final isTax = item.typeNameVi == 'Phí';
        print('  ${i + 1}. ${item.description}: ${item.amount}đ '
              '[${item.categoryNameVi}] ${isTax ? "(TAX)" : ""}');
      }

      // Assertions
      expect(result.method, ParsingMethod.llm); // Should use LLM with API key
      expect(result.receiptType, ReceiptType.lotteMart);
      expect(result.items.length, greaterThanOrEqualTo(13));
    });

    test('Parse simple restaurant receipt with LLM', () async {
      final mockOcrResult = _createSimpleRestaurantOcrResult();

      print('\n🍜 Testing Restaurant Receipt with LLM:');
      print('=' * 60);

      final llmParser = LlmParserService(apiKey: apiKey);
      final items = await llmParser.parseReceipt(mockOcrResult);

      print('📊 Extracted ${items.length} items:');
      double total = 0;
      for (final item in items) {
        print('  - ${item.description}: ${item.amount}đ [${item.categoryNameVi}]');
        total += item.amount;
      }
      print('Total: ${total}đ (Expected: 130,000đ)');

      // Assertions
      expect(items.length, greaterThanOrEqualTo(4)); // At least 4 items
      expect(total, closeTo(130000, 1000)); // Close to expected total
    });
  });
}

/// Create mock OCR result for Lotte Mart receipt
OcrResult _createLotteMartOcrResult() {
  final lines = [
    'LOTTE Mart',
    'Ma sp Ten SP',
    '001 XV COMFORT DIEU KY TUI 3.1L',
    '226500 1',
    '8934868173038',
    '226, 500',
    '- 57, 000 1',  // Discount for item 001
    '002 NE.D.SLIFE LUOI 5P YE',
    '72524283',
    '51, 152',
    '003 TT LV DETOL HQ KN 4KG',
    '8934868177432',
    '192, 392',
    '004 6C HEINEKEN LON 330ML*6',
    '87193311119071',
    '108, 00',
    '005 BTCS 500ML VNECO S/D (L.Bl)',
    '8934863331010',
    '11, 700',
    '006 LZ TK TD+TL ON LOC 320G',
    '8958588001531',
    '24, 138',
    '007 GN G.TAN XOI 330G',
    '893486813383',
    '30, 100',
    '008 GIAY LAU KITCHEN TOWELS',
    '8934811058114',
    '44, 110',
    '009 TP NESTLE MILO 3IN1 (5*20G)',
    '8938516718619',
    '24, 700',
    '010 TV G.ROI CK HUONG YLANG 27G',
    '8934863331027',
    '7, 300',
    '011 TP LAU SAN SUNLIGHT XTRA',
    '8934863364223',
    '39, 200',
    '012 NST TUOI DALAT 500G',
    '1.282',
    '25, 638',
    '013 THIT XIEN KHO BP 500G',
    '0.272',
    '65, 280',
    'giam gia don so',
    '65, 280',
    '51, 152',
    '192, 392',
    '108, 000',
    '11, 700',
    '24, 138',
    '30, 100',
    '44, 110',
    '24, 700',
    '7, 300',
    '39, 200',
    '25, 638',
    '14, 493',  // VAT
    '28, 808',  // VAT
    '- 57, 000',
    'Tong cong',
    '750, 258',
  ];

  final textLines = lines.map((line) => TextLineData(
    text: line,
    confidence: 0.95,
  )).toList();

  final textBlocks = [
    TextBlockData(
      text: lines.join('\n'),
      lines: textLines,
      confidence: 0.95,
    ),
  ];

  return OcrResult(
    rawText: lines.join('\n'),
    textBlocks: textBlocks,
    processingTimeMs: 100,
    blockCount: 1,
  );
}

/// Create mock OCR result for simple restaurant receipt
OcrResult _createSimpleRestaurantOcrResult() {
  final lines = [
    'Quán Phở Hà Nội',
    'Địa chỉ: 123 Lý Thường Kiệt',
    'Phở bò tái 45,000đ',
    'Phở gà 40,000đ',
    'Nước chanh 15,000đ',
    'Bánh cuốn 30,000đ',
    'Tổng cộng: 130,000đ',
    'Cảm ơn quý khách!',
  ];

  final textLines = lines.map((line) => TextLineData(
    text: line,
    confidence: 0.9,
  )).toList();

  final textBlocks = [
    TextBlockData(
      text: lines.join('\n'),
      lines: textLines,
      confidence: 0.9,
    ),
  ];

  return OcrResult(
    rawText: lines.join('\n'),
    textBlocks: textBlocks,
    processingTimeMs: 50,
    blockCount: 1,
  );
}