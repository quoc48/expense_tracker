# Typography Reference Guide - Quick Lookup

A quick-reference guide for typography usage in the Expense Tracker app.

---

## Font Sizes (5 Sizes Only)

```
32px  ← Hero numbers (monthly totals)
20px  ← Screen headers
16px  ← Body text, buttons, card titles
14px  ← Secondary text, labels, captions
12px  ← Small text, timestamps, hints

DO NOT USE: 10px, 11px, 13px, 15px, 18px, 24px, 28px, 36px, 48px
           (except in Material 3 textTheme which handles these)
```

**Reference:** `MinimalistTypography.size*` constants

---

## Font Weights (3 Weights Only)

```
400  ← Regular (body text, descriptions)
500  ← Medium (buttons, labels, emphasis)
600  ← SemiBold (headings, strong emphasis)  ← Use for "bold"

DO NOT USE: 700 (.bold), 300, 800, 900
```

**Rule:** `FontWeight.bold` = WRONG. Use `FontWeight.w600` instead.

**Reference:** `FontWeights` constants (to be added in Phase D)

---

## Text Styles by Use Case

### Hero Numbers (Large Impact)
```dart
// Monthly total spending
Text(
  '\$12,345,678',
  style: AppTypography.currencyLarge(color: MinimalistColors.gray900),
),

// Elements: 24px, semiBold, monospace, tabular figures
```

### Screen Titles
```dart
Text(
  'Expense Tracker',
  style: Theme.of(context).textTheme.headlineMedium,
),

// Elements: 20px, semiBold, high contrast
```

### Card Titles
```dart
Text(
  'Monthly Overview',
  style: Theme.of(context).textTheme.titleMedium,
),

// Elements: 16px, medium weight
```

### Body Text (Default)
```dart
Text(
  'Tap + to add your first expense',
  style: Theme.of(context).textTheme.bodyLarge,
),

// Elements: 16px, regular weight, relaxed line height
```

### Small Text (Labels, Hints)
```dart
Text(
  'Remaining budget',
  style: Theme.of(context).textTheme.labelSmall,
),

// Elements: 12px, medium weight, secondary color
```

### Currency Values
```dart
// Large currency (hero numbers)
AppTypography.currencyLarge(color: color)  // 24px, w600, mono

// Medium currency (amounts in lists)
AppTypography.currencyMedium(color: color)  // 18px, w500, mono

// Small currency (compact displays)
AppTypography.currencySmall(color: color)   // 14px, w400, mono
```

### Component-Specific Styles

#### Expense List Items
```dart
// Title (description)
ComponentTextStyles.expenseTitle(textTheme)

// Amount
ComponentTextStyles.expenseAmount(textTheme)

// Category
ComponentTextStyles.expenseCategory(textTheme)

// Date
ComponentTextStyles.expenseDate(textTheme)
```

#### Analytics Cards
```dart
// Card title
ComponentTextStyles.cardTitle(textTheme)

// Large number
ComponentTextStyles.cardValue(textTheme)

// Subtitle/context
ComponentTextStyles.cardSubtitle(textTheme)

// Change percentage
ComponentTextStyles.cardChange(textTheme)
```

#### Budget Alerts
```dart
// "Budget exceeded" title
ComponentTextStyles.alertTitle(textTheme)

// "150%" percentage
ComponentTextStyles.alertPercentage(textTheme)

// Alert message
ComponentTextStyles.alertMessage(textTheme)
```

#### Form Fields
```dart
// "Email" label
ComponentTextStyles.fieldLabel(textTheme)

// User input text
ComponentTextStyles.fieldInput(textTheme)

// "Enter email" hint
ComponentTextStyles.fieldHint(textTheme)

// "Email is required" error
ComponentTextStyles.fieldError(textTheme)
```

#### Buttons
```dart
// Primary button text
ComponentTextStyles.buttonPrimary(textTheme)

// Secondary button text
ComponentTextStyles.buttonSecondary(textTheme)
```

#### Empty States
```dart
// "No expenses yet"
ComponentTextStyles.emptyTitle(textTheme)

// "Tap + to add..."
ComponentTextStyles.emptyMessage(textTheme)
```

---

## Color Usage in Text

### Primary Text (High Contrast)
```dart
color: MinimalistColors.gray900

Usage: Hero numbers, primary headings, emphasized text
Where: Numbers in cards, budget status, main content
```

### Secondary Text (Medium Contrast)
```dart
color: MinimalistColors.gray700

Usage: Body text, labels, secondary info
Where: Descriptions, metadata, supporting text
```

### Tertiary Text (Low Contrast)
```dart
color: MinimalistColors.gray500

Usage: Disabled state, secondary labels
Where: Placeholder text, disabled buttons
```

