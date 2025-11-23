import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Overlay widget shown during OCR processing
///
/// Features:
/// - Animated loading indicator
/// - Progress text updates
/// - Estimated time remaining
/// - Cancel button
///
/// Typical processing time: 5-10 seconds
class ProcessingOverlay extends StatefulWidget {
  /// Callback when user taps cancel button
  final VoidCallback? onCancel;

  /// Current processing step (optional)
  final String? currentStep;

  const ProcessingOverlay({
    super.key,
    this.onCancel,
    this.currentStep,
  });

  @override
  State<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _elapsedSeconds = 0;

  // Processing steps with Vietnamese text
  static const List<String> _processingSteps = [
    'Đang xử lý ảnh...', // Processing image...
    'Nhận diện văn bản...', // Recognizing text...
    'Trích xuất thông tin...', // Extracting information...
    'Phân tích dữ liệu...', // Analyzing data...
  ];

  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation for smooth appearance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Update progress text every 2 seconds
    Future.delayed(const Duration(seconds: 2), _cycleSteps);

    // Track elapsed time for estimated time remaining
    Future.delayed(const Duration(seconds: 1), _incrementTime);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Cycle through processing steps to show progress
  void _cycleSteps() {
    if (!mounted) return;

    setState(() {
      _currentStepIndex = (_currentStepIndex + 1) % _processingSteps.length;
    });

    // Schedule next step update
    Future.delayed(const Duration(seconds: 2), _cycleSteps);
  }

  /// Increment elapsed time counter
  void _incrementTime() {
    if (!mounted) return;

    setState(() {
      _elapsedSeconds++;
    });

    // Schedule next increment
    Future.delayed(const Duration(seconds: 1), _incrementTime);
  }

  /// Calculate estimated time remaining
  String _getEstimatedTime() {
    // OCR typically takes 5-10 seconds
    // Show optimistic estimate to reduce anxiety
    if (_elapsedSeconds < 3) {
      return 'Khoảng 5 giây nữa...'; // About 5 more seconds...
    } else if (_elapsedSeconds < 6) {
      return 'Khoảng 3 giây nữa...'; // About 3 more seconds...
    } else {
      return 'Sắp xong...'; // Almost done...
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: colorScheme.surface.withValues(alpha: 0.95),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============================================
                // Animated Loading Indicator
                // ============================================
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ============================================
                // Main Title
                // ============================================
                Text(
                  'Đang xử lý hóa đơn',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================
                // Current Step Indicator
                // ============================================
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    widget.currentStep ?? _processingSteps[_currentStepIndex],
                    key: ValueKey<int>(_currentStepIndex),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // ============================================
                // Estimated Time Remaining
                // ============================================
                Text(
                  _getEstimatedTime(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 32),

                // ============================================
                // Progress Bar (indeterminate)
                // ============================================
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),

                const SizedBox(height: 32),

                // ============================================
                // Tip/Info Text
                // ============================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.lightbulb,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Đang xử lý trên thiết bị của bạn',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // Cancel Button
                // ============================================
                if (widget.onCancel != null)
                  TextButton.icon(
                    onPressed: widget.onCancel,
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      size: 20,
                    ),
                    label: const Text('Hủy'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple variant of ProcessingOverlay with just loading indicator
///
/// Use this for quick operations where detailed progress is not needed
class SimpleProcessingOverlay extends StatelessWidget {
  final String? message;

  const SimpleProcessingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
