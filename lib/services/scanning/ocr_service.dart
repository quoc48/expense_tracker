import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for extracting text from images using Google ML Kit
///
/// Supports Vietnamese text recognition and handles:
/// - Text block parsing for structured data
/// - Error handling and timeouts
/// - On-device processing (privacy-first)
class OcrService {
  // Text recognizer configured for Vietnamese language
  late final TextRecognizer _textRecognizer;

  // Maximum time allowed for OCR processing (10 seconds)
  static const Duration _processingTimeout = Duration(seconds: 10);

  OcrService() {
    // Initialize ML Kit text recognizer with Vietnamese script support
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin, // Vietnamese uses Latin script
    );
  }

  /// Extract text from an image file
  ///
  /// Returns [OcrResult] containing extracted text and metadata
  /// Throws [OcrException] if processing fails or times out
  Future<OcrResult> extractText(File imageFile) async {
    try {
      debugPrint('🔍 OCR: Starting text extraction from ${imageFile.path}');
      final startTime = DateTime.now();

      // Create input image from file
      final inputImage = InputImage.fromFile(imageFile);

      // Process image with timeout protection
      final RecognizedText recognizedText = await _textRecognizer
          .processImage(inputImage)
          .timeout(
            _processingTimeout,
            onTimeout: () {
              throw OcrTimeoutException(
                'OCR processing exceeded ${_processingTimeout.inSeconds} seconds',
              );
            },
          );

      // Calculate processing time
      final processingTime = DateTime.now().difference(startTime);
      debugPrint('✅ OCR: Completed in ${processingTime.inMilliseconds}ms');
      debugPrint('📝 OCR: Extracted ${recognizedText.blocks.length} text blocks');

      // Parse text blocks into structured data
      final textBlocks = _parseTextBlocks(recognizedText);

      return OcrResult(
        rawText: recognizedText.text,
        textBlocks: textBlocks,
        processingTimeMs: processingTime.inMilliseconds,
        blockCount: recognizedText.blocks.length,
      );
    } on OcrException {
      // Re-throw OCR-specific exceptions
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ OCR: Error during text extraction: $e');
      debugPrint('Stack trace: $stackTrace');
      throw OcrException('Failed to extract text: $e');
    }
  }

  /// Parse recognized text into structured text blocks
  ///
  /// Each block contains:
  /// - Text content
  /// - Line-by-line breakdown
  /// - Confidence score (0.0 to 1.0)
  List<TextBlockData> _parseTextBlocks(RecognizedText recognizedText) {
    final blocks = <TextBlockData>[];

    for (final block in recognizedText.blocks) {
      // Extract lines from each block
      final lines = block.lines.map((line) {
        return TextLineData(
          text: line.text,
          confidence: line.confidence ?? 0.0,
        );
      }).toList();

      // Skip empty blocks
      if (lines.isEmpty || block.text.trim().isEmpty) {
        continue;
      }

      blocks.add(TextBlockData(
        text: block.text,
        lines: lines,
        confidence: _calculateAverageLineConfidence(lines),
      ));
    }

    debugPrint('📊 OCR: Parsed ${blocks.length} non-empty text blocks');
    return blocks;
  }

  /// Calculate average confidence from lines
  /// ML Kit provides confidence at line level, not block level
  static double _calculateAverageLineConfidence(List<TextLineData> lines) {
    if (lines.isEmpty) return 0.0;

    final sum = lines.fold<double>(
      0.0,
      (sum, line) => sum + line.confidence,
    );
    return sum / lines.length;
  }

  /// Clean up resources
  /// Call this when the service is no longer needed
  Future<void> dispose() async {
    await _textRecognizer.close();
    debugPrint('🧹 OCR: Text recognizer disposed');
  }
}

// ============================================================================
// Data Models
// ============================================================================

/// Result of OCR text extraction
class OcrResult {
  /// Complete extracted text as a single string
  final String rawText;

  /// Structured text blocks with line-by-line data
  final List<TextBlockData> textBlocks;

  /// Time taken to process the image (milliseconds)
  final int processingTimeMs;

  /// Number of text blocks found
  final int blockCount;

  const OcrResult({
    required this.rawText,
    required this.textBlocks,
    required this.processingTimeMs,
    required this.blockCount,
  });

  /// Check if any text was extracted
  bool get hasText => rawText.isNotEmpty;

  /// Get all lines of text across all blocks
  List<String> get allLines {
    return textBlocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .toList();
  }

  /// Get average confidence across all blocks (0.0 to 1.0)
  double get averageConfidence {
    if (textBlocks.isEmpty) return 0.0;

    final sum = textBlocks.fold<double>(
      0.0,
      (sum, block) => sum + block.confidence,
    );
    return sum / textBlocks.length;
  }

  @override
  String toString() {
    return 'OcrResult('
        'blocks: $blockCount, '
        'lines: ${allLines.length}, '
        'time: ${processingTimeMs}ms, '
        'confidence: ${(averageConfidence * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// A text block extracted from the image
///
/// Blocks are typically paragraphs or groups of related lines
class TextBlockData {
  /// Complete text of this block
  final String text;

  /// Individual lines within this block
  final List<TextLineData> lines;

  /// Recognition confidence (0.0 to 1.0)
  /// Higher values indicate better recognition quality
  final double confidence;

  const TextBlockData({
    required this.text,
    required this.lines,
    required this.confidence,
  });

  @override
  String toString() => 'TextBlock(lines: ${lines.length}, confidence: $confidence)';
}

/// A single line of text within a block
class TextLineData {
  /// Text content of this line
  final String text;

  /// Recognition confidence (0.0 to 1.0)
  final double confidence;

  const TextLineData({
    required this.text,
    required this.confidence,
  });

  @override
  String toString() => 'TextLine("$text", confidence: $confidence)';
}

// ============================================================================
// Exceptions
// ============================================================================

/// Base exception for OCR-related errors
class OcrException implements Exception {
  final String message;

  const OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}

/// Exception thrown when OCR processing exceeds timeout
class OcrTimeoutException extends OcrException {
  const OcrTimeoutException(super.message);

  @override
  String toString() => 'OcrTimeoutException: $message';
}