### Status Colors (Semantic)
```dart
// Approaching budget limit (70-90%)
color: MinimalistColors.alertWarning  // Sandy gold #E9C46A

// Near budget limit (90-100%)
color: MinimalistColors.alertCritical  // Peachy orange #F4A261

// Over budget (>100%)
color: MinimalistColors.alertError     // Coral terracotta #E76F51
```

---

## DO's and DON'Ts

### ✅ DO

```dart
// Use theme text styles
style: Theme.of(context).textTheme.titleMedium

// Use component text styles
style: ComponentTextStyles.expenseTitle(textTheme)

// Use currency styles
style: AppTypography.currencyMedium(color: color)

// Override with copyWith (max 2 properties)
style: textTheme.bodyMedium?.copyWith(
  color: MyColors.custom,
)

// Use semantic color names
color: MinimalistColors.gray900

// Use FontWeights constants (after Phase D)
fontWeight: FontWeights.semiBold

// Use design token font sizes
fontSize: MinimalistTypography.sizeCaption  // 14px
```

### ❌ DON'T

```dart
// Never hardcode TextStyle
style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.black,
)

// Never use arbitrary font sizes
fontSize: 13,  // Use 12 or 14
fontSize: 10,  // Use 12
fontSize: 24,  // Use 20 or 32

// Never use FontWeight.bold
fontWeight: FontWeight.bold  // Use FontWeight.w600

// Never override 3+ properties in copyWith
style: textTheme.bodyMedium?.copyWith(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.custom,
  letterSpacing: 0.5,  // ← 4 properties = too many
)

// Never use hardcoded hex colors
color: Color(0xFF333333)  // Use MinimalistColors

// Never use Material 2 textTheme styles
// (Material 3 textTheme is used globally)
```

---

## Common Patterns

### Pattern 1: List Item
```dart
ListTile(
  title: Text(
    expense.description,
    style: ComponentTextStyles.expenseTitle(theme.textTheme),
  ),
  subtitle: Text(
    dateFormat.format(expense.date),
    style: ComponentTextStyles.expenseDate(theme.textTheme),
  ),
  trailing: Text(
    formatCurrency(expense.amount),
    style: ComponentTextStyles.expenseAmount(theme.textTheme),
  ),
)
```

### Pattern 2: Card Title + Value
```dart
Column(
  children: [
    Text(
      'Total Spending',
      style: ComponentTextStyles.cardTitle(theme.textTheme),
    ),
    SizedBox(height: 8),
    Text(
      '\$12,345',
      style: ComponentTextStyles.cardValue(theme.textTheme),
    ),
  ],
)
```

### Pattern 3: Currency Display
```dart
Text(
  CurrencyFormatter.format(amount),
  style: AppTypography.currencyMedium(
    color: MinimalistColors.gray900,  // Hero number
  ),
)
```

### Pattern 4: Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: statusColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    statusText,
    style: ComponentTextStyles.statusBadge(
      theme.textTheme,
      statusTextColor,
    ),
  ),
)
```

### Pattern 5: Empty State
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.receipt, size: 72),
      SizedBox(height: 16),
      Text(
        'No expenses yet',
        style: ComponentTextStyles.emptyTitle(theme.textTheme),
      ),
      SizedBox(height: 8),
      Text(
        'Tap + to add your first expense',
        style: ComponentTextStyles.emptyMessage(theme.textTheme),
      ),
    ],
  ),
)
```

---

## Line Heights

```
Display text (headings):    1.2  (tight for impact)
Headline/Title:            1.3  (balanced)
Body text:                 1.5  (comfortable reading)
Labels/Buttons:            1.4  (compact)
```

All automatically applied via theme. **Don't override unless necessary.**

---

## Letter Spacing

```
Headings:     -0.25 to 0.15  (tight to slight relaxed)
Body:          0.25 to 0.5   (normal to relaxed)
Labels:        0.5           (wide for emphasis)
```

All automatically applied via theme. **Don't override unless necessary.**

---

## Material 3 TextTheme Reference

### Display Styles (Large Impact)
```
displayLarge   → 48px, bold, tight
displayMedium  → 36px, w600, tight
displaySmall   → 28px, w600, relaxed
```

### Headline Styles (Section Headers)
```
headlineLarge  → 24px, w500, balanced
headlineMedium → 20px, w500, balanced
headlineSmall  → 18px, w500, balanced
```

### Title Styles (Card/Item Titles)
```
titleLarge     → 16px, w600, relaxed
titleMedium    → 14px, w500, relaxed
titleSmall     → 12px, w500, secondary color
```

