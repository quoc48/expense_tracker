import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client instance
///
/// This provides easy access to the Supabase client throughout the app.
/// Usage: `supabase.from('expenses').select()` or `supabase.auth.signIn()`
///
/// The client is initialized in main.dart before the app starts,
/// so it's safe to use anywhere in the app.
final supabase = Supabase.instance.client;
