/// Spacing system for consistent layout throughout the app
/// Based on Material Design 3's 4px base unit
class AppSpacing {
  // Private constructor
  AppSpacing._();

  // ===== Base Spacing Values =====
  // Using 4px base unit for Material Design 3 compliance
  static const double space2xs = 4.0;   // Minimal gap
  static const double spaceXs = 8.0;    // Compact spacing
  static const double spaceSm = 12.0;   // Small spacing
  static const double spaceMd = 16.0;   // Standard spacing (most common)
  static const double spaceLg = 20.0;   // Large spacing
  static const double spaceXl = 24.0;   // Extra large
  static const double space2xl = 32.0;  // Major sections
  static const double space3xl = 40.0;  // Screen padding
  static const double space4xl = 48.0;  // Hero spacing
  static const double space5xl = 56.0;  // Extra hero spacing
  static const double space6xl = 64.0;  // Maximum spacing

  // ===== Semantic Spacing =====
  // Component-specific spacing values
  static const double cardPadding = spaceMd;          // 16px inside cards
  static const double cardMargin = spaceSm;           // 12px between cards
  static const double screenPadding = spaceMd;        // 16px screen edges (matches Expenses)
  static const double listItemGap = spaceSm;          // 12px between list items
  static const double sectionGap = spaceXl;           // 24px between sections
  static const double inputSpacing = spaceSm;         // 12px between form fields
  static const double buttonPadding = spaceMd;        // 16px button internal padding
  static const double iconTextGap = spaceXs;          // 8px between icon and text
  static const double chipSpacing = spaceXs;          // 8px between chips/badges

  // ===== Typography Spacing =====
  // Spacing related to text elements
  static const double paragraphGap = spaceMd;         // 16px between paragraphs
  static const double headingGap = spaceLg;           // 20px after headings
  static const double labelGap = spaceXs;             // 8px between label and input

  // ===== Grid & Layout Spacing =====
  static const double gridGap = spaceMd;              // 16px grid gap
  static const double columnGap = spaceXl;            // 24px between columns
  static const double rowGap = spaceMd;               // 16px between rows

  // ===== Responsive Breakpoints =====
  // For adaptive spacing on different screen sizes
  static const double compactScreenPadding = spaceMd; // 16px on small screens
  static const double regularScreenPadding = spaceLg; // 20px on regular screens
  static const double largeScreenPadding = space2xl;  // 32px on tablets

  /// Get responsive padding based on screen width
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < 360) return compactScreenPadding;
    if (screenWidth < 600) return regularScreenPadding;
    return largeScreenPadding;
  }

  /// Get responsive card margin based on screen width
  static double getResponsiveCardMargin(double screenWidth) {
    if (screenWidth < 360) return spaceXs;
    if (screenWidth < 600) return spaceSm;
    return spaceMd;
  }
}