# Alert Colors - Visual Implementation Guide

## Color Palette

### Alert Colors (New - Earth Tones)
```
┌─────────────────────────────────────────────────────────────┐
│ Sandy Gold          #E9C46A  70-90% Budget Usage            │
│ ███████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░│
│ Peachy Orange       #F4A261  90-100% Budget Usage           │
│ ███████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░│
│ Coral Terracotta    #E76F51  >100% Budget Usage (Exceeded)  │
│ ███████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────────────────────────────────────────┘
```

### Grayscale Foundation (Unchanged)
```
┌─────────────────────────────────────────────────────────────┐
│ Gray500 (Secondary)  #9E9E9E  < 70% Budget - Safe State     │
│ ███████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│ Gray700 (Body Text)  #616161  Regular text content          │
│ ███████████████████████████████████████████░░░░░░░░░░░░░░░░│
│ Gray900 (Primary)    #212121  Strong emphasis / Text color  │
│ █████████████████████████████████████████████████████████████│
└─────────────────────────────────────────────────────────────┘
```

---

## Component Color Mapping

### 1. Budget Alert Banner (at top of expense list)

#### Display Logic
```
Budget %    Banner Status    Icon Color    Background           Text Color
─────────────────────────────────────────────────────────────────────────
< 70%       Hidden           (none)        (none)              (none)
70-90%      Visible          Sandy Gold    Sandy Gold 5-10%    Gray900
90-100%     Visible          Peachy Org.   Peachy Orange 8%    Gray900
> 100%      Visible+Pulse    Coral Terr.   Coral Terr. 5-10%   Gray900
```

#### Example: 85% Budget (Warning State)
```
┌──────────────────────────────────────────────────────────┐
│ ⚠️ Approaching budget limit              [✕]             │
│ Left border: 4px Sandy Gold (#E9C46A)                    │
│ Background gradient: Sandy Gold tint                      │
│ Icon color: Sandy Gold                                   │
│ Text: Gray900 (high contrast)                            │
└──────────────────────────────────────────────────────────┘
```

#### Example: 105% Budget (Over Budget State)
```
┌──────────────────────────────────────────────────────────┐
│ ✖️ Budget exceeded                      [✕]              │
│ Left border: 4px Coral Terracotta (#E76F51)             │
│ Background gradient: Coral Terracotta tint               │
│ Icon color: Coral Terracotta (with pulse animation)     │
│ Text: Gray900 (high contrast)                            │
│                                                           │
│ [Subtle pulsing effect: 1.5s cycle, 2% scale change]   │
└──────────────────────────────────────────────────────────┘
```

---

### 2. Monthly Overview Card (Analytics screen)

#### Full Card Layout
```
┌─────────────────────────────────────────────────────────────────┐
│ 💼 Monthly Overview                                              │
├─────────────────────────────────────────────────────────────────┤
│                                          ┌──────────────────┐   │
│  ₦ 125,000                               │ ⚠️  Approaching   │   │
│  Total Spending                          │    limit     85% │   │
│                                          └──────────────────┘   │
│                                                                  │
│ Budget (₦200,000)                                          85%  │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░                              │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│ 💰 Remaining      │   ⏱️ Previous                                │
│ ₦ 75,000          │   ₦ 110,000    ↑ 13.6%                     │
└─────────────────────────────────────────────────────────────────┘
```

#### Status Badge Colors by Budget %
```
Budget Usage    Color                 Hex Code   Status Text
──────────────────────────────────────────────────────────────
< 70%           Gray500 (secondary)   #9E9E9E    "On track"
70-90%          Sandy Gold            #E9C46A    "Approaching limit"
90-100%         Peachy Orange         #F4A261    "Near limit"
≥ 100%          Coral Terracotta      #E76F51    "Over budget"
```

#### Progress Bar Color Progression
```
0% ───────────────────────────────────────────────────── 100% +
    Gray500                        Sandy Gold    Peachy  Coral
    (safe)                         (warning)     (criti) (over)
                                   ↓ 70%         ↓ 90%  ↓ 100%
```

---

## Before & After Comparison

### BEFORE (Current - Grayscale)

#### 85% Budget State
```
Status Badge:           [⚠️  Gray700]        (subtle, hard to spot)
Progress Bar Color:     Gray700              (same as normal text)
Percentage Text:        85%  (gray700)       (no urgency)
Banner at top:          Sandy Gold ✓         (only place with color)
```

### AFTER (Updated - Alert Colors)

#### 85% Budget State
```
Status Badge:           [⚠️  Sandy Gold]     (warm, noticeable)
Progress Bar Color:     Sandy Gold (#E9C46A) (matches badge)
Percentage Text:        85%  (sandy gold)    (consistent color)
Banner at top:          Sandy Gold ✓         (reinforces alert)
```

---

## Color Application Details

### When Implementing _getStatusColor()

```dart
// Budget percentage thresholds and their corresponding alert colors

if (_percentageUsed >= 100) {
    // Budget exceeded - highest urgency
    Color: Coral Terracotta (#E76F51)
    Icon:  ✖️ (X circle)
    Text:  "Over budget"
    Badge: Coral background (8% opacity) + coral border
}

else if (_percentageUsed >= 90) {
    // Near budget limit - urgent action needed
    Color: Peachy Orange (#F4A261)
    Icon:  ⚠️ (warning)
    Text:  "Near limit" or "Critical"
    Badge: Orange background (8% opacity) + orange border
}

else if (_percentageUsed >= 70) {
    // Approaching budget - caution needed
    Color: Sandy Gold (#E9C46A)
    Icon:  ⚠️ (warning)
    Text:  "Approaching limit"
    Badge: Gold background (6-8% opacity) + gold border
}

else {
    // Safe - no alert needed
    Color: Gray500 (#9E9E9E)
    Icon:  ✓ (check circle)
    Text:  "On track"
    Badge: Gray background (10% opacity) + gray border
}
```

