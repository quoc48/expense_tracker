# Lesson: Cache-First Loading with Memory Preload

**Date**: December 7, 2025
**Problem**: Cache load taking 230ms instead of <50ms target
**Solution**: Memory cache + compute() isolate preloading
**Result**: 0ms cache access (instant!)

---

## The Problem

When loading cached expenses from SharedPreferences:

```
Phase 0.2 (cache read): 228ms  ← TOO SLOW!
  - getString: 0ms
  - jsonDecode: 0ms
  - fromMap loop: 233ms  ← BOTTLENECK FOUND
```

**Root Cause**: `Expense.fromMap()` was taking ~8ms per item due to `DateTime.parse()` being slow in Flutter debug mode.

---

## The Solution

### Architecture Pattern: Preload + Memory Cache

```
┌─────────────────────────────────────────────────────────────────┐
│                        APP STARTUP                               │
├─────────────────────────────────────────────────────────────────┤
│  Splash Screen (user waits anyway)                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  1. StorageService.initialize()     → SharedPrefs ready  │   │
│  │  2. StorageService.preloadCache()   → Parse in isolate   │   │
│  │     └─ compute(_parseExpensesJson)  → Background thread  │   │
│  │     └─ _memoryCache = parsed        → Store in memory    │   │
│  └─────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                        APP RUNNING                               │
├─────────────────────────────────────────────────────────────────┤
│  ExpenseProvider.loadExpenses()                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  getCachedCurrentMonthExpenses()                         │   │
│  │    └─ if (_memoryCache != null)                          │   │
│  │         return _memoryCache;  → INSTANT! (0ms)           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. Top-Level Function for Isolate
```dart
// Must be top-level (not a method) for compute() to work
List<Expense> _parseExpensesJson(String json) {
  final List<dynamic> list = jsonDecode(json);
  return list.map((e) => Expense.fromMap(e)).toList();
}
```

#### 2. Memory Cache Field
```dart
class StorageService {
  List<Expense>? _memoryCache;  // Pre-parsed expenses
  // ...
}
```

#### 3. Preload at Startup
```dart
// In main.dart
final storageService = StorageService();
await storageService.initialize();
await storageService.preloadCache();  // Heavy work during splash
```

#### 4. Instant Access
```dart
Future<List<Expense>?> getCachedCurrentMonthExpenses() async {
  // Fast path: Return pre-parsed memory cache (instant!)
  if (_memoryCache != null) {
    return _memoryCache;  // 0ms!
  }
  // Slow path: Parse from disk (fallback)
  // ...
}
```

---

## Why This Works

### Flutter Isolates
- `compute()` spawns a separate Dart isolate (like a thread)
- Isolates have their own memory heap - no shared state
- Heavy CPU work doesn't block UI animations
- Perfect for: JSON parsing, image processing, encryption

### Memory vs Disk Access
| Access Type | Time | Why |
|-------------|------|-----|
| Memory (List reference) | 0ms | Pointer access, O(1) |
| SharedPreferences getString | 0ms | Already loaded in memory |
| jsonDecode | 0ms | Fast C++ implementation |
| DateTime.parse x 28 | 230ms | String parsing, regex, timezone |

### Debug vs Release Mode
- Debug mode: 10-20x slower for CPU operations (no JIT)
- Release mode: Would be ~20-30ms instead of 230ms
- But our solution works for both!

---

## Results

| Metric | Before | After |
|--------|--------|-------|
| Phase 0.2 (cache read) | 228ms | **0ms** |
| Total cache load | 231ms | **0ms** |
| User experience | Visible delay | **Instant** |

---

## When to Use This Pattern

**Good candidates:**
- JSON parsing of cached data
- Image/file decoding
- Heavy object construction (many DateTime.parse, regex, etc.)
- Any startup data that can be pre-loaded

**Not needed for:**
- Simple key-value reads
- Small data (<10 items)
- Data that changes frequently
- Release-only apps where debug perf doesn't matter

---

## Files Changed

- `lib/services/storage_service.dart` - Added memory cache + preload
- `lib/main.dart` - Added preloadCache() call at startup

---

## Key Takeaways

1. **Measure before optimizing** - Sub-phase timing revealed the exact bottleneck
2. **Move work to where users don't notice** - Splash screen is free time
3. **Memory > Disk > Network** - Always cache in the fastest layer possible
4. **compute() for CPU work** - Keep the main thread for UI only
5. **Debug mode lies** - Always verify perf in release mode too
