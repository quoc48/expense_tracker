import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';

/// A tappable icon button with visual feedback on press.
///
/// **Design Reference**: Provides consistent tap state feedback across the app.
///
/// **Features**:
/// - Light gray highlight on tap (opacity 0.1 black overlay)
/// - Configurable icon, size, and colors
/// - Optional circular background
/// - Smooth animation on press/release
///
/// **Usage**:
/// ```dart
/// TappableIcon(
///   icon: PhosphorIconsRegular.x,
///   onTap: () => Navigator.pop(context),
///   size: 24,
///   backgroundColor: Colors.white,
///   iconColor: Colors.black,
/// )
/// ```
class TappableIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;
  final double? containerSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? highlightColor;
  final EdgeInsets? padding;
  final bool isCircular;

  const TappableIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.iconSize = 24,
    this.containerSize,
    this.iconColor,
    this.backgroundColor,
    this.highlightColor,
    this.padding,
    this.isCircular = true,
  });

  @override
  State<TappableIcon> createState() => _TappableIconState();
}

class _TappableIconState extends State<TappableIcon> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.containerSize ?? (widget.iconSize + 16);
    // Use gray5 (#E5E5EA) for pressed state - visible and consistent with design system
    final pressedColor = widget.highlightColor ?? AppColors.gray5;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque, // Ensure taps register on transparent areas
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: containerSize,
        height: containerSize,
        padding: widget.padding ?? const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // When pressed, show gray5 (#E5E5EA) background circle
          color: _isPressed ? pressedColor : (widget.backgroundColor ?? Colors.transparent),
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}

/// A tappable circular button with icon, commonly used in camera controls.
///
/// **Design Reference**: Figma camera screen buttons (node-id=62-2489)
///
/// **Specs**:
/// - Container: 40x40 white circle
/// - Icon: 24px
/// - Tap state: Light gray overlay
///
/// **Usage**:
/// ```dart
/// TappableCircleButton(
///   icon: PhosphorIconsFill.image,
///   onTap: () => _pickFromGallery(),
/// )
/// ```
class TappableCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final Color? activeIconColor;
  final bool isActive;

  const TappableCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconSize = 24,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.activeIconColor,
    this.isActive = false,
  });

  @override
  State<TappableCircleButton> createState() => _TappableCircleButtonState();
}

class _TappableCircleButtonState extends State<TappableCircleButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.isActive
        ? (widget.activeIconColor ?? Colors.amber)
        : widget.iconColor;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withValues(alpha: 0.8)
              : widget.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: widget.iconSize,
          color: effectiveIconColor,
        ),
      ),
    );
  }
}

/// A tappable capture button with ring design for camera.
///
/// **Design Reference**: Figma capture button (node-id=62-2859)
///
/// **Specs**:
/// - Size: 66x66
/// - Outer ring: White border 3px
/// - Inner circle: White filled
/// - Tap state: Slightly dimmed
class TappableCaptureButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isCapturing;
  final double size;

  const TappableCaptureButton({
    super.key,
    this.onTap,
    this.isCapturing = false,
    this.size = 66,
  });

  @override
  State<TappableCaptureButton> createState() => _TappableCaptureButtonState();
}

class _TappableCaptureButtonState extends State<TappableCaptureButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isCapturing) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isCapturing;
    final innerColor = isDisabled
        ? Colors.white54
        : (_isPressed ? Colors.white70 : Colors.white);

    return GestureDetector(
      onTap: isDisabled ? null : widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isPressed ? Colors.white70 : Colors.white,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerColor,
            ),
          ),
        ),
      ),
    );
  }
}
