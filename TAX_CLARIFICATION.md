# Vietnamese Receipt Tax Structure - Clarified

## ✅ Correct Understanding

### How Vietnamese Receipts Work (Lotte Mart Example):

```
RECEIPT STRUCTURE:
─────────────────────────────────────────────
001 XV COMFORT:           226,500đ  (with VAT)
002-013 Items:            523,758đ  (with VAT)
                          ─────────
Subtotal:                 750,258đ  ← "Tong cong"

INFORMATIONAL SECTION (tax breakdown):
05% VAT:                   14,493đ  ℹ️
08% VAT:                   28,808đ  ℹ️
(Tax already included in item prices above)

DISCOUNTS (applied after):
- Item discount (001):    -57,000đ
- Order discount:             -58đ
                          ─────────
FINAL PAYMENT:            693,200đ  ← What you pay
─────────────────────────────────────────────
```

### Key Points:

1. **Item Prices INCLUDE VAT**
   - When you see "226,500đ" for item 001, VAT is already included
   - The receipt shows tax-inclusive pricing

2. **VAT Lines are INFORMATIONAL**
   - The "05% VAT: 14,493đ" lines show tax breakdown
   - They are NOT added on top of item prices
   - They explain how much of the total is tax

3. **Total Calculation**
   ```
   Items (with VAT):  750,258đ
   - Discounts:       -57,058đ
   = Final:           693,200đ
   ```

4. **NOT like US Sales Tax**
   - US: Shelf price $10 → At register: $10 + tax = $10.80
   - Vietnam: Display price 10,000đ → Already includes tax

## 🎯 For Expense Tracking

### What to Extract:
✅ **13 Product Items** (prices already include VAT)
- 001: 169,500đ (after discount)
- 002: 14,900đ
- 003-013: As shown

❌ **Do NOT Extract:**
- VAT lines (informational only)
- "Tong cong" line
- Discount summary lines

### Total Calculation:
```
Sum of 13 items = 693,200đ
(This matches what you paid)
```

## 📝 Vision Parser Updates

### Prompt Changes:
1. **Extract ONLY product items** (001-999)
2. **IGNORE VAT lines** (tax already in prices)
3. **Apply discounts** to relevant items
4. **Use final amounts** from rightmost column

### Expected Output:
```json
{
  "items": [
    {
      "code": "001",
      "description": "XV COMFORT DIEU KY TUI 3.1L",
      "amount": 169500  // After discount, includes VAT
    },
    {
      "code": "002",
      "description": "CL-BAO TAY",
      "amount": 14900  // Includes VAT
    }
    // ... 11 more items
  ]
}
```

### UI Display:
```
Tìm thấy 13 sản phẩm:
Giá đã bao gồm VAT

• 001 XV COMFORT: 169,500đ
• 002 CL-BAO TAY: 14,900đ
...

Tổng: 693,200đ
```

## 💡 Why This Matters

**For Budgeting:**
- User wants to know: "How much did I spend on groceries?"
- Answer: 693,200đ (the final payment)
- NOT: 650,000đ + 43,000đ tax (confusing!)

**For Categories:**
- "I spent 169,500đ on household items" ✅
- NOT "I spent 160,000đ + 9,500đ tax" ❌

**For Simplicity:**
- One number per item (tax-inclusive)
- Matches what's on the shelf/receipt
- No complex tax calculations needed

---

**Status**: ✅ Understood and Implemented
**Last Updated**: 2025-11-15
**Model Updated**: Vision parser prompt revised
