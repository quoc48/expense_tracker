import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/scanning/vision_parser_service.dart';
import '../../services/learning/expense_pattern_service.dart';
import '../../models/scanning/scanned_item.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/sync_provider.dart';
import '../../repositories/supabase_expense_repository.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../theme/minimalist/minimalist_icons.dart';
import '../../widgets/common/tappable_icon.dart';
import '../../widgets/common/add_expense_sheet.dart';
import '../../widgets/common/select_date_sheet.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/success_overlay.dart';

/// Scanning state enum for managing the three distinct states
enum ScanningState {
  preview,    // Initial state: sheet-style image preview (Figma node-id=62-1863)
  processing, // Processing the receipt with Vision AI
  results,    // Showing parsed results for review/edit
}

/// Preview screen for captured/selected receipt image
///
/// **Design Reference**: Figma node-id=62-1863
///
/// **Preview State UI (Bottom Sheet)**:
/// - Modal bottom sheet overlaying camera screen
/// - White background with 24px top rounded corners
/// - Header: Back button ("< Camera") left, X close button right
/// - Image: Simple display with cover fit, 12px rounded corners
/// - Button: "Use this picture" - 48px height, black bg, white text
///
/// **Processing State**: Shows progress checklist during Vision AI processing
/// **Results State**: Displays parsed items for review and editing
///
/// **Usage**: Call [showImagePreviewSheet] instead of pushing this widget directly.
class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

