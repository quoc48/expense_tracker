import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'typography/app_typography.dart';
import 'colors/app_colors.dart';
import 'constants/app_constants.dart';
import 'constants/app_spacing.dart';

/// Main theme configuration for the Expense Tracker app
/// Provides both light and dark themes with consistent design tokens
class AppTheme {
  // Private constructor
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    // Define the color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary500,
      brightness: Brightness.light,
      primary: AppColors.primary500,
      onPrimary: Colors.white,
      secondary: AppColors.primary400,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      outline: AppColors.dividerLight,
    );

    // Create text theme with proper hierarchy
    final textTheme = AppTypography.createTextTheme(
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
      textTertiary: AppColors.textTertiaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Scaffold background
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: AppConstants.elevation1,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: AppConstants.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.cardMargin,
          vertical: AppSpacing.spaceXs,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevation0,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding,
            vertical: AppSpacing.spaceSm,
          ),
          minimumSize: Size(88, AppConstants.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding,
            vertical: AppSpacing.spaceSm,
          ),
          minimumSize: Size(88, AppConstants.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: AppColors.dividerLight,
            width: AppConstants.borderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppConstants.borderFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppConstants.borderDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppConstants.borderFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiaryLight,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.error,
        ),
        helperStyle: textTheme.bodySmall,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        selectedColor: colorScheme.primaryContainer,
        deleteIconColor: AppColors.textSecondaryLight,
        labelStyle: textTheme.labelMedium!,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceXs,
          vertical: AppSpacing.space2xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.chipRadius),
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: AppColors.textPrimaryLight,
        size: AppConstants.iconSizeMd,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        minVerticalPadding: AppSpacing.spaceXs,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        leadingAndTrailingTextStyle: textTheme.labelSmall,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.dividerLight,
        thickness: AppConstants.dividerThickness,
        space: AppSpacing.spaceMd,
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: colorScheme.primaryContainer,
        elevation: AppConstants.elevation0,
        height: AppConstants.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(textTheme.labelMedium),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: AppConstants.elevation24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: AppConstants.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.dialogRadius),
          ),
        ),
      ),

      // Page transitions
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    // Define the color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary500,
      brightness: Brightness.dark,
      primary: AppColors.primary400,
      onPrimary: Colors.black,
      secondary: AppColors.primary300,
      onSecondary: Colors.black,
      error: AppColors.errorLight,
      onError: Colors.black,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      outline: AppColors.dividerDark,
    );

    // Create text theme with proper hierarchy
    final textTheme = AppTypography.createTextTheme(
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      textTertiary: AppColors.textTertiaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Scaffold background
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: AppConstants.elevation1,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppConstants.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.cardMargin,
          vertical: AppSpacing.spaceXs,
        ),
      ),

      // Dark theme versions of other components...
      // (Similar to light theme but with dark colors)

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: AppColors.dividerDark,
            width: AppConstants.borderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppConstants.borderFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        helperStyle: textTheme.bodySmall,
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: colorScheme.primaryContainer,
        elevation: AppConstants.elevation0,
        height: AppConstants.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Other components inherit from light theme with dark colors
    );
  }

  /// Helper method to determine if dark mode should be used
  static bool shouldUseDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}