# Alert Color Implementation - Code Snippets

## Color Definitions (Already in Place ✅)
**File**: `lib/theme/minimalist/minimalist_colors.dart` (lines 57-67)

```dart
// ==========================================
// Alert Colors (warm minimalist earth tones)
// ==========================================

/// Budget warning (70-90%) - Sandy gold
static const Color alertWarning = Color(0xFFE9C46A);

/// Budget critical (90-100%) - Peachy orange
static const Color alertCritical = Color(0xFFF4A261);

/// Budget over/error (>100%) - Coral terracotta
static const Color alertError = Color(0xFFE76F51);
```

---

## 1. BudgetAlertBanner - ALREADY CORRECT ✅

**File**: `lib/widgets/budget_alert_banner.dart`

### Alert Level Detection (lines 56-64)
```dart
String get _alertLevel {
  if (widget.budgetPercentage >= 100) {
    return 'over';
  } else if (widget.budgetPercentage >= 90) {
    return 'critical';
  } else {
    return 'warning';
  }
}
```

### Accent Color Selection (lines 108-118)
```dart
Color get _accentColor {
  switch (_alertLevel) {
    case 'over':
      return MinimalistColors.alertError;     // Coral terracotta
    case 'critical':
      return MinimalistColors.alertCritical;  // Peachy orange
    case 'warning':
    default:
      return MinimalistColors.alertWarning;   // Sandy gold
  }
}
```

### Gradient Background (lines 68-104)
```dart
LinearGradient get _backgroundGradient {
  switch (_alertLevel) {
    case 'over':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MinimalistColors.alertError.withValues(alpha: 0.05),
          MinimalistColors.alertError.withValues(alpha: 0.1),
          MinimalistColors.alertError.withValues(alpha: 0.05),
        ],
      );
    case 'critical':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MinimalistColors.alertCritical.withValues(alpha: 0.05),
          MinimalistColors.alertCritical.withValues(alpha: 0.08),
        ],
      );
    case 'warning':
    default:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MinimalistColors.alertWarning.withValues(alpha: 0.08),
          MinimalistColors.alertWarning.withValues(alpha: 0.05),
          MinimalistColors.alertWarning.withValues(alpha: 0.08),
        ],
      );
  }
}
```

### Display in Expense List
```dart
// In ExpenseListScreen._buildExpenseList()
// Banner appears above the expense list
BudgetAlertBanner(
  budgetPercentage: budgetPercentage,
)
```

---

## 2. MonthlyOverviewCard - NEEDS UPDATE ❌

**File**: `lib/widgets/summary_cards/monthly_overview_card.dart`

### Current Status Badge (lines 182-204)
```dart
// CURRENT: Uses grayscale
if (isCurrentMonth && budgetAmount > 0)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: statusColor.withValues(alpha: 0.1),  // Light tint of status color
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, size: 16, color: statusColor),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    ),
  ),
```

### Current Status Color Logic (lines 69-77) - UPDATE THIS
```dart
// CURRENT: Uses grayscale
Color _getStatusColor() {
  if (_percentageUsed < 70) {
    return MinimalistColors.gray500;  // Secondary - on track
  } else if (_percentageUsed < 90) {
    return MinimalistColors.gray700;  // Body text - warning
  } else {
    return MinimalistColors.gray850;  // Strong emphasis - critical
  }
}
```

### UPDATED Status Color Logic
```dart
// NEW: Uses alert colors
Color _getStatusColor() {
  if (_percentageUsed >= 100) {
    return MinimalistColors.alertError;      // Coral terracotta
  } else if (_percentageUsed >= 90) {
    return MinimalistColors.alertCritical;   // Peachy orange
  } else if (_percentageUsed >= 70) {
    return MinimalistColors.alertWarning;    // Sandy gold
  } else {
    return MinimalistColors.gray500;         // Secondary - on track
  }
}
```

### Progress Bar Section (lines 232-240)
```dart
// Status colors automatically propagate to progress bar
LinearProgressIndicator(
  value: progressValue,
  backgroundColor: MinimalistColors.gray200,  // Light background
  valueColor: AlwaysStoppedAnimation<Color>(statusColor),  // Uses _getStatusColor()
  minHeight: 8,
  borderRadius: BorderRadius.circular(4),
),
```

