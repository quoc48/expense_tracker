import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Service for managing camera functionality
///
/// This service handles:
/// - Camera initialization and disposal
/// - Camera lifecycle (resume/pause)
/// - Flash control
/// - Switching between front/back cameras
/// - Taking photos
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;

  /// Get the camera controller
  /// Returns null if camera is not initialized
  CameraController? get controller => _controller;

  /// Check if camera is initialized and ready
  bool get isInitialized => _isInitialized && _controller != null;

  /// Check if flash is available on current camera
  bool get hasFlash {
    if (_controller == null) return false;
    return _controller!.description.lensDirection == CameraLensDirection.back;
  }

  /// Get current flash mode
  FlashMode get flashMode {
    return _controller?.value.flashMode ?? FlashMode.off;
  }

  /// Get available cameras count
  int get availableCamerasCount => _cameras?.length ?? 0;

  /// Initialize the camera service
  ///
  /// This must be called before using any camera functionality.
  /// By default, initializes with the back camera (best for receipt scanning).
  ///
  /// Returns true if initialization successful, false otherwise.
  Future<bool> initialize() async {
    try {
      // Get list of available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available on this device');
        return false;
      }

      // Select back camera for receipt scanning (index 0 is usually back camera)
      _selectedCameraIndex = 0;

      // Initialize camera controller
      return await _initializeCamera(_selectedCameraIndex);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return false;
    }
  }

  /// Initialize camera with specific index
  Future<bool> _initializeCamera(int cameraIndex) async {
    try {
      // Dispose previous controller if exists
      await _controller?.dispose();

      // Create new controller with high resolution for better OCR
      _controller = CameraController(
        _cameras![cameraIndex],
        ResolutionPreset.high, // High resolution for clear text
        enableAudio: false, // No audio needed for photos
        imageFormatGroup: ImageFormatGroup.jpeg, // JPEG for smaller file size
      );

      // Initialize the controller
      await _controller!.initialize();

      _isInitialized = true;
      debugPrint('Camera initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Toggle flash on/off
  ///
  /// Only works on back camera (front cameras don't have flash).
  /// Returns the new flash mode.
  Future<FlashMode> toggleFlash() async {
    if (_controller == null || !_isInitialized) {
      return FlashMode.off;
    }

    if (!hasFlash) {
      debugPrint('Flash not available on front camera');
      return FlashMode.off;
    }

    try {
      // Toggle between off and auto
      // We use auto instead of always-on to save battery and avoid harsh lighting
      final newMode =
          flashMode == FlashMode.off ? FlashMode.auto : FlashMode.off;

      await _controller!.setFlashMode(newMode);
      debugPrint('Flash mode changed to: $newMode');
      return newMode;
    } catch (e) {
      debugPrint('Error toggling flash: $e');
      return flashMode;
    }
  }

  /// Switch between front and back camera
  ///
  /// Returns true if switch successful, false otherwise.
  Future<bool> flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      debugPrint('Cannot flip camera: only one camera available');
      return false;
    }

    try {
      // Switch to next camera (0 -> 1 or 1 -> 0)
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

      // Reinitialize with new camera
      final success = await _initializeCamera(_selectedCameraIndex);

      if (success) {
        debugPrint('Camera flipped successfully');
      }

      return success;
    } catch (e) {
      debugPrint('Error flipping camera: $e');
      return false;
    }
  }

  /// Take a photo
  ///
  /// Returns XFile containing the photo, or null if failed.
  /// The photo is saved to temporary storage and should be processed/deleted
  /// after use.
  Future<XFile?> takePicture() async {
    if (_controller == null || !_isInitialized) {
      debugPrint('Cannot take picture: camera not initialized');
      return null;
    }

    if (!_controller!.value.isInitialized) {
      debugPrint('Cannot take picture: camera controller not ready');
      return null;
    }

    try {
      // Take the picture
      final XFile photo = await _controller!.takePicture();
      debugPrint('Photo taken: ${photo.path}');
      return photo;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  /// Pause the camera (call when screen is not visible)
  ///
  /// This saves battery and resources when the camera screen is in background.
  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.pausePreview();
        debugPrint('Camera paused');
      } catch (e) {
        debugPrint('Error pausing camera: $e');
      }
    }
  }

  /// Resume the camera (call when screen becomes visible again)
  Future<void> resume() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.resumePreview();
        debugPrint('Camera resumed');
      } catch (e) {
        debugPrint('Error resuming camera: $e');
      }
    }
  }

  /// Dispose camera resources
  ///
  /// IMPORTANT: Always call this when done with the camera to free resources!
  /// Typically called in dispose() method of the screen using the camera.
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      debugPrint('Camera disposed');
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  /// Set exposure offset (brightness adjustment)
  ///
  /// Value range: typically -2.0 to +2.0
  /// Positive values make image brighter, negative values darker.
  Future<void> setExposureOffset(double offset) async {
    if (_controller == null || !_isInitialized) return;

    try {
      // Clamp offset to controller's min/max range
      final minExposure = await _controller!.getMinExposureOffset();
      final maxExposure = await _controller!.getMaxExposureOffset();
      final clampedOffset = offset.clamp(minExposure, maxExposure);

      await _controller!.setExposureOffset(clampedOffset);
      debugPrint('Exposure offset set to: $clampedOffset');
    } catch (e) {
      debugPrint('Error setting exposure offset: $e');
    }
  }

  /// Set zoom level
  ///
  /// Value range: 1.0 (no zoom) to maxZoomLevel
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_isInitialized) return;

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final clampedZoom = zoom.clamp(1.0, maxZoom);

      await _controller!.setZoomLevel(clampedZoom);
      debugPrint('Zoom level set to: $clampedZoom');
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }
}
