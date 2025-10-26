import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

/// LoginScreen - Email/Password authentication UI
///
/// This is the entry point for unauthenticated users.
/// Users can log in with existing credentials or navigate to signup.
///
/// **Features:**
/// - Email and password input with validation
/// - Loading state during authentication
/// - Error messages displayed in SnackBar
/// - Link to signup screen for new users
/// - Material Design 3 styling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  // GlobalKey gives us access to FormState methods like validate()
  final _formKey = GlobalKey<FormState>();

  // Text controllers to get user input
  // These allow us to read the text from TextFormFields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Local loading state (separate from provider)
  // We use this to prevent multiple submissions
  bool _isSubmitting = false;

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  ///
  /// Validates form, then calls AuthProvider.signIn()
  /// Shows success/error messages via SnackBar
  Future<void> _handleLogin() async {
    // 1. Validate all form fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // 2. Prevent multiple submissions
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // 3. Get auth provider (don't listen for changes during async operation)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 4. Attempt sign in
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // 5. Reset submitting state
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    // 6. Show error if sign in failed
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Note: If success, AuthGate will automatically show main app
    // No manual navigation needed!
  }

  /// Navigate to signup screen
  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // App title
                  Text(
                    'Expense Tracker',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Sign in to manage your expenses',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      // Validation runs when form.validate() is called
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      // Basic email format check
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null; // null means validation passed
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Hide password text
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(), // Submit on Enter
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  FilledButton(
                    onPressed: _isSubmitting ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  OutlinedButton(
                    onPressed: _navigateToSignup,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
