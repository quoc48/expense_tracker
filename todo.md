# Receipt Scanning Feature - TODO List

**Project**: Expense Tracker Flutter App
**Feature**: OCR-based Receipt Scanning
**Total Estimate**: 100-130 hours (4-5 weeks at 20-25 hours/week)
**Last Updated**: 2025-11-13

---

## Phase 1: Foundation (Week 1) - 8-12 hours

### 1.1 Dependencies Setup (2-3 hours)
- [ ] Add dependencies to pubspec.yaml
  - google_mlkit_text_recognition: ^0.13.0
  - camera: ^0.11.0
  - image_picker: ^1.1.0
  - image: ^4.2.0
  - hive: ^2.2.3
  - hive_flutter: ^1.1.0
  - connectivity_plus: ^6.0.0
  - path_provider: ^2.1.0
  - permission_handler: ^11.3.0
- [ ] Add dev dependencies
  - hive_generator: ^2.0.1
  - build_runner: ^2.4.0
- [ ] Run `flutter pub get`
- [ ] Test app still builds

**Dependencies**: None
**Success Criteria**: App builds without errors, all packages resolve

### 1.2 Permissions Configuration (2-3 hours)
- [ ] iOS: Update Info.plist with camera usage description
- [ ] iOS: Update Info.plist with photo library description
- [ ] Android: Update AndroidManifest.xml with camera permission
- [ ] Android: Update AndroidManifest.xml with storage permission
- [ ] Create permission_handler service wrapper
- [ ] Test permission flow on device

**Dependencies**: 1.1
**Success Criteria**: Permission prompts appear correctly, can grant/deny

### 1.3 Directory Structure (1 hour)
- [ ] Create lib/models/scanning/ directory
- [ ] Create lib/screens/scanning/ directory
- [ ] Create lib/widgets/scanning/ directory
- [ ] Create lib/services/scanning/ directory
- [ ] Create lib/utils/scanning/ directory
- [ ] Create lib/repositories/offline/ directory

**Dependencies**: None
**Success Criteria**: Clean project structure ready for implementation

### 1.4 Base Models (3-4 hours)
- [ ] Create ScannedReceipt model
  - id, scanDate, items, totalAmount, status
- [ ] Create ScannedItem model
  - description, amount, categoryNameVi, typeNameVi, confidence
- [ ] Create QueuedReceipt Hive model with @HiveType annotations
- [ ] Create QueuedItem Hive model with @HiveType annotations
- [ ] Run build_runner to generate .g.dart files
- [ ] Write unit tests for model serialization
- [ ] Initialize Hive in main.dart

**Dependencies**: 1.1
**Success Criteria**: Models compile, Hive boxes open, tests pass

### 1.5 Hive Setup (1-2 hours)
- [ ] Initialize Hive in main.dart
- [ ] Register QueuedReceipt adapter
- [ ] Register QueuedItem adapter
- [ ] Open receipt_queue box
- [ ] Test Hive persistence (write/read)

**Dependencies**: 1.4
**Success Criteria**: Can write to and read from Hive box

**Phase 1 Testing Checkpoint**:
- [ ] All dependencies installed
- [ ] Permissions work on iOS and Android
- [ ] Models serialize correctly
- [ ] Hive persistence works

---

## Phase 2: Camera & Image Capture (Week 1-2) - 12-16 hours

### 2.1 Camera Service (4-5 hours)
- [ ] Create CameraService class
- [ ] Initialize camera controller
- [ ] Handle camera lifecycle (resume/pause)
- [ ] Implement flash toggle
- [ ] Implement camera flip (front/back)
- [ ] Add error handling
- [ ] Write unit tests

**Dependencies**: 1.2
**Success Criteria**: Camera initializes correctly, controls work

### 2.2 CameraCaptureScreen UI (4-5 hours)
- [ ] Create CameraCaptureScreen stateful widget
- [ ] Implement full-screen camera preview
- [ ] Add AppBar with back and flash buttons
- [ ] Add bottom controls (Gallery, Capture, Flip)
- [ ] Add guidelines overlay for framing
- [ ] Implement capture button with animation
- [ ] Add haptic feedback on capture
- [ ] Handle permissions denied state

**Dependencies**: 2.1
**Success Criteria**: Can see camera preview, all controls functional

