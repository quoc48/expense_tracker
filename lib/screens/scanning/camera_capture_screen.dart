import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../services/scanning/camera_service.dart';
import '../../services/scanning/permission_service.dart';
import 'image_preview_screen.dart';

/// Full-screen camera interface for capturing receipt photos
///
/// Features:
/// - Live camera preview
/// - Flash toggle
/// - Gallery picker
/// - Camera flip (front/back)
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

  /// Handle flash toggle
  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    setState(() {}); // Rebuild to update flash icon
  }

  /// Handle camera flip
  Future<void> _flipCamera() async {
    await _cameraService.flipCamera();
    setState(() {}); // Rebuild with new camera
  }

  /// Handle capture button press
  Future<void> _capturePhoto() async {
    if (_isCapturing) return; // Prevent multiple captures

    setState(() => _isCapturing = true);

    try {
      final photo = await _cameraService.takePicture();

      if (photo != null && mounted) {
        // Navigate to preview screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imagePath: photo.path,
            ),
          ),
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
        // Navigate to preview screen with selected image
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imagePath: image.path,
            ),
          ),
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

        // Receipt framing guidelines
        _buildGuidelinesOverlay(),

        // Top app bar
        _buildAppBar(),

        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  /// Top app bar with back and flash buttons
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              color: Colors.white,
              iconSize: 28,
            ),

            // Flash button (only show for back camera)
            if (_cameraService.hasFlash)
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _cameraService.flashMode == FlashMode.off
                      ? PhosphorIconsRegular.lightning
                      : PhosphorIconsFill.lightning,
                ),
                color: Colors.white,
                iconSize: 28,
              ),
          ],
        ),
      ),
    );
  }

  /// Bottom controls with gallery, capture, and flip buttons
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              _buildControlButton(
                icon: PhosphorIconsRegular.image,
                label: 'Thư viện',
                onPressed: _pickFromGallery,
              ),

              // Capture button (larger, centered)
              _buildCaptureButton(),

              // Flip camera button (only show if multiple cameras)
              if (_cameraService.availableCamerasCount > 1)
                _buildControlButton(
                  icon: PhosphorIconsRegular.cameraRotate,
                  label: 'Đảo',
                  onPressed: _flipCamera,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Control button (gallery, flip)
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
          iconSize: 32,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Large capture button
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCapturing ? null : _capturePhoto,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isCapturing ? Colors.white54 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Guidelines overlay to help frame receipts
  Widget _buildGuidelinesOverlay() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner markers
            ...List.generate(4, (index) {
              return Positioned(
                top: index < 2 ? 0 : null,
                bottom: index >= 2 ? 0 : null,
                left: index % 2 == 0 ? 0 : null,
                right: index % 2 == 1 ? 0 : null,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border(
                      top: index < 2
                          ? BorderSide(color: Colors.white, width: 3)
                          : BorderSide.none,
                      bottom: index >= 2
                          ? BorderSide(color: Colors.white, width: 3)
                          : BorderSide.none,
                      left: index % 2 == 0
                          ? BorderSide(color: Colors.white, width: 3)
                          : BorderSide.none,
                      right: index % 2 == 1
                          ? BorderSide(color: Colors.white, width: 3)
                          : BorderSide.none,
                    ),
                  ),
                ),
              );
            }),

            // Hint text
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Text(
                'Đặt hóa đơn trong khung',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
