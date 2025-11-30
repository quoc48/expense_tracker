import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Minimalist icon system using Phosphor Icons
/// Light weight (1.5px) for maximum calm aesthetic
class MinimalistIcons {
  // Prevent instantiation
  MinimalistIcons._();

  // ==========================================
  // Navigation Icons
  // ==========================================

  /// Expenses tab icons
  static const IconData expensesInactive = PhosphorIconsLight.receipt;
  static const IconData expensesActive = PhosphorIconsFill.receipt;

  /// Analytics tab icons
  static const IconData analyticsInactive = PhosphorIconsLight.chartPie;
  static const IconData analyticsActive = PhosphorIconsFill.chartPie;

  /// Get navigation icon based on selection state
  static IconData getNavigationIcon(String tab, bool isSelected) {
    switch (tab) {
      case 'expenses':
        return isSelected ? expensesActive : expensesInactive;
      case 'analytics':
        return isSelected ? analyticsActive : analyticsInactive;
      default:
        return PhosphorIconsLight.house;
    }
  }

  // ==========================================
  // Category Icons (Vietnamese)
  // ==========================================
  // EXACTLY 14 categories as defined in Supabase database
  // No "Other" category - users must choose specific categories
  //
  // Two icon styles available:
  // - Light (regular): For forms, lists, expense cards
  // - Fill: For CategoryCard widgets (bar chart style)

  /// Map of category names to their LIGHT icons (14 total)
  /// Use for: forms, expense list items, general UI
  ///
  /// **IMPORTANT**: Keys must match EXACTLY with Supabase category names!
  /// Supabase is the source of truth for category spellings.
  static const Map<String, IconData> categoryIcons = {
    'Thực phẩm': PhosphorIconsLight.forkKnife,      // Food
    'Tiền nhà': PhosphorIconsLight.house,           // Housing
    'Biểu gia đình': PhosphorIconsLight.usersThree, // Family (Biểu not Biếu!)
    'Cà phê': PhosphorIconsLight.coffee,            // Coffee
    'Du lịch': PhosphorIconsLight.airplaneTilt,     // Travel
    'Giáo dục': PhosphorIconsLight.graduationCap,   // Education
    'Giải trí': PhosphorIconsLight.popcorn,         // Entertainment
    'Hoá đơn': PhosphorIconsLight.invoice,          // Bills
    'Quà vật': PhosphorIconsLight.gift,             // Gifts
    'Sức khỏe': PhosphorIconsLight.heartbeat,       // Health (khỏe not khoẻ!)
    'Thời trang': PhosphorIconsLight.handbag,       // Fashion
    'Tạp hoá': PhosphorIconsLight.shoppingCart,     // Groceries
    'TẾT': PhosphorIconsLight.flower,               // Tet Holiday (uppercase TẾT!)
    'Đi lại': PhosphorIconsLight.motorcycle,        // Transportation
  };

  /// Map of category names to their FILL icons (14 total)
  /// Use for: CategoryCard widgets, ExpenseListTile icons, SelectionCard
  ///
  /// **IMPORTANT**: Keys must match EXACTLY with Supabase category names!
  /// Supabase is the source of truth for category spellings.
  static const Map<String, IconData> categoryIconsFill = {
    'Thực phẩm': PhosphorIconsFill.forkKnife,      // Food
    'Tiền nhà': PhosphorIconsFill.house,           // Housing
    'Biểu gia đình': PhosphorIconsFill.usersThree, // Family (Biểu not Biếu!)
    'Cà phê': PhosphorIconsFill.coffee,            // Coffee
    'Du lịch': PhosphorIconsFill.airplaneTilt,     // Travel
    'Giáo dục': PhosphorIconsFill.graduationCap,   // Education
    'Giải trí': PhosphorIconsFill.popcorn,         // Entertainment
    'Hoá đơn': PhosphorIconsFill.invoice,          // Bills
    'Quà vật': PhosphorIconsFill.gift,             // Gifts
    'Sức khỏe': PhosphorIconsFill.heartbeat,       // Health (khỏe not khoẻ!)
    'Thời trang': PhosphorIconsFill.shoppingBag,   // Fashion (shoppingBag per Figma)
    'Tạp hoá': PhosphorIconsFill.shoppingCart,     // Groceries
    'TẾT': PhosphorIconsFill.flower,               // Tet Holiday (uppercase TẾT!)
    'Đi lại': PhosphorIconsFill.motorcycle,        // Transportation
  };

  // ==========================================
  // Category Colors (from Figma Design)
  // ==========================================
  // Design Reference: Figma node-id=56-3815
  // Used for SelectionCard backgrounds (10% opacity) and icon colors

