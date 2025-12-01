import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../services/scanning/camera_service.dart';
import '../../services/scanning/permission_service.dart';
import '../../widgets/common/tappable_icon.dart';
import 'image_preview_screen.dart';

/// Full-screen camera interface for capturing receipt photos
///
/// **Design Reference**: Figma node-id=62-2484
///
/// **Layout Structure**:
/// - Full-screen camera preview with 80% black overlay outside safe area
/// - Top: Close button (white circle, 40x40) aligned right
/// - Center: Image safe area (full-width - 32px, 30% white bg, 12px radius)
/// - Bottom: Gallery | Capture | Flash buttons in horizontal row
///
/// **Features**:
/// - Live camera preview
/// - Gallery picker
/// - Flash toggle
/// - Receipt framing guidelines
/// - Permission handling
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final PermissionService _permissionService = PermissionService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isInitializing = true;
  bool _hasPermission = false;
  String? _errorMessage;
  bool _isCapturing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to handle app pause/resume
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    // Clean up resources
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  /// Handle app lifecycle changes (pause/resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Camera should pause when app goes to background
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraService.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Resume camera when app comes back to foreground
      if (_hasPermission) {
        _cameraService.resume();
      }
    }
  }

  /// Initialize camera with permission check
  ///
  /// WORKAROUND: Bypassing permission_handler due to iOS bug.
  /// The camera package will handle permissions internally and show
  /// the system permission dialog when accessing the camera.
  Future<void> _initializeCamera() async {
    debugPrint('📱 [CameraScreen] === _initializeCamera() START ===');
    debugPrint('📱 [CameraScreen] WORKAROUND: Bypassing permission_handler');
    debugPrint('📱 [CameraScreen] Camera package will handle permissions directly');

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // WORKAROUND: Skip permission_handler entirely
      // Go directly to camera initialization
      // The camera package will request permissions when calling availableCameras()
      debugPrint('📱 [CameraScreen] Initializing camera service directly...');
      final success = await _cameraService.initialize();
      debugPrint('📱 [CameraScreen] Camera service initialization: $success');

      if (success) {
        debugPrint('📱 [CameraScreen] ✅ Camera initialized successfully!');
        setState(() {
          _isInitializing = false;
          _hasPermission = true;
        });
      } else {
        debugPrint('📱 [CameraScreen] ❌ Camera initialization failed');
        setState(() {
          _isInitializing = false;
          _hasPermission = false;
          _errorMessage =
              'Không thể khởi động máy ảnh. Vui lòng cấp quyền truy cập máy ảnh trong Cài đặt → Quyền riêng tư → Máy ảnh.';
        });
      }

      debugPrint('📱 [CameraScreen] === _initializeCamera() END ===');
    } on CameraException catch (e) {
      debugPrint('❌ [CameraScreen] CameraException: ${e.code} - ${e.description}');

      String errorMessage;
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        errorMessage =
            'Quyền truy cập máy ảnh bị từ chối.\n\nVui lòng cấp quyền trong:\nCài đặt → Quyền riêng tư → Máy ảnh → Expense Tracker';
      } else {
        errorMessage = 'Lỗi máy ảnh: ${e.description ?? 'Không xác định'}';
      }

      setState(() {
        _isInitializing = false;
        _hasPermission = false;
        _errorMessage = errorMessage;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [CameraScreen] ERROR in _initializeCamera: $e');
      debugPrint('❌ [CameraScreen] Stack trace: $stackTrace');

      // Check if error message mentions permissions
      final errorStr = e.toString().toLowerCase();
      String errorMessage;

      if (errorStr.contains('permission') ||
          errorStr.contains('authorization') ||
          errorStr.contains('denied')) {
        errorMessage =
            'Quyền truy cập máy ảnh bị từ chối.\n\nVui lòng cấp quyền trong:\nCài đặt → Quyền riêng tư → Máy ảnh → Expense Tracker';
      } else {
        errorMessage = 'Lỗi khởi động máy ảnh: $e';
      }

      setState(() {
        _isInitializing = false;
        _hasPermission = false;
        _errorMessage = errorMessage;
      });
    }
  }





  /// Handle capture button press
  Future<void> _capturePhoto() async {
    if (_isCapturing) return; // Prevent multiple captures

    setState(() => _isCapturing = true);

    try {
      final photo = await _cameraService.takePicture();

      if (photo != null && mounted) {
        // Show preview as bottom sheet overlay (Figma node-id=62-1863)
        await showImagePreviewSheet(
          context: context,
          imagePath: photo.path,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  /// Handle gallery picker
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Good balance of quality and file size
      );

      if (image != null && mounted) {
        // Show preview as bottom sheet overlay (Figma node-id=62-1863)
        await showImagePreviewSheet(
          context: context,
          imagePath: image.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể chọn ảnh từ thư viện'),
          ),
        );
      }
    }
  }

  /// Toggle flash on/off
  Future<void> _toggleFlash() async {
    final controller = _cameraService.controller;
    if (controller == null) return;

    try {
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.off);
      } else {
        await controller.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return _buildLoadingView();
    }

    if (!_hasPermission || _errorMessage != null) {
      return _buildErrorView();
    }

    return _buildCameraView();
  }

  /// Loading view while camera initializes
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Đang khởi động máy ảnh...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Error view when camera fails or permission denied
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.warningCircle,
              size: 64,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Try again button
            FilledButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(PhosphorIconsRegular.arrowClockwise),
              label: const Text('Thử lại'),
            ),

            const SizedBox(height: 12),

            // Open settings button (if permission denied)
            if (!_hasPermission)
              FilledButton.icon(
                onPressed: () async {
                  await _permissionService.openSettings();
                },
                icon: const Icon(PhosphorIconsRegular.gear),
                label: const Text('Mở cài đặt'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),

            const SizedBox(height: 12),

            // Use gallery instead button
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(PhosphorIconsRegular.image),
              label: const Text('Chọn từ thư viện'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            // Back button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Main camera view
  Widget _buildCameraView() {
    final controller = _cameraService.controller;
    if (controller == null) return const SizedBox();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(controller),

        // Dark overlay outside capture frame
        _buildDarkOverlay(),

        // Receipt framing guidelines
        _buildGuidelinesOverlay(),

        // Top app bar
        _buildAppBar(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  /// Top bar with close button aligned right
  ///
  /// **Figma Specs** (node-id=62-2489):
  /// - Close button: White circle 40x40, padding 4px, X icon 24px
  /// - Position: Top-right with 16px padding
  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Close button - white circle with X icon and tap feedback
              TappableCircleButton(
                icon: PhosphorIconsRegular.x,
                onTap: () => Navigator.of(context).pop(),
                size: 40,
                iconSize: 24,
                backgroundColor: Colors.white,
                iconColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom controls with Gallery | Capture | Flash buttons
  ///
  /// **Figma Specs** (node-id=62-2855):
  /// - Layout: Row with 56px gap between items
  /// - Gallery button: White circle 40x40, image icon 24px
  /// - Capture button: 66x66 with ring design
  /// - Flash button: White circle 40x40, lightning icon 24px
  /// - Bottom padding: 40px (absolute, no SafeArea)
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40, // Absolute 40px from screen bottom per Figma
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gallery button - white circle with image icon and tap feedback
          TappableCircleButton(
            icon: PhosphorIconsFill.image,
            onTap: _pickFromGallery,
            size: 40,
            iconSize: 24,
            backgroundColor: Colors.white,
            iconColor: Colors.black,
          ),

          const SizedBox(width: 56), // Gap from Figma

          // Capture button - large ring design with tap feedback
          TappableCaptureButton(
            onTap: _capturePhoto,
            isCapturing: _isCapturing,
            size: 66,
          ),

          const SizedBox(width: 56), // Gap from Figma

          // Flash button - lightning-slash when off, lightning-fill when on
          TappableCircleButton(
            icon: _isFlashOn
                ? PhosphorIconsFill.lightning
                : PhosphorIconsRegular.lightningSlash,
            onTap: _toggleFlash,
            size: 40,
            iconSize: 24,
            backgroundColor: Colors.white,
            iconColor: Colors.black,
            activeIconColor: Colors.amber,
            isActive: _isFlashOn,
          ),
        ],
      ),
    );
  }

  /// Dark overlay outside the capture frame to focus attention
  ///
  /// **Figma Specs** (node-id=62-2486):
  /// - Overlay color: rgba(0,0,0,0.8) - 80% black
  /// - Safe area: Full width - 32px (16px margins), 12px border radius
  /// - Safe area positioned with top bar space and bottom controls space
  Widget _buildDarkOverlay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;

    // Frame dimensions: full width with 16px margins on each side
    final frameWidth = screenWidth - 32;

    // Calculate vertical space:
    // Top: safe area + 16px padding + 40px close button + 16px gap
    // Bottom: 40px padding + 66px capture button + 16px gap (absolute, no safe area)
    final topOffset = safeAreaPadding.top + 16 + 40 + 16;
    final bottomOffset = 40 + 66 + 16; // No safe area padding - absolute positioning
    final frameHeight = screenHeight - topOffset - bottomOffset;

    return CustomPaint(
      size: Size(screenWidth, screenHeight),
      painter: _OverlayPainter(
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        borderRadius: 12,
        topOffset: topOffset,
      ),
    );
  }

  /// Guidelines overlay to help frame receipts
  ///
  /// **Figma Specs** (node-id=62-2492):
  /// - Border: Subtle white border with 12px rounded corners
  /// - No corner markers - just clean rounded rectangle
  Widget _buildGuidelinesOverlay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;

    // Match the same dimensions as the overlay cutout
    final frameWidth = screenWidth - 32;
    final topOffset = safeAreaPadding.top + 16 + 40 + 16;
    final bottomOffset = 40 + 66 + 16; // No safe area - absolute positioning
    final frameHeight = screenHeight - topOffset - bottomOffset;

    return Positioned(
      top: topOffset,
      left: 16,
      child: Container(
        width: frameWidth,
        height: frameHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Custom painter for dark overlay with transparent cutout
///
/// **Figma Specs** (node-id=62-2486):
/// - Overlay: 80% black opacity
/// - Cutout: Rounded rectangle for safe area
class _OverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;
  final double borderRadius;
  final double topOffset;

  _OverlayPainter({
    required this.frameWidth,
    required this.frameHeight,
    required this.borderRadius,
    required this.topOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate frame position (horizontally centered, vertically positioned)
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = topOffset;

    // Create the overlay path (full screen)
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the cutout path (rounded rectangle for safe area)
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
          Radius.circular(borderRadius),
        ),
      );

    // Subtract cutout from overlay to create transparent area
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );

    // Draw the overlay with 80% black per Figma spec
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return frameWidth != oldDelegate.frameWidth ||
        frameHeight != oldDelegate.frameHeight ||
        topOffset != oldDelegate.topOffset;
  }
}
