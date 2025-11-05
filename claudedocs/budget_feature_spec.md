# Budget Feature Specification

**Branch:** `feature/budget-tracking`
**Started:** 2025-11-02
**Status:** 🔄 In Development

---

## 📋 Overview

Add monthly budget tracking with:
- Default 20M VND budget
- Visual progress indicators (green/yellow/red)
- Spending pace predictor
- Alert banners at 80% and 100%
- Scalable Settings UI

---

## 🎯 Core Features

### 1. Budget Configuration
- **Default**: 20,000,000 VND
- **Edit**: Via Settings screen
- **Storage**: Supabase `user_preferences` table
- **Validation**: Min 0, Max 1 billion VND

### 2. Budget Progress Display (Analytics Card)
```
Budget: 18.5M / 20M đ • 1.5M left
████████████████████░░░ 92%
📈 Pace: At this rate: 19.8M đ by month-end
```

**Color Thresholds**:
- Green: ≤60% spent
- Yellow: 60-85% spent
- Red: >85% spent

**Pace Formula**: `(currentSpending / daysPassed) × daysInMonth`

### 3. Alert Banners (Expense List)

**80% Warning**:
```
⚠️ Budget Alert                    [×]
You've used 16M / 20M đ (80%)
4M đ remaining this month
```

**100% Exceeded**:
```
🚨 Budget Exceeded                 [×]
You've spent 21M / 20M đ (105%)
1M đ over budget
```

**Dismissal**: Session-only (reappears on app restart)

### 4. Settings UI
- **Access**: Top-right icon on Expense List screen
- **Structure**: Category-based (Budget, Appearance, Advanced)
- **Scalable**: Ready for future settings (language, theme, recurring expenses)

---

## 🏗️ Architecture

### Database Schema

```sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    monthly_budget FLOAT DEFAULT 20000000,
    language TEXT DEFAULT 'vi',
    theme TEXT DEFAULT 'system',
    currency TEXT DEFAULT 'VND',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Data Flow

```
Settings Screen → UserPreferencesProvider → Repository → Supabase
                         ↓
Analytics Screen ← ConsumerWidget ← Provider (reactive updates)
Expense List ← ConsumerWidget ← Provider (for alerts)
```

### Files Structure

**New Files**:
- `lib/models/user_preferences.dart` - Data model
- `lib/repositories/user_preferences_repository.dart` - Interface
- `lib/repositories/supabase_user_preferences_repository.dart` - Implementation
- `lib/providers/user_preferences_provider.dart` - State management
- `lib/screens/settings_screen.dart` - Settings UI
- `lib/widgets/settings/budget_setting_tile.dart` - Budget list item
- `lib/widgets/settings/budget_edit_dialog.dart` - Budget input
- `lib/widgets/budget_alert_banner.dart` - Alert component

**Modified Files**:
- `lib/main.dart` - Add UserPreferencesProvider
- `lib/screens/expense_list_screen.dart` - Settings icon + banner
- `lib/widgets/summary_cards/monthly_total_card.dart` - Budget progress

---

## 🧪 Testing Checklist

### Backend
- [ ] Default 20M loads on first launch
- [ ] Budget saves to Supabase
- [ ] Updates reflect immediately
- [ ] RLS policies work

### Settings UI
- [ ] Settings icon navigates correctly
- [ ] Budget displays current value
- [ ] Edit dialog validates input
- [ ] Vietnamese formatting works

### Analytics
- [ ] Green bar at 50% ✅
- [ ] Yellow bar at 70% ✅
- [ ] Red bar at 90% ✅
- [ ] Pace calculation accurate
- [ ] Past months hide budget

### Banners
- [ ] 80% banner shows at threshold
- [ ] 100% banner shows when exceeded
- [ ] Dismiss works for session
- [ ] Reappears on restart

### Edge Cases
- [ ] Zero spending (0%)
- [ ] Day 1 (no errors)
- [ ] Day 30 (pace = actual)
- [ ] Large budget (1B+)

---

## 📊 Implementation Progress

See: `claudedocs/budget_feature_progress.md`

---

## 🎓 Key Decisions

### Why Repository Pattern?
- **Testability**: Mock without real Supabase
- **Flexibility**: Easy to switch backends
- **SOLID**: Dependency Inversion Principle

### Why 60%/85% Thresholds?
- **60%**: Psychological "comfortable half spent"
- **85%**: Allows ~4.5 days to course-correct
- **Research-based**: Balances awareness without alarm

### Why Session-Only Dismissal?
- **Critical warnings**: Should persist across sessions
- **User control**: Can dismiss when busy
- **Prevents ignoring**: Can't permanently hide problems

### Why Current Month Only?
- **Actionable**: Can't change past spending
- **Reduces guilt**: No dwelling on past failures
- **Focus**: Future action, not past mistakes

---

## 🚀 Future Enhancements (Tier 2+)

- Month-end summary before reset
- Quick budget edit from Analytics
- Weekly spending breakdown
- Historical budget adherence
- Category-specific insights
- Smart budget suggestions
- Category-level budgets

---

**Last Updated**: 2025-11-02
**Living Document**: Updates as implementation progresses
