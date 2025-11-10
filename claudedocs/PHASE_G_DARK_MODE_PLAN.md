# Phase G: Dark Mode Implementation Plan

**Branch**: feature/dark-mode (new branch from main)
**Estimated Time**: 5-8 hours (3 sessions)
**Scope**: Full dark mode + theme persistence + system theme support

---

## Prerequisites

**Before starting:**
1. Merge `feature/ui-modernization` to `main`
2. Create new branch: `git checkout -b feature/dark-mode`
3. Verify current design system is working correctly

---

## Session 1: Dark Colors + Theme Provider (2-3 hours)

### 1.1 Define Dark Mode Color Palette

**Create/Update**: `lib/theme/minimalist/minimalist_colors.dart`

**Add dark mode colors (inverted grayscale):**
```dart
// Dark Mode Grayscale (for dark theme)
static const Color darkGray50 = Color(0xFF0A0A0A);   // Background (almost black)
static const Color darkGray100 = Color(0xFF121212);  // Card background (elevated)
static const Color darkGray200 = Color(0xFF1E1E1E);  // Dividers
static const Color darkGray300 = Color(0xFF2A2A2A);  // Borders
static const Color darkGray400 = Color(0xFF404040);  // Disabled
static const Color darkGray500 = Color(0xFF757575);  // Tertiary text
static const Color darkGray600 = Color(0xFF9E9E9E);  // Secondary text
static const Color darkGray700 = Color(0xFFBDBDBD);  // Body text
static const Color darkGray800 = Color(0xFFE0E0E0);  // Headings
static const Color darkGray900 = Color(0xFFFAFAFA);  // Primary text (lightest)
```

**Adjust alert colors for dark mode:**
```dart
// Alert Colors (slightly dimmed for dark mode)
static const Color darkAlertWarning = Color(0xFFD4B55F);   // Sandy gold (dimmed)
static const Color darkAlertCritical = Color(0xFFE09456);  // Peachy orange (dimmed)
static const Color darkAlertError = Color(0xFFD36449);     // Coral terracotta (dimmed)
```

**Add helper method:**
```dart
/// Get color based on theme brightness
static Color getAdaptiveGray(BuildContext context, {
  required Color lightColor,
  required Color darkColor,
}) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark ? darkColor : lightColor;
}
```

### 1.2 Create Theme Configuration

**Create**: `lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'minimalist/minimalist_colors.dart';
import 'typography/app_typography.dart';

class AppTheme {
  // Light theme (current minimalist design)
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: MinimalistColors.black,
        onPrimary: MinimalistColors.white,
        secondary: MinimalistColors.gray700,
        onSecondary: MinimalistColors.white,
        error: MinimalistColors.alertError,
        onError: MinimalistColors.white,
        surface: MinimalistColors.white,
        onSurface: MinimalistColors.gray900,
        surfaceContainerHighest: MinimalistColors.gray100,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: MinimalistColors.white,
        foregroundColor: MinimalistColors.gray900,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.titleMedium,
          fontWeight: FontWeight.w600,
          color: MinimalistColors.gray900,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: MinimalistColors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ... other theme properties
    );
  }

  // Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: MinimalistColors.white,
        onPrimary: MinimalistColors.darkGray900,
        secondary: MinimalistColors.darkGray700,
        onSecondary: MinimalistColors.darkGray900,
        error: MinimalistColors.darkAlertError,
        onError: MinimalistColors.darkGray900,
        surface: MinimalistColors.darkGray100,
        onSurface: MinimalistColors.darkGray900,
        surfaceContainerHighest: MinimalistColors.darkGray200,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: MinimalistColors.darkGray100,
        foregroundColor: MinimalistColors.darkGray900,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.titleMedium,
          fontWeight: FontWeight.w600,
          color: MinimalistColors.darkGray900,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: MinimalistColors.black.withOpacity(0.24),  // Stronger shadow for dark mode
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: MinimalistColors.darkGray200,  // Slightly elevated
      ),

      // ... other theme properties
    );
  }
}
```

