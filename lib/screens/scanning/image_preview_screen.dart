import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Preview screen for captured/selected receipt image
///
/// Allows user to:
/// - Review the image quality with pinch-to-zoom
/// - See quality warnings (blur, size issues)
/// - Retake if needed
/// - Process the receipt (move to OCR)
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

  bool _isAnalyzing = true;
  bool _isBlurry = false;
  bool _isTooSmall = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  // Process button (placeholder - will integrate OCR in Phase 3)
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // TODO: Navigate to processing overlay in Phase 3
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chức năng xử lý OCR sẽ được thêm trong Phase 3'),
                          ),
                        );
                      },
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
