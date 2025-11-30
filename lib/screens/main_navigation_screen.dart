import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_list_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'add_expense_screen.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/home/floating_nav_bar.dart';
import '../widgets/common/add_expense_options_sheet.dart';

/// MainNavigationScreen is the root screen that contains the bottom navigation bar.
/// It manages which screen is currently displayed based on the selected tab.
///
/// **Design Reference**: Figma node-id=5-1095
///
/// **Learning: Custom vs Material NavigationBar**
/// We use a custom FloatingNavBar instead of Material's NavigationBar because
/// the Figma design requires:
/// 1. Pill-shaped navigation container (not full-width)
/// 2. Integrated FAB as part of the bar
/// 3. Icon-only design (no labels)
/// 4. Specific spacing and shadow styling
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // _selectedIndex tracks which tab is currently active
  // 0 = Analytics (Home), 1 = Expenses, 2 = Settings
  int _selectedIndex = 0;

  // List of screens corresponding to each navigation destination
  // Order matches FloatingNavBar: Analytics → Expenses → Settings
  final List<Widget> _screens = [
    const HomeScreen(),           // Analytics (default home)
    const ExpenseListScreen(),    // Expenses list
    const SettingsScreen(),       // Settings
  ];

  // Auth subscription to listen for sign-in events
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes and load expenses once authenticated
    // This prevents querying Supabase before the session is fully restored
    _setupAuthListener();
  }

  /// Set up auth listener to load expenses when authentication is ready
  void _setupAuthListener() {
    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      // Load expenses when authenticated (either new sign-in or restored session)
      // initialSession: Session restored from storage (app restart with existing session)
      // signedIn: New login completed
      if ((event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) &&
          session != null &&
          mounted) {
        // Small delay to ensure Supabase client has applied the session token
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use FloatingNavBarScaffold for custom Figma-designed navigation
    return FloatingNavBarScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      onFabTap: _handleAddExpense,
      // IndexedStack keeps all screens in memory but only shows one
      // This preserves the state of each screen when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }

  /// Handle FAB tap to show add expense options bottom sheet.
  ///
  /// Shows a bottom sheet with 3 options:
  /// - Manual: Opens AddExpenseScreen for manual entry
  /// - Camera: Opens camera for receipt scanning
  /// - Voice: Future feature (does nothing for now)
  void _handleAddExpense() async {
    final method = await showAddExpenseOptionsSheet(context: context);

    if (!mounted || method == null) return;

    switch (method) {
      case AddExpenseInputMethod.manual:
        _navigateToManualEntry();
        break;
      case AddExpenseInputMethod.camera:
        _navigateToCamera();
        break;
      case AddExpenseInputMethod.voice:
        // Future feature - do nothing for now
        break;
    }
  }

  /// Navigate to manual expense entry screen
  Future<void> _navigateToManualEntry() async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    // If user saved an expense, add it via provider
    if (result != null && mounted) {
      await Provider.of<ExpenseProvider>(context, listen: false)
          .addExpense(result);
    }
  }

  /// Navigate to camera for receipt scanning
  void _navigateToCamera() {
    // TODO: Implement camera navigation
    // This will be connected to the existing receipt scanning feature
    debugPrint('Camera option tapped - to be implemented');
  }
}