  /// Map of category names to their brand colors
  /// Use for: SelectionCard icon background (10% opacity), icon color
  static const Map<String, Color> categoryColors = {
    'Thực phẩm': Color(0xFFFF8D28),      // Orange - Food
    'Tiền nhà': Color(0xFFFFCC00),       // Yellow - Housing
    'Biểu gia đình': Color(0xFF34C759), // Green - Family
    'Cà phê': Color(0xFFAC7F5E),         // Brown - Coffee
    'Du lịch': Color(0xFF00C8B3),        // Teal-green - Travel
    'Giáo dục': Color(0xFF00C3D0),       // Teal - Education
    'Giải trí': Color(0xFF00C0E8),       // Cyan - Entertainment
    'Hoá đơn': Color(0xFFFF2D55),        // Pink - Bills
    'Quà vật': Color(0xFF0088FF),        // Blue - Gifts
    'Sức khỏe': Color(0xFF6155F5),       // Indigo - Health
    'Thời trang': Color(0xFFCB30E0),     // Purple - Fashion
    'Tạp hoá': Color(0xFFFFCC00),        // Yellow - Groceries
    'TẾT': Color(0xFFFF2D55),            // Pink - Tet Holiday
    'Đi lại': Color(0xFF34C759),         // Green - Transportation
  };

  /// Get category color
  /// Returns gray if category not found
  static Color getCategoryColor(String categoryName) {
    return categoryColors[categoryName] ?? const Color(0xFF8E8E93);
  }

  /// Get LIGHT icon for a category (for forms, lists, general UI)
  /// If category not found, returns a warning icon to indicate data issue
  static IconData getCategoryIcon(String categoryName) {
    return categoryIcons[categoryName] ?? PhosphorIconsLight.warning;
  }

  /// Get FILL icon for a category (for CategoryCard widgets)
  /// If category not found, returns a warning icon to indicate data issue
  static IconData getCategoryIconFill(String categoryName) {
    return categoryIconsFill[categoryName] ?? PhosphorIconsFill.warning;
  }

  // ==========================================
  // Expense Type Icons
  // ==========================================

  /// Expense type indicators
  static const IconData expenseNecessary = PhosphorIconsLight.checkCircle;   // Phải chi
  static const IconData expenseUnexpected = PhosphorIconsLight.warning;       // Phát sinh
  static const IconData expenseWasteful = PhosphorIconsLight.xCircle;        // Lãng phí

  /// Get expense type icon
  static IconData getExpenseTypeIcon(String type) {
    switch (type) {
      case 'Phải chi':
        return expenseNecessary;
      case 'Phát sinh':
        return expenseUnexpected;
      case 'Lãng phí':
        return expenseWasteful;
      default:
        return PhosphorIconsLight.circleNotch;
    }
  }

  // ==========================================
  // Form Field Icons
  // ==========================================

  /// Input field icons
  static const IconData fieldDescription = PhosphorIconsLight.textT;
  static const IconData fieldAmount = PhosphorIconsLight.currencyDollar;
  static const IconData fieldCategory = PhosphorIconsLight.tag;
  static const IconData fieldDate = PhosphorIconsLight.calendarBlank;
  static const IconData fieldNotes = PhosphorIconsLight.note;
  static const IconData fieldEmail = PhosphorIconsLight.envelope;
  static const IconData fieldPassword = PhosphorIconsLight.lock;
  static const IconData fieldPasswordVisible = PhosphorIconsLight.eye;
  static const IconData fieldPasswordHidden = PhosphorIconsLight.eyeSlash;
  static const IconData fieldSearch = PhosphorIconsLight.magnifyingGlass;
  static const IconData fieldFilter = PhosphorIconsLight.funnel;

  // ==========================================
  // Input Method Icons (Add Expense Sheet)
  // ==========================================
  // Used in AddExpenseOptionsSheet for selecting input method
  // Design Reference: Figma node-id=58-3460

  /// Manual entry - pencil icon
  static const IconData inputManual = PhosphorIconsLight.pencilSimpleLine;

  /// Camera/scan receipt - camera icon
  static const IconData inputCamera = PhosphorIconsLight.camera;

  /// Voice input - user speaking icon
  static const IconData inputVoice = PhosphorIconsLight.userSound;

  // ==========================================
  // Action Icons
  // ==========================================

