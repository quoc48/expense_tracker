import 'package:flutter/material.dart';
import 'expense_list_screen.dart';
import 'analytics_screen.dart';

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
  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const AnalyticsScreen(),
  ];

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
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
            tooltip: 'View and manage expenses',
          ),

          // Analytics tab
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
            tooltip: 'View spending analytics',
          ),
        ],
      ),
    );
  }
}
