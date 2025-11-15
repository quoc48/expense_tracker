import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/scanning/vision_parser_service.dart';
import '../../models/scanning/scanned_item.dart';
import '../../widgets/scanning/processing_overlay.dart';

/// Preview screen for captured/selected receipt image
///
/// Allows user to:
/// - Review the image quality with pinch-to-zoom
/// - See quality warnings (blur, size issues)
/// - Retake if needed
/// - Process the receipt with Vision AI
class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final VisionParserService _visionParser = VisionParserService();

  bool _isAnalyzing = true;
  bool _isBlurry = false;
  bool _isTooSmall = false;
  bool _isProcessing = false;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _analyzeImageQuality();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _image?.dispose();
    super.dispose();
  }

  /// Analyze image quality for blur and size
  Future<void> _analyzeImageQuality() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _image = frame.image;

      setState(() {
        // Check if image is too small for good OCR
        // Minimum recommended: 800x800 pixels
        _isTooSmall = _image!.width < 800 || _image!.height < 800;

        // Simple blur detection: very small images often indicate blur
        // More sophisticated blur detection could use Laplacian variance
        _isBlurry = _image!.width < 600 || _image!.height < 600;

        _isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  /// Reset zoom to default
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  /// Process the receipt image with Vision AI
  Future<void> _processReceipt() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint('📸 Starting receipt processing for: ${widget.imagePath}');
      final imageFile = File(widget.imagePath);

      // Check if Vision parser is configured
      if (!_visionParser.isConfigured) {
        throw Exception('Vision AI chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env');
      }

      // Process image directly with Vision AI (no OCR step)
      debugPrint('👁️ Processing receipt with Vision AI...');
      final startTime = DateTime.now();
      final scannedItems = await _visionParser.parseReceiptImage(imageFile);

      if (scannedItems.isEmpty) {
        throw Exception('Không tìm thấy mặt hàng nào trong hóa đơn');
      }

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('✅ Vision AI extracted ${scannedItems.length} items in ${processingTime}ms');

      // CRITICAL - Delete temp image file (privacy)
      await _deleteTempImageFile(imageFile);

      // Navigate to review screen (Phase 5)
      // For now, show success dialog with results
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        await _showResultsDialog(scannedItems, processingTime);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error processing receipt: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        _showErrorDialog(e.toString());
      }
    }
  }

  /// Delete temporary image file after processing (PRIVACY CRITICAL)
  Future<void> _deleteTempImageFile(File imageFile) async {
    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
        debugPrint('🗑️ Deleted temp image file: ${imageFile.path}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to delete temp image: $e');
      // Don't throw - this is cleanup, not critical to user flow
    }
  }

  /// Show results dialog (temporary until Phase 5 Review Screen is ready)
  Future<void> _showResultsDialog(
    List<ScannedItem> items,
    int processingTimeMs,
  ) async {
    final total = items.fold<double>(0.0, (sum, item) => sum + item.amount);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.checkCircle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Vision AI - Kết quả'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tìm thấy ${items.length} sản phẩm:'),
              const SizedBox(height: 4),
              Text(
                'Giá đã bao gồm VAT',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        '${item.description}: ${_formatAmount(item.amount)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
              const Divider(height: 24),
              Text(
                'Tổng: ${_formatAmount(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                '⚡ ${processingTimeMs}ms | 👁️ GPT-4o-mini | 💰 ~\$0.0003',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and return to camera
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close preview
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(PhosphorIconsRegular.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Lỗi xử lý'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Format amount as Vietnamese currency
  String _formatAmount(double amount) {
    final amountStr = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    var count = 0;

    for (var i = amountStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amountStr[i]);
      count++;
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Xem trước'),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Reset zoom button
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsOut),
            onPressed: _resetZoom,
            tooltip: 'Đặt lại zoom',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quality warnings
          if (!_isAnalyzing && (_isBlurry || _isTooSmall))
            _buildQualityWarnings(),

          // Image preview with zoom
          Expanded(
            child: _buildImageViewer(),
          ),

          // Helpful tip
          _buildTipText(),

          // Bottom actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Retake button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Chụp lại'),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Process button
                  Expanded(
                    child: FilledButton(
                      onPressed: _isProcessing ? null : _processReceipt,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Xử lý hóa đơn'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
        // Processing overlay
        if (_isProcessing)
          ProcessingOverlay(
            onCancel: () {
              setState(() {
                _isProcessing = false;
              });
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  /// Quality warning banner
  Widget _buildQualityWarnings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withValues(alpha: 0.9),
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsRegular.warning,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getQualityWarningText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityWarningText() {
    if (_isBlurry && _isTooSmall) {
      return 'Ảnh có thể bị mờ và quá nhỏ. Thử chụp lại với ánh sáng tốt hơn.';
    } else if (_isBlurry) {
      return 'Ảnh có thể bị mờ. Hãy chắc chắn rằng ảnh rõ nét.';
    } else if (_isTooSmall) {
      return 'Ảnh hơi nhỏ. Chụp gần hơn để có kết quả tốt hơn.';
    }
    return '';
  }

  /// Zoomable image viewer with InteractiveViewer
  Widget _buildImageViewer() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      boundaryMargin: const EdgeInsets.all(20),
      child: Center(
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Helpful tip text
  Widget _buildTipText() {
    if (_isAnalyzing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Đang phân tích chất lượng ảnh...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      );
    }

    if (_isBlurry || _isTooSmall) {
      // Warning already shown above, don't repeat
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsRegular.info,
            size: 16,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Kéo ngón tay để phóng to, kiểm tra văn bản rõ ràng',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
