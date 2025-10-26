# Milestone 3: Analytics & Charts - Implementation Plan

## 📊 Overview
Add analytics screen with data visualization using bottom navigation and `graphic` charting library.

## 🎯 User Requirements
Based on brainstorming session on 2025-10-26:

### Navigation Choice:
✅ **Bottom Navigation Bar** (Expenses | Analytics)
- Always visible
- Industry standard
- Clean separation of concerns

### Analytics Features:
1. **Monthly totals & comparison**
   - Current month total spending
   - Previous month total
   - Percentage change indicator (↑/↓)

2. **Category breakdown chart**
   - Bar chart showing spending by category
   - Interactive tooltips
   - Color-coded

3. **Spending trends over time**
   - Line chart for last 6 months
   - Area fill with gradient
   - Shows spending patterns

4. **Month selector**
   - Format: ◀ October 2025 ▶
   - Navigate previous/next months
   - Cannot go beyond current month

### Chart Library:
✅ **graphic v2.6.0** (chosen over fl_chart)
- Grammar of Graphics approach
- Declarative, composable
- Great animations
- Interactive by default
- Steeper learning curve but more educational

---

## 🏗️ Implementation Phases

### Phase 1: Navigation Structure (1 hour)
**Goal**: Add bottom navigation to app

**Files**:
- CREATE: `lib/screens/main_navigation_screen.dart`
- MODIFY: `lib/main.dart`
- MODIFY: `lib/screens/expense_list_screen.dart`

**Tasks**:
1. Create MainNavigationScreen with NavigationBar
2. Two destinations: Expenses (Icons.receipt_long) and Analytics (Icons.bar_chart)
3. Manage _selectedIndex state
4. Switch between screens
5. Update main.dart to use MainNavigationScreen as home
6. Remove Scaffold wrapper from ExpenseListScreen (keep content only)

**Learning**: Bottom navigation patterns, widget composition

---

### Phase 2: Provider State Management (1.5 hours)
**Goal**: Share expense data between screens

**Dependencies**:
```yaml
provider: ^6.1.0
```

**Files**:
- CREATE: `lib/providers/expense_provider.dart`
- MODIFY: `lib/main.dart`
- MODIFY: `lib/screens/expense_list_screen.dart`
- MODIFY: `lib/screens/add_expense_screen.dart` (minimal)

**Tasks**:
1. Create ExpenseProvider extending ChangeNotifier
2. Move expense list state to provider
3. Move StorageService to provider
4. Implement methods: loadExpenses, addExpense, updateExpense, deleteExpense
5. Call notifyListeners() after state changes
6. Wrap MaterialApp with ChangeNotifierProvider in main.dart
7. Refactor ExpenseListScreen to use Provider.of or Consumer
8. Remove local state management from ExpenseListScreen

**Learning**: Provider pattern, ChangeNotifier, state lifting, reactive programming

---

### Phase 3: Analytics Utilities (1 hour)
**Goal**: Create data processing functions

**Files**:
- CREATE: `lib/utils/analytics_calculator.dart`
- CREATE: `lib/models/month_total.dart`

**Tasks**:
1. Create MonthTotal model (month: DateTime, total: double)
2. Implement analytics functions:
   - `getExpensesForMonth(expenses, month)` - filter by month
   - `getTotalForMonth(expenses, month)` - sum amounts
   - `getCategoryBreakdown(expenses, month)` - Map<Category, double>
   - `getTypeBreakdown(expenses, month)` - Map<ExpenseType, double>
   - `getMonthlyTrend(expenses, monthCount)` - List<MonthTotal> for last N months
3. Helper: `isSameMonth(date1, date2)` - compare months ignoring days
4. Date formatting utilities

**Learning**: Data aggregation, filtering, DateTime manipulation, Map operations

---

### Phase 4: Analytics Screen Foundation (1.5 hours)
**Goal**: Build analytics screen UI without charts

**Files**:
- CREATE: `lib/screens/analytics_screen.dart`
- MODIFY: `lib/screens/main_navigation_screen.dart`

**Tasks**:
1. Create AnalyticsScreen StatefulWidget
2. Add _selectedMonth state (default = current month)
3. Build month selector:
   - Previous button (◀)
   - Month/Year display (October 2025)
   - Next button (▶) - disabled if current month
4. Create summary card:
   - This month total
   - Previous month total
   - Percentage change with color (green down, red up)
   - Icon: ↑ or ↓
