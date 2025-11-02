# Next Session Quick Start: Complete Phase 5.5

**Task**: Finish Repository Pattern (15 minutes)  
**Goal**: Connect app to Supabase → see 873 expenses!

---

## ⚡ 4 Quick Fixes Needed

Open `lib/providers/expense_provider.dart` and make these changes:

### Fix 1: Line ~73 - addExpense()
```dart
// BEFORE:
await _storageService.saveExpenses(_expenses);

// AFTER:
await _repository.create(expense);
```

### Fix 2: Line ~108 - updateExpense()
```dart
// BEFORE:
await _storageService.saveExpenses(_expenses);

// AFTER:  
await _repository.update(updatedExpense);
```

### Fix 3: Line ~138 - deleteExpense()
```dart
// BEFORE:
await _storageService.saveExpenses(_expenses);

// AFTER:
await _repository.delete(expenseId);
```

### Fix 4: Line ~158 - restoreExpense()
```dart
// BEFORE:
await _storageService.saveExpenses(_expenses);

// AFTER:
await _repository.create(expense);
```

---

## 🚀 After Fixing

1. **Save file** - Compiler errors disappear
2. **Hot reload** - Press `r` in `flutter run` terminal
3. **Check console** - Should see: `Loaded 873 expenses from Supabase`
4. **Check app** - Expense list shows historical data!

---

## ✅ Testing Checklist

- [ ] List shows 873 expenses
- [ ] Vietnamese text displays correctly
- [ ] Add new expense works
- [ ] Edit expense works
- [ ] Delete expense works

---

## 💾 Final Commit

```bash
git add lib/providers/expense_provider.dart
git commit -m "M5 Phase 5.5: Repository Pattern complete - app connected to Supabase"
```

---

## 📁 Files to Check

**Modified**: `lib/providers/expense_provider.dart`  
**Created**: `lib/repositories/` (already committed)  
**Branch**: `feature/supabase-setup`

---

**Time**: 15 minutes total  
**Reward**: See your 873 expenses! 🎉
