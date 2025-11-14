import 'package:permission_handler/permission_handler.dart';

/// Service for managing camera and photo library permissions
///
/// This service wraps the permission_handler package to provide
/// a clean interface for requesting and checking permissions needed
/// for the receipt scanning feature.
class PermissionService {
  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  Future<bool> hasPhotoLibraryPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Request camera permission
  ///
  /// Returns true if permission is granted, false otherwise.
  /// If permission is permanently denied, returns false and the user
  /// must manually enable it in settings.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Check if permission is permanently denied
  ///
  /// If true, we should show a dialog explaining that the user
  /// needs to go to app settings to enable the permission.
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  ///
  /// Opens the system settings page for this app, where the user
  /// can manually enable permissions.
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Request all permissions needed for receipt scanning
  ///
  /// This is a convenience method that requests both camera and
  /// photo library permissions at once.
  ///
  /// Returns a map with the permission status for each permission:
  /// - 'camera': true/false
  /// - 'photos': true/false
  Future<Map<String, bool>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    return {
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'photos': statuses[Permission.photos]?.isGranted ?? false,
    };
  }

  /// Check if all permissions are granted
  Future<bool> hasAllPermissions() async {
    final camera = await hasCameraPermission();
    final photos = await hasPhotoLibraryPermission();
    return camera && photos;
  }
}