### 2.3 Image Picker Integration (2 hours)
- [ ] Integrate image_picker for gallery selection
- [ ] Add gallery button to CameraCaptureScreen
- [ ] Handle image selection
- [ ] Navigate to preview after selection

**Dependencies**: 2.2
**Success Criteria**: Can select images from gallery

### 2.4 ImagePreviewScreen (3-4 hours)
- [ ] Create ImagePreviewScreen widget
- [ ] Implement zoomable image view (pinch to zoom)
- [ ] Add Retake button (returns to camera)
- [ ] Add Process button (continues to OCR)
- [ ] Add quality warnings (blur detection, size check)
- [ ] Style with minimalist theme

**Dependencies**: 2.2, 2.3
**Success Criteria**: Can preview image, zoom works, navigation works

### 2.5 Image Processing Utility (2-3 hours)
- [ ] Create ImageProcessor class
- [ ] Implement image compression (max 1920x1920, 85% quality)
- [ ] Implement rotation correction (EXIF data)
- [ ] Implement blur detection
- [ ] Implement size validation
- [ ] Write unit tests

**Dependencies**: None
**Success Criteria**: Images compressed correctly, quality maintained

**Phase 2 Testing Checkpoint**:
- [ ] Can take photo with camera
- [ ] Can select photo from gallery
- [ ] Preview shows image correctly
- [ ] Zoom works smoothly
- [ ] Image compression works
- [ ] Test on iOS and Android devices

---

## Phase 3: OCR Integration (Week 2) - 16-20 hours

### 3.1 OCR Service (6-8 hours)
- [ ] Create OcrService class
- [ ] Integrate Google ML Kit TextRecognizer
- [ ] Implement extractText() method
- [ ] Handle Vietnamese language recognition
- [ ] Parse text blocks and lines
- [ ] Add error handling
- [ ] Add timeout handling (10 seconds max)
- [ ] Write unit tests with sample images

**Dependencies**: 1.1
**Success Criteria**: Can extract text from Vietnamese receipts

### 3.2 Receipt Parser (6-8 hours)
- [ ] Create ReceiptParser class
- [ ] Implement amount extraction (multiple formats: 50.000, 50,000, 50000)
- [ ] Implement item line parsing (description + amount pairs)
- [ ] Handle tabular formats
- [ ] Handle vertical list formats
- [ ] Identify total line (optional)
- [ ] Filter noise and headers/footers
- [ ] Write unit tests with various receipt formats

**Dependencies**: 3.1
**Success Criteria**: >70% accuracy on real receipts

### 3.3 Processing Overlay Widget (2-3 hours)
- [ ] Create ProcessingOverlay widget
- [ ] Add animated loading indicator
- [ ] Show progress text ("Extracting text...")
- [ ] Add estimated time remaining
- [ ] Implement cancel button
- [ ] Handle cancellation gracefully

**Dependencies**: None
**Success Criteria**: Shows progress during OCR, cancel works

### 3.4 OCR Integration Testing (2-3 hours)
- [ ] Collect 10 real Vietnamese receipts
- [ ] Test OCR on each receipt
- [ ] Measure accuracy (% items correct)
- [ ] Measure processing time
- [ ] Document failure patterns
- [ ] Refine parsing logic based on results

**Dependencies**: 3.1, 3.2
**Success Criteria**: 70%+ items extracted correctly, <10s processing

**Phase 3 Testing Checkpoint**:
- [ ] OCR extracts text from receipts
- [ ] Parser identifies items and amounts
- [ ] Processing time <10 seconds
- [ ] Error handling works
- [ ] Test with 10 different receipt formats

---

## Phase 4: Category Matching (Week 2-3) - 12-16 hours

### 4.1 Keyword Dictionary (4-5 hours)
- [ ] Create keyword_dictionaries.dart
- [ ] Build keyword lists for all 14 categories:
  - Cà phê (coffee, latte, trà sữa, etc.)
  - Thực phẩm (rau, thịt, gạo, etc.)
  - Ăn uống (nhà hàng, cơm, phở, etc.)
  - Du lịch (khách sạn, vé máy bay, etc.)
  - Đi lại (taxi, grab, xăng, etc.)
  - Hoá đơn (điện, nước, internet, etc.)
  - Mua sắm (quần áo, giày dép, etc.)
  - Giải trí (phim, game, karaoke, etc.)
  - Sức khỏe (bệnh viện, thuốc, etc.)
  - Giáo dục (học phí, sách, etc.)
  - Tạp hoá (circle k, family mart, etc.)
  - Thú cưng (chó, mèo, pet food, etc.)
  - TẾT (bánh chưng, lì xì, etc.)
  - Khác (fallback)
