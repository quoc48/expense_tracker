# Minimalist Theme Implementation

This directory contains the minimalist theme redesign for the Expense Tracker app.

## 📁 File Structure

```
lib/theme/minimalist/
├── README.md                    # This file
├── minimalist_colors.dart       # Grayscale color system
├── minimalist_icons.dart        # Phosphor icon mappings
├── minimalist_typography.dart   # Simplified text styles
└── minimalist_theme.dart        # Complete theme configuration
```

## 🎨 Design System

### Color Philosophy
- **90% Grayscale**: All UI elements use gray shades
- **10% Accent**: Black for CTAs and active states
- **Semantic Only**: Color only for success/warning/error states

### Icon System
- **Phosphor Flutter**: Modern, consistent icon set
- **Light Weight (1.5px)**: Maximum minimalism
- **Fill Variants**: For selected states only

### Typography
- **3 Weights Only**: 400 (Regular), 500 (Medium), 600 (SemiBold)
- **5 Size Levels**: 32px, 20px, 16px, 14px, 12px
- **Hierarchy via Weight**: Not color

## 💻 Implementation Guide

### Step 1: Install Dependencies

```yaml
# pubspec.yaml
dependencies:
  phosphor_flutter: ^2.1.0
```

```bash
flutter pub get
```

### Step 2: Create Color System

```dart
// minimalist_colors.dart
class MinimalistColors {
  // Grayscale palette
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic colors (backgrounds only)
  static const Color successBg = Color(0xFFF1F8F4);
  static const Color successText = Color(0xFF1B5E20);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color warningText = Color(0xFFF57C00);
  static const Color errorBg = Color(0xFFFEF1F2);
  static const Color errorText = Color(0xFFB71C1C);
}
```

### Step 3: Create Icon Mappings

```dart
// minimalist_icons.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MinimalistIcons {
  // Navigation
  static const IconData expensesInactive = PhosphorIconsLight.receipt;
  static const IconData expensesActive = PhosphorIconsFill.receipt;
  static const IconData analyticsInactive = PhosphorIconsLight.chartPie;
  static const IconData analyticsActive = PhosphorIconsFill.chartPie;

  // Categories
  static const Map<String, IconData> categoryIcons = {
    'Thực phẩm': PhosphorIconsLight.forkKnife,
    'Đi lại': PhosphorIconsLight.car,
    'Hoá đơn': PhosphorIconsLight.lightning,
    'Giải trí': PhosphorIconsLight.popcorn,
    'Mua sắm': PhosphorIconsLight.shoppingBag,
    'Sức khỏe': PhosphorIconsLight.heartbeat,
    'Giáo dục': PhosphorIconsLight.graduationCap,
    'Quà tặng': PhosphorIconsLight.gift,
    'Lương': PhosphorIconsLight.wallet,
    'Đồ uống': PhosphorIconsLight.coffee,
    'Thời trang': PhosphorIconsLight.tShirt,
    'Công nghệ': PhosphorIconsLight.devices,
    'Cá nhân': PhosphorIconsLight.user,
    'Khác': PhosphorIconsLight.dotsThree,
  };

  // Expense Types
  static const IconData necessary = PhosphorIconsLight.checkCircle;
  static const IconData unexpected = PhosphorIconsLight.warning;
  static const IconData wasteful = PhosphorIconsLight.xCircle;

  // Actions
  static const IconData add = PhosphorIconsRegular.plus;
  static const IconData edit = PhosphorIconsLight.pencilSimple;
  static const IconData delete = PhosphorIconsLight.trash;
  static const IconData settings = PhosphorIconsLight.gear;
  static const IconData logout = PhosphorIconsLight.signOut;
}
```

### Step 4: Create Typography System