### Body Styles (Main Content)
```
bodyLarge      → 16px, normal, relaxed
bodyMedium     → 14px, normal, relaxed
bodySmall      → 12px, normal, secondary
```

### Label Styles (Buttons, Chips)
```
labelLarge     → 14px, w500, tight
labelMedium    → 12px, w500, tight
labelSmall     → 11px, w500, tight, tertiary
```

---

## When to Use What

| Situation | Style | Example |
|-----------|-------|---------|
| App title/header | headlineMedium | "Expense Tracker" |
| Screen section | titleMedium | "Monthly Overview" |
| Card title | titleMedium | "Total Spending" |
| Large number | displayMedium / currencyLarge | "$12,345" |
| List item title | titleLarge | Expense description |
| List item meta | labelSmall | Date, category |
| Body paragraph | bodyLarge | Description text |
| Hint/placeholder | bodyMedium (opacity 0.38) | "Enter amount" |
| Button text | labelLarge | "Save", "Cancel" |
| Error message | bodySmall | "Required field" |
| Small label | labelSmall | "Budget limit" |
| Currency amount | currencyMedium | "$500" amount |
| Percentage | currencySmall | "25%" of budget |

---

## Dark Mode Support

All colors and styles automatically adapt to dark mode via:
```dart
// System automatically provides dark-adapted colors
Theme.of(context).textTheme
Theme.of(context).colorScheme

// Minimalist colors also support dark mode
MinimalistColors.gray900  // Automatically darker in dark mode
```

**No special handling needed** for typography in dark mode.

---

## Accessibility

### Text Contrast
- Primary text (gray900) on white: ✅ WCAG AAA (21:1)
- Secondary text (gray700) on white: ✅ WCAG AAA (13:1)
- Status colors: ✅ All meet WCAG AA minimum

### Text Size
- Minimum readable: 12px ✅
- Body text: 16px ✅
- Never goes below 11px (labelSmall)

### Line Height
- Minimum: 1.2 (headings) ✅
- Normal: 1.5 (body) ✅
- Ensures readability and accessibility

---

## Troubleshooting

### Problem: Text looks blurry
**Solution:** Use theme styles instead of hardcoding
```dart
// Bad
style: TextStyle(fontSize: 14)

// Good
style: theme.textTheme.bodyMedium
```

### Problem: Text color doesn't fit background
**Solution:** Use semantic color names
```dart
// Bad
color: Color(0xFF555555)

// Good
color: MinimalistColors.gray700
```

### Problem: Font weight not matching design
**Solution:** Check design system has only 3 weights
```dart
// Bad: Using .w700
fontWeight: FontWeight.bold

// Good: Using .w600
fontWeight: FontWeight.w600
```

### Problem: Size not in the 5-size scale
**Solution:** Map to nearest size
```
Need 13px? Use 12px (labelSmall)
Need 15px? Use 16px (bodyMedium)
Need 19px? Use 20px (headlineMedium)
```

### Problem: Text overlapping or clipping
**Solution:** Check line height and padding
```dart
// Add breathing room
Padding(
  padding: EdgeInsets.symmetric(vertical: 4),  // Prevent clipping
  child: Text(...),
)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 9, 2025 | Initial typography system |
| 1.1 | TBD (Phase D) | FontWeights constants, new component styles |

---

## Related Documents

- **TYPOGRAPHY_ANALYSIS.md** - Complete technical analysis
- **TYPOGRAPHY_FIXES_PHASE_D.md** - Implementation guide
- **TYPOGRAPHY_EXECUTIVE_SUMMARY.md** - High-level overview
- **app_typography.dart** - Source implementation
- **minimalist_typography.dart** - Design token definitions

---

## Quick Links

**Design System Files:**
- Typography: `/lib/theme/typography/app_typography.dart`
- Minimalist: `/lib/theme/minimalist/minimalist_typography.dart`
- Colors: `/lib/theme/colors/app_colors.dart`
- Spacing: `/lib/theme/constants/app_spacing.dart`

**Widget Examples:**
- Cards: `/lib/widgets/summary_cards/`
- Charts: `/lib/widgets/category_chart.dart`, `trends_chart.dart`
- Settings: `/lib/widgets/settings/`

---

## Summary

✅ **5 font sizes** (12, 14, 16, 20, 32px)  
✅ **3 font weights** (.400, .500, .600)  
✅ **Semantic component styles** (expenseTitle, cardValue, etc.)  
✅ **Semantic color names** (gray900, gray700, gray500)  
✅ **Material 3 compliance** (headlineSmall, bodyMedium, etc.)

**Golden Rule:** Never hardcode. Always use theme, design system, or component styles.

---

*Last Updated: November 9, 2025*  
*Status: Complete & Ready for Phase D Implementation*
