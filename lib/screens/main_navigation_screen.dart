import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_list_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../providers/expense_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/home/floating_nav_bar.dart';

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

  /// Handle FAB tap to add new expense
  void _handleAddExpense() {
    // Navigate to add expense screen
    // For now, switch to Expenses tab which has the add functionality
    // TODO: Navigate directly to AddExpenseScreen
    setState(() {
      _selectedIndex = 1; // Switch to Expenses tab
    });
  }
}
