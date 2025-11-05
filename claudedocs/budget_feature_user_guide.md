# Budget Tracking Feature - User Guide

**Last Updated:** November 4, 2025
**Feature Version:** 1.0
**Status:** Production-Ready

---

## 📖 Overview

The Budget Tracking feature helps you monitor your monthly spending and stay within your financial goals. Set a monthly budget and receive real-time feedback through color-coded progress indicators and smart alert banners.

---

## 🚀 Getting Started

### Setting Your First Budget

1. **Open Settings**
   - Tap the ⚙️ Settings icon in the top-right corner of the Expense List screen

2. **Navigate to Budget**
   - Under the "Budget" section, tap **Monthly Budget**

3. **Enter Your Budget**
   - Enter your desired monthly budget (e.g., 20,000,000 VND)
   - The field accepts values from 0 to 1 billion VND
   - Use Vietnamese number formatting (e.g., 20.000.000)

4. **Save**
   - Tap **Save** to apply your budget
   - Your budget is automatically synced to the cloud

---

## 📊 Understanding Budget Progress

### Analytics Screen - Monthly Overview Card

Navigate to the **Analytics** tab to view your budget progress:

**Current Month Display** (Full Mode):
```
💰 Monthly Overview              ⚠️ Warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
17,000,000₫
Total Spending

Budget (20M) ................... 85%
████████████████████░░░░░░░░░░░

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 Remaining    │    🕐 Previous
3M              │    19.1M ↓ 82.2%
```

**What You See:**
- **Total Spending**: Your total expenses for the month (hero number)
- **Status Badge**: Visual indicator of budget health
  - ✅ Green "On track" (< 70%)
  - ⚠️ Orange "Approaching limit" (70-90%)
  - 🚨 Red "Near limit" (90-100%)
  - 🚨 Red "Over budget" (> 100%)
- **Budget Progress Bar**: Visual representation of spending vs budget
- **Percentage**: Exact percentage of budget used
- **Remaining**: How much budget you have left (or how much over)
- **Previous Month**: Comparison with last month's spending

**Past Month Display** (Simplified Mode):
- When viewing previous months, budget sections are hidden
- Only shows: Total Spending + Previous Month comparison
- Rationale: You can't change past spending, so budget tracking isn't actionable

---

## 🚨 Budget Alert Banners

### What Are Alert Banners?

Alert banners appear at the top of your Expense List when you approach or exceed your budget limits. They provide immediate visual feedback about your spending status.

### Alert Levels

**1. Warning (70-90% of budget)**
```
┌────────────────────────────────────┐
│ ⚠️ Approaching budget limit     ✕ │
└────────────────────────────────────┘
```
- **Color**: Orange/Yellow background with orange border
- **When**: You've spent 70-90% of your monthly budget
- **Action**: Consider reducing discretionary spending

**2. Critical (90-100% of budget)**
```
┌────────────────────────────────────┐
│ ⚠️ Near budget limit            ✕ │
└────────────────────────────────────┘
```
- **Color**: Red background with red border
- **When**: You've spent 90-100% of your monthly budget
- **Action**: Minimize non-essential expenses

**3. Over Budget (> 100%)**
```
┌────────────────────────────────────┐
│ 🚨 Budget exceeded              ✕ │
└────────────────────────────────────┘
```
- **Color**: Red background with dark red border
- **When**: You've exceeded your monthly budget
- **Action**: Review spending and adjust for next month

---

## 🎯 Smart Dismissal Behavior

### Dismissing Alerts

- **How**: Tap the ✕ button on the right side of the banner
- **Effect**: Banner disappears immediately

### When Banners Reappear

The budget feature uses **smart dismissal logic** that balances user control with important alerts:

**Banner STAYS HIDDEN when:**
- You dismissed a Warning banner at 75%
- You add a small expense → now at 85%
- **Still Warning level** → banner stays hidden ✅
- You already acknowledged the warning

**Banner REAPPEARS when:**
- You dismissed a Warning banner at 75%
- Your budget changes → now at 95%
- **Level changed to Critical** → banner reappears ✅
- New severity requires your attention!

**Examples:**

| Scenario | Result |
|----------|--------|
| Dismissed at 75% (Warning) → Add expense → 85% (Warning) | Stays hidden |
| Dismissed at 75% (Warning) → Budget changed → 95% (Critical) | Reappears |
| Dismissed at 95% (Critical) → Delete expense → 75% (Warning) | Reappears |
| Dismissed at 105% (Over) → Pay down → 95% (Critical) | Reappears |
| App restart | Reappears (reset) |

**Why This Design?**
- Respects your dismissal within the same severity level
- Alerts you when the situation changes significantly
- Prevents banner fatigue while maintaining awareness

