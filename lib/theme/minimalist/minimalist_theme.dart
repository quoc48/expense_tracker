import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'minimalist_colors.dart';
import 'minimalist_typography.dart';

/// Complete minimalist theme configuration
/// Combines colors, typography, and component themes
class MinimalistTheme {
  // Prevent instantiation
  MinimalistTheme._();

  // ==========================================
  // Light Theme
  // ==========================================

  /// Get the complete light theme
  static ThemeData get lightTheme {
    // Define the color scheme first
    final colorScheme = _createLightColorScheme();

    // Create text theme with the color scheme
    final textTheme = MinimalistTypography.createTextTheme(
      primaryTextColor: colorScheme.onSurface,
      secondaryTextColor: MinimalistColors.gray600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Platform
      platform: TargetPlatform.iOS, // iOS-style overscroll

      // Visual density
      visualDensity: VisualDensity.standard,

      // Scaffold
      scaffoldBackgroundColor: MinimalistColors.gray50,

      // AppBar
      appBarTheme: _createAppBarTheme(colorScheme, textTheme),

      // Cards
      cardTheme: _createCardTheme(),

      // Buttons
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme, textTheme),
      textButtonTheme: _createTextButtonTheme(colorScheme, textTheme),
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme, textTheme),

      // Floating Action Button
      floatingActionButtonTheme: _createFabTheme(colorScheme),

      // Input Decoration
      inputDecorationTheme: _createInputDecorationTheme(colorScheme, textTheme),

      // Navigation Bar
      navigationBarTheme: _createNavigationBarTheme(colorScheme, textTheme),

      // Bottom Navigation Bar (fallback)
      bottomNavigationBarTheme: _createBottomNavBarTheme(colorScheme, textTheme),

      // List Tiles
      listTileTheme: _createListTileTheme(colorScheme, textTheme),

      // Dividers
      dividerTheme: _createDividerTheme(),

      // Icon Theme
      iconTheme: _createIconTheme(colorScheme),

      // Chip Theme
      chipTheme: _createChipTheme(colorScheme, textTheme),

      // Dialog Theme
      dialogTheme: _createDialogTheme(colorScheme, textTheme),

      // Snackbar Theme
      snackBarTheme: _createSnackBarTheme(colorScheme, textTheme),

      // Progress Indicators
      progressIndicatorTheme: _createProgressIndicatorTheme(colorScheme),

      // Switch Theme
      switchTheme: _createSwitchTheme(colorScheme),

      // Checkbox Theme
      checkboxTheme: _createCheckboxTheme(colorScheme),

