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
      tertiaryTextColor: MinimalistColors.gray500,
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

      // Filled Button
      filledButtonTheme: _createFilledButtonTheme(colorScheme),

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
  // Dark Theme
  // ==========================================

  /// Get the complete dark theme
  static ThemeData get darkTheme {
    // Define the dark color scheme
    final colorScheme = _createDarkColorScheme();

    // Create text theme with dark colors
    final textTheme = MinimalistTypography.createTextTheme(
      primaryTextColor: colorScheme.onSurface,
      secondaryTextColor: MinimalistColors.darkGray600,
      tertiaryTextColor: MinimalistColors.darkGray500,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Platform
      platform: TargetPlatform.iOS,

      // Visual density
      visualDensity: VisualDensity.standard,

      // Scaffold
      scaffoldBackgroundColor: MinimalistColors.darkGray50,

      // AppBar
      appBarTheme: _createAppBarThemeDark(colorScheme, textTheme),

      // Cards
      cardTheme: _createCardThemeDark(),

      // Buttons
      elevatedButtonTheme: _createElevatedButtonThemeDark(colorScheme, textTheme),
      textButtonTheme: _createTextButtonThemeDark(colorScheme, textTheme),
      outlinedButtonTheme: _createOutlinedButtonThemeDark(colorScheme, textTheme),

      // Floating Action Button
      floatingActionButtonTheme: _createFabThemeDark(colorScheme),

      // Filled Button
      filledButtonTheme: _createFilledButtonThemeDark(colorScheme),

      // Input Decoration
      inputDecorationTheme: _createInputDecorationThemeDark(colorScheme, textTheme),

      // Navigation Bar
      navigationBarTheme: _createNavigationBarThemeDark(colorScheme, textTheme),

      // Bottom Navigation Bar (fallback)
      bottomNavigationBarTheme: _createBottomNavBarThemeDark(colorScheme, textTheme),

      // List Tiles
      listTileTheme: _createListTileThemeDark(colorScheme, textTheme),

      // Dividers
      dividerTheme: _createDividerThemeDark(),

      // Icon Theme
      iconTheme: _createIconThemeDark(colorScheme),

      // Chip Theme
      chipTheme: _createChipThemeDark(colorScheme, textTheme),

      // Dialog Theme
      dialogTheme: _createDialogThemeDark(colorScheme, textTheme),

      // Snackbar Theme
      snackBarTheme: _createSnackBarThemeDark(colorScheme, textTheme),

      // Progress Indicators
      progressIndicatorTheme: _createProgressIndicatorThemeDark(colorScheme),

      // Switch Theme
      switchTheme: _createSwitchThemeDark(colorScheme),

      // Checkbox Theme
      checkboxTheme: _createCheckboxThemeDark(colorScheme),

      // Radio Theme
      radioTheme: _createRadioThemeDark(colorScheme),
    );
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

  /// Create dark color scheme
  static ColorScheme _createDarkColorScheme() {
    return ColorScheme.dark(
      // Primary colors (white for actions in dark mode)
      primary: MinimalistColors.white,
      onPrimary: MinimalistColors.black,  // Black icon/text on white background
      primaryContainer: MinimalistColors.darkGray800,
      onPrimaryContainer: MinimalistColors.darkGray900,

      // Secondary colors
      secondary: MinimalistColors.darkGray700,
      onSecondary: MinimalistColors.darkGray900,
      secondaryContainer: MinimalistColors.darkGray300,
      onSecondaryContainer: MinimalistColors.darkGray900,

      // Tertiary
      tertiary: MinimalistColors.darkGray600,
      onTertiary: MinimalistColors.darkGray900,
      tertiaryContainer: MinimalistColors.darkGray200,
      onTertiaryContainer: MinimalistColors.darkGray900,

      // Error colors
      error: MinimalistColors.darkAlertError,
      onError: MinimalistColors.darkGray900,
      errorContainer: MinimalistColors.darkAlertError.withValues(alpha: 0.2),
      onErrorContainer: MinimalistColors.darkGray900,

      // Surface colors
      surface: MinimalistColors.darkGray100,
      onSurface: MinimalistColors.darkGray900,
      surfaceContainerHighest: MinimalistColors.darkGray200,
      onSurfaceVariant: MinimalistColors.darkGray600,

      // Outline
      outline: MinimalistColors.darkGray300,
      outlineVariant: MinimalistColors.darkGray200,

      // Shadows
      shadow: MinimalistColors.black,

      // Inverse colors
      inverseSurface: MinimalistColors.white,
      onInverseSurface: MinimalistColors.gray900,
      inversePrimary: MinimalistColors.black,

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
      elevation: 4,  // Consistent with dark mode
      focusElevation: 6,  // Consistent with dark mode
      hoverElevation: 6,  // Consistent with dark mode
      highlightElevation: 8,  // Consistent with dark mode
      shape: const CircleBorder(),  // Circular shape - consistent with dark mode
    );
  }

  /// FilledButton theme - matches FAB color pattern
  static FilledButtonThemeData _createFilledButtonTheme(ColorScheme colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,      // Black in light mode (same as FAB)
        foregroundColor: colors.onPrimary,    // White in light mode (same as FAB)
        iconColor: colors.onPrimary,          // Ensure icons use same color
        disabledBackgroundColor: MinimalistColors.gray300,
        disabledForegroundColor: MinimalistColors.gray500,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ).copyWith(
        // Override Material 3 overlay colors to use onPrimary
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.onPrimary.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.onPrimary.withValues(alpha: 0.05);
          }
          return null;
        }),
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

  // ==========================================
  // Dark Component Themes
  // ==========================================

  /// AppBar theme (dark)
  static AppBarTheme _createAppBarThemeDark(ColorScheme colors, TextTheme text) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: MinimalistColors.darkGray100,
      foregroundColor: colors.onSurface,
      titleTextStyle: text.headlineLarge,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: 24,
      ),
    );
  }

  /// Card theme (dark)
  static CardThemeData _createCardThemeDark() {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: MinimalistColors.darkGray300,
          width: 1,
        ),
      ),
      color: MinimalistColors.darkGray200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Elevated button theme (dark)
  static ElevatedButtonThemeData _createElevatedButtonThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: MinimalistColors.darkGray400,
        disabledForegroundColor: MinimalistColors.darkGray600,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 40),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Text button theme (dark)
  static TextButtonThemeData _createTextButtonThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: MinimalistColors.darkGray500,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(64, 36),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Outlined button theme (dark)
  static OutlinedButtonThemeData _createOutlinedButtonThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: MinimalistColors.darkGray500,
        side: const BorderSide(color: MinimalistColors.darkGray400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 40),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Floating Action Button theme (dark)
  static FloatingActionButtonThemeData _createFabThemeDark(ColorScheme colors) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primary,  // Same as light mode - uses white in dark theme
      foregroundColor: colors.onPrimary,  // Same as light mode - uses black in dark theme
      elevation: 4,  // Slightly higher elevation for better visibility
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: const CircleBorder(),  // Proper circular shape
    );
  }

  /// FilledButton theme (dark) - matches FAB color pattern
  static FilledButtonThemeData _createFilledButtonThemeDark(ColorScheme colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,      // White in dark mode (same as FAB)
        foregroundColor: colors.onPrimary,    // Black in dark mode (same as FAB)
        iconColor: colors.onPrimary,          // Ensure icons use same color
        disabledBackgroundColor: MinimalistColors.darkGray400,
        disabledForegroundColor: MinimalistColors.darkGray600,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ).copyWith(
        // Override Material 3 overlay colors to use onPrimary
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.onPrimary.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.onPrimary.withValues(alpha: 0.05);
          }
          return null;
        }),
      ),
    );
  }

  /// Input decoration theme (dark)
  static InputDecorationTheme _createInputDecorationThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return InputDecorationTheme(
      filled: false,
      fillColor: MinimalistColors.darkGray100,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),

      // Borders
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: MinimalistColors.darkGray400),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MinimalistColors.darkGray400),
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
        borderSide: BorderSide(color: MinimalistColors.darkGray300),
      ),

      // Text styles
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodySmall,
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: colors.error),
      hintStyle: text.bodyMedium?.copyWith(
        color: MinimalistColors.darkGray500,
      ),

      // Icons
      iconColor: MinimalistColors.darkGray600,
      prefixIconColor: MinimalistColors.darkGray600,
      suffixIconColor: MinimalistColors.darkGray600,
    );
  }

  /// Navigation bar theme (dark)
  static NavigationBarThemeData _createNavigationBarThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: MinimalistColors.darkGray100,
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
          color: MinimalistColors.darkGray600,
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
          color: MinimalistColors.darkGray600,
          size: 24,
        );
      }),
    );
  }

  /// Bottom navigation bar theme (dark)
  static BottomNavigationBarThemeData _createBottomNavBarThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: MinimalistColors.darkGray100,
      selectedItemColor: colors.primary,
      unselectedItemColor: MinimalistColors.darkGray600,
      selectedLabelStyle: text.labelSmall,
      unselectedLabelStyle: text.labelSmall,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  /// List tile theme (dark)
  static ListTileThemeData _createListTileThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ListTileThemeData(
      dense: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: MinimalistColors.darkGray600,
      textColor: colors.onSurface,
      tileColor: MinimalistColors.darkGray100,
      selectedTileColor: MinimalistColors.darkGray200,
      selectedColor: colors.primary,
    );
  }

  /// Divider theme (dark)
  static DividerThemeData _createDividerThemeDark() {
    return const DividerThemeData(
      color: MinimalistColors.darkGray300,
      thickness: 1,
      space: 1,
    );
  }

  /// Icon theme (dark)
  static IconThemeData _createIconThemeDark(ColorScheme colors) {
    return const IconThemeData(
      color: MinimalistColors.darkGray700,
      size: 24,
    );
  }

  /// Chip theme (dark)
  static ChipThemeData _createChipThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ChipThemeData(
      backgroundColor: MinimalistColors.darkGray200,
      deleteIconColor: MinimalistColors.darkGray600,
      disabledColor: MinimalistColors.darkGray300,
      selectedColor: colors.primary,
      secondarySelectedColor: MinimalistColors.darkGray700,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: text.labelMedium!,
      secondaryLabelStyle: text.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MinimalistColors.darkGray400),
      ),
    );
  }

  /// Dialog theme (dark)
  static DialogThemeData _createDialogThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return DialogThemeData(
      backgroundColor: MinimalistColors.darkGray100,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MinimalistColors.darkGray300),
      ),
    );
  }

  /// Snackbar theme (dark)
  static SnackBarThemeData _createSnackBarThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return SnackBarThemeData(
      backgroundColor: MinimalistColors.darkGray200,  // Dark background for dark mode
      contentTextStyle: text.bodyMedium?.copyWith(
        color: MinimalistColors.darkGray900,  // White text
      ),
      actionTextColor: MinimalistColors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Progress indicator theme (dark)
  static ProgressIndicatorThemeData _createProgressIndicatorThemeDark(
    ColorScheme colors,
  ) {
    return ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: MinimalistColors.darkGray300,
      circularTrackColor: MinimalistColors.darkGray300,
    );
  }

  /// Switch theme (dark)
  static SwitchThemeData _createSwitchThemeDark(ColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return MinimalistColors.darkGray500;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: 0.5);
        }
        return MinimalistColors.darkGray400;
      }),
    );
  }

  /// Checkbox theme (dark)
  static CheckboxThemeData _createCheckboxThemeDark(ColorScheme colors) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(MinimalistColors.darkGray900),
      side: const BorderSide(color: MinimalistColors.darkGray500, width: 2),
    );
  }

  /// Radio theme (dark)
  static RadioThemeData _createRadioThemeDark(ColorScheme colors) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return MinimalistColors.darkGray500;
      }),
    );
  }
}