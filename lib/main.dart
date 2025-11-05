import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'widgets/auth_gate.dart';
import 'theme/app_theme.dart';

// This is the entry point of the Flutter app
// The main() function is called when the app starts
// Now async to support Supabase initialization
Future<void> main() async {
  // Ensure Flutter bindings are initialized before async operations
  // Required for loading .env and initializing Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // This contains our Supabase URL and Anon Key
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from .env
  // This must complete before the app starts
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ExpenseTrackerApp());
}

// ExpenseTrackerApp is the root widget of our application
// It's a StatelessWidget because the app-level configuration doesn't change
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider allows us to provide multiple providers to the widget tree
    // We now have three providers:
    // 1. AuthProvider - handles user authentication and session
    // 2. ExpenseProvider - manages expense data (CRUD operations)
    // 3. UserPreferencesProvider - manages user settings and budget configuration
    // All providers are available to all descendant widgets
    return MultiProvider(
      providers: [
        // AuthProvider must be first because other providers may depend on auth state
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        // ExpenseProvider handles expense data management
        ChangeNotifierProvider(
          create: (context) {
            final provider = ExpenseProvider();
            // Load expenses from storage when the provider is created
            // This happens asynchronously, so the app will show loading state initially
            provider.loadExpenses();
            return provider;
          },
        ),
        // UserPreferencesProvider handles user settings and budget configuration
        ChangeNotifierProvider(
          create: (context) {
            final provider = UserPreferencesProvider();
            // Load user preferences (budget, language, theme) when provider is created
            // Creates default preferences (20M VND budget) for new users automatically
            provider.loadPreferences();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        // App title (shown in task switcher on Android)
        title: 'Expense Tracker',

        // Disable the debug banner in the top-right corner
        debugShowCheckedModeBanner: false,

        // Use our new centralized theme system
        // AppTheme provides consistent design tokens throughout the app
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        // Automatically switch between light and dark based on system settings
        themeMode: ThemeMode.system,

        // Set AuthGate as the home screen (instead of MainNavigationScreen)
        // AuthGate checks authentication and shows:
        // - LoginScreen if not authenticated
        // - MainNavigationScreen if authenticated
        home: const AuthGate(),
      ),
    );
  }
}
