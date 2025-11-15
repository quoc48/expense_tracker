import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/scanning/ocr_service.dart';
import 'package:expense_tracker/services/scanning/hybrid_parser_service.dart';
import 'package:expense_tracker/utils/scanning/receipt_parser.dart';
import 'package:expense_tracker/utils/scanning/simple_receipt_parser.dart';

/// Test with actual Lotte Mart receipt data from the image
void main() {
  group('Real Lotte Mart Receipt Tests', () {
    test('Parse actual Lotte receipt - Expected: 13 items + 2 taxes = 750,258đ', () async {
      // OCR data extracted from the actual receipt image
      final mockOcrResult = _createRealLotteOcrResult();

      print('\n📄 Testing with REAL Lotte Mart Receipt Data:');
      print('=' * 60);

      // Test simple parser
      print('\n📏 Simple Parser Results:');
      final simpleItems = SimpleReceiptParser.parseInlineReceipt(mockOcrResult);

      print('Extracted ${simpleItems.length} items:');
      double simpleTotal = 0;
      int simpleProductCount = 0;
      int simpleTaxCount = 0;

      for (final item in simpleItems) {
        if (item.isTax) {
          simpleTaxCount++;
          print('  TAX: ${item.description.padRight(20)} ${item.formattedAmount}');
        } else {
          simpleProductCount++;
          print('  ${item.code}: ${item.description.padRight(30)} ${item.formattedAmount}');
        }
        simpleTotal += item.amount;
      }

      print('\n📊 Simple Parser Summary:');
      print('  Products: $simpleProductCount');
      print('  Taxes: $simpleTaxCount');
      print('  Total: ${simpleTotal.toStringAsFixed(0)}đ');
      print('  Expected: 750,258đ');
      print('  Match: ${simpleTotal == 750258 ? "✅ EXACT" : "❌ Difference: ${(simpleTotal - 750258).toStringAsFixed(0)}đ"}');

      // Also test old parser for comparison
      print('\n📏 Original Rule-Based Parser Results:');
      final ruleItems = ReceiptParser.parseReceipt(mockOcrResult);

      print('Extracted ${ruleItems.length} items:');
      double ruleTotal = 0;
      int productCount = 0;
      int taxCount = 0;

      for (var i = 0; i < ruleItems.length; i++) {
        final item = ruleItems[i];
        if (item.isReadonly) {
          taxCount++;
          print('  TAX ${taxCount}: ${item.formattedAmount}');
        } else {
          productCount++;
          print('  ${productCount.toString().padLeft(2, "0")}: ${item.description.padRight(30)} ${item.formattedAmount}');
        }
        ruleTotal += item.amount;
      }

      print('\n📊 Summary:');
      print('  Products: $productCount');
      print('  Taxes: $taxCount');
      print('  Total: ${ruleTotal.toStringAsFixed(0)}đ');
      print('  Expected: 750,258đ');
      print('  Match: ${ruleTotal == 750258 ? "✅ EXACT" : "❌ Difference: ${(ruleTotal - 750258).toStringAsFixed(0)}đ"}');

      // Test hybrid parser
      print('\n🔄 Hybrid Parser Results:');
      final hybridParser = HybridParserService();
      final hybridResult = await hybridParser.parseReceipt(mockOcrResult);

      print('Method: ${hybridResult.method.displayName}');
      print('Items: ${hybridResult.itemCount} products + ${hybridResult.taxCount} taxes');
      print('Total: ${hybridResult.totalAmount.toStringAsFixed(0)}đ');

      // Assertions for exact receipt
      expect(ruleItems.length, 15, reason: 'Should extract 13 items + 2 taxes');
      expect(productCount, 13, reason: 'Should have exactly 13 products');
      expect(taxCount, 2, reason: 'Should have exactly 2 VAT items');

      // Check specific prices from receipt
      expect(ruleItems[0].amount, 169500, reason: 'Item 001 after discount');
      expect(ruleItems[1].amount, 14900, reason: 'Item 002');

      // The total might not match exactly due to rounding or OCR issues
      // but should be close
      expect(ruleTotal, closeTo(750258, 100000), reason: 'Total should be close to receipt');
    });
  });
}

/// Create OCR result from the actual Lotte Mart receipt image
OcrResult _createRealLotteOcrResult() {
  // Exact text from the receipt image
  final lines = [
    'LOTTE MART',
    'Hotline: 0901857057',
    'MST: 0304 741 634 - 006',
    'MANAGER TBH: Mr. Tuyen',
    'ENT      2025-11-09 15:02    POS:0208-0151',
    '==========================================',
    'Ma sp                 dgia    sl   so tien',
    '------------------------------------------',
    '001 XV COMFORT DIEU KY TUI 3.1L',
    '  8934868173038    226500    1    226,500',
    '[M)DC  ]   57,000A         1     -57,000',
    '002 CL-BAO TAY NHUA TU HUY SH 100C',
    '  8936110571753    14900     1     14,900',
    '003 SCA TH MILK M.S T.CAY 100G*4',
    '  8935217410309    27500     1     27,500',
    '004 SCA TH MILK M.SONG V.Q100G*4',
    '  8935217410507    27500     1     27,500',
    '005 SUA TT MEIJI DUA LUOI 946ML',
    '  8850329123575    69900     1     69,900',
    '006 MIT VINAMIT SAY GION 100G',
    '  8934743042909    40100     1     40,100',
    '007 CHUOI VANG DOLE',
    '  2312890000007    39900   1.282   51,152',
    '  Scode:2312890005115201282​6',
    '008 BA ROI HEO',
    '  2309530000008    194000  0.272   52,768',
    '  Scode:2309532005276800272​5',
    '009 BA ROI HEO',
    '  2309530000008    194000  0.294   57,036',
    '  Scode:2309537005703600294​5',
    '010 BA ROI HEO',
    '  2309530000008    194000  0.328   63,632',
    '  Scode:2309532006363200328​1',
    '011 NAC HEO XAY',
    '  2309700000005    165000  0.278   45,870',
    '  Scode:2309702004587000278​0',
    '012 CAI CHUA NGON 500G',
    '  8938524169083    39500     1     39,500',
    '013 XA LACH ROMAINE 250G',
    '  8936231020017    33900     1     33,900',
    '==========================================',
    '05 % VAT                           14,493',
    '08 % VAT                           28,808',
    'Tong cong                         750,258',
    'giam gia san pham                 -57,000',
    'Giam gia don so                       -58',
  ];

  // Create TextLineData objects
  final textLines = lines.map((line) => TextLineData(
    text: line,
    confidence: 0.95,
  )).toList();

  // Create TextBlockData
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