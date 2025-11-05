import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for the Expense Tracker app
/// Uses Inter font family for optimal readability and modern aesthetics
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  /// Creates a complete text theme with our custom typography scale
  static TextTheme createTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
  }) {
    return TextTheme(
      // Display styles - For hero numbers and large totals
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        height: 1.2,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600, // SemiBold
        letterSpacing: 0,
        height: 1.2,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: textPrimary,
      ),

      // Headline styles - For screen and section titles
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0,
        height: 1.3,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.3,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.3,
        color: textPrimary,
      ),

      // Title styles - For cards and list items
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,  // Slightly bolder for primary items
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: textSecondary, // Overlines are secondary
      ),

      // Body styles - For general content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        height: 1.5,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        height: 1.5,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        height: 1.5,
        color: textSecondary,
      ),

      // Label styles - For buttons, chips, badges
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
        color: textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
        color: textTertiary,
      ),
    );
  }

  /// Custom currency text styles with monospace font
  static TextStyle currencyLarge({Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.2,
      color: color,
      fontFeatures: const [
        FontFeature.tabularFigures(), // Align numbers in tables
      ],
    );
  }

  static TextStyle currencyMedium({Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.3,
      color: color,
      fontFeatures: const [
        FontFeature.tabularFigures(),
      ],
    );
  }

  static TextStyle currencySmall({Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0,
      height: 1.4,
      color: color,
      fontFeatures: const [
        FontFeature.tabularFigures(),
      ],
    );
  }

  /// Helper method to apply custom opacity to text
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withValues(alpha: opacity),
    );
  }
}

/// Typography hierarchy for specific components
class ComponentTextStyles {
  // Private constructor
  ComponentTextStyles._();

  // Expense list item
  static TextStyle expenseTitle(TextTheme theme) => theme.titleLarge!;  // Changed from titleMedium for better balance
  static TextStyle expenseAmount(TextTheme theme) => AppTypography.currencyMedium();
  static TextStyle expenseCategory(TextTheme theme) => theme.bodySmall!;
  static TextStyle expenseDate(TextTheme theme) => theme.labelSmall!;

  // Analytics card
  static TextStyle cardTitle(TextTheme theme) =>
      AppTypography.withOpacity(theme.titleLarge!, 0.6);
  static TextStyle cardValue(TextTheme theme) => theme.displayMedium!;
  static TextStyle cardSubtitle(TextTheme theme) =>
      AppTypography.withOpacity(theme.bodySmall!, 0.38);
  static TextStyle cardChange(TextTheme theme) => theme.bodyMedium!;

  // Budget alert
  static TextStyle alertTitle(TextTheme theme) => theme.headlineSmall!;
  static TextStyle alertPercentage(TextTheme theme) => theme.displaySmall!;
  static TextStyle alertMessage(TextTheme theme) =>
      AppTypography.withOpacity(theme.bodyMedium!, 0.6);

  // Form field
  static TextStyle fieldLabel(TextTheme theme) => theme.titleSmall!;
  static TextStyle fieldInput(TextTheme theme) => theme.bodyLarge!;
  static TextStyle fieldHint(TextTheme theme) =>
      AppTypography.withOpacity(theme.bodyMedium!, 0.38);
  static TextStyle fieldError(TextTheme theme) => theme.bodySmall!;

  // Button
  static TextStyle buttonPrimary(TextTheme theme) => theme.labelLarge!;
  static TextStyle buttonSecondary(TextTheme theme) => theme.labelMedium!;

  // Empty state
  static TextStyle emptyTitle(TextTheme theme) => theme.headlineMedium!;
  static TextStyle emptyMessage(TextTheme theme) =>
      AppTypography.withOpacity(theme.bodyLarge!, 0.6);
}

/// Line height multipliers for different text categories
class LineHeights {
  static const double display = 1.2;   // Tight for impact
  static const double headline = 1.3;  // Balanced
  static const double body = 1.5;      // Comfortable reading
  static const double label = 1.4;     // Compact
}

/// Letter spacing values
class LetterSpacing {
  static const double tight = -0.25;
  static const double normal = 0;
  static const double relaxed = 0.15;
  static const double loose = 0.25;
  static const double veryLoose = 0.5;
}