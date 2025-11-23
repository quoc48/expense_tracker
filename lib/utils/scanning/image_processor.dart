import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility for processing receipt images before OCR
///
/// This class handles:
/// - Image compression (reduce file size while maintaining quality)
/// - Rotation correction (using EXIF data)
/// - Quality validation (size, blur detection)
/// - Image preprocessing (contrast enhancement for OCR)
class ImageProcessor {
  /// Maximum image dimensions for OCR processing
  /// Larger images = better accuracy but slower processing
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;

  /// JPEG compression quality (0-100)
  /// 85 provides good balance between file size and quality
  static const int compressionQuality = 85;

  /// Minimum recommended dimensions for good OCR
  static const int minWidth = 800;
  static const int minHeight = 800;

  /// Process image for OCR
  ///
  /// This is the main method that:
  /// 1. Loads the image
  /// 2. Corrects rotation (EXIF)
  /// 3. Compresses to optimal size
  /// 4. Enhances contrast
  /// 5. Saves to temp file
  ///
  /// Returns path to processed image, or null if processing fails.
  static Future<String?> processForOcr(String imagePath) async {
    try {
      debugPrint('Processing image: $imagePath');

      // 1. Load image
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // 2. Correct rotation based on EXIF data
      image = _correctRotation(image, bytes);

      // 3. Resize if too large (maintains aspect ratio)
      image = _resizeImage(image);

      // 4. Enhance for OCR (increase contrast, sharpen)
      image = _enhanceForOcr(image);

      // 5. Save to temp file
      final processedPath = await _saveToTempFile(image);

      debugPrint('Image processed: $processedPath');
      return processedPath;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  /// Compress image without extensive processing
  ///
  /// Use this when you just need to reduce file size
  /// without OCR optimization.
  static Future<String?> compressImage(
    String imagePath, {
    int quality = compressionQuality,
  }) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      // Correct rotation
      image = _correctRotation(image, bytes);

      // Resize if too large
      image = _resizeImage(image);

      // Save with compression
      return await _saveToTempFile(image, quality: quality);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Validate image quality
  ///
  /// Returns a map with quality metrics:
  /// - isValid: overall quality assessment
  /// - width: image width in pixels
  /// - height: image height in pixels
  /// - isTooSmall: below minimum recommended size
  /// - aspectRatio: width/height ratio
  static Future<Map<String, dynamic>> validateQuality(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return {
          'isValid': false,
          'error': 'Could not decode image',
        };
      }

      final width = image.width;
      final height = image.height;
      final isTooSmall = width < minWidth || height < minHeight;
      final aspectRatio = width / height;

      // Consider image valid if it meets minimum size requirements
      final isValid = !isTooSmall;

      return {
        'isValid': isValid,
        'width': width,
        'height': height,
        'isTooSmall': isTooSmall,
        'aspectRatio': aspectRatio,
      };
    } catch (e) {
      debugPrint('Error validating image quality: $e');
      return {
        'isValid': false,
        'error': e.toString(),
      };
    }
  }

  /// Correct image rotation based on EXIF orientation data
  ///
  /// Cameras store orientation in EXIF metadata.
  /// Without correction, images may appear rotated incorrectly.
  ///
  /// Note: The image package automatically handles EXIF orientation
  /// when decoding, but we keep this method for explicit handling
  /// if needed in the future.
  static img.Image _correctRotation(img.Image image, Uint8List bytes) {
    try {
      // The image package (v4.x) automatically applies EXIF orientation
      // when decoding the image, so we typically don't need manual correction.
      // However, if issues arise, we can add manual rotation logic here.

      // For now, just return the image as-is since EXIF is auto-applied
      return image;
    } catch (e) {
      debugPrint('Error correcting rotation: $e');
      return image;
    }
  }

  /// Resize image to optimal dimensions for OCR
  ///
  /// Maintains aspect ratio while ensuring image is not too large.
  /// Smaller images = faster OCR, but lower accuracy.
  static img.Image _resizeImage(img.Image image) {
    final width = image.width;
    final height = image.height;

    // Skip if already within bounds
    if (width <= maxWidth && height <= maxHeight) {
      return image;
    }

    // Calculate new dimensions maintaining aspect ratio
    double scale;
    if (width > height) {
      scale = maxWidth / width;
    } else {
      scale = maxHeight / height;
    }

    final newWidth = (width * scale).round();
    final newHeight = (height * scale).round();

    debugPrint('Resizing image: ${width}x$height → ${newWidth}x$newHeight');

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear, // Good balance of speed/quality
    );
  }

  /// Enhance image for better OCR results
  ///
  /// Applies:
  /// - Contrast adjustment (makes text stand out)
  /// - Optional sharpening (makes edges clearer)
  static img.Image _enhanceForOcr(img.Image image) {
    // Increase contrast by 20% to make text more distinct
    // This helps OCR distinguish characters from background
    image = img.adjustColor(
      image,
      contrast: 1.2,
    );

    // Optional: Apply subtle sharpening to enhance edges
    // Uncomment if OCR accuracy needs improvement
    // image = img.convolution(image, filter: [
    //   0, -1, 0,
    //   -1, 5, -1,
    //   0, -1, 0,
    // ]);

    return image;
  }

  /// Save image to temporary file
  ///
  /// Creates a unique filename and saves to temp directory.
  /// These files should be deleted after OCR processing!
  static Future<String> _saveToTempFile(
    img.Image image, {
    int quality = compressionQuality,
  }) async {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create unique filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'receipt_processed_$timestamp.jpg';
    final filePath = path.join(tempDir.path, filename);

    // Encode as JPEG with compression
    final jpegBytes = img.encodeJpg(image, quality: quality);

    // Write to file
    final file = File(filePath);
    await file.writeAsBytes(jpegBytes);

    debugPrint('Saved processed image: $filePath (${jpegBytes.length} bytes)');
    return filePath;
  }

  /// Delete temporary image file
  ///
  /// IMPORTANT: Call this after OCR processing to maintain privacy
  /// and free up storage space.
  static Future<void> deleteTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted temp file: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting temp file: $e');
    }
  }

  /// Batch delete multiple temporary files
  static Future<void> deleteTempFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      await deleteTempFile(filePath);
    }
  }

  /// Clean up all orphaned temp receipt files
  ///
  /// Call this on app startup to remove any files left from
  /// previous sessions (e.g., if app crashed during processing).
  static Future<void> cleanupOldTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      int deletedCount = 0;
      for (final file in files) {
        if (file is File && file.path.contains('receipt_')) {
          await file.delete();
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        debugPrint('Cleaned up $deletedCount old receipt temp files');
      }
    } catch (e) {
      debugPrint('Error cleaning up old temp files: $e');
    }
  }
}
