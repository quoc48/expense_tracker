# Lesson: Flutter Context Lifecycle with Modal Bottom Sheets

**Date**: 2025-11-17  
**Category**: Flutter Bug Pattern  
**Severity**: Common, Easy to Miss

---

## The Bug Pattern

### Symptoms
- Navigation works but data doesn't save
- `context.mounted` returns `false` after async operations
- Code worked before, broke after adding modal bottom sheet
- No error messages, silent failure

### Root Cause

**Context becomes unmounted when modal bottom sheet closes:**

```dart
// ❌ WRONG - Captures bottom sheet's context
void _showOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => BottomSheet(  // ← New context created here
      onAction: () => _doSomething(context),  // ← Uses bottom sheet's context!
    ),
  );
}

// When bottom sheet closes:
// 1. Bottom sheet's context is disposed
// 2. onAction() callback fires
// 3. context.mounted = false
// 4. Code doesn't execute
```

**Timeline:**
1. Bottom sheet opens → New context created for bottom sheet
2. User taps option → `Navigator.pop()` closes bottom sheet
3. Bottom sheet's context disposed immediately
4. Callback fires with dead context → `context.mounted = false`
5. Async operations fail silently

---

## The Fix

**Capture parent context BEFORE showing modal:**

```dart
// ✅ CORRECT - Captures parent context
void _showOptions(BuildContext context) {
  final parentContext = context;  // ← Capture BEFORE modal

  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) => BottomSheet(  // ← Rename for clarity
      onAction: () => _doSomething(parentContext),  // ← Use parent context!
    ),
  );
}
```

**Key points:**
1. Modal builder gets NEW context (`bottomSheetContext`)
2. Parent context stays alive (tied to parent widget)
3. Callbacks use parent context → Still mounted after modal closes
4. Async operations work correctly

---

## Real-World Example

**Our Bug**: Receipt scanning feature broke manual expense save

**Before (working)**:
```dart
FAB → Navigator.push(AddExpenseScreen) → Save
// Single context throughout
```

**After (broken)**:
```dart
FAB → Modal Bottom Sheet → Navigator.push(AddExpenseScreen) → Save ❌
// Modal's context disposed before save
```

**Fixed**:
```dart
void _showAddExpenseOptions(BuildContext context) {
  final parentContext = context;  // Capture parent
  
  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) => AddExpenseBottomSheet(
      onManualAdd: () => _addExpenseManually(parentContext),  // Use parent
      onScanReceipt: () => _scanReceipt(parentContext),
    ),
  );
}
```

---

## Detection Strategy

**Add debug logging to catch this:**

```dart
Future<void> _someAsyncMethod(BuildContext context) async {
  final result = await Navigator.push(...);
  
  debugPrint('Returned from navigation');
  debugPrint('Result: $result');
  debugPrint('context.mounted: ${context.mounted}');  // ← KEY DIAGNOSTIC
  
  if (!context.mounted) {
    debugPrint('❌ Context not mounted - this is a bug!');
    return;
  }
  
  // Continue with logic
}
```

**Log output reveals the issue immediately:**
```
Result: Expense(abc123)
context.mounted: false  ← CAUGHT IT!
❌ Context not mounted - this is a bug!
```

---

## Prevention Rules

### ✅ DO:
1. **Capture context before modals**: `final parentContext = context;`
2. **Rename builder context**: `builder: (bottomSheetContext) =>` for clarity
3. **Use parent context in callbacks**: Ensures context outlives modal
4. **Add context.mounted checks**: Fail explicitly instead of silently
5. **Use guard clauses**: Check conditions separately for better debugging

### ❌ DON'T:
1. **Don't shadow context**: `builder: (context)` hides parent context
2. **Don't assume context stays valid**: Always check after async operations
3. **Don't combine checks**: `if (result != null && context.mounted)` hides which failed
4. **Don't skip logging**: Silent failures are hard to debug

---

## Related Patterns

**Similar issues occur with:**
- ✅ Dialogs: `showDialog()` - same pattern, capture parent context
- ✅ Drawers: `showDrawer()` - same pattern
- ✅ Routes: `showModalRoute()` - same pattern
- ✅ Any widget that creates new BuildContext

**General rule:**  
If you pass a callback to a widget that will be disposed, capture context BEFORE creating that widget.

---

## Code Smell Detection

**Red flags that indicate this bug:**

1. **Code worked → broke after adding modal** ← Strong indicator
2. **`context.mounted = false` after navigation** ← Definitive proof
3. **Silent failures (no errors)** ← Typical symptom
4. **Async operations after modal closes** ← High risk scenario

---

## Testing Strategy

**Always test:**
1. Open modal
2. Select option
3. Complete async flow
4. **Verify data actually saved** ← Don't just check UI

**Without verification:**
- UI might update locally (setState)
- But database/provider might not be called
- Silent data loss!

---

## Key Takeaways

1. **Modal bottom sheets create NEW context** that gets disposed on close
2. **Capture parent context BEFORE** showing modal
3. **Use parent context in callbacks** to ensure it's still mounted
4. **Add explicit logging** to catch context lifecycle bugs early
5. **Test end-to-end**, not just UI

**Remember**: Context is tied to widget lifecycle. When widget disposes, context dies. Plan accordingly!

---

## File Reference

**Fixed in**: `lib/screens/expense_list_screen.dart:246-258`  
**Related**: Flutter context lifecycle, modal bottom sheets, async navigation  
**Impact**: Critical - silent data loss without this pattern
