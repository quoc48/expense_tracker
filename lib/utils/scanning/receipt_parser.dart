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
  /// Also handles bare numbers for table-format receipts (Lotte Mart, etc.)
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

    // Pattern 7: Bare comma-separated (226,500 or "226, 500") - for table format receipts
    // Handles OCR artifacts with spaces after separators
    RegExp(r'(\d{1,3}(?:,\s*\d{3})+)(?:\s|$)', caseSensitive: false),

    // Pattern 8: Bare dot-separated (226.500 or "226. 500") - European/Vietnamese format
    // Handles OCR artifacts with spaces after separators
    RegExp(r'(\d{1,3}(?:\.\s*\d{3})+)(?:\s|$)', caseSensitive: false),

    // Pattern 9: Bare plain number (50000+) - fallback for simple formats
    // Minimum 5 digits to avoid false positives (dates, codes, etc.)
    RegExp(r'(\d{5,})(?:\s|$)', caseSensitive: false),
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
    'tong cong',  // Vietnamese total
    'tổng cộng',
  ];

  /// Keywords that indicate headers/footers/metadata (not items)
  static final _noiseKeywords = [
    // Receipt metadata
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

    // Table headers (Vietnamese receipts)
    'ma sp',      // Product code
    'mã sp',
    'dgia',       // Price
    'đơn giá',
    'don gia',
    'sl',         // Quantity
    'số lượng',
    'so luong',
    'so tien',    // Amount
    'số tiền',
    'ent',        // Entry/cashier

    // Store metadata
    'hotline',
    'mst:',       // Tax ID
    'manager',
    'pos:',       // POS terminal
    'scode:',     // Special codes
    'barcode',

    // Discount keywords
    'giam gia',   // Discount
    'giảm giá',
    'discount',

    // Date/time indicators
    'date',
    'time',
    'ngày',
    'ngay',
  ];

  // =========================================================================
  // Public API
  // =========================================================================

  /// Detect if this is a Lotte-style receipt with table format
  ///
  /// Indicators: "Ma sp" header, item codes (001-999), summary section
  static bool _isLotteStyleReceipt(List<String> lines) {
    return lines.any((line) {
      final lower = line.toLowerCase();
      return lower.contains('ma sp') ||
             lower.contains('mã sp') ||
             (lower.contains('dgia') && lower.contains('sl'));
    });
  }

  /// Parse Lotte-style receipt using two-pass strategy
  ///
  /// Pass 1: Extract all item codes + names
  /// Pass 2: Extract summary section prices
  /// Pass 3: Match items to prices by position
  static List<ParsedReceiptItem> _parseLotteReceipt(OcrResult ocrResult) {
    final allLines = ocrResult.allLines;

    // Pass 1: Extract all items (code + name) and check for prices in item section
    final items = <({int index, String code, String name, double? itemSectionPrice})>[];
    for (var i = 0; i < allLines.length; i++) {
      final line = allLines[i].trim();
      final match = RegExp(r'^(\d{3})\s+(.+)$').firstMatch(line);
      if (match != null) {
        final code = match.group(1)!;
        final name = match.group(2)!.trim();

        // Validate item name
        if (name.length >= 3 &&
            RegExp(r'[a-zA-Zàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]').hasMatch(name)) {

          // Only check for item section prices for item 001 (which typically has discounts)
          // Other items will use summary section prices to avoid false matches
          double? itemPrice;
          if (code == '001') {
            // Item 001 special handling: look for price and discount in item section
            for (var j = i + 1; j < (i + 10).clamp(0, allLines.length); j++) {
              final priceAmount = _extractAmount(allLines[j]);

              // Skip if null or too small
              if (priceAmount == null || priceAmount < 1000) continue;

              // Skip barcodes (9+ digits) - they look like huge prices
              final amountStr = priceAmount.toStringAsFixed(0);
              if (amountStr.length >= 9) {
                debugPrint('⏭️  Lotte Pass1: Skipping barcode-sized number: $priceAmount');
                continue;
              }

              // Found a valid price (1000-99999999)
              var finalPrice = priceAmount;

              // Check next 10 lines for discount (negative amount)
              // Discounts can be several lines after the price (barcodes, quantities, etc. in between)
              for (var k = j + 1; k < (j + 10).clamp(0, allLines.length); k++) {
                final discountAmount = _extractAmount(allLines[k]);
                if (discountAmount != null && discountAmount < 0) {
                  finalPrice = priceAmount - discountAmount.abs();
                  debugPrint('💰 Lotte Pass1: Item $code has price $priceAmount + discount $discountAmount = $finalPrice in item section');
                  break;
                }
              }

              itemPrice = finalPrice;
              debugPrint('📝 Lotte Pass1: Item $code has price $finalPrice in item section');
              break;
            }
          }
          // For items 002-013, don't look for prices in item section - use summary section

          items.add((index: i, code: code, name: name, itemSectionPrice: itemPrice));
          debugPrint('📝 Lotte Pass1: Found item $code: $name${itemPrice != null ? " (price: $itemPrice)" : ""}');
        }
      }
    }

    debugPrint('📝 Lotte Pass1: Extracted ${items.length} items');

    // Pass 2: Extract summary section prices
    // Find summary section (after "giam gia don so", before negative numbers)
    var summaryStart = -1;
    var summaryEnd = -1;

    for (var i = 0; i < allLines.length; i++) {
      final lower = allLines[i].toLowerCase();
      if (lower.contains('giam gia don so') || lower.contains('giảm giá đơn số')) {
        summaryStart = i + 1;
        debugPrint('📝 Lotte Pass2: Found summary start at line $i');
      }
      if (summaryStart > 0 && summaryEnd < 0) {
        final amount = _extractAmount(allLines[i]);
        if (amount != null && amount < 0) {
          summaryEnd = i;
          debugPrint('📝 Lotte Pass2: Found summary end at line $i');
          break;
        }
      }
    }

    // Extract summary prices with discount detection
    // Pattern: Price on one line, discount (negative) on next line
    final summaryPrices = <double>[];
    final summaryLines = <({double amount, int lineIndex, String line, bool hasDiscount})>[];
    final processedLines = <int>{};  // Track lines we've already processed

    if (summaryStart > 0 && summaryEnd > summaryStart) {
      for (var i = summaryStart; i < summaryEnd; i++) {
        // Skip if already processed (e.g., as a discount line)
        if (processedLines.contains(i)) continue;

        final amount = _extractAmount(allLines[i]);
        if (amount != null && amount > 0 && amount >= 1000) {
          var finalAmount = amount;
          var hasDiscount = false;

          // Check next few lines for discount (negative amount)
          for (var j = i + 1; j < (i + 3).clamp(0, summaryEnd); j++) {
            final discountAmount = _extractAmount(allLines[j]);
            if (discountAmount != null && discountAmount < 0) {
              finalAmount = amount - discountAmount.abs();
              hasDiscount = true;
              processedLines.add(j);  // Mark discount line as processed
              debugPrint('💰 Lotte Pass2: Found discount for $amount: $discountAmount → final: $finalAmount');
              break;
            }
          }

          summaryPrices.add(finalAmount);
          summaryLines.add((amount: finalAmount, lineIndex: i, line: allLines[i], hasDiscount: hasDiscount));
          debugPrint('📝 Lotte Pass2: Found summary price: $finalAmount at line $i${hasDiscount ? " (after discount)" : ""}');
        }
      }
    }

    debugPrint('📝 Lotte Pass2: Extracted ${summaryPrices.length} summary prices (with discounts applied)');

    // Filter and clean summary prices
    // Special handling: Summary starts with item 013's price, then items 002-012
    // Tax amounts are typically < 20,000 (VAT amounts)
    debugPrint('📝 Lotte Pass2: Processing summary prices for items 002-013');

    final allPrices = <double>[];  // Collect all non-duplicate, non-total prices
    final taxItems = <({double amount, String line})>[];  // Collect taxes with line context
    final seenPrices = <int>{};  // Track seen prices (rounded to avoid float issues)

    // First pass: collect all valid prices
    for (final summaryLine in summaryLines) {
      final price = summaryLine.amount;
      final roundedPrice = price.round();

      // Skip if we've seen this exact price (duplicates)
      if (seenPrices.contains(roundedPrice)) {
        debugPrint('⏭️  Lotte: Skipping duplicate price: $price');
        continue;
      }

      // Skip if this looks like the total (much larger than item prices)
      if (price > 500000) {  // 500,000đ threshold for totals
        debugPrint('⏭️  Lotte: Skipping total: $price');
        continue;
      }

      seenPrices.add(roundedPrice);
      allPrices.add(price);
      debugPrint('📝 Lotte: Found price: $price');
    }

    // Second pass: separate item prices from taxes
    // Taxes are typically the small amounts (< 20,000) at the end
    final cleanedPrices = <double>[];

    for (var i = 0; i < allPrices.length; i++) {
      final price = allPrices[i];

      // Check if this looks like a tax (small amount near the end)
      // VAT amounts are typically 14,493 and 28,808 (< 30,000)
      // Look for tax amounts in the last 2 positions (not 3)
      if (price < 30000 && i >= allPrices.length - 2) {
        // This is likely a tax
        taxItems.add((amount: price, line: price.toString()));
        debugPrint('💰 Lotte: Identified as tax: $price');
      } else {
        // This is an item price
        cleanedPrices.add(price);
        debugPrint('📝 Lotte: Identified as item price: $price');
      }
    }

    debugPrint('📝 Lotte Pass2: Cleaned to ${cleanedPrices.length} item prices + ${taxItems.length} taxes');

    // Pass 3: Match items to prices
    // Special order: Summary has item 013 first, then items 002-012
    final results = <ParsedReceiptItem>[];

    // Process each item
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      double? price;

      // Item 001: Use item section price (with discount)
      if (item.itemSectionPrice != null) {
        price = item.itemSectionPrice;
        debugPrint('✅ Lotte Match: ${item.code} ${item.name} → $price đ (from item section with discount)');
      }
      // Item 013: Use first summary price (special position)
      else if (item.code == '013' && cleanedPrices.isNotEmpty) {
        price = cleanedPrices.first;
        debugPrint('✅ Lotte Match: ${item.code} ${item.name} → $price đ (from summary - first position)');
      }
      // Items 002-012: Use remaining summary prices in order
      else {
        // Calculate index: items[1-11] map to cleanedPrices[1-11]
        // Skip item 001 (has itemSectionPrice) and item 013 (uses first price)
        var priceIndex = -1;
        if (i >= 1 && i <= 11) {  // Items 002-012 are at indices 1-11
          priceIndex = i;  // Use same index in cleanedPrices
        }

        if (priceIndex >= 0 && priceIndex < cleanedPrices.length) {
          price = cleanedPrices[priceIndex];
          debugPrint('✅ Lotte Match: ${item.code} ${item.name} → $price đ (from summary index $priceIndex)');
        } else {
          debugPrint('⚠️  Lotte: No price found for ${item.name}');
          continue;
        }
      }

      // Add to results
      if (price != null) {
        results.add(ParsedReceiptItem(
          description: item.name,
          amount: price,
          rawLine: '${item.code} ${item.name}',
        ));
      }
    }

    // Pass 4: Append tax items as readonly
    // Extract tax description from line (remove amount, keep keywords like VAT, Thuế)
    for (final tax in taxItems) {
      var description = tax.line;

      // Remove amount from description
      for (final pattern in _amountPatterns) {
        description = description.replaceAll(pattern, '');
      }

      // Clean up description
      description = description
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // If description is empty or too short, use generic name
      if (description.isEmpty || description.length < 2) {
        // Check if line contains VAT keywords
        final lower = tax.line.toLowerCase();
        if (lower.contains('vat') || lower.contains('thuế')) {
          description = 'VAT';
        } else {
          description = 'Phí';  // Generic "Fee"
        }
      }

      results.add(ParsedReceiptItem(
        description: description,
        amount: tax.amount,
        rawLine: tax.line,
        isReadonly: true,  // Mark as readonly
      ));
      debugPrint('📋 Lotte: Added readonly tax item: $description → ${tax.amount} đ');
    }

    debugPrint('📊 Lotte: Total ${results.length} items (${results.where((r) => !r.isReadonly).length} editable + ${results.where((r) => r.isReadonly).length} readonly)');

    return results;
  }

  /// Parse OCR result into structured receipt items
  ///
  /// Returns list of [ParsedReceiptItem] containing description and amount
  /// Filters out totals, headers, and noise
  ///
  /// Supports multiple receipt formats:
  /// 1. Single-line: "Item name 50.000đ"
  /// 2. Multi-line table: Item code + name on one line, amount on another
  /// 3. Lotte-style: Items with codes, summary section with final prices
  static List<ParsedReceiptItem> parseReceipt(OcrResult ocrResult) {
    debugPrint('📄 Parser: Starting receipt parsing');
    debugPrint('📄 Parser: Input has ${ocrResult.allLines.length} lines');

    // Detect Lotte-style receipt
    final isLotteReceipt = _isLotteStyleReceipt(ocrResult.allLines);
    if (isLotteReceipt) {
      debugPrint('🏪 Parser: Detected Lotte-style receipt - using two-pass parsing');
      return _parseLotteReceipt(ocrResult);
    }

    final items = <ParsedReceiptItem>[];
    final processedIndices = <int>{};

    // Try multi-line parsing first (for table-format receipts)
    for (var i = 0; i < ocrResult.allLines.length; i++) {
      // Skip already processed lines
      if (processedIndices.contains(i)) continue;

      final line = ocrResult.allLines[i].trim();
      if (line.isEmpty) continue;

      // Try to parse as multi-line item (item code + name, then amount)
      final multiLineItem = _parseMultiLineItem(
        ocrResult.allLines,
        i,
        processedIndices,
      );

      if (multiLineItem != null) {
        items.add(multiLineItem);
        debugPrint('✅ Parser: Found multi-line item - ${multiLineItem.description}: ${multiLineItem.amount}đ');
        continue;
      }

      // Fallback to single-line parsing
      final singleLineItem = _parseItemLine(line);
      if (singleLineItem != null) {
        items.add(singleLineItem);
        processedIndices.add(i);
        debugPrint('✅ Parser: Found single-line item - ${singleLineItem.description}: ${singleLineItem.amount}đ');
      }
    }

    debugPrint('📊 Parser: Extracted ${items.length} items from ${ocrResult.allLines.length} lines');
    if (ocrResult.allLines.isNotEmpty) {
      debugPrint('📊 Parser: Success rate: ${((items.length / ocrResult.allLines.length) * 100).toStringAsFixed(1)}%');
    }

    return items;
  }

  // =========================================================================
  // Private Parsing Logic
  // =========================================================================

  /// Parse multi-line item (for table-format receipts like Lotte Mart)
  ///
  /// Expected format:
  /// ```
  /// 001 XV COMFORT DIEU KY TUI 3.1L    ← Item line (code + name)
  ///                 226500   1          ← Unit price line
  /// 8934868173038                       ← Barcode line
  ///                 226,500             ← Final amount (TARGET)
  /// ```
  ///
  /// Returns ParsedReceiptItem if item code + amount found, null otherwise
  /// Updates processedIndices to skip processed lines
  static ParsedReceiptItem? _parseMultiLineItem(
    List<String> allLines,
    int currentIndex,
    Set<int> processedIndices,
  ) {
    final line = allLines[currentIndex].trim();

    // Check if this line starts with item code (001-999 followed by name)
    final itemCodeMatch = RegExp(r'^(\d{3})\s+(.+)$').firstMatch(line);
    if (itemCodeMatch == null) return null;

    final itemCode = itemCodeMatch.group(1)!;
    final itemName = itemCodeMatch.group(2)!.trim();

    // Item name should have some letters (not just numbers)
    if (!RegExp(r'[a-zA-Zàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]')
        .hasMatch(itemName)) {
      return null;
    }

    // Item name must be at least 3 characters (reject garbage like "e", "a")
    if (itemName.length < 3) {
      debugPrint('⏭️  Parser: Item name too short - "$itemName"');
      return null;
    }

    // Skip if item name looks like noise
    if (_isNoiseLine(itemName)) return null;

    debugPrint('🔍 Parser: Found item code "$itemCode" with name "$itemName"');

    // Look ahead within reasonable proximity for amount
    // Strategy: Search nearby lines (20), stop at section boundaries
    // Prefer amounts CLOSEST to item, not largest (to avoid picking TOTAL)
    final lookAheadLimit = (currentIndex + 20).clamp(0, allLines.length);
    final candidates = <({double amount, int lineIndex, bool isFormatted})>[];

    for (var i = currentIndex + 1; i < lookAheadLimit; i++) {
      final nextLine = allLines[i].trim();

      // Skip empty lines
      if (nextLine.isEmpty) continue;

      // Skip if already processed
      if (processedIndices.contains(i)) continue;

      // Stop at section boundaries to avoid picking totals/summaries
      final lowerLine = nextLine.toLowerCase();
      if (lowerLine.contains('vat') ||
          lowerLine.contains('subtotal') ||
          lowerLine.contains('tong cong') ||
          lowerLine.contains('giam gia')) {
        debugPrint('🛑 Parser: Hit section boundary at line $i: "$nextLine"');
        break;  // Stop searching at section boundaries
      }

      // Stop at next item code (don't search across items)
      if (RegExp(r'^\d{3}\s+').hasMatch(nextLine) && i != currentIndex) {
        debugPrint('🛑 Parser: Hit next item code at line $i');
        break;  // Stop at next item
      }

      // Try to extract amount from this line
      final amount = _extractAmount(nextLine);

      // Skip negative amounts (discounts like "-57,000")
      if (amount != null && amount < 0) {
        debugPrint('⏭️  Parser: Skipping negative amount (discount): $nextLine → $amount');
        continue;
      }

      if (amount != null && amount >= 1000) {  // Minimum 1,000 VND
        // Check if this looks like a barcode (very large number, 9+ digits)
        // Barcodes can be 13 digits or split by OCR into 9-digit chunks
        final amountStr = amount.toStringAsFixed(0);
        if (amountStr.length >= 9) {
          debugPrint('⏭️  Parser: Skipping barcode-sized number: $amount');
          continue;  // Skip barcodes
        }

        // Check if this is a decimal weight (e.g., 1.282 kg, 0.272 kg)
        // Pattern: 1-2 digits + separator + exactly 3 digits = likely weight, not price
        // Example: 1.282 (weight) vs 51.152 (price with thousand separator)
        // Check the PARSED amount, not just amount < 10, to catch "1.282" = 1282
        if (amount < 10000) {  // Less than 10,000 VND is suspicious
          // Check if original line contains this as a small decimal (weight pattern)
          if (RegExp(r'\b\d{1,2}[.,]\d{3}\b').hasMatch(nextLine)) {
            debugPrint('⏭️  Parser: Skipping likely decimal weight: $nextLine → $amount');
            continue;  // Skip weights
          }
        }

        // Check if the amount is formatted (has comma or dot separator)
        final isFormatted = RegExp(r'[\.,]').hasMatch(nextLine);

        candidates.add((
          amount: amount,
          lineIndex: i,
          isFormatted: isFormatted,
        ));
        debugPrint('🔍 Parser: Found candidate amount $amount (formatted: $isFormatted) at offset ${i - currentIndex}');
      }
    }

    // If no candidates found, not a valid item
    if (candidates.isEmpty) {
      debugPrint('⏭️  Parser: No valid amount found for item "$itemName"');
      return null;
    }

    // Pick the best candidate:
    // 1. Prefer formatted amounts (226,500) over plain numbers (226500)
    // 2. Among formatted, take the CLOSEST one (nearest to item, not largest!)
    //    This avoids picking the TOTAL at the bottom
    // 3. If no formatted, take the closest plain amount
    final formattedCandidates = candidates.where((c) => c.isFormatted).toList();

    if (formattedCandidates.isEmpty && candidates.isEmpty) {
      debugPrint('⏭️  Parser: No valid candidates');
      return null;
    }

    // Sort by line index (proximity) and take CLOSEST
    final bestCandidate = formattedCandidates.isNotEmpty
        ? (formattedCandidates..sort((a, b) => a.lineIndex.compareTo(b.lineIndex))).first
        : (candidates..sort((a, b) => a.lineIndex.compareTo(b.lineIndex))).first;

    var foundAmount = bestCandidate.amount;
    final amountLineIndex = bestCandidate.lineIndex;

    // Check for discount (negative amount in next 5 lines after the price)
    double? discountAmount;
    for (var i = amountLineIndex + 1; i < (amountLineIndex + 5).clamp(0, allLines.length); i++) {
      final discountLine = allLines[i].trim();
      final amount = _extractAmount(discountLine);
      if (amount != null && amount < 0) {
        discountAmount = amount.abs();
        debugPrint('🔍 Parser: Found discount $discountAmount after price');
        break;
      }
    }

    // Apply discount if found
    if (discountAmount != null && discountAmount > 0) {
      foundAmount = foundAmount - discountAmount;
      debugPrint('💰 Parser: Applied discount: ${bestCandidate.amount} - $discountAmount = $foundAmount');
    }

    debugPrint('✅ Parser: Selected amount $foundAmount from ${candidates.length} candidates');

    // Mark all lines between item and amount as processed
    for (var i = currentIndex; i <= amountLineIndex; i++) {
      processedIndices.add(i);
    }

    return ParsedReceiptItem(
      description: itemName,
      amount: foundAmount,
      rawLine: '$itemCode $itemName',
    );
  }

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
    if (description.isEmpty || description.length < 3) {
      debugPrint('⏭️  Parser: Invalid description (too short) - "$line"');
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
    // Check for negative amounts first (discounts like "-57,000")
    final isNegative = line.contains('-');

    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final amountStr = match.group(1)!;
        // Remove separators (dots, commas, spaces) and parse
        // Handles OCR artifacts like "226, 500" → "226500"
        final cleanAmount = amountStr.replaceAll(RegExp(r'[,.\s]'), '');
        var amount = double.tryParse(cleanAmount);

        if (amount != null) {
          // Apply negative sign if present
          if (isNegative) amount = -amount;

          // Return negative amounts too (will be filtered later)
          if (amount != 0) {
            return amount;
          }
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

  /// Whether this item is readonly (e.g., taxes, fees, non-editable items)
  /// Readonly items contribute to total but cannot be edited/deleted by user
  final bool isReadonly;

  const ParsedReceiptItem({
    required this.description,
    required this.amount,
    required this.rawLine,
    this.isReadonly = false,
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
