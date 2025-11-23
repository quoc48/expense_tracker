# Receipt Scanning Implementation Analysis

## Current Status: CRITICAL BUG IDENTIFIED

**Bug**: Vision AI returns invalid categories (e.g., "Gia dụng", "Đồ uống", "Ăn vặt", "Mua sắm") that don't exist in the 14 Supabase categories.

**Impact**: Crashes when editing scanned items or trying to save because the category validation in Supabase fails.

---

## 1. VALID CATEGORIES (14 Total)

### Source: lib/theme/minimalist/minimalist_icons.dart (Lines 41-61)

```dart
1. 'Thực phẩm'        → ForkKnife (Food)
2. 'Cà phê'           → Coffee (Coffee)
3. 'Đi lại'           → Car (Transportation)
4. 'Hoá đơn'          → Lightning (Bills)
5. 'Tiền nhà'         → House (Housing)
6. 'Giải trí'         → Popcorn (Entertainment)
7. 'Du lịch'          → Airplane (Travel)
8. 'Tạp hoá'          → ShoppingBag (Groceries)
9. 'Thời trang'       → TShirt (Fashion)
10. 'Sức khỏe'        → Heartbeat (Health)
11. 'Giáo dục'        → GraduationCap (Education)
12. 'Quà vật'         → Gift (Gifts)
13. 'TẾT'             → Sparkle (Holiday/Tet)
14. 'Biểu gia đình'   → Users (Family)
```

Also confirmed in:
- lib/theme/colors/app_colors.dart (Lines 101-116): categoryColors map
- lib/models/expense.dart (Line 117): Comment: "e.g., \"Cà phê\", \"Du lịch\", \"TẾT\""

---

## 2. INVALID CATEGORIES (Currently Hardcoded)

Vision AI returns these invalid categories (from lib/services/scanning/vision_parser_service.dart):

```dart
_categorizeItem() method (Lines 314-341):
- 'Gia dụng'      (INVALID - similar to valid 'Biểu gia đình' or 'Tạp hoá')
- 'Đồ uống'       (INVALID - similar to valid 'Cà phê')
- 'Ăn vặt'        (INVALID - similar to valid 'Thực phẩm')
- 'Mua sắm'       (INVALID - maps to 'Mua sắm' fallback)
```

---

## 3. RECEIPT SCANNING FLOW

### Entry Points:
1. **lib/screens/scanning/camera_capture_screen.dart**
   - Live camera or gallery picker
   - Routes to ImagePreviewScreen

### Processing Pipeline:
2. **lib/screens/scanning/image_preview_screen.dart**
   - Three states: preview → processing → results
   - Vision AI parsing happens here (line 135)
   - ScannedItems are converted to temporary Expenses for review (lines 511-518)
   - User can edit items (line 717-751)
   - Saves to provider (line 808-825)

3. **lib/services/scanning/vision_parser_service.dart** (PRIMARY PARSER)
   - parseReceiptImage() → calls Vision API → parseResponse()
   - **BUG**: _categorizeItem() (lines 314-341) returns invalid categories
   - Returns List<ScannedItem> with hardcoded categories

4. **lib/services/scanning/gemini_parser_service.dart** (ALTERNATIVE)
   - Similar structure to VisionParserService
   - Also has _categorizeItem() logic

5. **lib/services/scanning/llm_parser_service.dart** (FALLBACK)
   - Uses OpenAI's chat API (not vision-based)
   - Requires OCR text input
   - Less commonly used

6. **lib/services/scanning/hybrid_parser_service.dart**
   - Combines LLM + rule-based parsing
   - Also has category mapping

### Models:
- **lib/models/scanning/scanned_item.dart**
  - Fields: id, description, amount, categoryNameVi, typeNameVi, confidence
  - No validation on categoryNameVi!

- **lib/models/scanning/scanned_receipt.dart**
  - Container for List<ScannedItem>
  - No validation on items

### Conversion Flow:
- ScannedItem → temporary Expense (for review UI)
- ScannedItem → Expense (for saving)
- Both happen in lib/screens/scanning/image_preview_screen.dart (lines 511-823)