/// Shows the image preview as a bottom sheet overlay.
///
/// **Design Reference**: Figma node-id=62-1863
///
/// Returns `true` if the user confirmed ("Use this picture") and processing started,
/// `false` if cancelled.
///
/// **Usage**:
/// ```dart
/// final result = await showImagePreviewSheet(
///   context: context,
///   imagePath: photo.path,
/// );
/// ```
Future<bool?> showImagePreviewSheet({
  required BuildContext context,
  required String imagePath,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true, // Allow sheet to take full height
    backgroundColor: Colors.transparent, // We'll handle bg in the widget
    isDismissible: false, // Don't dismiss on tap outside
    enableDrag: false, // Disable drag to dismiss
    builder: (context) => ImagePreviewScreen(imagePath: imagePath),
  );
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  // Services
  late VisionParserService _visionParser;
  late ExpensePatternService _patternService;

  // State management
  ScanningState _currentState = ScanningState.preview;

  // Preview state variables - simplified (no zoom/quality analysis)
  // The new sheet-style UI doesn't need quality warnings or zoom

  // Processing state variables
  String _processingStep = 'Analyzing image...';
  double _processingProgress = 0.0; // 0.0 to 1.0 for progress bar

  // Animation controller for scanning line effect
  late AnimationController _scanAnimationController;
  late Animation<double> _scanLinePosition;

  // Results state variables
  List<ScannedItem> _scannedItems = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false; // Track saving state

  // Tap state for "Use this picture" button
  bool _isUseButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
    // Note: Removed _analyzeImageQuality() - new sheet-style UI is simplified
  }

  /// Initialize scanning line animation
  ///
  /// **Animation Details**:
  /// - Duration: 1.5 seconds for one complete cycle
  /// - Direction: Top (0.0) to bottom (1.0) and back
  /// - Repeat: Continuous while processing state is active
  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Linear animation from 0.0 to 1.0
    _scanLinePosition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanAnimationController);
  }

  /// Initialize pattern learning and vision parser services
  Future<void> _initializeServices() async {
    // Initialize pattern service with repository
    final repository = SupabaseExpenseRepository();
    _patternService = ExpensePatternService(expenseRepository: repository);

    // Initialize pattern service and load patterns
    await _patternService.initialize();

    // Create vision parser with pattern service
    _visionParser = VisionParserService(patternService: _patternService);

    debugPrint('🧠 Pattern Learning: ${_patternService.patternModel != null ? "Loaded" : "No patterns"}');
    if (_patternService.patternModel != null) {
      debugPrint('  - Categories: ${_patternService.patternModel!.patterns.length}');
      debugPrint('  - Learned from: ${_patternService.patternModel!.totalExpenses} expenses');
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _patternService.dispose();
    super.dispose();
  }

  /// Process the receipt image with Vision AI
  ///
  /// **Progress Tracking**:
  /// - 0.0-0.15: Initial analysis setup
  /// - 0.15-0.85: Vision AI processing (main work)
  /// - 0.85-0.95: Categorizing items
  /// - 0.95-1.0: Finalizing and cleanup
  Future<void> _processReceipt() async {
    // Start animation and reset progress
    _scanAnimationController.repeat(reverse: true);

    setState(() {
      _currentState = ScanningState.processing;
      _processingStep = 'Analyzing image...';
      _processingProgress = 0.0;
    });

    try {
      debugPrint('📸 Starting receipt processing for: ${widget.imagePath}');
      final imageFile = File(widget.imagePath);

      // Check if Vision parser is configured
      if (!_visionParser.isConfigured) {
        _scanAnimationController.stop();
        throw Exception('Vision AI chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env');
      }

      // Step 1: Initial analysis (0% -> 15%)
      await _updateProgress(0.15, 'Analyzing image...');
      if (!mounted) return;

      // Step 2: Processing with Vision AI (15% -> 85%)
      setState(() {
        _processingStep = 'Extracting items...';
      });

      debugPrint('👁️ Processing receipt with Vision AI...');
      final startTime = DateTime.now();

      // Simulate incremental progress during API call
      // Real progress happens in background, we animate smoothly to 85%
      _animateProgressTo(0.85, const Duration(milliseconds: 3000));

      final scannedItems = await _visionParser.parseReceiptImage(imageFile);

      if (scannedItems.isEmpty) {
        _scanAnimationController.stop();
        throw Exception('Không tìm thấy mặt hàng nào trong hóa đơn');
      }

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('✅ Vision AI extracted ${scannedItems.length} items in ${processingTime}ms');

      // Step 3: Categorizing (85% -> 95%)
      if (!mounted) return;
      await _updateProgress(0.95, 'Categorizing items...');

      // Step 4: Complete (95% -> 100%)
      if (!mounted) return;
      await _updateProgress(1.0, 'Complete!');
      await Future.delayed(const Duration(milliseconds: 300));

      // Stop animation
      _scanAnimationController.stop();

      // CRITICAL - Delete temp image file (privacy)
      await _deleteTempImageFile(imageFile);

      // Transition to results state
      if (!mounted) return;
      setState(() {
        _scannedItems = scannedItems;
        _currentState = ScanningState.results;
      });

    } catch (e, stackTrace) {
      debugPrint('❌ Error processing receipt: $e');
      debugPrint('Stack trace: $stackTrace');

      _scanAnimationController.stop();

      if (mounted) {
        setState(() {
          _currentState = ScanningState.preview;
          _processingProgress = 0.0;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  /// Update progress with smooth animation
  Future<void> _updateProgress(double target, String step) async {
    if (!mounted) return;
    setState(() {
      _processingStep = step;
      _processingProgress = target;
    });
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Animate progress smoothly to target value over duration
  void _animateProgressTo(double target, Duration duration) {
    final startProgress = _processingProgress;
    final totalSteps = 20;
    final stepDuration = duration ~/ totalSteps;
    final increment = (target - startProgress) / totalSteps;

    int currentStep = 0;
    Future.doWhile(() async {
      if (!mounted || currentStep >= totalSteps) return false;

      await Future.delayed(Duration(milliseconds: stepDuration.inMilliseconds));
      if (!mounted) return false;

      currentStep++;
      setState(() {
        _processingProgress = startProgress + (increment * currentStep);
      });
      return currentStep < totalSteps;
    });
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
    // All states use bottom sheet style with adaptive background
    final backgroundColor = AppColors.getSurface(context);

    return Container(
      // Take most of the screen height, leaving space at top to show camera behind
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: _buildBody(context),
    );
  }

  /// Handle close button - cancels entire flow and returns to expense list
  ///
  /// For results state, shows confirmation dialog first.
  /// This is different from back button which only goes back to camera.
  void _handleClose(BuildContext context) {
    if (_currentState == ScanningState.results) {
      // Show confirmation dialog before closing
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.getSurface(dialogContext),
          title: Text(
            'Discard changes?',
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(dialogContext),
            ),
          ),
          content: Text(
            'Unsaved items will be lost. Are you sure?',
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.getTextSecondary(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(dialogContext),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Cancel entire flow - return to expense list
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Discard',
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Cancel entire flow - return to expense list
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Build body based on current state
  Widget _buildBody(BuildContext context) {
    switch (_currentState) {
      case ScanningState.preview:
        return _buildPreviewState(context);
      case ScanningState.processing:
        return _buildProcessingState(context);
      case ScanningState.results:
        return _buildResultsState(context);
    }
  }

  // ========== STATE VIEW BUILDERS ==========

  /// Build Preview State view with new sheet-style UI
  ///
  /// **Design Reference**: Figma node-id=62-1863
  ///
  /// **Layout**:
  /// - White background (set in Scaffold)
  /// - Header: Back button ("< Camera") left, X close right
  /// - Image: Cover fit, 12px rounded corners, flexible height
  /// - Button: "Use this picture" - 48px, black bg, white text, fixed at bottom
  ///
  /// **Spacing**: 16px horizontal, 16px top, 40px bottom edge
  Widget _buildPreviewState(BuildContext context) {
    return SafeArea(
      // Disable bottom SafeArea - we handle bottom spacing manually (40px)
      bottom: false,
      child: Column(
        children: [
          // Top content with horizontal padding
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: _buildPreviewHeader(context),
          ),

          const SizedBox(height: 24),

          // Image display (flexible height, cover fit)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPreviewImage(),
            ),
          ),

          // "Use this picture" button - fixed at bottom with 40px spacing
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 40),
            child: _buildUseThisPictureButton(),
          ),
        ],
      ),
    );
  }

  /// Build preview header with back and close buttons
  ///
  /// **Design Reference**: Figma node-id=62-1863
  /// - Back button: caret-left icon + "Camera" text
  /// - Close button: X icon with tap state feedback
  Widget _buildPreviewHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button: "< Camera"
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.caretLeft,
                size: 24,
                color: AppColors.getTextPrimary(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Camera',
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
        ),

        // Close button - closes sheet and returns to camera
        TappableIcon(
          icon: PhosphorIconsRegular.x,
          onTap: () => _handleClose(context),
          iconSize: 24,
          iconColor: AppColors.getTextPrimary(context),
          containerSize: 32,
          isCircular: true,
        ),
      ],
    );
  }

  /// Build image display with rounded corners
  ///
  /// **Design Reference**: Figma node-id=62-1863
  /// - Full width, flexible height
  /// - Cover fit (aspect ratio preserved, may crop)
  /// - 12px rounded corners
  Widget _buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context), // Adaptive background while loading
        ),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Build "Use this picture" button with tap state feedback
  ///
  /// **Design Reference**: Figma node-id=62-1863
  /// - Height: 48px
  /// - Background: Black (pressed: gray), inverted in dark mode
  /// - Text: White, 16px medium
  /// - Border radius: 12px
  Widget _buildUseThisPictureButton() {
    // Adaptive colors for dark mode (inverted like FAB)
    final bgColor = AppColors.isDarkMode(context)
        ? (_isUseButtonPressed ? AppColors.neutral300Dark : AppColors.white)
        : (_isUseButtonPressed ? AppColors.gray : AppColors.textBlack);
    final textColor = AppColors.isDarkMode(context) ? AppColors.black : AppColors.white;

    return GestureDetector(
      onTap: _handleUseThisPicture,
      onTapDown: (_) => setState(() => _isUseButtonPressed = true),
      onTapUp: (_) => setState(() => _isUseButtonPressed = false),
      onTapCancel: () => setState(() => _isUseButtonPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Use this picture',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Handle "Use this picture" button tap
  ///
  /// Adds a brief delay to show visual feedback before processing
  Future<void> _handleUseThisPicture() async {
    setState(() => _isUseButtonPressed = true);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _processReceipt();
    }
  }

  /// Build Processing State view with new sheet-style UI
  ///
  /// **Design Reference**: Figma node-id=62-2550
  ///
  /// **Layout**:
  /// - Same sheet style as preview (white bg, 24px rounded corners)
  /// - Header: "< Camera" back + X close (reuses preview header)
  /// - Image with pink/magenta scanning overlay effect
  /// - Animated scanning line moving top-to-bottom
  /// - Bottom: "Scanning ..." text + progress bar
  /// - 40px bottom padding
  Widget _buildProcessingState(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header - same as preview state
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: _buildPreviewHeader(context),
          ),

          const SizedBox(height: 24),

          // Image with scanning overlay effect
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildScanningImage(),
            ),
          ),

          // Bottom section: "Scanning ..." text + progress bar
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 40),
            child: _buildProcessingBottom(),
          ),
        ],
      ),
    );
  }

  /// Build image with scanning overlay effect
  ///
  /// **Design Reference**: Figma node-id=62-2550
  ///
  /// **Effect**:
  /// - Image displayed with cover fit
  /// - Green semi-transparent overlay (radar-style)
  /// - Animated scanning line moving top-to-bottom with glow
  Widget _buildScanningImage() {
    // Green color for radar-style scanning effect
    const scanColor = Color(0xFF4CAF50); // Material Green 500

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Base image
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
            ),
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),

          // Green radar-style scanning overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: scanColor.withValues(alpha: 0.12), // Green at 12% opacity
              ),
            ),
          ),

          // Animated scanning line
          AnimatedBuilder(
            animation: _scanAnimationController,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final linePosition = _scanLinePosition.value * constraints.maxHeight;
                    return Stack(
                      children: [
                        // Scanning line with glow effect
                        Positioned(
                          left: 0,
                          right: 0,
                          top: linePosition - 2,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  scanColor.withValues(alpha: 0.8),
                                  scanColor,
                                  scanColor.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.1, 0.5, 0.9, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scanColor.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build bottom section with step name and progress bar
  ///
  /// **Design Reference**: Figma node-id=62-2550
  ///
  /// **Updates**:
  /// - Shows current processing step name (e.g., "Analyzing image...")
  /// - Black progress bar instead of blue
  Widget _buildProcessingBottom() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Processing step name (dynamic)
        Text(
          _processingStep,
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextPrimary(context),
          ),
        ),

        const SizedBox(height: 16),

        // Progress bar (adaptive)
        // Dark mode: Use neutral300Dark (#1E1E1E) for better contrast against black bg
        // Light mode: Use neutral300 (#E0E0E0) for good visibility
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.getNeutral300(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _processingProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getTextPrimary(context), // Adaptive progress bar
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Results State view with new sheet-style UI
  ///
  /// **Design Reference**: Figma node-id=62-2616
  ///
  /// **Layout**:
  /// - Header: "Scan Results" + X close button
  /// - Summary row: Total | Date (tappable) | # Items
  /// - Item list: Category icon + Description/Date + Amount
  /// - Bottom: "+ New Item" + "Add Expenses" buttons
  Widget _buildResultsState(BuildContext context) {
    final total = _scannedItems.fold<double>(0.0, (sum, item) => sum + item.amount);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header: "Scan Results" + X close
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: _buildResultsHeader(context),
          ),

          const SizedBox(height: 16),

          // Summary row: Total | Date | # Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSummaryRow(context, total),
          ),

          const SizedBox(height: 16),

          // Items list (no top divider, dividers between items)
          Expanded(
            child: _scannedItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _scannedItems.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => _buildDismissibleItemRow(index),
                  ),
          ),

          // Bottom actions: "+ New Item" + "Add Expenses"
          _buildResultsBottomActions(context),
        ],
      ),
    );
  }

  /// Build Results header with "Scan Results" title and X close button
  ///
  /// **Design Reference**: Figma node-id=62-2616
  Widget _buildResultsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Spacer for symmetry (same width as close button)
        const SizedBox(width: 32),

        // Title - centered
        Text(
          'Scan Results',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),

        // Close button
        TappableIcon(
          icon: PhosphorIconsRegular.x,
          onTap: () => _handleClose(context),
          iconSize: 24,
          iconColor: AppColors.getTextPrimary(context),
          containerSize: 32,
          isCircular: true,
        ),
      ],
    );
  }

  /// Build summary row with Total, Date picker, and Items count
  ///
  /// **Design Reference**: Figma node-id=62-2616
  ///
  /// **Layout**: Three columns - Total (flex) | Date (flex) | # Items (fixed width)
  Widget _buildSummaryRow(BuildContext context, double total) {
    final textColor = AppColors.getTextPrimary(context);
    final secondaryColor = AppColors.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context), // Adaptive background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Total column (flexible)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(total),
                  style: AppTypography.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // Date column (tappable, flexible)
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDateSheet(context),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min, // Don't expand beyond content
                    children: [
                      Flexible(
                        child: Text(
                          _formatDateSlash(_selectedDate),
                          style: AppTypography.style(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIconsRegular.calendarDots,
                        size: 20,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Items count column (fixed width to prevent overflow)
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '# Items',
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_scannedItems.length}',
                  style: AppTypography.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build dismissible item row with swipe-to-delete
  ///
  /// **Design Reference**: Figma node-id=62-2616
  ///
  /// Wraps the item row in a Dismissible for swipe-left-to-delete functionality.
  /// Shows divider between items (not after last item).
  Widget _buildDismissibleItemRow(int index) {
    final isLastItem = index == _scannedItems.length - 1;

    return Dismissible(
      key: Key(_scannedItems[index].id),
      direction: DismissDirection.endToStart, // Swipe left only
      onDismissed: (_) => _removeItemSilent(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          PhosphorIconsRegular.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Column(
        children: [
          _buildItemRow(index),
          // Divider between items (not after last item)
          if (!isLastItem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(height: 1, thickness: 0.5),
            ),
        ],
      ),
    );
  }

  /// Build individual item row in the list
  ///
  /// **Design Reference**: Figma node-id=62-2616
  ///
  /// **Layout**: Category icon (colored bg) + Description/Date + Amount
  Widget _buildItemRow(int index) {
    final item = _scannedItems[index];
    final validCategory = _validateCategory(item.categoryNameVi);
    final categoryColor = MinimalistIcons.getCategoryColor(validCategory);

    return InkWell(
      onTap: () => _editItemSheet(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon with circular colored background (matches expense list)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  MinimalistIcons.getCategoryIconFill(validCategory),
                  size: 18,
                  color: categoryColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Description and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: AppTypography.style(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateFull(_selectedDate),
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              _formatAmount(item.amount),
              style: AppTypography.style(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remove item silently (no snackbar/undo)
  void _removeItemSilent(int index) {
    setState(() {
      _scannedItems.removeAt(index);
    });
  }

  /// Build empty state view
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsRegular.receipt,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: AppTypography.style(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adding items manually',
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom actions with "+ New Item" and "Add Expenses" buttons
  ///
  /// **Design Reference**: Figma node-id=62-2616
  ///
  /// Both buttons have equal width (1:1 ratio).
  /// - New Item: SecondaryButton (transparent, with plus icon)
  /// - Add Expenses: PrimaryButton (filled black)
  Widget _buildResultsBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      child: Row(
        children: [
          // "+ New Item" button (transparent, equal width)
          Expanded(
            child: SecondaryButton(
              label: 'New Item',
              icon: PhosphorIconsRegular.plus,
              onPressed: _addNewItemSheet,
            ),
          ),

          const SizedBox(width: 12),

          // "Add Expenses" button (filled black, equal width)
          Expanded(
            child: PrimaryButton(
              label: 'Add Expenses',
              isLoading: _isSaving,
              onPressed: (_scannedItems.isEmpty || _isSaving) ? null : _saveAllItems,
            ),
          ),
        ],
      ),
    );
  }

  /// Open date picker sheet (same as Add Expense)
  Future<void> _selectDateSheet(BuildContext context) async {
    final DateTime? picked = await showSelectDateSheet(
      context: context,
      selectedDate: _selectedDate,
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Edit item using Add Expense sheet with "Edit Item" title
  Future<void> _editItemSheet(int index) async {
    final item = _scannedItems[index];

    // Convert ScannedItem to Expense for editing
    final tempExpense = Expense(
      id: 'temp_$index',
      amount: item.amount,
      description: item.description,
      categoryNameVi: _validateCategory(item.categoryNameVi),
      typeNameVi: item.typeNameVi,
      date: _selectedDate,
    );

    // Open Add Expense sheet with "Edit Item" title
    final result = await showAddExpenseSheet(
      context: context,
      expense: tempExpense,
      customTitle: 'Edit Item',
      customButtonLabel: 'Update',
    );

    if (result != null && mounted) {
      setState(() {
        _scannedItems[index] = ScannedItem(
          id: item.id,
          description: result.description,
          amount: result.amount,
          categoryNameVi: result.categoryNameVi,
          typeNameVi: result.typeNameVi,
          confidence: 1.0, // Manual edits have full confidence
        );
        // Also update date if changed in the edit sheet
        _selectedDate = result.date;
      });
    }
  }

  /// Add new item using Add Expense sheet with "New Item" title
  Future<void> _addNewItemSheet() async {
    // Create empty expense with selected date
    final newExpense = Expense(
      id: '',
      amount: 0.0,
      description: '',
      categoryNameVi: 'Thực phẩm', // Safe default
      typeNameVi: 'Phải chi',
      date: _selectedDate,
    );

    // Open Add Expense sheet with "New Item" title
    final result = await showAddExpenseSheet(
      context: context,
      expense: newExpense,
      customTitle: 'New Item',
      customButtonLabel: 'Add',
    );

    if (result != null && mounted) {
      setState(() {
        _scannedItems.add(ScannedItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: result.description,
          amount: result.amount,
          categoryNameVi: result.categoryNameVi,
          typeNameVi: result.typeNameVi,
          confidence: 1.0, // Manual items have full confidence
        ));
      });
    }
  }

  /// Format date as DD/MM/YYYY (for summary row)
  String _formatDateSlash(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format date as "Mon DD, YYYY" (for item rows)
  String _formatDateFull(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  // ========== HELPER METHODS ==========

  /// Validate and map category to valid Supabase category
  /// 
  /// Vision AI may return categories that don't exist in Supabase.
  /// This maps them to the closest valid category or returns a safe fallback.
  String _validateCategory(String categoryNameVi) {
    // List of valid Supabase categories (14 categories from Notion migration)
    const validCategories = {
      'Biểu gia đình',
      'Cà phê', 
      'Du lịch',
      'Giáo dục',
      'Giải trí',
      'Hoá đơn',
      'Quà vật',
      'Sức khỏe',
      'TẾT',
      'Thời trang',
      'Thực phẩm',
      'Tiền nhà',
      'Tạp hoá',
      'Đi lại',
    };

    // If category is already valid, return it
    if (validCategories.contains(categoryNameVi)) {
      return categoryNameVi;
    }

    // Map Vision AI categories to valid Supabase categories
    final categoryMap = {
      'Gia dụng': 'Tạp hoá',        // Household goods → Groceries
      'Đồ uống': 'Cà phê',          // Beverages → Coffee
      'Ăn vặt': 'Thực phẩm',        // Snacks → Food
      'Thuế & Phí': 'Hoá đơn',      // Taxes & Fees → Bills
      'Mua sắm': 'Tạp hoá',         // Shopping → Groceries
    };

    // Try to map to valid category
    final mapped = categoryMap[categoryNameVi];
    if (mapped != null) {
      debugPrint('📝 Category mapped: "$categoryNameVi" → "$mapped"');
      return mapped;
    }

    // Fallback to safe default
    debugPrint('⚠️ Unknown category "$categoryNameVi", using fallback "Thực phẩm"');
    return 'Thực phẩm';
  }

  /// Save all items as expenses
  Future<void> _saveAllItems() async {
    if (_scannedItems.isEmpty || _isSaving) return;

    // Set loading state
    setState(() {
      _isSaving = true;
    });

    try {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);
      final itemCount = _scannedItems.length;
      final isOnline = syncProvider.isOnline;

      // Create expenses from scanned items
      for (final item in _scannedItems) {
        final expense = Expense(
          id: '', // Will be generated by Supabase
          amount: item.amount,
          description: item.description,
          categoryNameVi: _validateCategory(item.categoryNameVi), // Validate!
          typeNameVi: item.typeNameVi,
          date: _selectedDate,
        );

        await expenseProvider.addExpense(expense);
      }

      if (!mounted) return;

      // Build success message based on item count and online status
      final String successMessage;
      if (isOnline) {
        successMessage = itemCount == 1
            ? 'Expense added.'
            : '$itemCount expenses added.';
      } else {
        successMessage = itemCount == 1
            ? 'Expense queued.'
            : '$itemCount expenses queued.';
      }

      // Navigate back to expense list (popping all scanner screens)
      // This will go: ImagePreviewScreen -> CameraScreen -> ExpenseListScreen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show success overlay (matches manual expense flow)
      // ignore: use_build_context_synchronously
      await showSuccessOverlay(
        context: context,
        message: successMessage,
      );

    } catch (e) {
      if (!mounted) return;

      // Reset saving state on error
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(PhosphorIconsRegular.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

}
