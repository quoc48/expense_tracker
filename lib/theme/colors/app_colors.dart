import 'package:flutter/material.dart';

/// Color system for the Expense Tracker app
/// Based on Figma design with iOS-style gray system
///
/// Design Reference: Figma node-id=5-939
///
/// **Usage**: Use adaptive helper methods for dark mode support:
/// - `AppColors.getBackground(context)` instead of `AppColors.background`
/// - `AppColors.getSurface(context)` for card/sheet backgrounds
/// - `AppColors.getTextPrimary(context)` for primary text
/// - `AppColors.getDivider(context)` for dividers
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===== iOS Gray System - Light Mode (from Figma) =====
  // These colors follow Apple's Human Interface Guidelines
  static const Color background = Color(0xFFEDEFF1);      // Main app background
  static const Color gray = Color(0xFF8E8E93);            // Secondary text
  static const Color gray3 = Color(0xFFC7C7CC);           // Borders
  static const Color gray5 = Color(0xFFE5E5EA);           // Dividers
  static const Color gray6 = Color(0xFFF2F2F7);           // Card backgrounds
  static const Color grayPlaceholder = Color(0xFFAEAEB2); // Placeholder text

  // ===== iOS Gray System - Dark Mode =====
  // Darker, more subtle colors for premium Revolut-style dark mode
  static const Color gray3Dark = Color(0xFF2C2C2E);       // Borders - subtle
  static const Color gray5Dark = Color(0xFF1A1A1A);       // Elevated surfaces
  static const Color gray6Dark = Color(0xFF121212);       // Card backgrounds - darker

  // ===== Overlay & Sheet Colors (from Figma node-id=58-3460) =====
  // Used for modal overlays, bottom sheets, and grabber indicators
  static const Color overlayDark = Color(0x33000000);     // 20% black - modal backdrop (light mode)
  static const Color overlayLight = Color(0x33FFFFFF);    // 20% white - modal backdrop (dark mode)
  static const Color grabber = Color(0x4D3C3C43);         // rgba(60,60,67,0.3) - iOS grabber

  // ===== Text Colors (from Figma) =====
  static const Color textBlack = Color(0xFF000000);       // Primary text, titles
  static const Color textWhite = Color(0xFFFFFFFF);       // Primary text in dark mode

  // ===== Primary Brand Colors =====
  // Keeping teal as primary for brand consistency
  static const Color primary50 = Color(0xFFE0F2F1);
  static const Color primary100 = Color(0xFFB2DFDB);
  static const Color primary200 = Color(0xFF80CBC4);
  static const Color primary300 = Color(0xFF4DB6AC);
  static const Color primary400 = Color(0xFF26A69A);
  static const Color primary500 = Color(0xFF00897B); // Main brand color
  static const Color primary600 = Color(0xFF00796B);
  static const Color primary700 = Color(0xFF00695C);
  static const Color primary800 = Color(0xFF00574B);
  static const Color primary900 = Color(0xFF004D40);

  // ===== Semantic Colors =====
  // Success (Budget safe, under budget, savings)
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successBackground = Color(0xFFE8F5E9);

  // Warning (Approaching limit, caution)
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningBackground = Color(0xFFFFF3E0);

  // Error (Over budget, danger, critical)
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);
  static const Color errorBackground = Color(0xFFFFEBEE);

  // Info (Informational, neutral alerts)
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFF4FC3F7);
  static const Color infoDark = Color(0xFF0288D1);
  static const Color infoBackground = Color(0xFFE1F5FE);

  // ===== Pure Black and White =====
  // Used for CTAs, active states, and high contrast elements
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // ===== Alert Colors (warm minimalist earth tones) =====
  // Used for budget status indicators with a cohesive warm palette
  static const Color alertWarning = Color(0xFFE9C46A);   // Budget 70-90% - Sandy gold
  static const Color alertCritical = Color(0xFFF4A261);  // Budget 90-100% - Peachy orange
  static const Color alertError = Color(0xFFE76F51);     // Budget >100% - Coral terracotta

  // ===== Dark Mode Alert Colors (dimmed warm earth tones) =====
  static const Color alertWarningDark = Color(0xFFD4B55F);   // Dimmed sandy gold
  static const Color alertCriticalDark = Color(0xFFE09456);  // Dimmed peachy orange
  static const Color alertErrorDark = Color(0xFFD36449);     // Dimmed coral terracotta

  // ===== Neutral Palette =====
  // Used for grayscale UI elements, backgrounds, and text
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);  // Disabled elements
  static const Color neutral500 = Color(0xFF9E9E9E);  // Secondary/tertiary text
  static const Color neutral600 = Color(0xFF757575);  // Labels
  static const Color neutral700 = Color(0xFF616161);  // Body text
  static const Color neutral800 = Color(0xFF424242);  // Subheadings
  static const Color neutral850 = Color(0xFF2D2D2D);  // Strong emphasis
  static const Color neutral900 = Color(0xFF212121);  // Primary text
  static const Color neutral950 = Color(0xFF121212);

  // ===== Dark Mode Neutral Palette =====
  // Ultra-dark Revolut-style grays - subtle elevation hierarchy
  static const Color neutral50Dark = Color(0xFF000000);   // Pure black background
  static const Color neutral100Dark = Color(0xFF121212);  // Cards - darker
  static const Color neutral200Dark = Color(0xFF161616);  // Sheets - slightly lighter
  static const Color neutral300Dark = Color(0xFF1E1E1E);  // Dividers - subtle
  static const Color neutral400Dark = Color(0xFF404040);  // Disabled
  static const Color neutral500Dark = Color(0xFF757575);  // Tertiary text
  static const Color neutral600Dark = Color(0xFF9E9E9E);  // Secondary text
  static const Color neutral700Dark = Color(0xFFBDBDBD);  // Body text
  static const Color neutral800Dark = Color(0xFFE0E0E0);  // Headings
  static const Color neutral850Dark = Color(0xFFE8E8E8);  // Strong emphasis
  static const Color neutral900Dark = Color(0xFFFAFAFA);  // Primary text

  // ===== Text Colors - Light Theme =====
  static const Color textPrimaryLight = Color(0xDE000000);    // 87% black
  static const Color textSecondaryLight = Color(0x99000000);  // 60% black
  static const Color textTertiaryLight = Color(0x61000000);   // 38% black
  static const Color textDisabledLight = Color(0x42000000);   // 26% black

  // ===== Text Colors - Dark Theme =====
  static const Color textPrimaryDark = Color(0xDEFFFFFF);     // 87% white
  static const Color textSecondaryDark = Color(0x99FFFFFF);   // 60% white
  static const Color textTertiaryDark = Color(0x61FFFFFF);    // 38% white
  static const Color textDisabledDark = Color(0x42FFFFFF);    // 26% white

  // ===== Surface Colors - Light Theme =====
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color dividerLight = Color(0x1F000000);        // 12% black

  // ===== Surface Colors - Dark Theme =====
  // Ultra-dark Revolut-style with subtle elevation hierarchy
  static const Color surfaceDark = Color(0xFF161616);         // Sheets/bottom sheets
  static const Color cardDark = Color(0xFF121212);            // Cards - darker, subtle
  static const Color surfaceVariantDark = Color(0xFF1A1A1A);  // Elevated variant
  static const Color backgroundDark = Color(0xFF000000);      // Pure black AMOLED background
  static const Color navBarDark = Color(0xFF1A1A1A);          // Nav bar - floats above cards
  static const Color dividerDark = Color(0xFF1E1E1E);         // Dividers - very subtle
  static const Color inputFieldDark = Color(0xFF1A1A1A);      // Search/input fields

  // ===== Glassmorphism Effects =====
  static const Color glassLight = Color(0xCCFFFFFF);          // 80% opacity white
  static const Color glassDark = Color(0xCC1E1E1E);           // 80% opacity dark
  static const Color glassBorder = Color(0x26FFFFFF);         // 15% white border

  // ===== Budget Status Colors (Gradient friendly) =====
  static const Color budgetSafe = success;
  static const Color budgetWarning = warning;
  static const Color budgetDanger = error;
  static const Color budgetCritical = Color(0xFFD32F2F);

  // ===== Expense Type Colors =====
  static const Color expenseMustHave = primary600;
  static const Color expenseNiceToHave = warning;
  static const Color expenseWasted = error;

  // ===== Category Colors (from Figma design) =====
  // These vibrant colors are used for category cards with 20% opacity background
  // and solid color fill for the progress bar
  static const Color categoryOrange = Color(0xFFFF8D28);
  static const Color categoryYellow = Color(0xFFFFCC00);
  static const Color categoryGreen = Color(0xFF34C759);   // iOS system green
  static const Color categoryBrown = Color(0xFFAC7F5E);
  static const Color categoryMint = Color(0xFF00C8B3);
  static const Color categoryTeal = Color(0xFF00C3D0);
  static const Color categoryCyan = Color(0xFF00C0E8);
  static const Color categoryPink = Color(0xFFFF2D55);    // iOS system pink
  static const Color categoryBlue = Color(0xFF0088FF);
  static const Color categoryIndigo = Color(0xFF6155F5);
  static const Color categoryPurple = Color(0xFFCB30E0);

  // Category color list for easy iteration
  static const List<Color> categoryColorList = [
    categoryOrange,
    categoryYellow,
    categoryGreen,
    categoryBrown,
    categoryMint,
    categoryTeal,
    categoryCyan,
    categoryPink,
    categoryBlue,
    categoryIndigo,
    categoryPurple,
  ];

  // ===== Category Colors Map (Vietnamese categories) =====
  // Maps category names to their designated colors (from Figma node-id=5-1798)
  //
  // **IMPORTANT**: Keys must match EXACTLY with Supabase category names!
  // Supabase is the source of truth for category spellings.
  static const Map<String, Color> categoryColors = {
    'Thực phẩm': categoryOrange,          // Food - Orange
    'Tiền nhà': categoryYellow,           // Housing - Yellow
    'Biểu gia đình': categoryGreen,       // Family - Green (Biểu not Biếu!)
    'Cà phê': categoryBrown,              // Coffee - Brown
    'Du lịch': categoryMint,              // Travel - Mint/Teal
    'Giáo dục': categoryTeal,             // Education - Teal
    'Giải trí': categoryCyan,             // Entertainment - Cyan
    'Hoá đơn': categoryPink,              // Bills - Pink
    'Quà vật': categoryBlue,              // Gifts - Blue
    'Sức khỏe': categoryIndigo,           // Health - Indigo (khỏe not khoẻ!)
    'Thời trang': categoryPurple,         // Fashion - Purple
    'Tạp hoá': categoryYellow,            // Groceries - Yellow
    'TẾT': categoryPink,                  // Tet Holiday - Pink (uppercase TẾT!)
    'Đi lại': categoryGreen,              // Transportation - Green
  };

  // ===== Helper Methods =====

  /// Get text color based on background brightness
  static Color getTextColorFor(Color background) {
    return background.computeLuminance() > 0.5
        ? textPrimaryLight
        : textPrimaryDark;
  }

  /// Get budget color based on percentage
  static Color getBudgetColor(double percentage) {
    if (percentage < 0.7) return budgetSafe;
    if (percentage < 0.9) return budgetWarning;
    if (percentage < 1.0) return budgetDanger;
    return budgetCritical;
  }

  /// Create a gradient from a base color
  static LinearGradient createGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.8),
        baseColor,
      ],
    );
  }

  /// Create a subtle gradient for cards
  static LinearGradient cardGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.05),
        baseColor.withValues(alpha: 0.1),
      ],
    );
  }

  /// Get category background color (20% opacity as per Figma design)
  /// Used for CategoryCard background behind the progress bar
  static Color getCategoryBackground(Color categoryColor) {
    return categoryColor.withValues(alpha: 0.2);
  }

  /// Get category color by index (cycles through available colors)
  static Color getCategoryColorByIndex(int index) {
    return categoryColorList[index % categoryColorList.length];
  }

  /// Get a color for a category name (with fallback)
  static Color getCategoryColor(String categoryName) {
    return categoryColors[categoryName] ?? categoryOrange;
  }

  // ===== Dark Mode Adaptive Helpers =====
  // Use these methods to automatically adapt colors based on theme

  /// Check if dark mode is active
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get adaptive background color (main app background)
  static Color getBackground(BuildContext context) {
    return isDarkMode(context) ? backgroundDark : background;
  }

  /// Get adaptive surface color (for sheets, cards, elevated surfaces)
  static Color getSurface(BuildContext context) {
    return isDarkMode(context) ? surfaceDark : surfaceLight;
  }

  /// Get adaptive nav bar background (floats above cards in dark mode)
  /// Hierarchy: bg (#000) → cards (#121212) → sheets (#161616) → nav bar (#1A1A1A)
  static Color getNavBarBackground(BuildContext context) {
    return isDarkMode(context) ? navBarDark : surfaceLight;
  }

  /// Get adaptive card background (#121212 in dark - darker, more subtle)
  /// Use this for cards that sit on the main background
  static Color getCardBackground(BuildContext context) {
    return isDarkMode(context) ? cardDark : gray6;
  }

  /// Get adaptive primary text color
  static Color getTextPrimary(BuildContext context) {
    return isDarkMode(context) ? textWhite : textBlack;
  }

  /// Get adaptive secondary text color
  static Color getTextSecondary(BuildContext context) {
    return isDarkMode(context) ? textSecondaryDark : gray;
  }

  /// Get adaptive divider color (iOS separator style)
  static Color getDivider(BuildContext context) {
    return isDarkMode(context) ? dividerDark : gray5;
  }

  /// Get adaptive border color
  static Color getBorder(BuildContext context) {
    return isDarkMode(context) ? gray3Dark : gray3;
  }

  /// Get adaptive input field background (for search bars, text inputs)
  static Color getInputFieldBackground(BuildContext context) {
    return isDarkMode(context) ? inputFieldDark : gray6;
  }

  /// Get adaptive overlay color (for modal backdrops)
  static Color getOverlay(BuildContext context) {
    return isDarkMode(context) ? overlayLight : overlayDark;
  }

  /// Get adaptive shadow for cards
  static BoxShadow getCardShadow(BuildContext context) {
    return BoxShadow(
      color: isDarkMode(context)
          ? Colors.black.withValues(alpha: 0.24)
          : Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    );
  }

  /// Get adaptive icon color based on active state
  static Color getIconColor(BuildContext context, {bool isActive = false}) {
    if (isActive) {
      return isDarkMode(context) ? textWhite : textBlack;
    }
    return isDarkMode(context) ? gray : gray;
  }

  /// Get adaptive placeholder text color
  static Color getPlaceholder(BuildContext context) {
    return isDarkMode(context) ? gray : grayPlaceholder;
  }

  // ===== Adaptive Neutral Colors =====
  // Use these for grayscale elements that need dark mode support

  /// Get adaptive neutral color for a given light/dark pair
  static Color getAdaptiveNeutral(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  /// Get adaptive neutral850 (strong emphasis text)
  static Color getNeutral850(BuildContext context) {
    return isDarkMode(context) ? neutral850Dark : neutral850;
  }

  /// Get adaptive neutral600 (labels, secondary UI)
  static Color getNeutral600(BuildContext context) {
    return isDarkMode(context) ? neutral600Dark : neutral600;
  }

  /// Get adaptive neutral500 (tertiary text)
  static Color getNeutral500(BuildContext context) {
    return isDarkMode(context) ? neutral500Dark : neutral500;
  }

  /// Get adaptive neutral400 (disabled elements)
  static Color getNeutral400(BuildContext context) {
    return isDarkMode(context) ? neutral400Dark : neutral400;
  }

  /// Get adaptive neutral100 (card backgrounds)
  static Color getNeutral100(BuildContext context) {
    return isDarkMode(context) ? neutral100Dark : neutral100;
  }

  /// Get adaptive neutral300 (borders/circles in dark mode)
  static Color getNeutral300(BuildContext context) {
    return isDarkMode(context) ? neutral300Dark : neutral300;
  }
}