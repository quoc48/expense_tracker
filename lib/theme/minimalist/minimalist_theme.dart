import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/app_colors.dart';
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
      secondaryTextColor: AppColors.neutral600,
      tertiaryTextColor: AppColors.neutral500,
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
      scaffoldBackgroundColor: AppColors.neutral50,

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
      secondaryTextColor: AppColors.neutral600Dark,
      tertiaryTextColor: AppColors.neutral500Dark,
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
      scaffoldBackgroundColor: AppColors.neutral50Dark,

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
      primary: AppColors.black,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.neutral900,
      onPrimaryContainer: AppColors.white,

      // Secondary colors (gray for less important)
      secondary: AppColors.neutral700,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.neutral200,
      onSecondaryContainer: AppColors.neutral900,

      // Tertiary (unused, set to gray)
      tertiary: AppColors.neutral500,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.neutral100,
      onTertiaryContainer: AppColors.neutral900,

      // Error colors
      error: AppColors.errorDark,
      onError: AppColors.white,
      errorContainer: AppColors.errorBackground,
      onErrorContainer: AppColors.errorDark,

      // Surface colors
      surface: AppColors.white,
      onSurface: AppColors.neutral900,
      surfaceContainerHighest: AppColors.neutral100,
      onSurfaceVariant: AppColors.neutral600,

      // Outline
      outline: AppColors.neutral300,
      outlineVariant: AppColors.neutral200,

      // Shadows and scrim
      shadow: AppColors.black,
      scrim: AppColors.black, // Pure black scrim for light mode

      // Inverse colors
      inverseSurface: AppColors.neutral900,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.white,

      // Surface tint
      surfaceTint: Colors.transparent,
    );
  }

  /// Create dark color scheme
  static ColorScheme _createDarkColorScheme() {
    return ColorScheme.dark(
      // Primary colors (white for actions in dark mode)
      primary: AppColors.white,
      onPrimary: AppColors.black,  // Black icon/text on white background
      primaryContainer: AppColors.neutral800Dark,
      onPrimaryContainer: AppColors.neutral900Dark,

      // Secondary colors
      secondary: AppColors.neutral700Dark,
      onSecondary: AppColors.neutral900Dark,
      secondaryContainer: AppColors.neutral300Dark,
      onSecondaryContainer: AppColors.neutral900Dark,

      // Tertiary
      tertiary: AppColors.neutral600Dark,
      onTertiary: AppColors.neutral900Dark,
      tertiaryContainer: AppColors.neutral200Dark,
      onTertiaryContainer: AppColors.neutral900Dark,

      // Error colors
      error: AppColors.alertErrorDark,
      onError: AppColors.neutral900Dark,
      errorContainer: AppColors.alertErrorDark.withValues(alpha: 0.2),
      onErrorContainer: AppColors.neutral900Dark,

      // Surface colors
      surface: AppColors.neutral100Dark,
      onSurface: AppColors.neutral900Dark,
      surfaceContainerHighest: AppColors.neutral200Dark,
      onSurfaceVariant: AppColors.neutral600Dark,

      // Outline
      outline: AppColors.neutral300Dark,
      outlineVariant: AppColors.neutral200Dark,

      // Shadows and scrim
      shadow: AppColors.black,
      scrim: AppColors.black, // Pure black scrim for dark mode (no tint)

      // Inverse colors
      inverseSurface: AppColors.white,
      onInverseSurface: AppColors.neutral900,
      inversePrimary: AppColors.black,

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
      backgroundColor: AppColors.white,
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
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      color: AppColors.white,
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
        disabledBackgroundColor: AppColors.neutral300,
        disabledForegroundColor: AppColors.neutral500,
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
        disabledForegroundColor: AppColors.neutral400,
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
        disabledForegroundColor: AppColors.neutral400,
        side: const BorderSide(color: AppColors.neutral300),
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
        disabledBackgroundColor: AppColors.neutral300,
        disabledForegroundColor: AppColors.neutral500,
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
      fillColor: AppColors.neutral50,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),

      // Borders
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.neutral300),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.neutral300),
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
        borderSide: BorderSide(color: AppColors.neutral200),
      ),

      // Text styles
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodySmall,
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: colors.error),
      hintStyle: text.bodyMedium?.copyWith(
        color: AppColors.neutral400,
      ),

      // Icons
      iconColor: AppColors.neutral600,
      prefixIconColor: AppColors.neutral600,
      suffixIconColor: AppColors.neutral600,
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
      backgroundColor: AppColors.white,
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
          color: AppColors.neutral500,
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
          color: AppColors.neutral500,
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
      backgroundColor: AppColors.white,
      selectedItemColor: colors.primary,
      unselectedItemColor: AppColors.neutral500,
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
      iconColor: AppColors.neutral600,
      textColor: colors.onSurface,
      tileColor: AppColors.white,
      selectedTileColor: AppColors.neutral100,
      selectedColor: colors.primary,
    );
  }

  /// Divider theme
  static DividerThemeData _createDividerTheme() {
    return const DividerThemeData(
      color: AppColors.neutral200,
      thickness: 1,
      space: 1,
    );
  }

  /// Icon theme
  static IconThemeData _createIconTheme(ColorScheme colors) {
    return const IconThemeData(
      color: AppColors.neutral700,
      size: 24,
    );
  }

  /// Chip theme
  static ChipThemeData _createChipTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ChipThemeData(
      backgroundColor: AppColors.neutral100,
      deleteIconColor: AppColors.neutral600,
      disabledColor: AppColors.neutral200,
      selectedColor: colors.primary,
      secondarySelectedColor: AppColors.neutral700,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: text.labelMedium!,
      secondaryLabelStyle: text.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral300),
      ),
    );
  }

  /// Dialog theme
  static DialogThemeData _createDialogTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return DialogThemeData(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral200),
      ),
    );
  }

  /// Snackbar theme
  static SnackBarThemeData _createSnackBarTheme(
    ColorScheme colors,
    TextTheme text,
  ) {
    return SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: AppColors.white,
      ),
      actionTextColor: AppColors.white,
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
      linearTrackColor: AppColors.neutral200,
      circularTrackColor: AppColors.neutral200,
    );
  }

  /// Switch theme
  static SwitchThemeData _createSwitchTheme(ColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return AppColors.neutral400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: 0.5);
        }
        return AppColors.neutral300;
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
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: const BorderSide(color: AppColors.neutral400, width: 2),
    );
  }

  /// Radio theme
  static RadioThemeData _createRadioTheme(ColorScheme colors) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return AppColors.neutral400;
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
      backgroundColor: AppColors.neutral100Dark,
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
          color: AppColors.neutral300Dark,
          width: 1,
        ),
      ),
      color: AppColors.neutral200Dark,
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
        disabledBackgroundColor: AppColors.neutral400Dark,
        disabledForegroundColor: AppColors.neutral600Dark,
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
        disabledForegroundColor: AppColors.neutral500Dark,
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
        disabledForegroundColor: AppColors.neutral500Dark,
        side: const BorderSide(color: AppColors.neutral400Dark),
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
        disabledBackgroundColor: AppColors.neutral400Dark,
        disabledForegroundColor: AppColors.neutral600Dark,
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
      fillColor: AppColors.neutral100Dark,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),

      // Borders
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.neutral400Dark),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.neutral400Dark),
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
        borderSide: BorderSide(color: AppColors.neutral300Dark),
      ),

      // Text styles
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodySmall,
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: colors.error),
      hintStyle: text.bodyMedium?.copyWith(
        color: AppColors.neutral500Dark,
      ),

      // Icons
      iconColor: AppColors.neutral600Dark,
      prefixIconColor: AppColors.neutral600Dark,
      suffixIconColor: AppColors.neutral600Dark,
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
      backgroundColor: AppColors.neutral100Dark,
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
          color: AppColors.neutral600Dark,
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
          color: AppColors.neutral600Dark,
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
      backgroundColor: AppColors.neutral100Dark,
      selectedItemColor: colors.primary,
      unselectedItemColor: AppColors.neutral600Dark,
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
      iconColor: AppColors.neutral600Dark,
      textColor: colors.onSurface,
      tileColor: AppColors.neutral100Dark,
      selectedTileColor: AppColors.neutral200Dark,
      selectedColor: colors.primary,
    );
  }

  /// Divider theme (dark)
  static DividerThemeData _createDividerThemeDark() {
    return const DividerThemeData(
      color: AppColors.neutral300Dark,
      thickness: 1,
      space: 1,
    );
  }

  /// Icon theme (dark)
  static IconThemeData _createIconThemeDark(ColorScheme colors) {
    return const IconThemeData(
      color: AppColors.neutral700Dark,
      size: 24,
    );
  }

  /// Chip theme (dark)
  static ChipThemeData _createChipThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return ChipThemeData(
      backgroundColor: AppColors.neutral200Dark,
      deleteIconColor: AppColors.neutral600Dark,
      disabledColor: AppColors.neutral300Dark,
      selectedColor: colors.primary,
      secondarySelectedColor: AppColors.neutral700Dark,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: text.labelMedium!,
      secondaryLabelStyle: text.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral400Dark),
      ),
    );
  }

  /// Dialog theme (dark)
  static DialogThemeData _createDialogThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return DialogThemeData(
      backgroundColor: AppColors.neutral100Dark,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral300Dark),
      ),
    );
  }

  /// Snackbar theme (dark)
  static SnackBarThemeData _createSnackBarThemeDark(
    ColorScheme colors,
    TextTheme text,
  ) {
    return SnackBarThemeData(
      backgroundColor: AppColors.neutral200Dark,  // Dark background for dark mode
      contentTextStyle: text.bodyMedium?.copyWith(
        color: AppColors.neutral900Dark,  // White text
      ),
      actionTextColor: AppColors.white,
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
      linearTrackColor: AppColors.neutral300Dark,
      circularTrackColor: AppColors.neutral300Dark,
    );
  }

  /// Switch theme (dark)
  static SwitchThemeData _createSwitchThemeDark(ColorScheme colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return AppColors.neutral500Dark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: 0.5);
        }
        return AppColors.neutral400Dark;
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
      checkColor: WidgetStateProperty.all(AppColors.neutral900Dark),
      side: const BorderSide(color: AppColors.neutral500Dark, width: 2),
    );
  }

  /// Radio theme (dark)
  static RadioThemeData _createRadioThemeDark(ColorScheme colors) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return AppColors.neutral500Dark;
      }),
    );
  }
}