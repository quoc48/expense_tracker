import 'package:flutter/material.dart';

/// Design constants for consistent UI elements
class AppConstants {
  // Private constructor
  AppConstants._();

  // ===== Border Radius =====
  static const double radiusXs = 4.0;    // Badges, chips
  static const double radiusSm = 8.0;    // Small buttons, tags
  static const double radiusMd = 12.0;   // Cards, inputs (default)
  static const double radiusLg = 16.0;   // Large cards, modals
  static const double radiusXl = 20.0;   // Sheets, dialogs
  static const double radius2xl = 24.0;  // Full-screen modals
  static const double radius3xl = 28.0;  // Extra large elements
  static const double radiusFull = 999.0; // Circular elements (FAB, avatars)

  // Semantic radius values
  static const double cardRadius = radiusMd;        // 12px for cards
  static const double buttonRadius = radiusSm;      // 8px for buttons
  static const double dialogRadius = radiusXl;      // 20px for dialogs
  static const double chipRadius = radiusFull;      // Full round for chips
  static const double inputRadius = radiusMd;       // 12px for text fields

  // ===== Elevation & Shadows =====
  static const double elevation0 = 0;     // Flat surfaces
  static const double elevation1 = 1;     // Slightly raised
  static const double elevation2 = 2;     // Cards, default
  static const double elevation3 = 3;     // Hovered cards
  static const double elevation4 = 4;     // Pressed/selected
  static const double elevation6 = 6;     // FAB, raised buttons
  static const double elevation8 = 8;     // Modals, dialogs
  static const double elevation12 = 12;   // Top app bars
  static const double elevation16 = 16;   // Navigation drawers
  static const double elevation24 = 24;   // Dialogs (highest)

  // Custom shadow definitions for modern design
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x1A000000),  // 10% black
    blurRadius: 16,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x26000000),  // 15% black
    blurRadius: 24,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  static const BoxShadow strongShadow = BoxShadow(
    color: Color(0x33000000),  // 20% black
    blurRadius: 32,
    offset: Offset(0, 12),
    spreadRadius: 0,
  );

  // Glassmorphism shadow
  static const BoxShadow glassShadow = BoxShadow(
    color: Color(0x0D000000),  // 5% black
    blurRadius: 32,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  // Card-specific shadows
  static List<BoxShadow> cardShadow = const [
    BoxShadow(
      color: Color(0x0F000000),  // Very subtle
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedCardShadow = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // ===== Animation Durations =====
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationExtraSlow = Duration(milliseconds: 600);
  static const Duration durationPageTransition = Duration(milliseconds: 350);

  // ===== Animation Curves =====
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveStandard = Curves.easeInOut;  // Default
  static const Curve curveEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);  // Material 3
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveDecelerate = Curves.decelerate;

  // ===== Icon Sizes =====
  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 24.0;  // Default
  static const double iconSizeLg = 28.0;
  static const double iconSizeXl = 32.0;
  static const double iconSize2xl = 40.0;
  static const double iconSize3xl = 48.0;

  // ===== Component Heights =====
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;  // Default
  static const double buttonHeightLg = 48.0;
  static const double inputHeight = 56.0;      // Text fields
  static const double appBarHeight = 56.0;     // Standard app bar
  static const double bottomNavHeight = 80.0;  // Bottom navigation
  static const double listItemHeight = 72.0;   // List tiles

  // ===== Opacity Values =====
  static const double opacityFull = 1.0;
  static const double opacityHigh = 0.87;      // Primary text
  static const double opacityMedium = 0.60;    // Secondary text
  static const double opacityLow = 0.38;       // Tertiary text
  static const double opacityDisabled = 0.26;  // Disabled elements
  static const double opacityDivider = 0.12;   // Divider lines
  static const double opacityOverlay = 0.80;   // Modal overlays
  static const double opacityGlass = 0.95;     // Glassmorphism

  // ===== Border Widths =====
  static const double borderThin = 0.5;
  static const double borderDefault = 1.0;
  static const double borderThick = 2.0;
  static const double borderFocus = 2.0;       // Focused inputs
  static const double dividerThickness = 1.0;

  // ===== Blur Values (for glassmorphism) =====
  static const double blurLight = 8.0;
  static const double blurMedium = 16.0;
  static const double blurStrong = 24.0;
  static const double blurGlass = 20.0;        // Standard glass effect
}