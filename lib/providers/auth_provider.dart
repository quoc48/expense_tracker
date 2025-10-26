import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// AuthProvider manages authentication state throughout the app
///
/// This provider wraps Supabase authentication and uses the Provider pattern
/// to notify widgets when auth state changes (login, logout, session refresh).
///
/// **How it works:**
/// 1. Listens to Supabase's auth state stream (onAuthStateChange)
/// 2. Automatically updates _currentUser when auth state changes
/// 3. Calls notifyListeners() to rebuild dependent widgets
/// 4. Provides methods for sign in, sign up, sign out
///
/// **Why this approach:**
/// - Supabase handles token refresh and session persistence automatically
/// - Provider pattern gives us familiar state management (like ExpenseProvider)
/// - Widgets rebuild automatically when auth state changes
/// - Clean separation: Supabase = auth logic, Provider = UI state
class AuthProvider extends ChangeNotifier {
  /// The currently authenticated user (null if not logged in)
  User? _currentUser;

  /// Loading state for async operations (sign in, sign up, etc.)
  bool _isLoading = false;

  /// Error message from last auth operation (null if successful)
  String? _errorMessage;

  /// Subscription to Supabase auth state changes
  /// This listens for SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED events
  StreamSubscription<AuthState>? _authSubscription;

  /// Constructor: Set up auth state listener and initialize with current session
  AuthProvider() {
    // Listen to Supabase auth state changes in real-time
    // This fires when user signs in, signs out, or token refreshes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (kDebugMode) {
        print('Auth state changed: $event');
      }

      // Update current user based on new session
      _currentUser = session?.user;
      _isLoading = false;
      notifyListeners(); // Rebuild all listening widgets
    });

    // Initialize with current session if it exists
    // This handles app restart when user is already logged in
    _currentUser = supabase.auth.currentSession?.user;
    _isLoading = false;
  }

  // ========================================
  // GETTERS - Public API for widgets
  // ========================================

  /// The currently logged in user (null if not authenticated)
  User? get currentUser => _currentUser;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Loading state for showing progress indicators
  bool get isLoading => _isLoading;

  /// Error message from last operation (null if successful)
  String? get errorMessage => _errorMessage;

  /// User's email (convenience getter)
  String? get userEmail => _currentUser?.email;

  // ========================================
  // AUTHENTICATION METHODS
  // ========================================

  /// Sign in with email and password
  ///
  /// Returns true if successful, false if error occurred.
  /// Error message can be accessed via [errorMessage] getter.
  ///
  /// Example usage:
  /// ```dart
  /// final success = await authProvider.signIn(email, password);
  /// if (!success) {
  ///   print(authProvider.errorMessage);
  /// }
  /// ```
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call Supabase auth API
      // This returns a session with JWT token
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // User is automatically set via onAuthStateChange listener
      // No need to manually set _currentUser here
      if (kDebugMode) {
        print('Sign in successful: ${response.user?.email}');
      }

      return true;
    } on AuthException catch (e) {
      // Supabase-specific auth errors (wrong password, user not found, etc.)
      _errorMessage = _formatAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Generic errors (network issues, etc.)
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up a new user with email and password
  ///
  /// Returns true if successful, false if error occurred.
  /// Error message can be accessed via [errorMessage] getter.
  ///
  /// **Email confirmation:** Disabled for testing (configured in your choices)
  /// User can access app immediately after signup.
  ///
  /// Example usage:
  /// ```dart
  /// final success = await authProvider.signUp(email, password);
  /// if (success) {
  ///   // Navigate to main app
  /// }
  /// ```
  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call Supabase auth API to create new user
      // emailRedirectTo is optional - used for email confirmation links
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Check if signup was successful
      if (response.user != null) {
        if (kDebugMode) {
          print('Sign up successful: ${response.user?.email}');
        }

        // Reset loading state
        _isLoading = false;

        // Check if email confirmation is required
        if (response.session == null) {
          _errorMessage = 'Please check your email to confirm your account.';
          notifyListeners();
          return false;
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create account. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      // Supabase-specific auth errors
      _errorMessage = _formatAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Generic errors
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  ///
  /// Clears the session and JWT token from secure storage.
  /// User will be redirected to login screen via AuthGate.
  ///
  /// Example usage:
  /// ```dart
  /// await authProvider.signOut();
  /// // AuthGate will automatically show login screen
  /// ```
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabase.auth.signOut();

      // User is automatically cleared via onAuthStateChange listener
      if (kDebugMode) {
        print('Sign out successful');
      }
    } catch (e) {
      _errorMessage = 'Failed to sign out. Please try again.';
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password via email
  ///
  /// Sends a password reset link to the user's email.
  /// User must click the link to reset their password.
  ///
  /// Returns true if email was sent successfully.
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await supabase.auth.resetPasswordForEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _formatAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  ///
  /// Call this when dismissing error dialogs to reset error state.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Format Supabase auth errors to user-friendly messages
  String _formatAuthError(String error) {
    // Common Supabase auth error messages
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.contains('Email not confirmed')) {
      return 'Please confirm your email before signing in.';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (error.contains('Password should be at least')) {
      return 'Password must be at least 6 characters.';
    } else if (error.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else {
      // Return original error if we don't have a custom message
      return error;
    }
  }

  // ========================================
  // CLEANUP
  // ========================================

  /// Dispose the auth subscription when provider is disposed
  ///
  /// This prevents memory leaks by canceling the stream subscription.
  /// Called automatically when the provider is removed from the widget tree.
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