5. Add placeholder sections for charts
6. Handle empty state (no expenses this month)
7. Replace Placeholder in main_navigation_screen.dart with AnalyticsScreen

**Learning**: Date arithmetic, conditional UI, state management, card layouts

---

### Phase 5: Charts with `graphic` Library (3-4 hours)
**Goal**: Implement interactive charts

**Dependencies**:
```yaml
graphic: ^2.6.0
```

**Files**:
- CREATE: `lib/widgets/category_chart.dart`
- CREATE: `lib/widgets/trends_chart.dart`
- MODIFY: `lib/screens/analytics_screen.dart`

#### Subtask A: Category Breakdown Chart (1.5 hours)
**Tasks**:
1. Study graphic package documentation and examples
2. Create CategoryChart widget
3. Transform data: Map<Category, double> → Chart data format
4. Implement vertical bar chart:
   - X-axis: Category names
   - Y-axis: Dollar amounts
   - Color by category
   - Tooltip on hover/tap
   - Smooth entrance animation
5. Handle empty data
6. Integrate into AnalyticsScreen

**Learning**: Grammar of Graphics, data transformation, Chart widget

#### Subtask B: Spending Trends Chart (1.5 hours)
**Tasks**:
1. Create TrendsChart widget
2. Transform data: List<MonthTotal> → Chart data format
3. Implement line chart:
   - X-axis: Month abbreviations (Jun, Jul, Aug...)
   - Y-axis: Total spending
   - Line with points
   - Area fill with gradient
   - Tooltip showing month + amount
   - Line drawing animation
4. Handle insufficient data (<2 months)
5. Integrate into AnalyticsScreen

**Learning**: Line charts, area charts, time-series data

#### Subtask C: Polish & Empty States (30 min)
**Tasks**:
1. Empty state for no data: friendly message + icon
2. Loading indicators while calculating
3. Chart animations tuning
4. Responsive sizing
5. Colors matching app theme

---

### Phase 6: Polish & Testing (1 hour)
**Goal**: Production-ready quality

**Tasks**:
1. **Animations**:
   - Smooth tab transitions
   - Chart update animations
   - Fade-in for content

2. **Testing**:
   - Test with 0 expenses
   - Test with 1 expense
   - Test with many expenses
   - Test month navigation
   - Test chart interactions
   - Test switching tabs
   - Test add/edit/delete updates charts
   - Test app restart (data persistence)

3. **Edge Cases**:
   - First month of using app
   - Future dates
   - Very large amounts
   - Many categories

4. **Polish**:
   - Consistent spacing
   - Proper loading states
   - Error messages if needed
   - Accessibility labels

5. **Documentation**:
   - Update todo.md
   - Create git commit
   - Update Serena memories

---

## 📦 Dependencies Summary

```yaml
dependencies:
  flutter:
    sdk: flutter
  intl: ^0.19.0  # (already have)
  shared_preferences: ^2.2.2  # (already have)
  provider: ^6.1.0  # NEW
  graphic: ^2.6.0  # NEW
```

---

## 🎓 Learning Objectives

By completing Milestone 3, you will learn:

1. **State Management**:
   - Provider pattern and ChangeNotifier
   - Lifting state up
   - Consumer vs Provider.of
   - When to use app-level state

2. **Data Visualization**:
   - Grammar of Graphics principles
   - Chart composition
   - Data transformation for charts
   - Interactive visualizations

3. **Flutter Patterns**:
   - Bottom navigation
   - Multi-screen apps
   - Widget composition
   - Responsive layouts

4. **Date/Time**:
   - Month arithmetic
   - Date comparison and filtering
   - Formatting dates for display

5. **Advanced UI**:
   - Chart animations
   - Loading states
   - Empty states
   - Conditional rendering

---

## ⏱️ Time Estimate

- **Total**: 8-10 hours
- **Per Session**: 2-3 hour coding sessions recommended
- **Milestones**: Can be broken into 3-4 sessions

---

## ✅ Success Criteria

Milestone 3 is complete when:
- ✅ Bottom navigation works smoothly
- ✅ Can switch between Expenses and Analytics
- ✅ Provider manages expense state
- ✅ Month selector navigates correctly
- ✅ Category chart displays and is interactive
- ✅ Trends chart shows spending over time
- ✅ Charts update when expenses change
- ✅ Empty states handled gracefully
- ✅ All features tested thoroughly
- ✅ Code committed with descriptive message

---

**Status**: Ready to implement
**Created**: 2025-10-26
**Approved by User**: Yes
