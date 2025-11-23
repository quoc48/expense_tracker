import 'package:flutter/foundation.dart';
import '../../services/scanning/ocr_service.dart';

/// Simplified receipt parser for inline-price format
///
/// Handles receipts where prices are on the same or next line as items
class SimpleReceiptParser {

  /// Parse receipt with inline prices
  static List<ParsedItem> parseInlineReceipt(OcrResult ocrResult) {
    final items = <ParsedItem>[];
    final lines = ocrResult.allLines;

    debugPrint('📝 Simple Parser: Processing ${lines.length} lines');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Check for item code pattern (001-999)
      final itemMatch = RegExp(r'^(\d{3})\s+(.+)$').firstMatch(line);
      if (itemMatch != null) {
        final code = itemMatch.group(1)!;
        final name = itemMatch.group(2)!.trim();

        // Look for price in next few lines
        double? price;
        double? finalPrice;

        for (var j = i + 1; j < (i + 5).clamp(0, lines.length); j++) {
          final priceLine = lines[j].trim();

          // Look for price pattern with quantity
          // Format: "226500    1    226,500" or similar
          final priceMatch = RegExp(r'(\d+)\s+[\d.]+\s+([\d,]+)$').firstMatch(priceLine);
          if (priceMatch != null) {
            final priceStr = priceMatch.group(2)!.replaceAll(',', '');
            price = double.tryParse(priceStr);
            finalPrice = price;

            // Check for discount on next line
            if (j + 1 < lines.length) {
              final nextLine = lines[j + 1].trim();
              if (nextLine.contains('-')) {
                final discountMatch = RegExp(r'-?([\d,]+)').firstMatch(nextLine);
                if (discountMatch != null) {
                  final discountStr = discountMatch.group(1)!.replaceAll(',', '');
                  final discount = double.tryParse(discountStr) ?? 0;
                  finalPrice = (price ?? 0) - discount;
                  debugPrint('💰 Found discount: $price - $discount = $finalPrice');
                }
              }
            }
            break;
          }

          // Alternative: Look for final amount in format "51,152"
          final amountMatch = RegExp(r'^[\d,]+$').firstMatch(priceLine);
          if (amountMatch == null) {
            // Try to find amount at end of line
            final endMatch = RegExp(r'([\d,]+)\s*$').firstMatch(priceLine);
            if (endMatch != null) {
              final amountStr = endMatch.group(1)!.replaceAll(',', '');
              finalPrice = double.tryParse(amountStr);
              if (finalPrice != null && finalPrice > 100) { // Min 100đ
                break;
              }
            }
          }
        }

        if (finalPrice != null && finalPrice > 0) {
          items.add(ParsedItem(
            code: code,
            description: name,
            amount: finalPrice,
          ));
          debugPrint('✅ Item $code: $name = ${finalPrice}đ');
        }
      }

      // Check for VAT lines
      if (line.contains('% VAT')) {
        final vatMatch = RegExp(r'(\d+)\s*%\s*VAT\s+([\d,]+)').firstMatch(line);
        if (vatMatch != null) {
          final percentage = vatMatch.group(1)!;
          final amountStr = vatMatch.group(2)!.replaceAll(',', '');
          final amount = double.tryParse(amountStr);

          if (amount != null && amount > 0) {
            items.add(ParsedItem(
              code: 'TAX',
              description: 'VAT $percentage%',
              amount: amount,
              isTax: true,
            ));
            debugPrint('💰 Tax: VAT $percentage% = ${amount}đ');
          }
        }
      }
    }

    debugPrint('📊 Simple Parser: Found ${items.length} items');
    return items;
  }
}

/// Simple parsed item
class ParsedItem {
  final String code;
  final String description;
  final double amount;
  final bool isTax;

  ParsedItem({
    required this.code,
    required this.description,
    required this.amount,
    this.isTax = false,
  });

  String get formattedAmount {
    final amountStr = amount.toStringAsFixed(0);
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
}