# Receipt Scanning Feature - Implementation Plan

**Project**: Expense Tracker Flutter App  
**Feature**: OCR-based Receipt Scanning with Batch Expense Creation  
**Version**: 1.0 MVP  
**Last Updated**: 2025-11-13

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Feature Requirements](#feature-requirements)
3. [Technical Architecture](#technical-architecture)
4. [UI/UX Flow](#uiux-flow)
5. [Database Schema Changes](#database-schema-changes)
6. [Implementation Phases](#implementation-phases)
7. [Offline Queue Design](#offline-queue-design)
8. [Testing Strategy](#testing-strategy)
9. [Risk Mitigation](#risk-mitigation)
10. [Success Metrics](#success-metrics)

---

## Executive Summary

### Problem Statement
Users with receipts containing 10+ items face tedious manual entry. Current workflow requires:
- 10+ individual expense entries
- Repeated category/type selection
- High chance of errors and omissions

### Solution
MVP receipt scanning feature using:
- **OCR**: Google ML Kit for text extraction
- **Keyword Matching**: Rule-based category assignment (no LLM)
- **Batch Creation**: Single review screen for all items
- **Offline Queue**: Reliable sync when connection returns

### Core Principle
**Simple Review > Complex Automation**
- No confidence scores shown to users
- Clean UI focused on quick review and adjustment
- User review is the validation mechanism

### Key Constraints
- **Data**: 912 existing expenses across 14 Vietnamese categories
- **Backend**: Supabase with existing RLS policies
- **Offline**: Must work without connectivity
- **No LLM**: Keep costs/complexity minimal for MVP

---

## Feature Requirements

### Functional Requirements

#### FR1: Receipt Capture
- Camera integration for taking receipt photos
- Gallery selection for existing photos
- Image quality validation (blur detection, size limits)
- Preview before processing

#### FR2: OCR Processing
- Vietnamese text recognition
- Extract item descriptions and amounts
- Handle common receipt formats (vertical lists, tabular)
- Robust number parsing (50.000, 50,000, 50000)

#### FR3: Category Assignment
- Keyword-based matching using 14 existing categories:
  - Thực phẩm, Du lịch, Cà phê, Tạp hoá, Ăn uống
  - Sức khỏe, Giáo dục, Đi lại, Hoá đơn, Mua sắm
  - Giải trí, Thú cưng, TẾT, Khác
- Default to "Khác" when no match found
- Allow manual override during review

#### FR4: Review Screen
- List all extracted items
- Edit description, amount, category, type
- Delete incorrect items
- Add missed items
- Select expense type (Phải chi, Phát sinh, Lãng phí)
- Batch save all items

#### FR5: Offline Queue
- Queue scanned receipts when offline
- Auto-process queue when connectivity returns
- Visual indicators for pending items
- Retry failed uploads

### Non-Functional Requirements

#### NFR1: Performance
- OCR processing < 10 seconds for typical receipts
- Smooth UI during processing (loading states)
- Efficient image compression before processing

#### NFR2: Reliability
- Handle network failures gracefully
- No data loss during offline periods
- Automatic retry with exponential backoff

#### NFR3: Usability
- Simple, intuitive UI
- Clear feedback for all actions
- Minimal taps to complete workflow
- Error messages in Vietnamese

#### NFR4: Privacy
- Process images locally (no external APIs)
- Delete images after processing
- No persistent image storage

---

## Technical Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface Layer                    │
├─────────────────────────────────────────────────────────────┤
│  MainNavigationScreen (FAB with 2 options)                  │
│    ├─ "Add Manual" → AddExpenseScreen (existing)           │
│    └─ "Scan Receipt" → CameraCaptureScreen (NEW)           │
│                            ↓                                 │
│         ImagePreviewScreen (NEW)                            │
│                            ↓                                 │
│         ProcessingOverlay (NEW)                             │
│                            ↓                                 │
│         ReceiptReviewScreen (NEW)                           │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  ReceiptScannerProvider (State Management)                  │
│    ├─ Manages scan workflow state                          │
│    ├─ Coordinates services                                 │
│    └─ Handles offline queue                                │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
├─────────────────────────────────────────────────────────────┤
│  OcrService              CategoryMatchingService            │
│  ├─ ML Kit integration   ├─ Keyword dictionary             │
│  ├─ Text extraction      ├─ Pattern matching               │
│  └─ Image preprocessing  └─ Fallback logic                 │
│                                                              │
│  OfflineQueueService                                        │
│  ├─ Queue management (Hive)                                │
│  ├─ Connectivity detection                                 │
│  └─ Retry logic with exponential backoff                   │
└─────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  Models:                                                     │
│  ├─ ScannedReceipt (contains list of ScannedItem)          │
│  ├─ ScannedItem (description, amount, category)            │
│  └─ QueuedReceipt (for offline storage)                    │
│                                                              │
│  Storage:                                                    │
│  ├─ Hive (offline queue persistence)                       │
│  └─ Supabase (final expense storage)                       │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

#### New Dependencies
```yaml
dependencies:
  # OCR
  google_mlkit_text_recognition: ^0.13.0  # Vietnamese text support
  
  # Camera
  camera: ^0.11.0
  image_picker: ^1.1.0
  
  # Image Processing
  image: ^4.2.0  # Compression, rotation, quality
  
  # Offline Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Connectivity
  connectivity_plus: ^6.0.0
  
  # Utilities
  path_provider: ^2.1.0  # Temporary file storage
  permission_handler: ^11.3.0  # Camera permissions

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

### Directory Structure

```
lib/
├── models/
│   ├── expense.dart (existing)
│   ├── scanned_receipt.dart (NEW)
│   ├── scanned_item.dart (NEW)
│   └── queued_receipt.dart (NEW - Hive model)
│
├── screens/
│   ├── camera_capture_screen.dart (NEW)
│   ├── image_preview_screen.dart (NEW)
│   └── receipt_review_screen.dart (NEW)
│
├── widgets/
│   ├── scanning/
│   │   ├── camera_controls.dart (NEW)
│   │   ├── processing_overlay.dart (NEW)
│   │   ├── scanned_item_card.dart (NEW)
│   │   └── offline_queue_indicator.dart (NEW)
│
├── providers/
│   ├── expense_provider.dart (existing)
│   └── receipt_scanner_provider.dart (NEW)
│
├── services/
│   ├── ocr_service.dart (NEW)
│   ├── category_matching_service.dart (NEW)
│   └── offline_queue_service.dart (NEW)
│
├── utils/
│   ├── image_processor.dart (NEW)
│   ├── receipt_parser.dart (NEW)
│   └── keyword_matcher.dart (NEW)
│
└── repositories/
    └── offline_queue_repository.dart (NEW)
```

---

## UI/UX Flow

### Overview
Simple, linear flow with clear progression:
1. Tap FAB → Choose "Scan Receipt"
2. Take photo or select from gallery
3. Preview and confirm
4. Processing overlay (5-10 seconds)
5. Review extracted items
6. Save batch

### Detailed Screen Flows

#### 1. FAB Interaction (Modified)

**Location**: `MainNavigationScreen` / `ExpenseListScreen`

**Before** (existing):
```
[+] FAB → Opens AddExpenseScreen directly
```

**After** (modified):
```
[+] FAB → Shows 2 options:
  ├─ "Add Manual" (existing flow)
  └─ "Scan Receipt" (new flow)
```

**Implementation**:
```dart
// Show speed dial or bottom sheet with 2 options
FloatingActionButton(
  onPressed: () => _showAddExpenseOptions(context),
  child: Icon(PhosphorIconsRegular.plus),
)

void _showAddExpenseOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => AddExpenseBottomSheet(
      onManualAdd: () => _openManualEntry(context),
      onScanReceipt: () => _openReceiptScanner(context),
    ),
  );
}
```

**Visual Design**:
```
┌─────────────────────────────────────┐
│  Add Expense                        │
├─────────────────────────────────────┤
│                                     │
│  📝  Add Manual                     │
│      Enter expense details         │
│                                     │
│  📷  Scan Receipt                   │
│      Extract from photo            │
│                                     │
└─────────────────────────────────────┘
```

#### 2. Camera Capture Screen

**Purpose**: Capture receipt photo with preview

**Features**:
- Full-screen camera preview
- Flash toggle
- Gallery picker option
- Guidelines overlay (receipt framing)
- Capture button with haptic feedback

**UI Elements**:
```
┌─────────────────────────────────────┐
│  ← Back               Flash [⚡]    │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│                                     │
│         Camera Preview              │
│                                     │
│      [---- Guidelines ----]         │ ← Visual guide
│                                     │
│                                     │
├─────────────────────────────────────┤
│  [Gallery]  [⚪ Capture]  [Flip]   │ ← Controls
└─────────────────────────────────────┘
```

**File**: `lib/screens/camera_capture_screen.dart`

#### 3. Image Preview Screen

**Purpose**: Confirm image quality before processing

**Features**:
- Zoomable image preview
- Retake option
- Process button
- Quality warnings (blur, too small, etc.)

**UI Elements**:
```
┌─────────────────────────────────────┐
│  Preview Receipt            [✕]     │
├─────────────────────────────────────┤
│                                     │
│                                     │
│      [Receipt Image Preview]        │
│      Pinch to zoom                  │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ⚠️ Tip: Make sure text is clear   │
├─────────────────────────────────────┤
│  [Retake]         [Process Receipt] │
└─────────────────────────────────────┘
```

**File**: `lib/screens/image_preview_screen.dart`

#### 4. Processing Overlay

**Purpose**: Show progress during OCR processing

**Features**:
- Animated loading indicator
- Progress steps (if applicable)
- Cancel option
- Estimated time remaining

**UI Elements**:
```
┌─────────────────────────────────────┐
│                                     │
│          🔍                         │
│     Processing Receipt...           │
│                                     │
│  [████████░░] 80%                   │
│                                     │
│  Extracting text from image...      │
│  Estimated time: 3 seconds          │
│                                     │
│         [Cancel]                    │
│                                     │
└─────────────────────────────────────┘
```

**Widget**: `lib/widgets/scanning/processing_overlay.dart`

#### 5. Receipt Review Screen (PRIMARY NEW SCREEN)

**Purpose**: Review and edit extracted items before batch save

**Key Decisions**:
- ✅ **NO confidence scores** - users review everything anyway
- ✅ **Simple card UI** - focus on quick edits
- ✅ **Edit in place** - no separate edit screens
- ✅ **Delete with swipe** - familiar gesture
- ✅ **Add missed items** - floating action button

**UI Layout**:
```
┌─────────────────────────────────────┐
│  Review Receipt          [Save All] │ ← AppBar
├─────────────────────────────────────┤
│  📋 5 items • Total: 285,000đ       │ ← Summary
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🍕 Thực phẩm         50,000đ  │ │ ← Item card
│  │ Bánh mì Việt Nam              │ │
│  │ Type: Phải chi          [✏️]  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ ☕ Cà phê            35,000đ  │ │
│  │ Cà phê sữa đá                 │ │
│  │ Type: Phải chi          [✏️]  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ... (more items) ...              │
│                                     │
├─────────────────────────────────────┤
│         [+ Add Missed Item]         │ ← FAB
└─────────────────────────────────────┘
```

**Interaction Flow**:
1. **Tap item card** → Open inline edit mode
2. **Swipe left** → Delete item
3. **Tap category icon** → Open category picker
4. **Tap amount** → Edit amount
5. **Tap description** → Edit text
6. **Tap "Save All"** → Batch create expenses

**Edit Mode** (inline expansion):
```
┌───────────────────────────────────┐
│ Description: [Bánh mì Việt Nam ]  │ ← Text field
│ Amount: [50,000           ]       │ ← Number field
│ Category: [Thực phẩm     ▼]      │ ← Dropdown
│ Type: [Phải chi          ▼]      │ ← Dropdown
│                                   │
│ [Cancel]            [Update]      │
└───────────────────────────────────┘
```

**File**: `lib/screens/receipt_review_screen.dart`

#### 6. Offline Queue Indicator

**Purpose**: Show pending items waiting for sync

**Location**: Top of `ExpenseListScreen` (banner)

**UI Elements**:
```
┌─────────────────────────────────────┐
│  ⏳ 2 receipts waiting to sync      │
│  Will upload when online            │
│              [Retry Now]            │
└─────────────────────────────────────┘
```

**States**:
- **Hidden**: No items in queue
- **Warning**: Items pending < 24 hours
- **Error**: Items pending > 24 hours or failed

**Widget**: `lib/widgets/scanning/offline_queue_indicator.dart`

### Navigation Flow Diagram

```
MainNavigationScreen
    │
    ├─ FAB Tap
    │   └─ BottomSheet: [Add Manual | Scan Receipt]
    │       │
    │       ├─ Add Manual → AddExpenseScreen (existing)
    │       │
    │       └─ Scan Receipt → CameraCaptureScreen
    │                           │
    │                           ├─ Capture Photo
    │                           │   └─ ImagePreviewScreen
    │                           │       │
    │                           │       ├─ Retake → Back to camera
    │                           │       │
    │                           │       └─ Process → ProcessingOverlay
    │                           │                      │
    │                           │                      └─ ReceiptReviewScreen
    │                           │                          │
    │                           │                          ├─ Edit Items
    │                           │                          ├─ Add/Delete Items
    │                           │                          │
    │                           │                          └─ Save All
    │                           │                              │
    │                           │                              ├─ Online → Supabase
    │                           │                              └─ Offline → Queue
    │                           │
    │                           └─ Gallery Picker
    │                               └─ (same flow as captured)
    │
    └─ Offline Queue Indicator
        └─ Retry Now → Process queued items
```

---

## Database Schema Changes

### New Tables

#### 1. `receipt_scans` (Optional - for audit trail)

**Purpose**: Track receipt scanning history

```sql
CREATE TABLE IF NOT EXISTS receipt_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Scan metadata
  scan_date TIMESTAMPTZ NOT NULL DEFAULT now(),
  item_count INTEGER NOT NULL DEFAULT 0,
  total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
  
  -- Processing info
  processing_time_ms INTEGER,  -- OCR duration
  success BOOLEAN NOT NULL DEFAULT true,
  error_message TEXT,
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_receipt_scans_user_date ON receipt_scans(user_id, scan_date DESC);

-- RLS
ALTER TABLE receipt_scans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own receipt scans"
  ON receipt_scans FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own receipt scans"
  ON receipt_scans FOR INSERT
  WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE receipt_scans IS 'Audit trail for receipt scanning operations';
```

### Modified Tables

#### `expenses` Table
**No changes needed** - existing schema already supports batch creation via repository methods.

### Hive Models (Local Offline Storage)

#### QueuedReceipt Model

```dart
import 'package:hive/hive.dart';

part 'queued_receipt.g.dart';

@HiveType(typeId: 0)
class QueuedReceipt extends HiveObject {
  @HiveField(0)
  String id;  // UUID for tracking
  
  @HiveField(1)
  DateTime queuedAt;
  
  @HiveField(2)
  List<QueuedItem> items;
  
  @HiveField(3)
  int retryCount;
  
  @HiveField(4)
  DateTime? lastRetryAt;
  
  @HiveField(5)
  String? errorMessage;
  
  QueuedReceipt({
    required this.id,
    required this.queuedAt,
    required this.items,
    this.retryCount = 0,
    this.lastRetryAt,
    this.errorMessage,
  });
}

@HiveType(typeId: 1)
class QueuedItem extends HiveObject {
  @HiveField(0)
  String description;
  
  @HiveField(1)
  double amount;
  
  @HiveField(2)
  String categoryNameVi;
  
  @HiveField(3)
  String typeNameVi;
  
  @HiveField(4)
  DateTime date;
  
  @HiveField(5)
  String? note;
  
  QueuedItem({
    required this.description,
    required this.amount,
    required this.categoryNameVi,
    required this.typeNameVi,
    required this.date,
    this.note,
  });
}
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
**Goal**: Set up core infrastructure and dependencies

**Tasks**:
1. Add dependencies to `pubspec.yaml`
2. Set up camera permissions (iOS/Android)
3. Initialize Hive for offline storage
4. Create base models:
   - `ScannedReceipt`
   - `ScannedItem`
   - `QueuedReceipt` (Hive model)
5. Create directory structure

**Deliverables**:
- ✅ All dependencies installed and working
- ✅ Camera permission flow functional
- ✅ Hive database initialized
- ✅ Models defined with serialization

**Testing**:
- Camera permission prompts appear correctly
- Hive box opens without errors
- Models serialize/deserialize correctly

**Time Estimate**: 8-12 hours

---

### Phase 2: Camera & Image Capture (Week 1-2)
**Goal**: Implement photo capture and preview

**Tasks**:
1. Create `CameraCaptureScreen`
   - Camera preview
   - Flash toggle
   - Gallery picker integration
   - Capture button with animation
2. Create `ImagePreviewScreen`
   - Zoomable image view
   - Quality warnings
   - Retake/Process buttons
3. Implement `ImageProcessor` utility
   - Compression
   - Rotation correction
   - Quality validation

**Deliverables**:
- ✅ Functional camera interface
- ✅ Gallery selection works
- ✅ Image preview with zoom
- ✅ Image quality validation

**Testing**:
- Take photos in various lighting
- Select images from gallery
- Test rotation handling
- Verify compression ratios

**Time Estimate**: 12-16 hours

---

### Phase 3: OCR Integration (Week 2)
**Goal**: Implement text extraction from images

**Tasks**:
1. Create `OcrService`
   - ML Kit integration
   - Vietnamese text recognition
   - Text block parsing
2. Create `ReceiptParser` utility
   - Extract line items
   - Parse amounts (various formats)
   - Handle common receipt structures
3. Create `ProcessingOverlay` widget
   - Progress indicator
   - Cancel functionality
   - Error handling

**Deliverables**:
- ✅ OCR extracts Vietnamese text
- ✅ Parser identifies items and amounts
- ✅ Processing overlay shows progress

**Testing**:
- Test with real Vietnamese receipts
- Test various number formats (50.000, 50,000, 50000)
- Test edge cases (no amounts, unclear text)
- Measure processing time

**Time Estimate**: 16-20 hours

**Critical Success Factor**: Accuracy on real receipts (target: 70%+ correct extractions)

---

### Phase 4: Category Matching (Week 2-3)
**Goal**: Implement keyword-based category assignment

**Tasks**:
1. Create `CategoryMatchingService`
   - Build keyword dictionaries for 14 categories
   - Implement pattern matching algorithm
   - Handle compound words and variations
2. Create `KeywordMatcher` utility
   - Vietnamese text normalization
   - Fuzzy matching for typos
   - Confidence scoring (internal only)
3. Testing with real expense data
   - Sample 100 expenses from database
   - Validate matching accuracy
   - Refine keyword dictionaries

**Keyword Dictionary Structure**:
```dart
const categoryKeywords = {
  'Cà phê': [
    'cà phê', 'cafe', 'coffee', 'caphê', 'caphe',
    'latte', 'espresso', 'americano', 'cappuccino',
    'trà sữa', 'tra sua', 'bubble tea',
  ],
  'Thực phẩm': [
    'thực phẩm', 'thuc pham', 'food',
    'rau', 'củ', 'quả', 'trái cây',
    'thịt', 'cá', 'tôm', 'gạo', 'bánh mì',
  ],
  'Du lịch': [
    'du lịch', 'dulich', 'travel', 'tour',
    'khách sạn', 'hotel', 'vé máy bay',
    'homestay', 'resort',
  ],
  // ... 11 more categories
};
```

**Deliverables**:
- ✅ Keyword dictionaries for all 14 categories
- ✅ Matching algorithm with >60% accuracy
- ✅ Fallback to "Khác" for unmatched items

**Testing**:
- Test against 100 real expenses
- Measure category assignment accuracy
- Identify missing keywords
- Refine dictionaries based on results

**Time Estimate**: 12-16 hours

**Critical Success Factor**: >60% automatic category accuracy (users will review/adjust)

---

### Phase 5: Review Screen (Week 3)
**Goal**: Implement the core review and edit UI

**Tasks**:
1. Create `ReceiptReviewScreen`
   - Item list with cards
   - Summary header (count, total)
   - Save all button
2. Create `ScannedItemCard` widget
   - Display mode (tap to edit)
   - Edit mode (inline expansion)
   - Swipe to delete
   - Category/type pickers
3. Add item functionality
   - FAB to add missed items
   - Manual entry form
4. Batch save logic
   - Validate all items
   - Create expenses via provider
   - Handle partial failures

**Deliverables**:
- ✅ Functional review screen
- ✅ Inline editing works smoothly
- ✅ Can add/delete items
- ✅ Batch save creates all expenses

**Testing**:
- Review screen with 1, 5, 10, 20 items
- Edit various fields
- Delete items
- Add new items
- Test batch save with network errors

**Time Estimate**: 16-20 hours

---

### Phase 6: Offline Queue (Week 3-4)
**Goal**: Implement reliable offline queueing

**Tasks**:
1. Create `OfflineQueueService`
   - Queue management with Hive
   - Connectivity detection
   - Auto-processing on reconnect
   - Retry logic with exponential backoff
2. Create `OfflineQueueRepository`
   - CRUD operations for queued receipts
   - Status tracking
   - Error handling
3. Create `OfflineQueueIndicator` widget
   - Banner showing pending items
   - Retry button
   - Status messages
4. Integration with `ReceiptScannerProvider`
   - Queue when offline
   - Sync when online
   - Update UI on status changes

**Retry Logic**:
```dart
// Exponential backoff: 30s, 60s, 120s, 300s, 600s
int getRetryDelay(int retryCount) {
  const delays = [30, 60, 120, 300, 600];
  if (retryCount >= delays.length) {
    return delays.last;
  }
  return delays[retryCount];
}
```

**Deliverables**:
- ✅ Offline queue persists across app restarts
- ✅ Auto-sync on connectivity return
- ✅ Retry logic handles transient failures
- ✅ UI shows queue status

**Testing**:
- Queue 5 receipts while offline
- Turn on connectivity → verify auto-sync
- Simulate network errors → verify retries
- Restart app → verify queue persists
- Test max retry limits

**Time Estimate**: 16-20 hours

**Critical Success Factor**: Zero data loss during offline periods

---

### Phase 7: FAB Integration (Week 4)
**Goal**: Modify FAB to show 2 options

**Tasks**:
1. Modify `MainNavigationScreen` or `ExpenseListScreen`
   - Replace direct FAB navigation
   - Show bottom sheet with 2 options
2. Create `AddExpenseBottomSheet` widget
   - "Add Manual" option
   - "Scan Receipt" option
   - Icons and descriptions
3. Wire up navigation
   - Manual → existing `AddExpenseScreen`
   - Scan → new `CameraCaptureScreen`

**Deliverables**:
- ✅ FAB shows 2 options
- ✅ Navigation to both flows works
- ✅ Existing manual flow unchanged

**Testing**:
- Tap FAB → see 2 options
- Tap "Add Manual" → manual entry screen
- Tap "Scan Receipt" → camera screen
- Cancel bottom sheet → returns to list

**Time Estimate**: 4-6 hours

---

### Phase 8: Testing & Polish (Week 4-5)
**Goal**: Comprehensive testing and UX refinement

**Tasks**:
1. End-to-end testing
   - Complete scan workflow
   - Offline queue workflow
   - Error scenarios
2. Performance optimization
   - Image compression tuning
   - OCR speed improvements
   - UI smoothness (60fps)
3. Error handling
   - User-friendly error messages
   - Recovery flows
   - Logging for debugging
4. UI polish
   - Loading states
   - Animations
   - Haptic feedback
   - Vietnamese localization
5. Documentation
   - User guide
   - Technical documentation
   - Update README

**Test Cases**:
1. **Happy Path**: Scan → Review → Save (10 items)
2. **Offline Path**: Scan while offline → Save → Go online → Verify sync
3. **Error Recovery**: Network error during save → Retry → Success
4. **Edge Cases**: 
   - 1 item receipt
   - 50+ item receipt
   - Receipt with no amounts
   - Blurry image
   - Non-receipt image
5. **Permissions**: Denied → Explain → Request again
6. **Device Variations**: Test on multiple iOS/Android devices

**Deliverables**:
- ✅ All test cases passing
- ✅ Performance targets met (<10s OCR)
- ✅ Error handling comprehensive
- ✅ UI polished and smooth
- ✅ Documentation complete

**Time Estimate**: 16-20 hours

---

### Summary Timeline

| Phase | Description | Hours | Week |
|-------|-------------|-------|------|
| 1 | Foundation | 8-12 | 1 |
| 2 | Camera & Image Capture | 12-16 | 1-2 |
| 3 | OCR Integration | 16-20 | 2 |
| 4 | Category Matching | 12-16 | 2-3 |
| 5 | Review Screen | 16-20 | 3 |
| 6 | Offline Queue | 16-20 | 3-4 |
| 7 | FAB Integration | 4-6 | 4 |
| 8 | Testing & Polish | 16-20 | 4-5 |
| **Total** | | **100-130 hours** | **4-5 weeks** |

**Assumptions**:
- 20-25 hours/week dedication
- Access to real Vietnamese receipts for testing
- Existing codebase is stable
- No major blockers or scope changes

---

## Offline Queue Design

### Architecture Overview

```
User Action (Save Receipt)
        ↓
[Connectivity Check]
        ↓
    ┌───────┴───────┐
    │               │
  Online         Offline
    │               │
    ↓               ↓
Supabase ←── [Hive Queue] ──→ Auto-Retry
    │                              ↓
    ↓                         [Success]
 Success                           ↓
                              Remove from Queue
```

### Queue State Machine

```
┌──────────┐  Queue   ┌─────────┐  Retry   ┌──────────┐
│  IDLE    │ ───────→ │ PENDING │ ───────→ │ RETRYING │
└──────────┘          └─────────┘          └──────────┘
                           │                      │
                           │                      ↓
                      Network Up           ┌──────────┐
                           │               │  FAILED  │
                           ↓               └──────────┘
                      ┌─────────┐               │
                      │ SYNCING │               │
                      └─────────┘               │
                           │                    │
                      ┌────┴────┐               │
                      │         │               │
                   Success   Failure            │
                      │         │               │
                      ↓         └───────────────┘
                 ┌─────────┐
                 │ SUCCESS │
                 └─────────┘
```

### Queue Data Model

```dart
enum QueueStatus {
  pending,   // Waiting for connectivity
  retrying,  // Active retry in progress
  syncing,   // Uploading to Supabase
  failed,    // Max retries exceeded
  success,   // Completed successfully
}

class QueuedReceipt {
  String id;
  DateTime queuedAt;
  List<QueuedItem> items;
  QueueStatus status;
  int retryCount;
  DateTime? lastRetryAt;
  String? errorMessage;
  
  // Computed properties
  bool get canRetry => retryCount < 5;
  bool get isStale => DateTime.now().difference(queuedAt).inHours > 24;
}
```

### Retry Strategy

**Exponential Backoff with Jitter**:
```dart
class RetryStrategy {
  static const maxRetries = 5;
  static const baseDelaySeconds = 30;
  
  int getDelaySeconds(int retryCount) {
    if (retryCount >= maxRetries) return -1; // No more retries
    
    // Exponential: 30s, 60s, 120s, 300s, 600s
    int delay = baseDelaySeconds * (1 << retryCount);
    
    // Add jitter (±20%) to prevent thundering herd
    int jitter = (delay * 0.2 * (Random().nextDouble() - 0.5)).toInt();
    
    return delay + jitter;
  }
}
```

**Retry Triggers**:
1. **Automatic**: Connectivity change event
2. **Manual**: User taps "Retry Now" button
3. **Scheduled**: Timer-based retries with backoff
4. **App Restart**: Process queue on app launch

### Connectivity Detection

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  Stream<ConnectivityResult>? _connectivityStream;
  
  // Listen to connectivity changes
  void listenToConnectivity(Function(bool isOnline) onConnectivityChange) {
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream!.listen((result) {
      bool isOnline = result != ConnectivityResult.none;
      onConnectivityChange(isOnline);
    });
  }
  
  // Check current connectivity
  Future<bool> isOnline() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

### Queue Processing Logic

```dart
class OfflineQueueService {
  Future<void> processQueue() async {
    if (!(await _connectivityService.isOnline())) {
      debugPrint('Offline - skipping queue processing');
      return;
    }
    
    final queue = await _repository.getPendingReceipts();
    
    for (final receipt in queue) {
      if (!receipt.canRetry) {
        await _repository.markAsFailed(receipt.id);
        continue;
      }
      
      try {
        await _repository.updateStatus(receipt.id, QueueStatus.syncing);
        
        // Batch create expenses
        for (final item in receipt.items) {
          final expense = _itemToExpense(item);
          await _expenseRepository.create(expense);
        }
        
        // Success - remove from queue
        await _repository.delete(receipt.id);
        
      } catch (e) {
        // Failure - increment retry count and reschedule
        await _repository.incrementRetry(
          receipt.id,
          errorMessage: e.toString(),
        );
        
        // Schedule next retry
        int delay = _retryStrategy.getDelaySeconds(receipt.retryCount);
        if (delay > 0) {
          Timer(Duration(seconds: delay), () => _retryReceipt(receipt.id));
        }
      }
    }
  }
}
```

### Queue UI Indicator

**States and Messages**:

| State | Condition | UI Message | Color |
|-------|-----------|------------|-------|
| Hidden | Queue empty | (none) | - |
| Info | 1-2 items, <6 hours | "1 receipt waiting to sync" | Blue |
| Warning | 3+ items OR 6-24 hours | "3 receipts waiting to sync" | Yellow |
| Error | >24 hours OR failed | "Sync failed - tap to retry" | Red |

**Visual States**:
```
INFO (Blue):
┌─────────────────────────────────────┐
│ ℹ️ 1 receipt waiting to sync        │
│   Will upload when online           │
└─────────────────────────────────────┘

WARNING (Yellow):
┌─────────────────────────────────────┐
│ ⚠️ 3 receipts waiting to sync       │
│   Last queued 8 hours ago           │
│               [Retry Now]           │
└─────────────────────────────────────┘

ERROR (Red):
┌─────────────────────────────────────┐
│ ❌ Sync failed for 2 receipts       │
│   Network error - tap to retry      │
│               [Retry Now]           │
└─────────────────────────────────────┘
```

### Persistence Strategy

**Hive Box Configuration**:
```dart
await Hive.initFlutter();
Hive.registerAdapter(QueuedReceiptAdapter());
Hive.registerAdapter(QueuedItemAdapter());

final queueBox = await Hive.openBox<QueuedReceipt>('receipt_queue');
```

**Box Operations**:
```dart
// Add to queue
await queueBox.put(receipt.id, receipt);

// Get all pending
final pending = queueBox.values
    .where((r) => r.status == QueueStatus.pending)
    .toList();

// Remove from queue
await queueBox.delete(receipt.id);

// Update status
final receipt = queueBox.get(id);
receipt.status = QueueStatus.syncing;
await receipt.save();
```

### Error Handling

**Error Categories**:
1. **Transient** (retryable):
   - Network timeout
   - Server 5xx errors
   - Rate limiting
   
2. **Permanent** (not retryable):
   - Invalid data (4xx errors)
   - Authentication failures
   - RLS policy violations

**Error Recovery**:
```dart
if (error is SocketException) {
  // Transient - queue for retry
  await _queueService.addToQueue(receipt);
} else if (error is HttpException && error.statusCode >= 500) {
  // Server error - queue for retry
  await _queueService.addToQueue(receipt);
} else {
  // Permanent error - show user message
  _showError('Failed to save receipt. Please try again manually.');
}
```

---

## Testing Strategy

### Unit Tests

**Coverage Targets**: >80% for services, 100% for utilities

#### OcrService Tests
```dart
test('extracts Vietnamese text from image', () async {
  final image = await loadTestImage('receipt_vietnamese.jpg');
  final result = await ocrService.extractText(image);
  
  expect(result.text, contains('Bánh mì'));
  expect(result.confidence, greaterThan(0.7));
});

test('handles empty image gracefully', () async {
  final image = await loadTestImage('empty.jpg');
  final result = await ocrService.extractText(image);
  
  expect(result.text, isEmpty);
  expect(result.error, isNull);
});
```

#### CategoryMatchingService Tests
```dart
test('matches coffee keywords correctly', () {
  final category = matchingService.matchCategory('cà phê sữa đá');
  expect(category, equals('Cà phê'));
});

test('handles compound words', () {
  final category = matchingService.matchCategory('bánh mì thịt');
  expect(category, equals('Thực phẩm'));
});

test('defaults to Khác for unknown items', () {
  final category = matchingService.matchCategory('xyz123');
  expect(category, equals('Khác'));
});
```

#### OfflineQueueService Tests
```dart
test('queues receipt when offline', () async {
  connectivityService.setOffline();
  
  await queueService.queueReceipt(receipt);
  
  final queued = await queueRepository.getAll();
  expect(queued.length, equals(1));
  expect(queued.first.status, equals(QueueStatus.pending));
});

test('processes queue when online', () async {
  await queueService.queueReceipt(receipt);
  connectivityService.setOnline();
  
  await queueService.processQueue();
  
  final queued = await queueRepository.getAll();
  expect(queued, isEmpty);
});
```

### Widget Tests

**Focus**: UI components and interactions

#### CameraCaptureScreen Tests
```dart
testWidgets('shows camera preview', (tester) async {
  await tester.pumpWidget(MaterialApp(home: CameraCaptureScreen()));
  
  expect(find.byType(CameraPreview), findsOneWidget);
  expect(find.text('Capture'), findsOneWidget);
});

testWidgets('gallery button opens image picker', (tester) async {
  await tester.pumpWidget(MaterialApp(home: CameraCaptureScreen()));
  
  await tester.tap(find.text('Gallery'));
  await tester.pumpAndSettle();
  
  // Verify ImagePicker was called (mock verification)
});
```

#### ReceiptReviewScreen Tests
```dart
testWidgets('displays scanned items', (tester) async {
  final items = [
    ScannedItem(description: 'Coffee', amount: 35000, category: 'Cà phê'),
    ScannedItem(description: 'Bread', amount: 20000, category: 'Thực phẩm'),
  ];
  
  await tester.pumpWidget(MaterialApp(
    home: ReceiptReviewScreen(items: items),
  ));
  
  expect(find.text('Coffee'), findsOneWidget);
  expect(find.text('Bread'), findsOneWidget);
  expect(find.text('55,000đ'), findsOneWidget);
});

testWidgets('allows editing item', (tester) async {
  final items = [ScannedItem(...)];
  
  await tester.pumpWidget(MaterialApp(
    home: ReceiptReviewScreen(items: items),
  ));
  
  await tester.tap(find.byType(ScannedItemCard).first);
  await tester.pumpAndSettle();
  
  expect(find.byType(TextField), findsWidgets);
  expect(find.text('Update'), findsOneWidget);
});
```

### Integration Tests

**Focus**: End-to-end workflows

#### Complete Scan Workflow
```dart
testWidgets('complete scan to save workflow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap FAB
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // Choose "Scan Receipt"
  await tester.tap(find.text('Scan Receipt'));
  await tester.pumpAndSettle();
  
  // Simulate camera capture
  await tester.tap(find.text('Capture'));
  await tester.pumpAndSettle();
  
  // Process image (mock OCR result)
  await tester.tap(find.text('Process'));
  await tester.pumpAndSettle(Duration(seconds: 5));
  
  // Verify review screen
  expect(find.byType(ReceiptReviewScreen), findsOneWidget);
  
  // Save all
  await tester.tap(find.text('Save All'));
  await tester.pumpAndSettle();
  
  // Verify expenses created
  expect(find.text('5 expenses added'), findsOneWidget);
});
```

#### Offline Queue Workflow
```dart
testWidgets('queues receipt when offline and syncs when online', (tester) async {
  // Set offline mode
  await NetworkSimulator.setOffline();
  
  // Scan and save receipt
  await scanAndSaveReceipt(tester);
  
  // Verify queued
  expect(find.text('1 receipt waiting to sync'), findsOneWidget);
  
  // Go online
  await NetworkSimulator.setOnline();
  await tester.pumpAndSettle(Duration(seconds: 2));
  
  // Verify synced
  expect(find.text('1 receipt waiting to sync'), findsNothing);
});
```

### Manual Testing Checklist

**Device Testing**:
- [ ] iPhone 12/13/14 (various iOS versions)
- [ ] Android device (test various manufacturers)
- [ ] iPad (if supporting tablets)

**Receipt Varieties**:
- [ ] Grocery store receipt (10-20 items)
- [ ] Restaurant receipt (3-5 items)
- [ ] Coffee shop receipt (1-2 items)
- [ ] Gas station receipt
- [ ] Pharmacy receipt
- [ ] E-commerce receipt (printed)

**Image Qualities**:
- [ ] Well-lit photo
- [ ] Dim lighting
- [ ] Slight blur
- [ ] Crumpled receipt
- [ ] Receipt with watermarks
- [ ] Faded ink

**Edge Cases**:
- [ ] Receipt with 1 item
- [ ] Receipt with 50+ items
- [ ] Receipt with no prices
- [ ] Non-receipt image (should fail gracefully)
- [ ] Upside-down receipt
- [ ] Partially visible receipt

**Error Scenarios**:
- [ ] Camera permission denied
- [ ] Gallery permission denied
- [ ] Network timeout during save
- [ ] Server error (simulate 500)
- [ ] Supabase RLS policy error
- [ ] Device storage full

**Offline Testing**:
- [ ] Queue 5 receipts while offline
- [ ] Restart app → queue persists
- [ ] Go online → auto-sync
- [ ] Manual retry button
- [ ] Failed sync after 5 retries

### Performance Testing

**Metrics to Measure**:

| Metric | Target | Method |
|--------|--------|--------|
| OCR Processing Time | < 10 seconds | Stopwatch in code |
| Image Compression Time | < 2 seconds | Stopwatch in code |
| UI Frame Rate | 60 fps | Flutter DevTools |
| Memory Usage | < 100 MB | Flutter DevTools |
| Battery Impact | < 5% per scan | iOS Battery Usage |
| Queue Sync Time | < 5 sec per receipt | Stopwatch in code |

**Load Testing**:
- Process receipt with 50 items
- Queue 10 receipts
- Sync 10 queued receipts simultaneously

---

## Risk Mitigation

### Technical Risks

#### Risk 1: OCR Accuracy Below Expectations
**Impact**: High - Core feature depends on accurate extraction

**Mitigation**:
1. **Pre-processing**: Enhance image quality before OCR
   - Increase contrast
   - Apply sharpening
   - Correct rotation
2. **Fallback**: Allow manual entry for problematic receipts
3. **User feedback**: Track OCR failures to identify patterns
4. **Iteration**: Refine parsing logic based on real-world data

**Contingency**: If <50% accuracy, consider:
- Alternative OCR engines (Tesseract, AWS Textract)
- LLM integration (future enhancement)
- Semi-automatic mode (OCR + manual correction)

#### Risk 2: Category Matching Poor Performance
**Impact**: Medium - Users will need to manually correct many items

**Mitigation**:
1. **Extensive keyword lists**: Cover variations and typos
2. **Learning mechanism**: Track user corrections to improve keywords
3. **Smart defaults**: Use most frequent category for ambiguous items
4. **Quick edit**: Make category changes fast (inline dropdown)

**Contingency**:
- Add machine learning model for category prediction (Phase 2)
- User-customizable keyword mappings

#### Risk 3: Offline Queue Data Loss
**Impact**: Critical - Would break user trust

**Mitigation**:
1. **Hive persistence**: Reliable local database
2. **Atomic operations**: All-or-nothing saves
3. **Data validation**: Verify integrity before/after saves
4. **Backup strategy**: Optional export to JSON
5. **Extensive testing**: Simulate crashes, force quits, low battery

**Contingency**:
- Manual queue inspection tool (debug screen)
- Queue export/import functionality

#### Risk 4: Performance on Low-End Devices
**Impact**: Medium - Could cause app freezes or crashes

**Mitigation**:
1. **Async processing**: All heavy operations in background
2. **Image downscaling**: Reduce resolution for slow devices
3. **Progressive processing**: Show results as they come
4. **Device profiling**: Test on budget Android phones

**Contingency**:
- Performance mode (lower quality, faster processing)
- Warning for receipts with >20 items

### UX Risks

#### Risk 5: User Confusion with Review Screen
**Impact**: Medium - Could lead to incorrect expenses

**Mitigation**:
1. **Clear instructions**: Tooltips on first use
2. **Obvious edit controls**: Large tap targets
3. **Confirmation before save**: "Save 10 expenses?"
4. **Undo functionality**: Allow correction after save

**Contingency**:
- User tutorial (first-time onboarding)
- Help button with examples

#### Risk 6: FAB Change Disrupts Existing Users
**Impact**: Low - Minor UX change

**Mitigation**:
1. **Clear labels**: "Add Manual" (not just icons)
2. **Familiar flow**: Manual entry unchanged
3. **Quick access**: Bottom sheet appears instantly

**Contingency**:
- User preference to set default action
- Long-press FAB for direct manual entry

### Project Risks

#### Risk 7: Scope Creep
**Impact**: High - Could delay delivery

**Mitigation**:
1. **Fixed scope**: This document defines MVP
2. **Phase gates**: Review before starting each phase
3. **Future backlog**: Document "nice-to-haves" separately
4. **Time boxing**: Hard deadlines for each phase

**Out of Scope for MVP**:
- ❌ LLM integration
- ❌ Machine learning models
- ❌ Multi-language support (beyond Vietnamese)
- ❌ Receipt storage/archival
- ❌ OCR for handwritten receipts
- ❌ Export to PDF/Excel

#### Risk 8: External Dependencies Break
**Impact**: Medium - Could block progress

**Mitigation**:
1. **Version pinning**: Lock dependency versions
2. **Regular updates**: Monitor for breaking changes
3. **Abstraction layer**: Wrap third-party APIs
4. **Alternative ready**: Know fallback options

**Key Dependencies**:
- `google_mlkit_text_recognition` → Fallback: Firebase ML Kit
- `camera` → Fallback: `image_picker` only
- `hive` → Fallback: `shared_preferences` + JSON

### Data Risks

#### Risk 9: Privacy Concerns with Images
**Impact**: High - User trust issue

**Mitigation**:
1. **Local processing**: Never upload images to servers
2. **Immediate deletion**: Delete after processing
3. **No logging**: Don't log image data
4. **Transparency**: Document privacy approach in UI

**Privacy Policy Points**:
- Images processed locally on device
- Images deleted immediately after extraction
- No image data stored or transmitted
- OCR results stored as text only

#### Risk 10: Supabase Rate Limits
**Impact**: Low - Unlikely with current user base

**Mitigation**:
1. **Batch operations**: Single request for multiple expenses
2. **Retry logic**: Respect rate limit headers
3. **Queue buffering**: Accumulate before syncing
4. **Monitoring**: Track API usage

**Contingency**:
- Upgrade Supabase plan if needed
- Implement client-side throttling

---

## Success Metrics

### Quantitative Metrics

#### Adoption Metrics
- **Feature Discovery Rate**: % of users who try scan feature within 7 days
  - Target: >40%
- **Scan Frequency**: Average scans per active user per week
  - Target: >1 scan/week
- **Retention**: % of users who scan again after first use
  - Target: >60%

#### Accuracy Metrics
- **OCR Accuracy**: % of items correctly extracted
  - Target: >70% (description + amount)
- **Category Match Accuracy**: % of items correctly categorized
  - Target: >60% (users will review/adjust)
- **Amount Parse Accuracy**: % of amounts correctly parsed
  - Target: >90%

#### Performance Metrics
- **Processing Time**: Median time from capture to review screen
  - Target: <10 seconds
- **Queue Sync Success Rate**: % of queued receipts successfully synced
  - Target: >95%
- **Error Rate**: % of scans that fail completely
  - Target: <5%

#### Efficiency Metrics
- **Time Saved**: Estimated time saved vs manual entry
  - Target: >60% time reduction for 10+ item receipts
- **Edits Per Item**: Average corrections needed per scanned item
  - Target: <1.5 edits/item
- **Completion Rate**: % of scans that result in saved expenses
  - Target: >80%

### Qualitative Metrics

#### User Feedback
- Survey after first scan:
  - "Was the scanning feature easy to use?" (1-5 scale)
  - "Would you use this feature again?" (Yes/No)
  - "What could be improved?" (Open text)

#### Usability Observations
- Monitor support requests related to scanning
- Track app reviews mentioning OCR feature
- A/B test UI variations if needed

### Analytics Events to Track

```dart
// Feature usage
analytics.logEvent('scan_receipt_started');
analytics.logEvent('scan_receipt_completed', parameters: {
  'item_count': itemCount,
  'processing_time_ms': processingTime,
  'edited_items': editedCount,
});

// OCR performance
analytics.logEvent('ocr_completed', parameters: {
  'items_extracted': extractedCount,
  'confidence_avg': avgConfidence,
  'processing_time_ms': processingTime,
});

// Category matching
analytics.logEvent('category_matched', parameters: {
  'auto_matched': autoMatchedCount,
  'user_corrected': correctedCount,
  'accuracy_rate': accuracyRate,
});

// Offline queue
analytics.logEvent('receipt_queued', parameters: {
  'queue_size': queueSize,
  'is_offline': isOffline,
});
analytics.logEvent('queue_synced', parameters: {
  'receipts_synced': syncedCount,
  'retry_count': retryCount,
});

// Errors
analytics.logEvent('scan_error', parameters: {
  'error_type': errorType,
  'stage': stage, // capture, processing, review, save
});
```

### Success Criteria Summary

**MVP will be considered successful if**:
1. ✅ >70% OCR accuracy on real receipts
2. ✅ >80% of scans result in saved expenses
3. ✅ >60% user retention (scan again after first use)
4. ✅ <5% error rate
5. ✅ <10 second processing time
6. ✅ Zero offline data loss
7. ✅ Positive user feedback (>4/5 rating)

---

## Appendix

### Keyword Dictionary Examples

**Full keyword mappings** (to be refined during Phase 4):

```dart
const Map<String, List<String>> categoryKeywords = {
  'Cà phê': [
    'cà phê', 'cafe', 'coffee', 'caphê', 'caphe',
    'latte', 'espresso', 'americano', 'cappuccino',
    'trà sữa', 'tra sua', 'bubble tea', 'milk tea',
    'sinh tố', 'smoothie', 'nước ép', 'juice',
  ],
  
  'Thực phẩm': [
    'thực phẩm', 'thuc pham', 'food', 'grocery',
    'rau', 'củ', 'quả', 'trái cây', 'trai cay',
    'thịt', 'cá', 'tôm', 'hải sản',
    'gạo', 'bún', 'phở', 'bánh mì',
    'siêu thị', 'chợ', 'coopmart', 'lotte mart',
  ],
  
  'Ăn uống': [
    'ăn uống', 'an uong', 'nhà hàng', 'nha hang',
    'restaurant', 'quán ăn', 'quan an',
    'buffet', 'lẩu', 'nướng', 'bbq',
    'cơm', 'phở', 'bún', 'mì',
  ],
  
  'Du lịch': [
    'du lịch', 'dulich', 'travel', 'tour',
    'khách sạn', 'khach san', 'hotel',
    'vé máy bay', 've may bay', 'flight',
    'homestay', 'resort', 'airbnb',
    'vé tham quan', 've tham quan', 'ticket',
  ],
  
  'Đi lại': [
    'đi lại', 'di lai', 'transportation',
    'xe', 'taxi', 'grab', 'uber',
    'xăng', 'xang', 'gas', 'petrol',
    'xe buýt', 'bus', 'metro',
    'vé xe', 've xe', 'toll',
  ],
  
  'Hoá đơn': [
    'hoá đơn', 'hoa don', 'bill', 'utility',
    'điện', 'dien', 'electric',
    'nước', 'nuoc', 'water',
    'internet', 'wifi', 'mobile',
    'điện thoại', 'dien thoai', 'phone',
  ],
  
  'Mua sắm': [
    'mua sắm', 'mua sam', 'shopping',
    'quần áo', 'quan ao', 'clothes',
    'giày dép', 'giay dep', 'shoes',
    'túi xách', 'tui xach', 'bag',
    'phụ kiện', 'phu kien', 'accessories',
  ],
  
  'Giải trí': [
    'giải trí', 'giai tri', 'entertainment',
    'phim', 'cinema', 'movie',
    'game', 'netflix', 'spotify',
    'karaoke', 'bar', 'pub',
  ],
  
  'Sức khỏe': [
    'sức khỏe', 'suc khoe', 'health',
    'bệnh viện', 'benh vien', 'hospital',
    'phòng khám', 'phong kham', 'clinic',
    'thuốc', 'thuoc', 'medicine',
    'vitamin', 'dược', 'duoc', 'pharmacy',
  ],
  
  'Giáo dục': [
    'giáo dục', 'giao duc', 'education',
    'học phí', 'hoc phi', 'tuition',
    'sách', 'sach', 'book',
    'khóa học', 'khoa hoc', 'course',
    'văn phòng phẩm', 'stationery',
  ],
  
  'Tạp hoá': [
    'tạp hoá', 'tap hoa', 'convenience',
    'tạp hóa', 'tap hoa', 'minimart',
    'circle k', 'family mart', '7-eleven',
    'cửa hàng tiện lợi', 'cua hang tien loi',
  ],
  
  'Thú cưng': [
    'thú cưng', 'thu cung', 'pet',
    'chó', 'cho', 'dog',
    'mèo', 'meo', 'cat',
    'thức ăn thú cưng', 'pet food',
    'bác sĩ thú y', 'veterinary',
  ],
  
  'TẾT': [
    'tết', 'tet', 'lunar new year',
    'mâm cỗ', 'mam co',
    'bánh chưng', 'banh chung',
    'hoa', 'mai', 'đào',
    'lì xì', 'li xi', 'red envelope',
  ],
  
  'Khác': [
    // Fallback category - no specific keywords
    'khác', 'khac', 'other', 'misc',
  ],
};
```

### Receipt Parser Regex Patterns

```dart
class ReceiptParser {
  // Vietnamese currency patterns
  static final amountPatterns = [
    RegExp(r'(\d{1,3}(?:\.\d{3})*)\s*[đdĐD]'),  // 50.000đ
    RegExp(r'(\d{1,3}(?:,\d{3})*)\s*[đdĐD]'),   // 50,000đ
    RegExp(r'(\d+)\s*[đdĐD]'),                   // 50000đ
    RegExp(r'(\d{1,3}(?:\.\d{3})*)\s*VND'),      // 50.000 VND
    RegExp(r'(\d{1,3}(?:,\d{3})*)\s*VND'),       // 50,000 VND
  ];
  
  // Item line patterns (description + amount)
  static final itemLinePattern = RegExp(
    r'^(.+?)\s+(\d{1,3}(?:[.,]\d{3})*)\s*[đdĐDvV]',
    multiLine: true,
  );
  
  // Total line patterns
  static final totalPatterns = [
    RegExp(r'Tổng\s*(?:cộng)?\s*:?\s*(\d+)'),
    RegExp(r'Total\s*:?\s*(\d+)'),
    RegExp(r'Thành\s*tiền\s*:?\s*(\d+)'),
  ];
}
```

### Image Processing Configuration

```dart
class ImageProcessingConfig {
  // Compression settings
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int quality = 85;
  
  // OCR preprocessing
  static const double contrastFactor = 1.2;
  static const double sharpnessFactor = 1.1;
  
  // Quality thresholds
  static const int minWidth = 800;
  static const int minHeight = 800;
  static const double maxBlurThreshold = 100.0;
}
```

---

## Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-13 | Claude | Initial comprehensive plan |

---

**Next Steps**: Review this plan → Create `todo.md` with broken-down tasks → Begin Phase 1 implementation
