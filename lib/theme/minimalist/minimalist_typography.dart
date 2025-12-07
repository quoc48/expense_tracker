import 'package:flutter/material.dart';

/// Minimalist typography system with reduced complexity
/// Only 3 font weights and 5 size levels for clear hierarchy
class MinimalistTypography {
  // Prevent instantiation
  MinimalistTypography._();

  // ==========================================
  // Font Families
  // ==========================================

  /// Primary font for all UI text
  static const String fontFamily = 'Inter';

  /// Monospace font for numbers and currency
  static const String monoFamily = 'JetBrains Mono';

  /// System font fallback chain
  static const List<String> fontFallback = [
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  // ==========================================
  // Font Weights (Only 3!)
  // ==========================================

  /// Regular - Body text, descriptions, secondary content
  static const FontWeight regular = FontWeight.w400;

  /// Medium - Buttons, labels, navigation, emphasis
  static const FontWeight medium = FontWeight.w500;

  /// SemiBold - Headings, titles, numbers, strong emphasis
  static const FontWeight semiBold = FontWeight.w600;

  // ==========================================
  // Font Sizes (Only 5!)
  // ==========================================

  /// Hero size - 32px - Monthly totals only
  static const double sizeHero = 32.0;

  /// Title size - 20px - Screen headers
  static const double sizeTitle = 20.0;

  /// Body size - 16px - Default text, buttons
  static const double sizeBody = 16.0;

  /// Caption size - 16px - Secondary info, labels (Updated: 14 → 16)
  static const double sizeCaption = 16.0;

  /// Small size - 14px - Timestamps, hints, minimal text (Updated: 12 → 14)
  static const double sizeSmall = 14.0;

  // ==========================================
  // Line Heights
  // ==========================================

  /// Tight line height for headings
  static const double lineHeightTight = 1.2;

  /// Normal line height for body text
  static const double lineHeightNormal = 1.5;

  /// Relaxed line height for reading
  static const double lineHeightRelaxed = 1.6;

  // ==========================================
  // Letter Spacing
  // ==========================================

  /// Tight spacing for headings
  static const double letterSpacingTight = -0.02;

  /// Normal spacing for body text
  static const double letterSpacingNormal = 0.0;

  /// Wide spacing for small caps, labels
  static const double letterSpacingWide = 0.04;

  // ==========================================
  // Text Theme Creation
  // ==========================================

  /// Create a complete TextTheme with minimalist styling
  static TextTheme createTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color tertiaryTextColor,
  }) {
    return TextTheme(
      // Hero number (32px, semibold, mono)
      displayLarge: TextStyle(
        fontFamily: monoFamily,
        fontSize: sizeHero,
        fontWeight: semiBold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
        color: primaryTextColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),

      // Screen title (20px, semibold)
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeTitle,
        fontWeight: semiBold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
        color: primaryTextColor,
      ),

      // Section header (16px, semibold)
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBody,
        fontWeight: semiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: primaryTextColor,
      ),

      // Card title (16px, medium)
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBody,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: primaryTextColor,
      ),

      // List item title (14px, medium)
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeCaption,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: primaryTextColor,
      ),

      // Small title (12px, medium)
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSmall,
        fontWeight: medium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
        color: secondaryTextColor,
      ),

      // Body text (16px, regular)
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBody,
        fontWeight: regular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
        color: primaryTextColor,
      ),

      // Secondary body (14px, regular)
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeCaption,
        fontWeight: regular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: secondaryTextColor,
      ),

      // Caption text (12px, regular)
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSmall,
        fontWeight: regular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
        color: secondaryTextColor,
      ),

      // Button text (16px, medium)
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBody,
        fontWeight: medium,
        height: lineHeightTight,
        letterSpacing: letterSpacingWide,
        color: primaryTextColor,
      ),

      // Small button (14px, medium)
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeCaption,
        fontWeight: medium,
        height: lineHeightTight,
        letterSpacing: letterSpacingWide,
        color: primaryTextColor,
      ),

      // Tiny label (12px, medium, uppercase)
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSmall,
        fontWeight: medium,
        height: lineHeightTight,
        letterSpacing: letterSpacingWide,
        color: tertiaryTextColor,
      ),
    );
  }

  // ==========================================
  // Custom Text Styles
  // ==========================================

  /// Currency display style (monospace, tabular figures)
  static TextStyle currencyStyle({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontSize: size,
      fontWeight: weight,
      height: lineHeightTight,
      letterSpacing: letterSpacingNormal,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Large currency (24px, semibold)
  static TextStyle currencyLarge(Color color) => currencyStyle(
    size: 24.0,
    weight: semiBold,
    color: color,
  );

  /// Medium currency (18px, medium)
  static TextStyle currencyMedium(Color color) => currencyStyle(
    size: 18.0,
    weight: medium,
    color: color,
  );

  /// Small currency (14px, regular)
  static TextStyle currencySmall(Color color) => currencyStyle(
    size: sizeCaption,
    weight: regular,
    color: color,
  );

  /// Percentage style for charts and statistics
  static TextStyle percentageStyle(Color color) => TextStyle(
    fontFamily: monoFamily,
    fontSize: sizeCaption,
    fontWeight: medium,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Date/time style
  static TextStyle dateTimeStyle(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSmall,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: color,
  );

  /// Category label style
  static TextStyle categoryStyle(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeCaption,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: color,
  );

  /// Error message style
  static TextStyle errorStyle(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSmall,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: color,
  );

  // ==========================================
  // Text Style Helpers
  // ==========================================

  /// Apply ellipsis overflow to a text style
  static TextStyle withEllipsis(TextStyle style) {
    return style.copyWith(
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Apply fade overflow to a text style
  static TextStyle withFade(TextStyle style) {
    return style.copyWith(
      overflow: TextOverflow.fade,
    );
  }

  /// Make text uppercase
  static String toUpperCase(String text) {
    return text.toUpperCase();
  }

  /// Format for small caps effect (uppercase + smaller size)
  static TextStyle smallCaps(TextStyle style) {
    return style.copyWith(
      fontSize: (style.fontSize ?? sizeBody) * 0.8,
      letterSpacing: letterSpacingWide,
      fontWeight: medium,
    );
  }
}