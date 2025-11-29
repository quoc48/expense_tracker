import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_list_screen.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';
import '../providers/expense_provider.dart';
import '../services/supabase_service.dart';

/// MainNavigationScreen is the root screen that contains the bottom navigation bar.
/// It manages which screen is currently displayed based on the selected tab.
///
/// Learning: NavigationBar is Material Design 3's bottom navigation component.
/// It's different from the older BottomNavigationBar - it has updated styling
/// and animations that follow MD3 principles.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // _selectedIndex tracks which tab is currently active
  // 0 = Expenses, 1 = Analytics
  int _selectedIndex = 0;

  // List of screens corresponding to each navigation destination
  // NOTE: HomeScreen replaces AnalyticsScreen for UI redesign testing
  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const HomeScreen(),  // New redesigned analytics/home screen
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
    return Scaffold(
      // The body displays the currently selected screen
      // IndexedStack keeps all screens in memory but only shows one
      // This preserves the state of each screen when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // NavigationBar: Material 3 bottom navigation component
      bottomNavigationBar: NavigationBar(
        // selectedIndex: Currently selected destination (0-based)
        selectedIndex: _selectedIndex,

        // onDestinationSelected: Called when user taps a destination
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        // destinations: List of navigation tabs
        destinations: const [
          // Expenses tab
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.receipt),
            selectedIcon: Icon(PhosphorIconsFill.receipt),
            label: 'Expenses',
            tooltip: 'View and manage expenses',
          ),

          // Analytics tab
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.chartPie),
            selectedIcon: Icon(PhosphorIconsFill.chartPie),
            label: 'Analytics',
            tooltip: 'View spending analytics',
          ),
        ],
      ),
    );
  }
}