### 1.3 Create Theme Provider

**Create**: `lib/providers/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load theme preference from storage
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';

    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Set theme mode and persist preference
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String themeModeString;

    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }

    await prefs.setString('theme_mode', themeModeString);
  }
}
```

### 1.4 Update Main App

**Update**: `lib/main.dart`

```dart
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Expense Tracker',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          // ... rest of app config
        );
      },
    );
  }
}
```

### 1.5 Add Theme Toggle to Settings

**Update**: `lib/screens/settings_screen.dart`

```dart
// Add theme selection section
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(PhosphorIconsLight.palette),
        title: Text('Appearance'),
      ),
      RadioListTile<ThemeMode>(
        title: const Text('Light'),
        value: ThemeMode.light,
        groupValue: themeProvider.themeMode,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            themeProvider.setThemeMode(value);
          }
        },
      ),
      RadioListTile<ThemeMode>(
        title: const Text('Dark'),
        value: ThemeMode.dark,
        groupValue: themeProvider.themeMode,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            themeProvider.setThemeMode(value);
          }
        },
      ),
      RadioListTile<ThemeMode>(
        title: const Text('System'),
        subtitle: const Text('Follow device setting'),
        value: ThemeMode.system,
        groupValue: themeProvider.themeMode,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            themeProvider.setThemeMode(value);
          }
        },
      ),
    ],
  ),
)
```

**Session 1 Deliverables:**
- ✅ Dark mode color palette defined
- ✅ Light + Dark theme configuration
- ✅ ThemeProvider with persistence
- ✅ Theme toggle in Settings
- ✅ Theme loads on app startup

---

## Session 2: Adaptive Components (2-3 hours)

### 2.1 Update Screens

**Strategy**: Replace hardcoded colors with theme-aware alternatives

**Before:**
```dart
color: MinimalistColors.gray900
```

**After (Option A - Simple):**
```dart
color: Theme.of(context).colorScheme.onSurface
```

**After (Option B - Explicit):**
```dart
color: MinimalistColors.getAdaptiveGray(
  context,
  lightColor: MinimalistColors.gray900,
  darkColor: MinimalistColors.darkGray900,
)
```

### 2.2 Screens to Update

1. **ExpenseListScreen**
   - Background colors
   - Text colors
   - Card backgrounds
   - Icon colors

2. **AnalyticsScreen**
   - Month selector card
   - Summary cards background
   - Chart colors
   - Empty state

3. **SettingsScreen**
   - Card backgrounds
   - List tile colors
   - Divider colors

4. **AddExpenseScreen**
   - Form field backgrounds
   - Text input colors
   - Button colors

5. **Auth Screens** (Login/Register)
   - Background
   - Form fields
   - Error messages

### 2.3 Update Widgets

1. **MonthlyOverviewCard**
   - Card background
   - Text colors (hero, labels, amounts)
   - Progress bar colors
   - Status badge colors

2. **CategoryChart**
   - Bar colors (maintain hierarchy in dark mode)
   - Background bars
   - Grid lines
   - Axis labels

3. **TrendsChart**
   - Line colors
   - Grid colors
   - Labels

4. **BudgetAlertBanner**
   - Alert background colors
   - Text colors (ensure contrast)

### 2.4 Test Contrast Ratios

**Tools:**
- WebAIM Contrast Checker
- Flutter DevTools (color inspector)

**Minimum ratios:**
- Normal text: 4.5:1
- Large text (≥18px): 3:1
- UI components: 3:1

**Test combinations:**
- Dark background + light text
- Dark cards + light text
- Alert colors on dark background
- Chart colors on dark background

**Session 2 Deliverables:**
- ✅ All screens adapted to dark mode
- ✅ All widgets adapted to dark mode
- ✅ WCAG AA contrast verified
- ✅ Charts readable in both themes

---

## Session 3: Polish & Documentation (1-2 hours)

### 3.1 Visual Polish

