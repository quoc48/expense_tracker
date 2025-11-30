# Expense Tracker Design System Guide

This document defines the design system rules and usage patterns for the Expense Tracker app. Follow these guidelines to ensure visual consistency across all components.

---

## Table of Contents

1. [Typography](#typography)
2. [Colors](#colors)
3. [Icons](#icons)
4. [Spacing](#spacing)
5. [Components](#components)
6. [Quick Reference](#quick-reference)

---

## Typography

### Font Family

The app uses **MomoTrustSans** as the primary font, loaded from local assets (not Google Fonts).

```yaml
# pubspec.yaml
fonts:
  - family: MomoTrustSans
    fonts:
      - asset: assets/fonts/momo_trust_sans/MomoTrustSans-VariableFont_wght.ttf
```

### Usage Rule

**ALWAYS use `AppTypography.style()` for all text in custom components.**

```dart
import '../../theme/typography/app_typography.dart';

// ✅ CORRECT - Uses design system typography
Text(
  'Hello',
  style: AppTypography.style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textBlack,
  ),
)

// ❌ WRONG - Raw TextStyle loses font consistency
Text(
  'Hello',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
)
```

### AppTypography.style() Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fontSize` | `double` | `14` | Font size in logical pixels |
| `fontWeight` | `FontWeight` | `FontWeight.normal` | Font weight (w400-w700) |
| `color` | `Color?` | `null` | Text color |
| `letterSpacing` | `double?` | `null` | Letter spacing |
| `height` | `double?` | `null` | Line height multiplier |

### Font Weights

| Weight | Usage |
|--------|-------|
| `w400` (Regular) | Body text, labels, placeholders |
| `w500` (Medium) | Emphasis, category amounts, option labels |
| `w600` (SemiBold) | Section titles, navigation, buttons |
| `w700` (Bold) | Large amounts, hero numbers |

### Typography Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display Large | 48px | Bold | Hero numbers |
| Display Medium | 32px | Bold | Main totals |
| Display Small | 28px | SemiBold | Alert percentages |
| Headline Large | 24px | Medium | Screen titles |
| Headline Medium | 20px | Medium | Section headers |
| Headline Small | 18px | Medium | Card titles |
| Title Large | 16px | SemiBold | List item titles |
| Title Medium | 14px | SemiBold | Section titles |
| Body Large | 16px | Regular | Primary content |
| Body Medium | 14px | Regular | Secondary content |
| Body Small | 12px | Regular | Captions |
| Label Large | 14px | Medium | Buttons, chips |
| Label Small | 10px | Regular | Chart labels |

### Currency Text (Monospace)

For currency values that need alignment, use `AppTypography.currencyLarge/Medium/Small()`:

```dart
// Uses JetBrains Mono with tabular figures
Text(
  '1,000,000',
  style: AppTypography.currencyLarge(color: AppColors.textBlack),
)
```

---

## Colors

### Import

```dart
import '../../theme/colors/app_colors.dart';
```

### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| `AppColors.textBlack` | `#000000` | Primary text, icons, buttons |
| `AppColors.white` | `#FFFFFF` | Backgrounds, button text |

### Gray Scale

| Name | Hex | Usage |
|------|-----|-------|
| `AppColors.gray` | `#8E8E93` | Placeholder text, inactive states |
| `AppColors.gray2` | `#AEAEB2` | Secondary placeholder |
| `AppColors.gray6` | `#F2F2F7` | Input backgrounds, cards |
| `AppColors.grabber` | `#E5E5EA` | Bottom sheet grabber |

### Semantic Colors

| Name | Usage |
|------|-------|
| `AppColors.expense` | Expense amounts (negative) |
| `AppColors.income` | Income amounts (positive) |
| `AppColors.warning` | Budget alerts |

### Usage Examples

```dart
// Text colors
color: AppColors.textBlack      // Primary text
color: AppColors.gray           // Placeholder, secondary
color: const Color(0xFFAEAEB2)  // gray2 for placeholders in inputs

// Background colors
color: AppColors.gray6          // Input field backgrounds
color: AppColors.white          // Sheet backgrounds
```

---

## Icons

### Icon Library

The app uses **Phosphor Icons** via the `phosphor_flutter` package.

```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';
```

### Usage Rule

**ALWAYS use `PhosphorIconsRegular` weight (not Light, Bold, etc.)**

```dart
// ✅ CORRECT - Regular weight
Icon(
  PhosphorIconsRegular.x,
  size: 24,
  color: AppColors.textBlack,
)

// ❌ WRONG - Light weight
Icon(
  PhosphorIconsLight.x,  // Don't use Light!
  size: 24,
)
```

### Common Icons

| Icon | Name | Usage |
|------|------|-------|
| X | `PhosphorIconsRegular.x` | Close buttons |
| Caret Down | `PhosphorIconsRegular.caretDown` | Select dropdowns |
| Calendar | `PhosphorIconsRegular.calendarDots` | Date picker |
| Plus | `PhosphorIconsRegular.plus` | Add actions |
| Pencil | `PhosphorIconsRegular.pencilSimple` | Edit actions |
| Trash | `PhosphorIconsRegular.trash` | Delete actions |
| House | `PhosphorIconsRegular.house` | Home navigation |
| ChartBar | `PhosphorIconsRegular.chartBar` | Analytics |
| List | `PhosphorIconsRegular.list` | Expense list |

### Category Icons

Use `MinimalistIcons.getCategoryIcon()` for expense categories:

```dart
import '../../theme/minimalist/minimalist_icons.dart';

Icon(
  MinimalistIcons.getCategoryIcon('Thực phẩm'),
  size: 24,
  color: AppColors.textBlack,
)
```

### Icon Sizes

| Size | Usage |
|------|-------|
| 20px | Inside input fields, compact UI |
| 24px | Standard icons, navigation, list items |
| 32px | Featured icons, empty states |

---

## Spacing

### Import

```dart
import '../../theme/constants/app_spacing.dart';
```

### Spacing Scale

| Name | Value | Usage |
|------|-------|-------|
| `AppSpacing.spaceXs` | 4px | Tight gaps (icon to text) |
| `AppSpacing.spaceSm` | 8px | Label to input gap |
| `AppSpacing.spaceMd` | 16px | Section padding, card gaps |
| `AppSpacing.spaceLg` | 24px | Between form fields |
| `AppSpacing.spaceXl` | 32px | Major section breaks |

### Common Patterns

```dart
// Label to input gap
const SizedBox(height: 8),

// Between form fields
const SizedBox(height: 24),

// Sheet horizontal padding
padding: const EdgeInsets.symmetric(horizontal: 16),

// Card internal padding
padding: const EdgeInsets.all(16),
```

---

## Components

### Form Inputs

Use the unified `FormInput` component for all form fields:

```dart
import 'widgets/common/form_input.dart';

// Text input
FormInput(
  variant: FormInputVariant.text,
  label: 'Description',
  placeholder: 'Enter description',
  controller: _controller,
)

// Select dropdown
FormInput(
  variant: FormInputVariant.select,
  label: 'Category',
  placeholder: 'Select category',
  value: selectedValue,
  onTap: () => _showPicker(),
)

// Date picker
FormInput(
  variant: FormInputVariant.date,
  label: 'Date',
  placeholder: 'Select date',
  value: formattedDate,
  onTap: () => _showDatePicker(),
)
```

### Form Input Specifications

- **Label**: 14px Regular, black
- **Input height**: 48px
- **Background**: `AppColors.gray6`
- **Border radius**: 12px
- **Horizontal padding**: 16px
- **Label-to-input gap**: 8px

### Buttons

```dart
import 'widgets/common/primary_button.dart';

PrimaryButton(
  label: 'Add Expense',
  onPressed: _handleSubmit,
  isLoading: _isLoading,
)
```

### Primary Button Specifications

- **Height**: 48px
- **Background**: Black (enabled), Gray (disabled)
- **Border radius**: 12px
- **Text**: 16px SemiBold, white

### Bottom Sheets

```dart
import 'widgets/common/grabber_bottom_sheet.dart';

// With grabber (default)
showGrabberBottomSheet(
  context: context,
  child: MyContent(),
);

// Full screen without grabber
showGrabberBottomSheet(
  context: context,
  showGrabber: false,
  isFullScreen: true,
  child: MyContent(),
);
```

### Sheet Header

```dart
import 'widgets/common/sheet_header.dart';

SheetHeader(
  title: 'Add Expense',
  onClose: () => Navigator.pop(context),
)
```

---

## Quick Reference

### Import Checklist

```dart
// Typography (REQUIRED for all text)
import '../../theme/typography/app_typography.dart';

// Colors
import '../../theme/colors/app_colors.dart';

// Icons
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/minimalist/minimalist_icons.dart';

// Spacing
import '../../theme/constants/app_spacing.dart';
```

### Do's and Don'ts

| ✅ DO | ❌ DON'T |
|-------|----------|
| Use `AppTypography.style()` | Use raw `TextStyle()` |
| Use `PhosphorIconsRegular` | Use `PhosphorIconsLight` |
| Use `AppColors.textBlack` | Use `Colors.black` |
| Use `AppColors.gray6` | Use hardcoded hex colors |
| Use `FormInput` component | Create custom input widgets |

### Common Patterns

```dart
// Standard text
Text(
  'Label',
  style: AppTypography.style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textBlack,
  ),
)

// Standard icon
Icon(
  PhosphorIconsRegular.plus,
  size: 24,
  color: AppColors.textBlack,
)

// Input background container
Container(
  height: 48,
  decoration: BoxDecoration(
    color: AppColors.gray6,
    borderRadius: BorderRadius.circular(12),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: ...
)
```

---

## File Locations

| Type | Path |
|------|------|
| Typography | `lib/theme/typography/app_typography.dart` |
| Colors | `lib/theme/colors/app_colors.dart` |
| Spacing | `lib/theme/constants/app_spacing.dart` |
| Icons | `lib/theme/minimalist/minimalist_icons.dart` |
| Form Components | `lib/widgets/common/form_input.dart` |
| Buttons | `lib/widgets/common/primary_button.dart` |
| Sheets | `lib/widgets/common/grabber_bottom_sheet.dart` |

---

**Last Updated**: 2024-11-30