- [ ] Include variations and typos
- [ ] Test keyword coverage against real expenses

**Dependencies**: None
**Success Criteria**: Comprehensive keyword lists for all categories

### 4.2 Category Matching Service (4-5 hours)
- [ ] Create CategoryMatchingService class
- [ ] Implement matchCategory() method
- [ ] Use keyword dictionaries
- [ ] Handle Vietnamese text normalization (remove accents for fuzzy matching)
- [ ] Implement scoring algorithm (multiple keyword matches)
- [ ] Default to "Khác" when no match
- [ ] Write unit tests

**Dependencies**: 4.1
**Success Criteria**: >60% automatic matching accuracy

### 4.3 Keyword Matcher Utility (2-3 hours)
- [ ] Create KeywordMatcher class
- [ ] Implement fuzzy matching for typos
- [ ] Implement compound word handling
- [ ] Add confidence scoring (internal only)
- [ ] Write unit tests

**Dependencies**: 4.2
**Success Criteria**: Handles common typos and variations

### 4.4 Matching Accuracy Testing (2-3 hours)
- [ ] Export 100 random expenses from database
- [ ] Run category matching on descriptions
- [ ] Calculate accuracy percentage
- [ ] Identify common mismatches
- [ ] Refine keyword lists based on results
- [ ] Re-test until >60% accuracy

**Dependencies**: 4.2
**Success Criteria**: >60% matching accuracy on real data

**Phase 4 Testing Checkpoint**:
- [ ] Keyword dictionaries cover all categories
- [ ] Matching algorithm works
- [ ] Tested against 100 real expenses
- [ ] Accuracy >60%
- [ ] Edge cases handled (empty strings, numbers only, etc.)

---

## Phase 5: Review Screen (Week 3) - 16-20 hours

### 5.1 ScannedItemCard Widget (5-6 hours)
- [ ] Create ScannedItemCard widget
- [ ] Display mode: show icon, category, description, amount
- [ ] Edit mode: inline expansion with text fields
- [ ] Implement tap to toggle edit mode
- [ ] Add category dropdown picker
- [ ] Add type dropdown picker (Phải chi, Phát sinh, Lãng phí)
- [ ] Add Update/Cancel buttons in edit mode
- [ ] Implement swipe to delete
- [ ] Style with minimalist theme

**Dependencies**: None
**Success Criteria**: Card displays correctly, edit mode works

### 5.2 ReceiptReviewScreen Layout (4-5 hours)
- [ ] Create ReceiptReviewScreen stateful widget
- [ ] Add AppBar with "Review Receipt" title and "Save All" button
- [ ] Add summary header (item count, total amount)
- [ ] Implement ListView of ScannedItemCard widgets
- [ ] Add empty state (no items)
- [ ] Add FAB for adding missed items
- [ ] Handle keyboard appearance (scroll to focused field)

**Dependencies**: 5.1
**Success Criteria**: Screen layout complete, scrolling works

### 5.3 Add Missed Item Dialog (3-4 hours)
- [ ] Create AddMissedItemDialog widget
- [ ] Add form fields: description, amount, category, type
- [ ] Validate inputs
- [ ] Return new ScannedItem on save
- [ ] Add to review list
- [ ] Style consistently

**Dependencies**: 5.2
**Success Criteria**: Can manually add items to review list

### 5.4 Batch Save Logic (4-5 hours)
- [ ] Implement validateAllItems() method
- [ ] Create expenses from ScannedItems
- [ ] Use ExpenseProvider to batch create
- [ ] Handle partial failures (some succeed, some fail)
- [ ] Show progress indicator during save
- [ ] Show success message with count
- [ ] Show error message if failures
- [ ] Navigate back to expense list on success

**Dependencies**: 5.2
**Success Criteria**: Can save all items as expenses, errors handled

