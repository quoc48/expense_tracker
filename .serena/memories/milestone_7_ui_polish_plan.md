# Milestone 7: UI Polish - Plan & Progress

**Date Started**: October 28, 2025
**Branch**: `feature/ui-polish`
**Status**: In Progress

---

## 🎯 Goals

Improve UI consistency and visual appeal through:
1. Context-based Vietnamese đồng (₫) formatting
2. Enhanced summary cards with grid layout
3. Better chart visualizations (colors, percentages, trends)
4. Improved report layout and responsiveness
5. **Add/Edit form money input improvements**

---

## 📋 Plan Decisions

### What We're Doing
✅ **Vietnamese đồng formatting** throughout app
✅ **Add/Edit form updates** (integer-only input, proper placeholder)
✅ **Summary cards enhancement** (grid layout, multiple focused cards)
✅ **Chart improvements** (colors, percentages, trend indicators)
✅ **Layout polish** (responsive, proper spacing)

### What We're Skipping (For Now)
❌ **Phase 5.5.2: Notion integration** - Not needed, data fully migrated
⏸️ **Phase 5.6: Offline-first sync** - Deferred until after UI polish
⏸️ **Milestone 6: Advanced features** - Comes after UI polish complete

---

## 🏗️ Implementation Phases

### Phase 0: Branch Setup ✅ COMPLETE
- ✅ Merged `feature/supabase-setup` to `develop`
- ✅ Created `feature/ui-polish` branch
- ✅ Updated Serena memory with plan

### Phase 1: Money Formatting Foundation (In Progress)
**Files to create**:
- `lib/utils/currency_formatter.dart` - Context-based formatter utility

**Files to modify**:
- `lib/screens/add_expense_screen.dart` - Remove decimals, update placeholder
- `lib/screens/expense_list_screen.dart` - Use new formatter
- `lib/screens/analytics_screen.dart` - Use new formatter with ₫
- `lib/widgets/category_chart.dart` - Use new formatter (compact mode)
- `lib/widgets/trends_chart.dart` - Use new formatter (compact mode)

**Key Features**:
- Vietnamese đồng (₫) as default currency
- Context-based formatting:
  - `compact`: "50k" for charts
  - `full`: "50.000₫" for lists (Vietnamese period separator)
  - `shortCompact`: "50k₫" for medium space
- Integer-only (no decimals for đồng)

**Form Changes**:
- Keyboard: `TextInputType.number` (was `numberWithOptions(decimal: true)`)
- Regex: `r'^\d*'` (was `r'^\d*\.?\d{0,2}'`)
- Placeholder: `'50000'` or `'50,000'` (was `'0.00'`)
- Icon: Consider `Icons.payments` (currently `Icons.attach_money`)

### Phase 2: Summary Cards Enhancement (Pending)
**New widget files**:
- `lib/widgets/summary_cards/summary_stat_card.dart` - Base reusable card
- `lib/widgets/summary_cards/monthly_total_card.dart` - Main total (2-column span)
- `lib/widgets/summary_cards/type_breakdown_card.dart` - Phải chi/Phát sinh/Lãng phí
- `lib/widgets/summary_cards/top_category_card.dart` - Highest category
- `lib/widgets/summary_cards/daily_average_card.dart` - Average per day

**Analytics screen changes**:
- Replace single summary card with `GridView.count`
- Responsive: 2 columns on wide screens, 1 on narrow
- Monthly total card spans 2 columns
- Visual hierarchy with elevation and colors

### Phase 3: Chart Improvements (Pending)
**Category Chart** (`lib/widgets/category_chart.dart`):
- 14 distinct category colors
- Percentage labels on bars
- Simple legend below chart
- Updated formatter usage

**Trends Chart** (`lib/widgets/trends_chart.dart`):
- Trend indicator (arrow + % change)
- Color-coded line (green down, red up)
- Updated formatter usage
- Optional gradient fill

### Phase 4: Layout Polish (Pending)
**Spacing & Responsiveness**:
- 20px screen edge padding
- 16px between cards
- Proper elevation (2dp/4dp)
- Material Design 3 compliance

**Animations**:
- Fade transitions for month changes
- Loading states
- Skeleton screens

### Phase 5: Testing & Documentation (Pending)
**Testing checklist**:
- Form: Add/Edit with integer input
- Display: Consistent ₫ symbols
- Responsive: Multiple screen sizes
- CRUD: All operations still work

---

## 📊 Progress Tracking

| Phase | Status | Estimated | Actual |
|-------|--------|-----------|--------|
| 0. Branch Setup | ✅ Complete | 15 min | 10 min |
| 1. Money Formatting | 🔄 In Progress | 45-60 min | - |
| 2. Summary Cards | ⏳ Pending | 45-60 min | - |
| 3. Chart Improvements | ⏳ Pending | 45-60 min | - |
| 4. Layout Polish | ⏳ Pending | 30-45 min | - |
| 5. Testing & Docs | ⏳ Pending | 20-30 min | - |
| **Total** | | **3.5-4.5 hours** | - |

---

## 🎓 Learning Focus

### Vietnamese Number Formatting
- Thousands separator: Period (.) not comma
  - Vietnamese: "50.000₫"
  - US: "50,000₫"
- No decimals needed (smallest unit is 1₫)
- Symbol position: After number

### Flutter Patterns
- Responsive layouts with `GridView`
- Context-based utilities (formatter)
- Widget composition (breaking large widgets)
- Material Design 3 principles
- fl_chart customization

### Design Decisions
- **Why no live formatting in input?**
  - Simple implementation
  - No cursor positioning issues
  - Standard Flutter pattern
  - Can enhance later as separate feature

---

## 📝 Next Steps

**Immediate** (Phase 1):
1. Create `currency_formatter.dart` utility
2. Update Add/Edit form (integer input, placeholder)
3. Replace all `NumberFormat.currency()` calls
4. Test form and display formatting

**After Phase 1**:
- Continue with summary cards (Phase 2)
- Then chart improvements (Phase 3)
- Layout polish (Phase 4)
- Final testing (Phase 5)

---

**Last Updated**: 2025-10-28
**Current Branch**: feature/ui-polish (branched from develop)