      // Radio Theme
      radioTheme: _createRadioTheme(colorScheme),
    );
  }

  // ==========================================
  // Dark Theme (Future Implementation)
  // ==========================================

  /// Get the complete dark theme
  static ThemeData get darkTheme {
    // For now, return light theme
    // TODO: Implement proper dark theme with inverted grays
    return lightTheme;
  }

  // ==========================================
  // Color Schemes
  // ==========================================

  /// Create light color scheme
  static ColorScheme _createLightColorScheme() {
    return ColorScheme.light(
      // Primary colors (black for actions)
      primary: MinimalistColors.black,
      onPrimary: MinimalistColors.white,
      primaryContainer: MinimalistColors.gray900,
      onPrimaryContainer: MinimalistColors.white,

      // Secondary colors (gray for less important)
      secondary: MinimalistColors.gray700,
      onSecondary: MinimalistColors.white,
      secondaryContainer: MinimalistColors.gray200,
      onSecondaryContainer: MinimalistColors.gray900,

      // Tertiary (unused, set to gray)
      tertiary: MinimalistColors.gray500,
      onTertiary: MinimalistColors.white,
      tertiaryContainer: MinimalistColors.gray100,
      onTertiaryContainer: MinimalistColors.gray900,

      // Error colors
      error: MinimalistColors.errorText,
      onError: MinimalistColors.white,
      errorContainer: MinimalistColors.errorBackground,
      onErrorContainer: MinimalistColors.errorText,

      // Surface colors
      surface: MinimalistColors.white,
      onSurface: MinimalistColors.gray900,
      surfaceContainerHighest: MinimalistColors.gray100,
      onSurfaceVariant: MinimalistColors.gray600,

      // Outline
      outline: MinimalistColors.gray300,
      outlineVariant: MinimalistColors.gray200,

      // Shadows
      shadow: MinimalistColors.black,

      // Inverse colors
      inverseSurface: MinimalistColors.gray900,
      onInverseSurface: MinimalistColors.white,
      inversePrimary: MinimalistColors.white,

      // Surface tint
      surfaceTint: Colors.transparent,
    );
  }

  // ==========================================
  // Component Themes
  // ==========================================

  /// AppBar theme
  static AppBarTheme _createAppBarTheme(ColorScheme colors, TextTheme text) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: MinimalistColors.white,
      foregroundColor: colors.onSurface,
      titleTextStyle: text.headlineLarge,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: 24,
      ),
    );
  }

  /// Card theme
  static CardThemeData _createCardTheme() {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: MinimalistColors.gray200,
          width: 1,
        ),
      ),
      color: MinimalistColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Elevated button theme
  static ElevatedButtonThemeData _createElevatedButtonTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: MinimalistColors.gray300,
        disabledForegroundColor: MinimalistColors.gray500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 40),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Text button theme
  static TextButtonThemeData _createTextButtonTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: MinimalistColors.gray400,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(64, 36),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Outlined button theme
  static OutlinedButtonThemeData _createOutlinedButtonTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: MinimalistColors.gray400,
        side: const BorderSide(color: MinimalistColors.gray300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 40),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Floating Action Button theme
  static FloatingActionButtonThemeData _createFabTheme(ColorScheme colors) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 2,
      focusElevation: 4,
      hoverElevation: 4,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Input decoration theme
  static InputDecorationTheme _createInputDecorationTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return InputDecorationTheme(
      filled: false,
      fillColor: MinimalistColors.gray50,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),

      // Borders
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: MinimalistColors.gray300),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MinimalistColors.gray300),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      disabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MinimalistColors.gray200),
      ),

      // Text styles
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodySmall,
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: colors.error),
      hintStyle: text.bodyMedium?.copyWith(
        color: MinimalistColors.gray400,
      ),

      // Icons
      iconColor: MinimalistColors.gray600,
      prefixIconColor: MinimalistColors.gray600,
      suffixIconColor: MinimalistColors.gray600,
    );
  }

  /// Navigation bar theme (Material 3)
  static NavigationBarThemeData _createNavigationBarTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: MinimalistColors.white,
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return text.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: MinimalistTypography.medium,
          );
        }
        return text.labelSmall?.copyWith(
          color: MinimalistColors.gray500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: colors.primary,
            size: 24,
          );
        }
        return const IconThemeData(
          color: MinimalistColors.gray500,
          size: 24,
        );
      }),
    );
  }

  /// Bottom navigation bar theme (fallback)
  static BottomNavigationBarThemeData _createBottomNavBarTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: MinimalistColors.white,
      selectedItemColor: colors.primary,
      unselectedItemColor: MinimalistColors.gray500,
      selectedLabelStyle: text.labelSmall,
      unselectedLabelStyle: text.labelSmall,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  /// List tile theme
  static ListTileThemeData _createListTileTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ListTileThemeData(
      dense: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: MinimalistColors.gray600,
      textColor: colors.onSurface,
      tileColor: MinimalistColors.white,
      selectedTileColor: MinimalistColors.gray100,
      selectedColor: colors.primary,
    );
  }

  /// Divider theme
  static DividerThemeData _createDividerTheme() {
    return const DividerThemeData(
      color: MinimalistColors.gray200,
      thickness: 1,
      space: 1,
    );
  }

  /// Icon theme
  static IconThemeData _createIconTheme(ColorScheme colors) {
    return const IconThemeData(
      color: MinimalistColors.gray700,
      size: 24,
    );
  }

  /// Chip theme
  static ChipThemeData _createChipTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ChipThemeData(
      backgroundColor: MinimalistColors.gray100,
      deleteIconColor: MinimalistColors.gray600,
      disabledColor: MinimalistColors.gray200,
      selectedColor: colors.primary,
      secondarySelectedColor: MinimalistColors.gray700,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: text.labelMedium!,
      secondaryLabelStyle: text.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MinimalistColors.gray300),
      ),
    );
  }

  /// Dialog theme
  static DialogThemeData _createDialogTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return DialogThemeData(
      backgroundColor: MinimalistColors.white,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MinimalistColors.gray200),
      ),
    );
  }

  /// Snackbar theme
  static SnackBarThemeData _createSnackBarTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return SnackBarThemeData(
      backgroundColor: MinimalistColors.gray900,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: MinimalistColors.white,
      ),
      actionTextColor: MinimalistColors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Progress indicator theme
  static ProgressIndicatorThemeData _createProgressIndicatorTheme(
    ColorScheme colors,
  ) {
    return ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: MinimalistColors.gray200,
      circularTrackColor: MinimalistColors.gray200,
    );
  }

  /// Switch theme
  static SwitchThemeData _createSwitchTheme(ColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return MinimalistColors.gray400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: 0.5);
        }
        return MinimalistColors.gray300;
      }),
    );
  }

  /// Checkbox theme
  static CheckboxThemeData _createCheckboxTheme(ColorScheme colors) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(MinimalistColors.white),
      side: const BorderSide(color: MinimalistColors.gray400, width: 2),
    );
  }

  /// Radio theme
  static RadioThemeData _createRadioTheme(ColorScheme colors) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return MinimalistColors.gray400;
      }),
    );
  }
}