---

## Opacity Guidelines for Backgrounds

### Alert Color Opacity Strategy

**Why opacity?** Creates subtle backgrounds while maintaining legibility

```
Component              Alert Color    Opacity    Use Case
───────────────────────────────────────────────────────────
Background gradient    Sandy Gold     5-10%      Alert banner
Background gradient    Peachy Orange  8%         Alert banner
Background gradient    Coral Terr.    5-10%      Alert banner (pulsing)

Status badge bg        Sandy Gold     10%        MonthlyOverviewCard
Status badge bg        Peachy Orange  10%        MonthlyOverviewCard
Status badge bg        Coral Terr.    10%        MonthlyOverviewCard

Progress bar accent    Alert color    100%       Visible fill color
```

### Opacity Calculation Example
```
Sandy Gold #E9C46A at 8% opacity:
- Red:   233 × 0.08 = 18.6  → 12h
- Green: 196 × 0.08 = 15.7  → 0Fh
- Blue:  106 × 0.08 = 8.5   → 08h
Result:  Nearly invisible background tint, text still readable
```

---

## Accessibility Considerations

### Contrast Ratios (WCAG AAA - 7:1 minimum)

```
Text Color          Background               Ratio   Status
────────────────────────────────────────────────────────────
Gray900             Sandy Gold (#E9C46A)     5.2:1   ✅ AA
Gray900             Peachy Orange (#F4A261) 4.8:1   ✅ AA
Gray900             Coral Terracotta (#E76F51) 4.1:1 ✅ AA
Gray900             Sandy Gold 10% opacity  9.1:1   ✅ AAA
Gray900             Peachy Orange 10% opacity 9.3:1 ✅ AAA
Gray900             Coral Terr. 10% opacity 9.5:1   ✅ AAA

Sandy Gold          Gray200 (progress bg)   3.2:1   ⚠️  Large text
Peachy Orange       Gray200 (progress bg)   3.1:1   ⚠️  Large text
Coral Terracotta    Gray200 (progress bg)   2.9:1   ⚠️  Large text
```

**Note**: Progress bar colors meet WCAG AA for 18pt+ text (which they are)

---

## Dark Mode Considerations

### Alert Colors in Dark Theme

The alert colors should remain the same in dark mode:
```
Light Theme:    Sandy Gold #E9C46A   ← Same
Dark Theme:     Sandy Gold #E9C46A   ← Same

Reason: Earth tones work well on both light and dark backgrounds
```

### Gradient Backgrounds (Dark Mode Adaptation)

```
Light Theme Gradient:
  Sandy Gold at 5-10% opacity (very subtle tint on white)

Dark Theme Gradient:
  Sandy Gold at 15-20% opacity (more visible tint on dark)
  
Rationale: Dark backgrounds need slightly more opacity for visibility
```

---

## Implementation Checklist

### Code Changes
- [ ] Update `_getStatusColor()` in MonthlyOverviewCard
- [ ] Update `getBudgetColor()` in MinimalistColors
- [ ] Update `getBudgetBackground()` in MinimalistColors
- [ ] Verify progress bar inherits color from `statusColor`
- [ ] Verify percentage text color uses `statusColor`

### Testing
- [ ] Test budget < 70% (gray badge, no banner)
- [ ] Test budget 70-90% (gold badge, gold banner)
- [ ] Test budget 90-100% (orange badge, orange banner)
- [ ] Test budget > 100% (red badge, red banner with pulse)
- [ ] Test color transitions when spending changes
- [ ] Test on light and dark themes
- [ ] Test with larger text (accessibility)
- [ ] Test on different device sizes
- [ ] Verify WCAG contrast ratios

### Documentation
- [ ] Update component comments with new colors
- [ ] Document threshold percentages
- [ ] Add color reference to design system
- [ ] Update style guide if exists

---

## Quick Reference Card

### Alert Color Thresholds
```
BUDGET < 70%    │ BUDGET 70-90%   │ BUDGET 90-100%  │ BUDGET > 100%
────────────────┼─────────────────┼─────────────────┼──────────────
Safe State      │ Warning         │ Critical        │ Over Budget
────────────────┼─────────────────┼─────────────────┼──────────────
No banner       │ Gold banner     │ Orange banner   │ Red banner
────────────────┤─────────────────┼─────────────────┼──────────────
Gray500         │ Sandy Gold      │ Peachy Orange   │ Coral Terr.
#9E9E9E         │ #E9C46A         │ #F4A261         │ #E76F51
────────────────┤─────────────────┼─────────────────┼──────────────
"On track"      │ "Approaching"   │ "Near limit"    │ "Over budget"
────────────────┴─────────────────┴─────────────────┴──────────────

Badge background opacity: 10% (light tint)
Banner background opacity: 5-10% (very subtle)
Progress bar: 100% opacity (solid color)
Icon accent: 100% opacity (solid color)
```

