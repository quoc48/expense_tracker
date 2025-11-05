import 'package:flutter/material.dart';

/// Color system for the Expense Tracker app
/// Provides semantic colors for consistent UI theming
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===== Primary Brand Colors =====
  // Teal palette for trust and financial stability
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

  // ===== Neutral Palette =====
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutral950 = Color(0xFF121212);

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
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color dividerDark = Color(0x1FFFFFFF);         // 12% white

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

  // ===== Category Colors (14 Vietnamese categories) =====
  static const Map<String, Color> categoryColors = {
    'Thực phẩm': Color(0xFFFF6B6B),       // Food - Warm red
    'Sức khỏe': Color(0xFF4ECDC4),        // Health - Teal
    'Thời trang': Color(0xFF95E1D3),      // Fashion - Mint
    'Giải trí': Color(0xFFF38181),        // Entertainment - Coral
    'Tiền nhà': Color(0xFFAA96DA),        // Housing - Purple
    'Hoá đơn': Color(0xFFFCBAD3),         // Bills - Pink
    'Biểu gia đình': Color(0xFFA8D8EA),   // Family - Sky blue
    'Giáo dục': Color(0xFFFFCB85),        // Education - Orange
    'TẾT': Color(0xFFFF6B6B),             // Tet Holiday - Red
    'Quà vật': Color(0xFFFFE66D),         // Gifts - Yellow
    'Tạp hoá': Color(0xFFC7CEEA),         // Groceries - Lavender
    'Đi lại': Color(0xFFB4F8C8),          // Transportation - Green
    'Du lịch': Color(0xFFFBE7C6),         // Travel - Peach
    'Cà phê': Color(0xFFA0E7E5),          // Coffee - Cyan
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
}