**Phase 5 Testing Checkpoint**:
- [ ] Review screen displays 1, 5, 10, 20 items correctly
- [ ] Can edit item inline
- [ ] Can change category and type
- [ ] Can delete items
- [ ] Can add missed items
- [ ] Batch save creates all expenses
- [ ] Partial failures handled gracefully
- [ ] UI remains responsive during save

---

## Phase 6: Offline Queue (Week 3-4) - 16-20 hours

### 6.1 Offline Queue Repository (4-5 hours)
- [ ] Create OfflineQueueRepository class
- [ ] Implement CRUD operations for Hive box
  - addToQueue(QueuedReceipt)
  - getAll()
  - getById(String id)
  - getPending()
  - updateStatus(String id, QueueStatus status)
  - incrementRetry(String id)
  - delete(String id)
- [ ] Write unit tests

**Dependencies**: 1.4, 1.5
**Success Criteria**: Can manage queue via repository

### 6.2 Connectivity Service (2-3 hours)
- [ ] Create ConnectivityService class
- [ ] Implement isOnline() check
- [ ] Implement listenToConnectivity() stream
- [ ] Handle connectivity changes
- [ ] Write unit tests

**Dependencies**: 1.1
**Success Criteria**: Accurately detects online/offline state

### 6.3 Offline Queue Service (6-8 hours)
- [ ] Create OfflineQueueService class
- [ ] Implement queueReceipt(ScannedReceipt) method
- [ ] Implement processQueue() method
- [ ] Implement retry logic with exponential backoff
- [ ] Implement max retry limit (5 attempts)
- [ ] Listen to connectivity changes → auto-process
- [ ] Handle transient vs permanent errors
- [ ] Add logging for debugging
- [ ] Write unit tests

**Dependencies**: 6.1, 6.2
**Success Criteria**: Queue processes automatically, retries work

### 6.4 Offline Queue Indicator Widget (3-4 hours)
- [ ] Create OfflineQueueIndicator widget
- [ ] Show banner at top of ExpenseListScreen
- [ ] Display pending count
- [ ] Show "Retry Now" button
- [ ] Implement manual retry on button tap
- [ ] Color-code by severity (info/warning/error)
- [ ] Auto-hide when queue empty
- [ ] Style with minimalist theme

**Dependencies**: 6.3
**Success Criteria**: Indicator shows queue status, retry button works

**Phase 6 Testing Checkpoint**:
- [ ] Queue 5 receipts while offline
- [ ] Verify queue persists across app restarts
- [ ] Turn on connectivity → verify auto-sync
- [ ] Simulate network errors → verify retries
- [ ] Test exponential backoff delays
- [ ] Test max retry limit (5)
- [ ] Manual retry button works
- [ ] Indicator shows correct status

---

## Phase 7: FAB Integration (Week 4) - 4-6 hours

### 7.1 Add Expense Bottom Sheet (2-3 hours)
- [ ] Create AddExpenseBottomSheet widget
- [ ] Add "Add Manual" option with icon and description
- [ ] Add "Scan Receipt" option with icon and description
- [ ] Implement navigation callbacks
- [ ] Style with minimalist theme
- [ ] Add animations

**Dependencies**: None
**Success Criteria**: Bottom sheet looks good, options clear

### 7.2 Modify FAB Behavior (1-2 hours)
- [ ] Update ExpenseListScreen FAB onPressed
- [ ] Show AddExpenseBottomSheet on tap
- [ ] Wire "Add Manual" → navigate to AddExpenseScreen
- [ ] Wire "Scan Receipt" → navigate to CameraCaptureScreen
- [ ] Test navigation flow

**Dependencies**: 7.1, Phase 2, Phase 5
**Success Criteria**: FAB shows 2 options, both navigations work

### 7.3 Integration Testing (1 hour)
- [ ] Test complete manual entry flow (unchanged)
- [ ] Test complete scan flow (end-to-end)
- [ ] Verify back navigation works correctly
- [ ] Test on iOS and Android

**Dependencies**: 7.2
**Success Criteria**: Both flows work without issues

**Phase 7 Testing Checkpoint**:
- [ ] FAB shows bottom sheet with 2 options
- [ ] "Add Manual" navigates to existing screen
- [ ] "Scan Receipt" starts camera flow
- [ ] Can cancel bottom sheet
- [ ] Existing manual flow unchanged

---

## Phase 8: Testing & Polish (Week 4-5) - 16-20 hours

