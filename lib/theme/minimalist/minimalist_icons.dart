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

  /// Map of category names to their icons (14 total)
  static const Map<String, IconData> categoryIcons = {
    // 1-7: Core spending categories
    'Thực phẩm': PhosphorIconsLight.forkKnife,      // 1. Food
    'Cà phê': PhosphorIconsLight.coffee,            // 2. Coffee
    'Đi lại': PhosphorIconsLight.car,               // 3. Transportation
    'Hoá đơn': PhosphorIconsLight.lightning,        // 4. Bills
    'Tiền nhà': PhosphorIconsLight.house,           // 5. Housing
    'Giải trí': PhosphorIconsLight.popcorn,         // 6. Entertainment
    'Du lịch': PhosphorIconsLight.airplane,         // 7. Travel

    // 8-11: Shopping & Personal
    'Tạp hoá': PhosphorIconsLight.shoppingBag,      // 8. Groceries
    'Thời trang': PhosphorIconsLight.tShirt,        // 9. Fashion
    'Sức khỏe': PhosphorIconsLight.heartbeat,       // 10. Health
    'Giáo dục': PhosphorIconsLight.graduationCap,   // 11. Education

    // 12-14: Special occasions
    'Quà vật': PhosphorIconsLight.gift,             // 12. Gifts
    'TẾT': PhosphorIconsLight.sparkle,              // 13. Holiday/Tet
    'Biểu gia đình': PhosphorIconsLight.users,      // 14. Family
  };

  /// Get icon for a category (no fallback since we have exactly 14)
  /// If category not found, returns a warning icon to indicate data issue
  static IconData getCategoryIcon(String categoryName) {
    // Return the icon if found, otherwise warning to indicate unmapped category
    return categoryIcons[categoryName] ?? PhosphorIconsLight.warning;
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
  static Widget createCategoryIcon(
    String category, {
    Color? color,
    double? size,
    bool isSelected = false,
  }) {
    return createIcon(
      getCategoryIcon(category),
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