### Percentage Display (lines 222-227)
```dart
// Percentage text also uses statusColor
Text(
  '${_percentageUsed.toStringAsFixed(1)}%',
  style: AppTypography.currencySmall(color: statusColor).copyWith(
    fontWeight: FontWeight.bold,
  ),
),
```

---

## 3. Helper Functions to Update

**File**: `lib/theme/minimalist/minimalist_colors.dart`

### Current Budget Color Function (lines 110-121) - UPDATE THIS
```dart
// CURRENT: Uses grayscale
static Color getBudgetColor(double percentage) {
  if (percentage >= 100) {
    return errorText; // Over budget - red
  } else if (percentage >= 90) {
    return gray900;   // Near limit - black
  } else if (percentage >= 70) {
    return gray700;   // Getting close - dark gray
  } else {
    return gray500;   // Safe - medium gray
  }
}
```

### UPDATED Budget Color Function
```dart
// NEW: Uses alert colors
static Color getBudgetColor(double percentage) {
  if (percentage >= 100) {
    return alertError;      // Coral terracotta
  } else if (percentage >= 90) {
    return alertCritical;   // Peachy orange
  } else if (percentage >= 70) {
    return alertWarning;    // Sandy gold
  } else {
    return gray500;         // Safe - medium gray
  }
}
```

### Current Budget Background Function (lines 123-132) - UPDATE THIS
```dart
// CURRENT: Uses semantic colors
static Color getBudgetBackground(double percentage) {
  if (percentage >= 100) {
    return errorBackground; // Over budget
  } else if (percentage >= 90) {
    return warningBackground; // Warning zone
  } else {
    return white; // Normal
  }
}
```

### UPDATED Budget Background Function
```dart
// NEW: Uses alert colors with subtle opacity
static Color getBudgetBackground(double percentage) {
  if (percentage >= 100) {
    return alertError.withValues(alpha: 0.08);      // Subtle coral
  } else if (percentage >= 90) {
    return alertCritical.withValues(alpha: 0.08);   // Subtle orange
  } else if (percentage >= 70) {
    return alertWarning.withValues(alpha: 0.06);    // Subtle gold
  } else {
    return white;  // Normal
  }
}
```

---

## Implementation Priority

### High Priority (Direct User Impact)
1. **MonthlyOverviewCard._getStatusColor()** - Budget badge color
2. **MinimalistColors.getBudgetColor()** - Helper function
3. **MinimalistColors.getBudgetBackground()** - Badge background

### Medium Priority (Helper Functions)
- Any other code using `getBudgetColor()` or `getBudgetBackground()`
- Verify theme consistency across screens

### No Changes Needed
- BudgetAlertBanner (already correct)
- TypeBreakdownCard (intentionally grayscale)
- Charts and trend indicators

---

## Visual Comparison

### Current Implementation
```
Budget < 70%:   Gray500 (secondary text)
Budget 70-90%:  Gray700 (body text)
Budget 90-100%: Gray850 (subheading, subtle)
Budget > 100%:  Gray850 (subheading, subtle)
```

### New Implementation
```
Budget < 70%:   Gray500 (secondary text) - unchanged
Budget 70-90%:  #E9C46A Sandy Gold - warm, alert state
Budget 90-100%: #F4A261 Peachy Orange - more urgent
Budget > 100%:  #E76F51 Coral Terracotta - critical state
```

---

## Color Scheme Context

### Minimalist Philosophy
- 90% grayscale for clean, focused interface
- 10% semantic colors for functional alerts
- Alert colors (warm earth tones) for budget states
- High contrast with gray900/white text for accessibility

### Alert Color Psychology
- **Sandy Gold** (#E9C46A): Warm, inviting warning
- **Peachy Orange** (#F4A261): More urgent, energetic
- **Coral Terracotta** (#E76F51): Highest urgency, action required

---

## Files Summary

```
lib/theme/minimalist/minimalist_colors.dart
├── Lines 57-67: Alert color definitions ✅
├── Lines 110-121: getBudgetColor() ❌ UPDATE
└── Lines 123-132: getBudgetBackground() ❌ UPDATE

lib/widgets/summary_cards/monthly_overview_card.dart
├── Lines 69-77: _getStatusColor() ❌ UPDATE
└── Line 236: Progress bar (auto-updates via statusColor)

lib/widgets/budget_alert_banner.dart
├── Lines 56-118: Alert color usage ✅ CORRECT
└── Lines 68-104: Gradient backgrounds ✅ CORRECT
```