```dart
// minimalist_typography.dart
import 'package:flutter/material.dart';

class MinimalistTypography {
  static const String fontFamily = 'Inter';
  static const String monoFamily = 'JetBrains Mono';

  // Only 3 weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;

  static TextTheme createTextTheme(Color textColor) {
    return TextTheme(
      // Hero number
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: semiBold,
        color: textColor,
        fontFamily: monoFamily,
      ),

      // Screen title
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: semiBold,
        color: textColor,
      ),

      // Body text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: regular,
        color: textColor,
      ),

      // Secondary info
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: regular,
        color: textColor.withOpacity(0.7),
      ),

      // Captions
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: regular,
        color: textColor.withOpacity(0.5),
      ),

      // Buttons
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: medium,
        color: textColor,
      ),
    );
  }
}
```

### Step 5: Create Complete Theme

```dart
// minimalist_theme.dart
import 'package:flutter/material.dart';
import 'minimalist_colors.dart';
import 'minimalist_typography.dart';

class MinimalistTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Colors
      colorScheme: ColorScheme.light(
        primary: MinimalistColors.black,
        onPrimary: MinimalistColors.white,
        secondary: MinimalistColors.gray600,
        onSecondary: MinimalistColors.white,
        surface: MinimalistColors.white,
        onSurface: MinimalistColors.gray900,
        background: MinimalistColors.gray50,
        onBackground: MinimalistColors.gray900,
        error: MinimalistColors.errorText,
        onError: MinimalistColors.white,
      ),

      // Typography
      textTheme: MinimalistTypography.createTextTheme(
        MinimalistColors.gray900,
      ),

      // Component Themes
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: MinimalistColors.gray100),
        ),
        color: MinimalistColors.white,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MinimalistColors.black,
          foregroundColor: MinimalistColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: MinimalistColors.gray300),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: MinimalistColors.black, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: MinimalistColors.errorText, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Similar but with inverted colors
    return lightTheme; // Implement dark theme later
  }
}
```

## 🔄 Migration Strategy

### Phase 1: Non-Breaking Addition
1. Add theme files alongside existing theme
2. Create feature flag for theme switching
3. Test on single screen first

### Phase 2: Gradual Rollout
```dart
// In app_theme.dart
class AppTheme {
  static bool useMinimalist = false; // Feature flag

  static ThemeData get lightTheme {
    if (useMinimalist) {
      return MinimalistTheme.lightTheme;
    }
    return _originalLightTheme;
  }
}
```

### Phase 3: Component Migration
1. Navigation bar first (high visibility)
2. Then cards and lists
3. Finally forms and dialogs

## 🧪 Testing Checklist

### Visual Tests
- [ ] All grays render correctly
- [ ] Black accent visible
- [ ] Icons display properly
- [ ] Text hierarchy clear

### Functional Tests
- [ ] Theme switching works
- [ ] Icons change on state
- [ ] Forms still functional
- [ ] Charts display data

### Accessibility Tests
- [ ] Contrast ratio ≥ 4.5:1
- [ ] Touch targets ≥ 44px
- [ ] Screen reader compatible
- [ ] Color blind safe

## 🚨 Common Issues

### Issue: Icons Not Showing
```dart
// Ensure import is correct
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Not 'phosphor_icons' or 'phosphor'
```

### Issue: Colors Too Light
```dart
// Adjust gray values if needed
static const Color gray700 = Color(0xFF616161); // Can darken to 0xFF424242
```

### Issue: Lost Hierarchy
```dart
// Increase weight differences
static const FontWeight regular = FontWeight.w300;  // Lighter
static const FontWeight semiBold = FontWeight.w700; // Heavier
```

## 📚 Resources

- [Phosphor Icons Catalog](https://phosphoricons.com)
- [Material Design 3 Guidelines](https://m3.material.io)
- [Flutter ThemeData Docs](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [WCAG Contrast Checker](https://webaim.org/resources/contrastchecker/)

## 🎯 Next Steps

1. Install phosphor_flutter package
2. Create color system file
3. Create icon mappings
4. Create typography system
5. Build complete theme
6. Test on one screen
7. Gradually migrate components

---

**Created**: November 2025
**Author**: Development Team
**Status**: Ready for Implementation