import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

// StorageService: Handles all data persistence operations
// This is a "Service" - a class that handles business logic separate from UI
class StorageService {
  // Key used to store expenses in shared_preferences
  // Making it static const means it's the same across all instances
  static const String _expensesKey = 'expenses';

  // SharedPreferences instance - we'll initialize this once
  SharedPreferences? _prefs;

  // Initialize the storage service
  // This must be called before using save/load methods
  // async: This operation takes time (disk access)
  Future<void> initialize() async {
    // SharedPreferences.getInstance() returns a Future
    // await: Wait for it to complete before continuing
    _prefs = await SharedPreferences.getInstance();
  }

  // Save expenses to local storage
  // Future<void>: Returns nothing, but takes time (async operation)
  Future<void> saveExpenses(List<Expense> expenses) async {
    // Make sure we're initialized
    if (_prefs == null) {
      await initialize();
    }

    // Convert list of Expense objects to list of Maps
    // Each expense.toMap() converts one Expense to a Map<String, dynamic>
    final List<Map<String, dynamic>> expenseMaps =
        expenses.map((expense) => expense.toMap()).toList();

    // Convert the list of maps to a JSON string
    // jsonEncode: Dart's built-in JSON serializer
    // Example: [{"id": "1", "description": "Food"...}, {"id": "2"...}]
    final String jsonString = jsonEncode(expenseMaps);

    // Save the JSON string to shared_preferences
    // setString returns a Future<bool> (true if successful)
    await _prefs!.setString(_expensesKey, jsonString);

    // The ! after _prefs tells Dart "I know this is not null"
    // We can safely use it because we checked/initialized above
  }

  // Load expenses from local storage
  // Future<List<Expense>>: Returns a list of expenses (eventually)
  Future<List<Expense>> loadExpenses() async {
    // Make sure we're initialized
    if (_prefs == null) {
      await initialize();
    }

    // Try to get the saved JSON string
    // getString returns null if the key doesn't exist (first time)
    final String? jsonString = _prefs!.getString(_expensesKey);

    // If no data saved yet, return empty list
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      // Decode the JSON string back to a list of maps
      // jsonDecode: Dart's built-in JSON deserializer
      // The result is dynamic, so we cast it to List<dynamic>
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert each map back to an Expense object
      // We iterate through the list and use Expense.fromMap
      final List<Expense> expenses = jsonList
          .map((json) => Expense.fromMap(json as Map<String, dynamic>))
          .toList();

      return expenses;
    } catch (e) {
      // If there's an error (corrupted data, etc.), return empty list
      // In production, you might want to log this error
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Clear all saved expenses (useful for testing/debugging)
  Future<void> clearExpenses() async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs!.remove(_expensesKey);
  }
}
