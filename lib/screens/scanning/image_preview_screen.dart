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
import '../../widgets/expense_card.dart';
import '../../theme/colors/app_colors.dart';
import '../../theme/typography/app_typography.dart';
import '../../widgets/common/tappable_icon.dart';

import '../../screens/add_expense_screen.dart';

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

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  // Services
  late VisionParserService _visionParser;
  late ExpensePatternService _patternService;

  // State management
  ScanningState _currentState = ScanningState.preview;

  // Preview state variables - simplified (no zoom/quality analysis)
  // The new sheet-style UI doesn't need quality warnings or zoom

  // Processing state variables
  String _processingStep = 'Analyzing image...';

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
    // Note: Removed _analyzeImageQuality() - new sheet-style UI is simplified
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
    _patternService.dispose();
    super.dispose();
  }

  /// Process the receipt image with Vision AI
  Future<void> _processReceipt() async {
    setState(() {
      _currentState = ScanningState.processing;
      _processingStep = 'Analyzing image...';
    });

    try {
      debugPrint('📸 Starting receipt processing for: ${widget.imagePath}');
      final imageFile = File(widget.imagePath);

      // Check if Vision parser is configured
      if (!_visionParser.isConfigured) {
        throw Exception('Vision AI chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env');
      }

      // Step 1: Analyzing
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      setState(() {
        _processingStep = 'Extracting items...';
      });

      // Process image with Vision AI
      debugPrint('👁️ Processing receipt with Vision AI...');
      final startTime = DateTime.now();
      final scannedItems = await _visionParser.parseReceiptImage(imageFile);

      if (scannedItems.isEmpty) {
        throw Exception('Không tìm thấy mặt hàng nào trong hóa đơn');
      }

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('✅ Vision AI extracted ${scannedItems.length} items in ${processingTime}ms');

      // Step 2: Categorizing
      if (!mounted) return;
      setState(() {
        _processingStep = 'Categorizing items...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Complete
      if (!mounted) return;
      setState(() {
        _processingStep = 'Complete!';
      });
      await Future.delayed(const Duration(milliseconds: 300));

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

      if (mounted) {
        setState(() {
          _currentState = ScanningState.preview;
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
    // All states use bottom sheet style
    // Background color changes based on state
    final backgroundColor = switch (_currentState) {
      ScanningState.preview => Colors.white,
      ScanningState.processing => Colors.white,
      ScanningState.results => Colors.white,
    };

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
          title: const Text('Discard changes?'),
          content: const Text('Unsaved items will be lost. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Cancel entire flow - return to expense list
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Discard'),
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
                color: AppColors.textBlack,
              ),
              const SizedBox(width: 4),
              Text(
                'Camera',
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
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
          iconColor: AppColors.textBlack,
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
          color: AppColors.gray6, // Light gray background while loading
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
  /// - Background: Black (pressed: gray)
  /// - Text: White, 16px medium
  /// - Border radius: 12px
  Widget _buildUseThisPictureButton() {
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
          color: _isUseButtonPressed ? AppColors.gray : AppColors.textBlack,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Use this picture',
          style: AppTypography.style(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
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

  /// Build Processing State view with checklist progress
  Widget _buildProcessingState(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Processing Receipt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Progress steps
                _buildProcessingStep(
                  'Analyzing image...',
                  _processingStep == 'Analyzing image...',
                  _processingStep != 'Analyzing image...',
                ),
                const SizedBox(height: 16),
                _buildProcessingStep(
                  'Extracting items...',
                  _processingStep == 'Extracting items...',
                  _processingStep == 'Categorizing items...' || _processingStep == 'Complete!',
                ),
                const SizedBox(height: 16),
                _buildProcessingStep(
                  'Categorizing items...',
                  _processingStep == 'Categorizing items...',
                  _processingStep == 'Complete!',
                ),
                const SizedBox(height: 16),
                _buildProcessingStep(
                  'Complete!',
                  _processingStep == 'Complete!',
                  false,
                ),

                const SizedBox(height: 24),

                // Cancel button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentState = ScanningState.preview;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a processing step indicator
  Widget _buildProcessingStep(String label, bool isActive, bool isComplete) {
    return Row(
      children: [
        // Icon
        if (isComplete)
          Icon(PhosphorIconsRegular.checkCircle, color: Colors.green.shade600, size: 24)
        else if (isActive)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        else
          Icon(PhosphorIconsRegular.circle, color: Colors.grey.shade400, size: 24),

        const SizedBox(width: 12),

        // Label
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isComplete || isActive ? null : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  /// Build Results State view with scanned items
  Widget _buildResultsState(BuildContext context) {
    final total = _scannedItems.fold<double>(0.0, (sum, item) => sum + item.amount);

    return Column(
      children: [
        // Date summary section
        _buildDateSummary(context),

        // Items list
        Expanded(
          child: _scannedItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _scannedItems.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = _scannedItems[index];
                    
                    // Convert ScannedItem to temporary Expense for display
                    final tempExpense = Expense(
                      id: 'temp_$index',
                      amount: item.amount,
                      description: item.description,
                      categoryNameVi: _validateCategory(item.categoryNameVi), // Validate!
                      typeNameVi: item.typeNameVi,
                      date: _selectedDate,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExpenseCard(
                        expense: tempExpense,
                        showWarning: item.confidence < 0.8,
                        showDate: false,
                        enableSwipe: true,
                        onTap: () => _editItem(index),
                        onDismissed: () => _removeItem(index),
                      ),
                    );
                  },
                ),
        ),

        // Bottom summary and actions
        _buildBottomActions(context, total),
      ],
    );
  }

  /// Build date summary section
  Widget _buildDateSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.calendar,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Date',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectDate(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adding items manually',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom actions bar
  ///
  /// **Spacing**: 16px horizontal/top, 40px bottom (consistent with preview)
  Widget _buildBottomActions(BuildContext context, double total) {
    return Container(
      // 16px sides/top, 40px bottom - consistent spacing across all states
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${_scannedItems.length} items)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatAmount(total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Add manual item button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addManualItem,
                  icon: const Icon(PhosphorIconsRegular.plus),
                  label: const Text('Add Item'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Save all button
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: (_scannedItems.isEmpty || _isSaving) ? null : _saveAllItems,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(PhosphorIconsRegular.check),
                  label: Text(_isSaving ? 'Saving...' : 'Save All'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Select date for all items
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)), // Allow 2 years future
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Edit item at index
  Future<void> _editItem(int index) async {
    final item = _scannedItems[index];
    
    // Convert to Expense for editing
    final tempExpense = Expense(
      id: 'temp_$index',
      amount: item.amount,
      description: item.description,
      categoryNameVi: _validateCategory(item.categoryNameVi), // Validate!
      typeNameVi: item.typeNameVi,
      date: _selectedDate,
    );

    // Open edit screen with hidden date field
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          expense: tempExpense,
          hiddenFields: const {'date'}, // Hide date - controlled by summary
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _scannedItems[index] = ScannedItem(
          id: item.id, // Keep original ID
          description: result.description,
          amount: result.amount,
          categoryNameVi: result.categoryNameVi,
          typeNameVi: result.typeNameVi,
          confidence: 1.0, // Manual edits have full confidence
        );
      });
    }
  }

  /// Remove item at index
  void _removeItem(int index) {
    setState(() {
      _scannedItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  /// Add manual item
  Future<void> _addManualItem() async {
    final newExpense = Expense(
      id: '',
      amount: 0.0,
      description: '',
      categoryNameVi: 'Thực phẩm', // Safe default - exists in Supabase
      typeNameVi: 'Phải chi',
      date: _selectedDate,
    );

    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          expense: newExpense,
          hiddenFields: const {'date'}, // Hide date - controlled by summary
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _scannedItems.add(ScannedItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate new ID
          description: result.description,
          amount: result.amount,
          categoryNameVi: result.categoryNameVi,
          typeNameVi: result.typeNameVi,
          confidence: 1.0, // Manual items have full confidence
        ));
      });
    }
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

      // Navigate back to expense list (popping all scanner screens)
      // This will go: ImagePreviewScreen -> CameraScreen -> ExpenseListScreen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show success message based on online/offline state
      if (isOnline) {
        // ONLINE: Items saved directly to Supabase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIconsRegular.checkCircle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ Saved $itemCount item${itemCount > 1 ? 's' : ''}'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // OFFLINE: Items queued for later sync
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(PhosphorIconsRegular.package, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('📦 Queued $itemCount item${itemCount > 1 ? 's' : ''} (will sync when online)'),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }

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