### Save Flow:
- lib/providers/expense_provider.dart → ExpenseProvider.addExpense()
- Calls lib/repositories/supabase_expense_repository.dart → create()
- **VALIDATION POINT**: Lines 104-109 check if category exists in _categoryIdMap
- THROWS EXCEPTION if categoryNameVi not found in Supabase!

---

## 4. CATEGORY VALIDATION GAPS

### Missing Validations:
1. **ScannedItem model** - No validation on categoryNameVi field
2. **Vision parser** - No validation after _categorizeItem() returns category
3. **Gemini parser** - No validation after parsing
4. **LLM parser** - No validation after parsing
5. **Image preview screen** - No validation before showing items to user
6. **Add expense screen** - No validation on category dropdown

### Existing Validations:
- **SupabaseExpenseRepository.create()** (lines 104-110)
  - Checks if category exists in _categoryIdMap
  - Throws exception: "Category \"...\" not found in Supabase"
  - This is LAST-LINE defense, happens during save

---

## 5. EDIT FLOW ISSUE

When user edits a scanned item (line 717-751):
1. ScannedItem → temporary Expense (line 721-728)
2. Opens AddExpenseScreen (line 731-738)
3. AddExpenseScreen loads categories from Supabase (line 98-108)
4. User selects valid category from dropdown
5. **BUT**: Invalid category from Vision parser is still in categoryNameVi field
6. If not changed, invalid category gets passed back
7. Save fails with "not found in Supabase" error

---

## 6. FILES TO MODIFY

### Priority 1 - Core Issue:
1. **lib/services/scanning/vision_parser_service.dart**
   - _categorizeItem() returns invalid categories
   - Need category validation OR mapping to valid categories

2. **lib/models/scanning/scanned_item.dart**
   - Add validation in constructor or separate validator method
   - Fail fast with meaningful error

3. **lib/screens/scanning/image_preview_screen.dart**
   - Add validation before showing results state
   - Show error dialog if invalid categories found
   - Auto-fix or ask user to review

### Priority 2 - Parsers:
4. **lib/services/scanning/gemini_parser_service.dart**
   - Same _categorizeItem() issue

5. **lib/services/scanning/llm_parser_service.dart**
   - May return invalid categories from LLM

6. **lib/services/scanning/hybrid_parser_service.dart**
   - Combines multiple parsers, propagates invalid categories

### Priority 3 - Future Improvements:
7. **lib/utils/scanning/receipt_parser.dart**
   - Rule-based parser, may also need category mapping

---

## 7. PATTERN LEARNING OPPORTUNITY

### Historical Data Available:
- 874 expenses already in Supabase
- Each has: description, categoryNameVi, typeNameVi, amount, date

### Integration Points:
1. **After Vision parsing** (image_preview_screen.dart, line 135)
   - Query historical expenses
   - Match descriptions to learned categories
   - Fix Vision parser's invalid category choices

2. **In category mapping** (new utility)
   - Build map: vision_category → valid_category
   - Use description text to find similar historical items
   - Confidence-weighted voting from similar items

3. **Before showing results** (image_preview_screen.dart, results state)
   - Apply learned mappings
   - Show confidence scores
   - Allow user override

### Repository Method:
- **lib/repositories/expense_repository.dart**
  - Add method: getExpensesByCategory()
  - Add method: searchExpensesByDescription()
  - Already has: getAll()

---

## 8. TESTING

### Test Files:
- lib/test/vision_parser_test.dart
- lib/test/llm_parser_live_test.dart
- lib/test/receipt_parser_test.dart
- lib/test/real_lotte_receipt_test.dart

### Need Tests For:
1. Category validation
2. Invalid category rejection
3. Category mapping/fixing
4. Edit flow with invalid categories

---

## Key Insights:

1. **Root cause**: Vision parser hardcodes invalid categories in _categorizeItem()
2. **Propagation**: Invalid categories flow through entire system without validation
3. **Crash point**: SupabaseExpenseRepository.create() is last-line defense
4. **Pattern learning**: 874 historical expenses provide learning signal
5. **MVP fix**: Validate + map invalid categories to valid ones before showing UI