### 8.1 End-to-End Testing (6-8 hours)
- [ ] Test complete scan workflow (10 items):
  - Open app → Tap FAB → Scan Receipt
  - Capture photo → Preview → Process
  - Review → Edit 2 items → Add 1 item → Delete 1 item
  - Save All → Verify expenses created
- [ ] Test offline queue workflow:
  - Turn off WiFi/data
  - Scan receipt → Save (goes to queue)
  - Turn on connectivity → Verify auto-sync
- [ ] Test error scenarios:
  - Camera permission denied
  - Network error during save
  - Invalid image (blur, too small)
  - OCR timeout
- [ ] Test edge cases:
  - 1 item receipt
  - 50+ item receipt
  - Receipt with no amounts
  - Non-receipt image

**Dependencies**: All previous phases
**Success Criteria**: All workflows complete successfully, errors handled

### 8.2 Performance Optimization (3-4 hours)
- [ ] Measure OCR processing time (target <10s)
- [ ] Optimize image compression settings
- [ ] Profile memory usage during OCR
- [ ] Ensure 60fps during UI interactions
- [ ] Test on low-end Android device
- [ ] Optimize if needed

**Dependencies**: Phase 3
**Success Criteria**: Performance targets met

### 8.3 Error Handling & Messages (2-3 hours)
- [ ] Review all error messages (use Vietnamese)
- [ ] Add user-friendly error explanations
- [ ] Implement recovery flows
- [ ] Add retry options where appropriate
- [ ] Test all error paths

**Dependencies**: All phases
**Success Criteria**: Errors clearly communicated, recoverable

### 8.4 UI Polish (3-4 hours)
- [ ] Add loading states to all async operations
- [ ] Add subtle animations (card entrance, button press)
- [ ] Add haptic feedback (capture, delete, save)
- [ ] Ensure consistent spacing and typography
- [ ] Test light and dark modes
- [ ] Final visual review

**Dependencies**: All phases
**Success Criteria**: UI feels polished and responsive

### 8.5 Documentation (2-3 hours)
- [ ] Write user guide (how to use scanning feature)
- [ ] Document technical architecture
- [ ] Update main README.md
- [ ] Add code comments where needed
- [ ] Create troubleshooting guide

**Dependencies**: All phases
**Success Criteria**: Documentation complete and clear

**Phase 8 Testing Checkpoint**:
- [ ] All test cases pass
- [ ] Performance targets met (<10s OCR, 60fps UI)
- [ ] Error handling comprehensive
- [ ] UI polished and smooth
- [ ] Tested on multiple devices (iOS/Android)
- [ ] Documentation complete
- [ ] Ready for production use

---

## Final Acceptance Criteria

### Functional
- [ ] Can capture receipt photo or select from gallery
- [ ] OCR extracts items and amounts (>70% accuracy)
- [ ] Categories auto-matched (>60% accuracy)
- [ ] Can review and edit all items
- [ ] Can add/delete items
- [ ] Batch save creates all expenses
- [ ] Works offline with queue

### Non-Functional
- [ ] OCR processing <10 seconds
- [ ] UI maintains 60fps
- [ ] No crashes or data loss
- [ ] Offline queue persists across restarts
- [ ] Zero data loss during offline periods
- [ ] Privacy maintained (images not stored)

### Quality
- [ ] Code follows project conventions
- [ ] All tests passing
- [ ] Error handling comprehensive
- [ ] User-facing messages in Vietnamese
- [ ] Consistent with existing UI theme

---

## Notes

**Time Estimates**:
- Total: 100-130 hours
- Per phase: 4-20 hours
- Assumes 20-25 hours/week availability

**Dependencies**:
- Phases 1-3 must be sequential
- Phases 4-5 can overlap slightly
- Phase 6 can start after Phase 1
- Phase 7 requires Phases 2 and 5
- Phase 8 requires all phases

**Testing Strategy**:
- Checkpoint after each phase
- Continuous integration testing
- Manual device testing throughout
- Final acceptance testing in Phase 8

**Risk Management**:
- If OCR accuracy <70%, refine parser (add 4-6 hours)
- If category matching <60%, expand keywords (add 2-4 hours)
- If performance issues, optimize processing (add 4-6 hours)
- Buffer time included in estimates for unexpected issues