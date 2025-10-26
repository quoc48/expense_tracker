import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/expense_provider.dart';
import 'screens/main_navigation_screen.dart';

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
    // ChangeNotifierProvider makes ExpenseProvider available to all descendant widgets
    // It creates a single instance of ExpenseProvider and keeps it alive
    // Any widget in the tree can access it using Provider.of or Consumer
    return ChangeNotifierProvider(
      // create: Factory function that creates the provider instance
      // This only runs once when the provider is first needed
      create: (context) {
        final provider = ExpenseProvider();
        // Load expenses from storage when the provider is created
        // This happens asynchronously, so the app will show loading state initially
        provider.loadExpenses();
        return provider;
      },
      child: MaterialApp(
      // App title (shown in task switcher on Android)
      title: 'Expense Tracker',

      // Disable the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // Material Design 3 theme configuration
      theme: ThemeData(
        // Use Material 3 design system
        useMaterial3: true,

        // Define color scheme - we'll use a teal/green theme (fits expense tracking)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // Teal 600
          brightness: Brightness.light,
        ),

        // Card styling
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // AppBar styling
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        // Input decoration theme (for forms)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),

        // FloatingActionButton theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),

        // Set MainNavigationScreen as the home screen
        // This provides bottom navigation to switch between Expenses and Analytics
        home: const MainNavigationScreen(),
      ),
    );
  }
}
