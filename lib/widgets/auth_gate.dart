import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/recurring_expense_provider.dart';
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

    // If authenticated, show main app with recurring expense auto-creation
    return const _AuthenticatedApp();
  }
}

/// Wrapper widget that handles post-login tasks like recurring expense auto-creation
///
/// **Why a separate widget?**
/// - AuthGate.build() can be called multiple times during rebuilds
/// - We only want to process recurring expenses ONCE per login session
/// - StatefulWidget with initState ensures one-time execution
class _AuthenticatedApp extends StatefulWidget {
  const _AuthenticatedApp();

  @override
  State<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<_AuthenticatedApp> {
  @override
  void initState() {
    super.initState();
    // Process recurring expenses after the first frame renders
    // This ensures the widget tree is built and context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processRecurringExpenses();
    });
  }

  /// Process recurring expenses to auto-create monthly expenses
  ///
  /// **Flow:**
  /// 1. Wait briefly for auth token to be fully ready
  /// 2. Load all recurring expense templates from Supabase
  /// 3. Check each active template: does it need expense creation for this month?
  /// 4. Create expenses for templates that haven't been created this month yet
  /// 5. Update lastCreatedDate on processed templates
  ///
  /// This runs silently in the background - no UI feedback needed.
  Future<void> _processRecurringExpenses() async {
    // Capture provider before async gap
    final provider = context.read<RecurringExpenseProvider>();
    
    try {
      // Small delay to ensure auth token is fully refreshed
      // This fixes race condition where token refresh happens simultaneously
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verify user is still authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Skipping recurring expenses - user not authenticated');
        return;
      }

      final count = await provider.processAutoCreation();

      if (count > 0) {
        debugPrint('✅ Auto-created $count recurring expenses');
      }
    } catch (e) {
      // Silent failure - recurring expense auto-creation is non-critical
      debugPrint('⚠️ Recurring expense auto-creation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
