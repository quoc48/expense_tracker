import 'package:flutter/material.dart';

/// Minimalist color system using grayscale as the foundation
/// with pure black for CTAs and subtle semantic colors for states
class MinimalistColors {
  // Prevent instantiation
  MinimalistColors._();

  // ==========================================
  // Grayscale Foundation (90% of UI)
  // ==========================================

  /// Background colors
  static const Color gray50 = Color(0xFFFAFAFA);   // Main background
  static const Color gray100 = Color(0xFFF5F5F5);  // Card backgrounds

  /// Dividers and borders
  static const Color gray200 = Color(0xFFEEEEEE);  // Dividers
  static const Color gray300 = Color(0xFFE0E0E0);  // Inactive borders

  /// Disabled and inactive states
  static const Color gray400 = Color(0xFFBDBDBD);  // Disabled elements
  static const Color gray500 = Color(0xFF9E9E9E);  // Secondary text

  /// Text hierarchy
  static const Color gray600 = Color(0xFF757575);  // Labels
  static const Color gray700 = Color(0xFF616161);  // Body text
  static const Color gray800 = Color(0xFF424242);  // Subheadings
  static const Color gray850 = Color(0xFF2D2D2D);  // Strong emphasis (added)
  static const Color gray900 = Color(0xFF212121);  // Primary text

  /// Pure black and white
  static const Color black = Color(0xFF000000);    // CTAs, active states
  static const Color white = Color(0xFFFFFFFF);    // Pure white

  // ==========================================
  // Semantic Colors (10% of UI)
  // ==========================================

  /// Success state (subtle)
  static const Color successBackground = Color(0xFFF1F8F4);
  static const Color successText = Color(0xFF1B5E20);

  /// Warning state (subtle)
  static const Color warningBackground = Color(0xFFFFF8E1);
  static const Color warningText = Color(0xFFF57C00);

  /// Error state (subtle)
  static const Color errorBackground = Color(0xFFFEF1F2);
  static const Color errorText = Color(0xFFB71C1C);

  /// Info state (subtle)
  static const Color infoBackground = Color(0xFFE8F4FD);
  static const Color infoText = Color(0xFF0D47A1);

  // ==========================================
  // Alert Colors (warm minimalist earth tones)
  // ==========================================

  /// Budget warning (70-90%) - Sandy gold
  static const Color alertWarning = Color(0xFFE9C46A);

  /// Budget critical (90-100%) - Peachy orange
  static const Color alertCritical = Color(0xFFF4A261);

  /// Budget over/error (>100%) - Coral terracotta
  static const Color alertError = Color(0xFFE76F51);

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Get text color based on background
  static Color getTextColor(Color background) {
    // Simple luminance check
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? gray900 : white;
  }

  /// Get border color for a surface
  static Color getBorderColor(bool isActive) {
    return isActive ? black : gray300;
  }

  /// Get icon color based on state
  static Color getIconColor(bool isActive) {
    return isActive ? black : gray600;
  }

  /// Create a subtle shadow
  static BoxShadow get subtleShadow => BoxShadow(
    color: black.withValues(alpha: 0.05),
    blurRadius: 2,
    offset: const Offset(0, 1),
    spreadRadius: 0,
  );

  /// Create a card shadow
  static BoxShadow get cardShadow => BoxShadow(
    color: black.withValues(alpha: 0.08),
    blurRadius: 4,
    offset: const Offset(0, 2),
    spreadRadius: 0,
  );

  // ==========================================
  // Budget Status Colors (Special Case)
  // ==========================================

  /// Get budget progress color based on percentage
  /// Uses minimalist alert colors (warm earth tones)
  static Color getBudgetColor(double percentage) {
    if (percentage >= 100) {
      return alertError;     // Over budget - coral terracotta
    } else if (percentage >= 90) {
      return alertCritical;  // Near limit - peachy orange
    } else if (percentage >= 70) {
      return alertWarning;   // Approaching - sandy gold
    } else {
      return gray500;        // Safe - medium gray (no alert)
    }
  }

  /// Get budget background based on percentage
  /// Returns subtle tints of alert colors for cohesive look
  static Color getBudgetBackground(double percentage) {
    if (percentage >= 100) {
      return alertError.withValues(alpha: 0.05);     // Subtle coral tint
    } else if (percentage >= 90) {
      return alertCritical.withValues(alpha: 0.05);  // Subtle orange tint
    } else if (percentage >= 70) {
      return alertWarning.withValues(alpha: 0.05);   // Subtle gold tint
    } else {
      return white;  // Normal - no tint needed
    }
  }

  // ==========================================
  // Chart Colors (Data Visualization)
  // ==========================================

  /// Default chart color (inactive/background)
  static const Color chartDefault = gray300;

  /// Active/selected chart element
  static const Color chartActive = black;

  /// Chart grid lines
  static const Color chartGrid = gray200;

  /// Positive trend (decrease in spending)
  static const Color trendPositive = successText;

  /// Negative trend (increase in spending)
  static const Color trendNegative = errorText;

  // ==========================================
  // Category Colors (Replaced with Gray)
  // ==========================================

  /// All categories use the same gray
  static const Color categoryDefault = gray100;
  static const Color categoryBorder = gray300;
  static const Color categoryIconDefault = gray600;
  static const Color categoryIconActive = black;

  /// Get category background (all gray now)
  static Color getCategoryBackground(String category) {
    // All categories use the same subtle gray
    return categoryDefault;
  }

  /// Get category icon color
  static Color getCategoryIconColor(String category, bool isSelected) {
    return isSelected ? categoryIconActive : categoryIconDefault;
  }

  // ==========================================
  // Dark Theme Support (Future)
  // ==========================================

  /// Check if we should use dark colors
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get adaptive color based on theme
  static Color getAdaptiveGray(BuildContext context, Color lightColor) {
    if (isDarkMode(context)) {
      // Invert the gray scale for dark mode
      if (lightColor == gray50) return gray900;
      if (lightColor == gray100) return gray800;
      if (lightColor == gray200) return gray700;
      if (lightColor == gray300) return gray600;
      if (lightColor == gray400) return gray500;
      if (lightColor == gray500) return gray400;
      if (lightColor == gray600) return gray300;
      if (lightColor == gray700) return gray200;
      if (lightColor == gray800) return gray100;
      if (lightColor == gray900) return gray50;
    }
    return lightColor;
  }
}