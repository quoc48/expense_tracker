import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'hybrid_parser_service.dart';

/// Configuration and factory for receipt parsers
///
/// Handles loading API keys from environment variables
/// and creating properly configured parser instances.
class ParserConfig {
  static ParserConfig? _instance;

  /// OpenAI API key loaded from .env file
  String? _openAiApiKey;

  /// Whether LLM parsing is available
  bool get hasLlmSupport => _openAiApiKey != null && _openAiApiKey!.isNotEmpty;

  /// Cost estimate per parse (in USD)
  /// GPT-3.5 Turbo: ~$0.002 per receipt (average)
  /// GPT-4 Turbo: ~$0.02 per receipt (10x more expensive)
  static const double estimatedCostPerParse = 0.002;

  ParserConfig._();

  /// Get singleton instance
  static ParserConfig get instance {
    _instance ??= ParserConfig._();
    return _instance!;
  }

  /// Initialize parser configuration
  ///
  /// Loads API keys from environment variables
  /// Should be called during app initialization
  static Future<void> initialize() async {
    final config = instance;

    try {
      // Load OpenAI API key from .env file
      config._openAiApiKey = dotenv.env['OPENAI_API_KEY'];

      if (config._openAiApiKey != null && config._openAiApiKey!.isNotEmpty) {
        debugPrint('✅ Parser Config: OpenAI API configured');
        debugPrint('📊 Using model: GPT-3.5 Turbo (cost-effective)');
        debugPrint('💰 Estimated cost: \$${estimatedCostPerParse} per receipt');
      } else {
        debugPrint('⚠️ Parser Config: No OpenAI API key found');
        debugPrint('📏 Will use rule-based parsing only');
      }
    } catch (e) {
      debugPrint('❌ Parser Config: Error loading configuration: $e');
      config._openAiApiKey = null;
    }
  }

  /// Create a configured hybrid parser
  ///
  /// Automatically uses the best available configuration:
  /// - With API key: LLM + rule-based fallback
  /// - Without API key: Rule-based only
  HybridParserService createParser({
    bool preferLlm = true,
    bool validateResults = true,
  }) {
    return HybridParserService(
      apiKey: _openAiApiKey,
      preferLlm: preferLlm && hasLlmSupport,
      validateResults: validateResults,
    );
  }

  /// Get parser status information
  Map<String, dynamic> getStatus() {
    return {
      'llm_available': hasLlmSupport,
      'model': hasLlmSupport ? 'gpt-3.5-turbo-1106' : null,
      'estimated_cost': hasLlmSupport ? estimatedCostPerParse : 0,
      'fallback': 'rule-based',
      'mode': hasLlmSupport ? 'hybrid' : 'offline',
    };
  }

  /// Model comparison for reference
  static const Map<String, Map<String, dynamic>> modelComparison = {
    'gpt-3.5-turbo': {
      'cost_per_1k_tokens': 0.001,
      'accuracy': 'Good',
      'speed': 'Fast (2-5s)',
      'recommended': true,
    },
    'gpt-4-turbo': {
      'cost_per_1k_tokens': 0.01,
      'accuracy': 'Excellent',
      'speed': 'Slower (5-15s)',
      'recommended': false, // Too expensive for regular use
    },
    'rule-based': {
      'cost_per_1k_tokens': 0.0,
      'accuracy': 'Moderate',
      'speed': 'Instant',
      'recommended': true, // As fallback
    },
  };
}

/// Usage example for receipt scanning screen
///
/// ```dart
/// class ReceiptScannerScreen extends StatefulWidget {
///   @override
///   void initState() {
///     super.initState();
///     _initializeParser();
///   }
///
///   Future<void> _initializeParser() async {
///     // Initialize parser config on app start
///     await ParserConfig.initialize();
///
///     // Create parser instance
///     final parser = ParserConfig.instance.createParser();
///
///     // Check status
///     final status = ParserConfig.instance.getStatus();
///     if (status['llm_available']) {
///       print('Using AI-powered parsing');
///     } else {
///       print('Using offline parsing');
///     }
///   }
///
///   Future<void> _parseReceipt(OcrResult ocrResult) async {
///     final parser = ParserConfig.instance.createParser();
///     final result = await parser.parseReceipt(ocrResult);
///
///     // Process results...
///   }
/// }
/// ```