---

## 💡 Tips & Best Practices

### Setting a Realistic Budget

1. **Review Past Spending**: Check 2-3 months of historical data in Analytics
2. **Calculate Average**: Find your typical monthly spending
3. **Add 10% Buffer**: Account for unexpected expenses
4. **Start Conservative**: It's easier to increase than decrease

**Example:**
- Average spending: 18M VND/month
- + 10% buffer: 18M × 1.1 = 19.8M
- Round up: **20M VND budget**

### Monitoring Your Budget

**Daily Check-ins:**
- Quick glance at Expense List for alert banners
- No banner = on track (< 70%)

**Weekly Reviews:**
- Open Analytics tab
- Check budget progress percentage
- Compare with previous month trends

**End of Month:**
- Review if you stayed under budget
- Analyze categories where you overspent
- Adjust next month's budget if needed

### Handling Budget Alerts

**Warning Alert (70-90%)**
- ✅ Review remaining days in the month
- ✅ Identify non-essential spending to cut
- ✅ Set a daily spending limit for remaining days
- ❌ Don't panic - you still have 10-30% buffer

**Critical Alert (90-100%)**
- ✅ Immediately review upcoming expenses
- ✅ Defer non-urgent purchases to next month
- ✅ Look for ways to reduce current spending
- ✅ Consider adjusting budget if consistently tight

**Over Budget**
- ✅ Analyze what caused the overage (one-time or pattern?)
- ✅ Review spending by category to find culprits
- ✅ Set stricter budget for next month to compensate
- ✅ Use this as learning for better planning

---

## 🔧 Advanced Features

### Budget Without Alerts

**Don't want alert banners?**
- Keep budget at 0 in Settings
- Analytics will still show spending totals
- No progress bars or alerts will appear
- Good for tracking-only without restrictions

### Viewing Past Budget Performance

Currently, budget tracking focuses on the current month. To see past performance:
1. Navigate to previous months in Analytics
2. Budget sections are hidden (simplified view)
3. Use "Previous" comparison to see trends
4. Manual tracking: Compare each month's total to your budget

---

## ❓ FAQ

**Q: Can I set different budgets for different months?**
A: Currently, one budget applies to all months. Change it in Settings as needed month-to-month.

**Q: What happens if I don't set a budget?**
A: The app works perfectly without a budget:
- Analytics shows your spending totals
- No budget progress bars appear
- No alert banners show
- You can still track and analyze spending

**Q: Do alert banners affect past months?**
A: No, alert banners only appear for the current month. Past spending can't be changed, so alerts aren't actionable.

**Q: What if I'm always over/under budget?**
A: Adjust your budget in Settings:
- Always under → Lower it to match actual spending
- Always over → Increase it or identify areas to cut
- Goal: Budget should be realistic and achievable

**Q: Can I set budgets for specific categories?**
A: Not yet! This is planned for a future update. Currently, budget applies to total monthly spending.

**Q: Does the budget reset each month automatically?**
A: Yes! Budget tracking automatically resets on the 1st of each month. Progress starts fresh at 0%.

---

## 🐛 Troubleshooting

**Problem: Budget not saving**
- **Check**: Internet connection for Supabase sync
- **Try**: Close and reopen app
- **Solution**: Budget saves locally first, syncs when online

**Problem: Alert banner not appearing**
- **Check 1**: Are you viewing current month? (past months don't show alerts)
- **Check 2**: Is your budget > 0? (no budget = no alerts)
- **Check 3**: Are you >= 70% of budget?
- **Try**: Hot reload app or navigate away and back

**Problem: Alert banner won't dismiss**
- **Try**: Tap the ✕ button firmly
- **Try**: Swipe down to refresh the screen
- **Note**: Banner reappears on app restart (expected behavior)

**Problem: Wrong percentage showing**
- **Check**: Is budget set correctly in Settings?
- **Check**: Are all expenses saved for current month?
- **Try**: Navigate to another month and back to refresh calculations

---

## 📈 Feature Roadmap

Future improvements being considered:

- **Category-level budgets**: Set separate budgets for Food, Transport, etc.
- **Budget history**: View past months' budget adherence
- **Spending pace prediction**: "At this rate, you'll spend X by month-end"
- **Quick budget adjustment**: Edit budget directly from Analytics
- **Budget templates**: Save and reuse budget presets
- **Weekly budgets**: Track spending week-by-week

---

## 💬 Feedback

Have suggestions for the budget feature? Found a bug? We'd love to hear from you!

**Built with care for mindful spending** 💰✨

---

**Document Version:** 1.0
**Feature Version:** 1.0 (Production)
**Last Updated:** November 4, 2025
