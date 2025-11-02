import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_navigation_screen.dart';

/// AuthGate - Protected route guard
///
/// This widget is the entry point of the app (used in main.dart).
/// It automatically shows the appropriate screen based on auth state:
/// - Loading screen while checking auth
/// - Login screen if not authenticated
/// - Main app if authenticated
///
/// **How it works:**
/// 1. Listens to AuthProvider changes via Provider.of()
/// 2. When auth state changes (login/logout), this widget rebuilds
/// 3. Automatically routes user to correct screen
/// 4. No manual navigation needed!
///
/// **Why this pattern is powerful:**
/// - Single source of truth for auth state
/// - Centralized routing logic (not scattered across screens)
/// - Reactive - UI automatically updates when auth state changes
/// - Prevents accessing main app without authentication
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider changes
    // When user logs in/out, this widget rebuilds automatically
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading screen while checking authentication
    // This happens during app startup when Supabase checks for existing session
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // If not authenticated, show login screen
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // If authenticated, show main app
    return const MainNavigationScreen();
  }
}