  /// Common action icons
  static const IconData actionAdd = PhosphorIconsRegular.plus;  // Slightly bolder for FAB
  static const IconData actionEdit = PhosphorIconsLight.pencilSimple;
  static const IconData actionDelete = PhosphorIconsLight.trash;
  static const IconData actionSave = PhosphorIconsLight.check;
  static const IconData actionCancel = PhosphorIconsLight.x;
  static const IconData actionSettings = PhosphorIconsLight.gear;
  static const IconData actionLogout = PhosphorIconsLight.signOut;
  static const IconData actionBack = PhosphorIconsLight.arrowLeft;
  static const IconData actionForward = PhosphorIconsLight.arrowRight;
  static const IconData actionUp = PhosphorIconsLight.arrowUp;
  static const IconData actionDown = PhosphorIconsLight.arrowDown;
  static const IconData actionMore = PhosphorIconsLight.dotsThreeVertical;
  static const IconData actionShare = PhosphorIconsLight.share;
  static const IconData actionExport = PhosphorIconsLight.export;
  static const IconData actionImport = PhosphorIconsLight.downloadSimple;
  static const IconData actionRefresh = PhosphorIconsLight.arrowsClockwise;

  // ==========================================
  // Status & Indicator Icons
  // ==========================================

  /// Status indicators
  static const IconData statusSuccess = PhosphorIconsLight.checkCircle;
  static const IconData statusError = PhosphorIconsLight.xCircle;
  static const IconData statusWarning = PhosphorIconsLight.warningCircle;
  static const IconData statusInfo = PhosphorIconsLight.info;
  static const IconData statusPending = PhosphorIconsLight.clock;
  static const IconData statusLoading = PhosphorIconsLight.circleNotch;

  /// Budget status icons
  static const IconData budgetSafe = PhosphorIconsLight.shieldCheck;
  static const IconData budgetWarning = PhosphorIconsLight.warningDiamond;
  static const IconData budgetOver = PhosphorIconsLight.siren;

  // ==========================================
  // Chart & Analytics Icons
  // ==========================================

  /// Chart type icons
  static const IconData chartPie = PhosphorIconsLight.chartPie;
  static const IconData chartBar = PhosphorIconsLight.chartBar;
  static const IconData chartLine = PhosphorIconsLight.chartLine;
  static const IconData chartDonut = PhosphorIconsLight.chartDonut;

  /// Trend indicators
  static const IconData trendUp = PhosphorIconsLight.trendUp;
  static const IconData trendDown = PhosphorIconsLight.trendDown;
  static const IconData trendFlat = PhosphorIconsLight.minus;

  // ==========================================
  // Utility Icons
  // ==========================================

  /// Miscellaneous icons
  static const IconData chevronLeft = PhosphorIconsLight.caretLeft;
  static const IconData chevronRight = PhosphorIconsLight.caretRight;
  static const IconData chevronUp = PhosphorIconsLight.caretUp;
  static const IconData chevronDown = PhosphorIconsLight.caretDown;
  static const IconData close = PhosphorIconsLight.x;
  static const IconData menu = PhosphorIconsLight.list;
  static const IconData home = PhosphorIconsLight.house;
  static const IconData user = PhosphorIconsLight.user;
  static const IconData notification = PhosphorIconsLight.bell;
  static const IconData help = PhosphorIconsLight.question;
  static const IconData theme = PhosphorIconsLight.sun;
  static const IconData themeDark = PhosphorIconsLight.moon;

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Get icon size based on context
  static double getIconSize(IconSizeType type) {
    switch (type) {
      case IconSizeType.tiny:
        return 16.0;
      case IconSizeType.small:
        return 20.0;
      case IconSizeType.medium:
        return 24.0;
      case IconSizeType.large:
        return 28.0;
      case IconSizeType.xlarge:
        return 32.0;
    }
  }

  /// Create an icon widget with consistent styling
  static Widget createIcon(
    IconData icon, {
    Color? color,
    double? size,
    String? semanticLabel,
  }) {
    return Icon(
      icon,
      color: color,
      size: size ?? getIconSize(IconSizeType.medium),
      semanticLabel: semanticLabel,
    );
  }

  /// Create a category icon widget
  /// Set [filled] to true for CategoryCard widgets (bar chart style)
  static Widget createCategoryIcon(
    String category, {
    Color? color,
    double? size,
    bool filled = false,
  }) {
    return createIcon(
      filled ? getCategoryIconFill(category) : getCategoryIcon(category),
      color: color,
      size: size ?? getIconSize(IconSizeType.small),
      semanticLabel: category,
    );
  }

  /// Create an expense type icon widget
  static Widget createExpenseTypeIcon(
    String type, {
    Color? color,
    double? size,
  }) {
    return createIcon(
      getExpenseTypeIcon(type),
      color: color,
      size: size ?? getIconSize(IconSizeType.small),
      semanticLabel: type,
    );
  }
}

/// Icon size types for consistent sizing
enum IconSizeType {
  tiny,    // 16px
  small,   // 20px
  medium,  // 24px (default)
  large,   // 28px
  xlarge,  // 32px
}