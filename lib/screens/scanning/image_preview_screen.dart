import 'dart:io';
import 'dart:ui' as ui;
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

import '../../screens/add_expense_screen.dart';

/// Scanning state enum for managing the three distinct states
enum ScanningState {
  preview,    // Initial state: preview image with zoom
  processing, // Processing the receipt with Vision AI
  results,    // Showing parsed results for review/edit
}

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

  // Services
  late VisionParserService _visionParser;
  late ExpensePatternService _patternService;

  // State management
  ScanningState _currentState = ScanningState.preview;
  
  // Preview state variables
  bool _isAnalyzing = true;
  bool _isBlurry = false;
  bool _isTooSmall = false;
  ui.Image? _image;
  
  // Processing state variables
  String _processingStep = 'Analyzing image...';
  
  // Results state variables
  List<ScannedItem> _scannedItems = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false; // Track saving state

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _analyzeImageQuality();
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
    _transformationController.dispose();
    _image?.dispose();
    _patternService.dispose();
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
    return Scaffold(
      backgroundColor: _currentState == ScanningState.results 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.black,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Build dynamic AppBar based on current state
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    String title;
    List<Widget> actions = [];
    
    switch (_currentState) {
      case ScanningState.preview:
        title = 'Preview Image';
        actions = [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsOut),
            onPressed: _resetZoom,
            tooltip: 'Reset zoom',
          ),
        ];
        break;
      case ScanningState.processing:
        title = 'Processing...';
        break;
      case ScanningState.results:
        title = 'Review Items';
        break;
    }

    return AppBar(
      backgroundColor: _currentState == ScanningState.results 
          ? null 
          : Colors.black,
      foregroundColor: _currentState == ScanningState.results 
          ? null 
          : Colors.white,
      title: Text(title),
      leading: const SizedBox.shrink(), // No leading widget
      actions: [
        ...actions,
        IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => _handleClose(context),
          tooltip: 'Close',
        ),
      ],
    );
  }

  /// Handle close button - behavior depends on state
  void _handleClose(BuildContext context) {
    if (_currentState == ScanningState.results) {
      // Show confirmation dialog before closing
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Unsaved items will be lost. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close preview screen
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
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

  /// Build Preview State view
  Widget _buildPreviewState(BuildContext context) {
    return Column(
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
                    child: const Text('Retake'),
                  ),
                ),

                const SizedBox(width: 16),

                // Process button
                Expanded(
                  child: FilledButton(
                    onPressed: _processReceipt,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Process Receipt'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
  Widget _buildBottomActions(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
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

  // ========== WIDGET BUILDERS ==========

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