**Check list:**
- [ ] Shadows visible but subtle in dark mode
- [ ] Card elevation distinguishable
- [ ] Alert colors maintain warm earth tone feel
- [ ] No pure white (#FFFFFF) in dark mode
- [ ] No pure black (#000000) text in dark mode
- [ ] Status badges readable in both themes
- [ ] FAB stands out in both themes
- [ ] Dividers visible but subtle

### 3.2 Edge Cases Testing

**Test scenarios:**
- [ ] Switch theme while on each screen
- [ ] Switch theme during form input
- [ ] Switch theme with modal open
- [ ] Switch theme with bottom sheet visible
- [ ] App restart in each theme mode
- [ ] System theme change detection
- [ ] Theme persists after logout/login

### 3.3 Update Documentation

**Update**: `claudedocs/DESIGN_SYSTEM_GUIDE.md`

Add section:
```markdown
## Dark Mode

### Color System
[Document dark mode color palette]

### Usage Guidelines
[How to use adaptive colors]

### Contrast Requirements
[WCAG compliance in dark mode]
```

**Create**: `claudedocs/DARK_MODE_IMPLEMENTATION.md`

Document:
- Dark mode philosophy
- Color palette rationale
- Implementation approach
- Testing methodology
- Common pitfalls avoided

**Update**: `lib/theme/minimalist/minimalist_colors.dart`

Add comprehensive comments:
- When to use each dark color
- Contrast ratios achieved
- Alert color adjustments

### 3.4 Performance Check

**Verify:**
- [ ] No jank when switching themes
- [ ] Smooth transitions
- [ ] No unnecessary rebuilds
- [ ] Efficient color lookups

**Session 3 Deliverables:**
- ✅ All edge cases tested
- ✅ Documentation updated
- ✅ Performance verified
- ✅ Final polish complete

---

## Git Workflow

### Commit Pattern

**Session 1:**
```
feat(theme): Add dark mode foundation and theme provider

- Define dark mode color palette (inverted grayscale)
- Create AppTheme with light and dark configurations
- Implement ThemeProvider with SharedPreferences persistence
- Add theme toggle to Settings screen
- Support Light/Dark/System theme modes
```

**Session 2:**
```
feat(theme): Make all components dark mode compatible

- Update all screens to use theme-aware colors
- Adapt charts for dark mode visibility
- Update all widgets to support theme switching
- Verify WCAG AA contrast ratios in dark mode
```

**Session 3:**
```
feat(theme): Polish dark mode and complete documentation

- Fine-tune shadows and elevation in dark mode
- Test and fix edge cases (theme switching scenarios)
- Update design system documentation
- Create dark mode implementation guide
```

### Final Merge

```bash
git checkout main
git merge feature/dark-mode
git push origin main
```

---

## Success Criteria

**Phase G is complete when:**
- ✅ Users can toggle between Light, Dark, and System themes
- ✅ Theme preference persists across app restarts
- ✅ All screens look good in both themes
- ✅ Charts and graphs readable in dark mode
- ✅ WCAG 2.1 AA contrast maintained in dark mode
- ✅ No visual glitches when switching themes
- ✅ System theme changes are detected and applied
- ✅ Documentation fully updated

---

## Estimated Timeline

**Conservative**: 8 hours (3 × 2-3 hour sessions)
**Optimistic**: 5 hours (3 × 1.5-2 hour sessions)
**Realistic**: 6-7 hours (3 × 2-2.5 hour sessions)

**Recommended pace:**
- Session 1: Foundation (can stop here and continue later)
- Session 2: Adaptation (majority of work)
- Session 3: Polish (quick cleanup)

---

## References

**Flutter Dark Theme Guide**: https://docs.flutter.dev/cookbook/design/themes
**Material Design Dark Theme**: https://m3.material.io/styles/color/dark-theme/overview
**WCAG Contrast Requirements**: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html

---

**Created**: 2025-01-10
**For**: Phase G (Dark Mode) implementation
**Branch**: feature/dark-mode (to be created)
**Prerequisite**: Merge feature/ui-modernization to main first
