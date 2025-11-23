# Session 2025-11-16: Vision Parser Optimization + Camera Permission Debug

**Branch**: feature/receipt-scanning  
**Last Commit**: e715ee4 - Vision parser optimization
**Status**: Vision parser ✅ | Camera permission debugging 🔧

---

## ✅ Completed Work

### 1. Vision Parser Optimization

**Problem**: Discount detection had shifting issues, weighted items used wrong amounts

**Solution Implemented**:
- **State machine approach**: STATE 1 (Item Header) → STATE 2 (Price Line) → STATE 3 (Discount Detection)
- **RIGHTMOST number rule**: Extract rightmost column ("so tien") not unit price ("dgia")
- **Increased capacity**: max_tokens 4000 → 8000 (handles 30+ items)

**Files Modified**:
- `lib/services/scanning/vision_parser_service.dart` - Complete prompt rewrite
- `.env.example` - Added Gemini + OpenAI API key documentation
- `pubspec.yaml` - Added google_generative_ai package

**Files Created**:
- `lib/services/scanning/gemini_parser_service.dart` - FREE tier alternative (future-ready)
- `GEMINI_PARSER_DEPLOYMENT.md` - Setup guide for Gemini

**Test Results**:
- ✅ ~90% accuracy on weighted items
- ✅ Correct extraction from "so tien" column
- ✅ Acceptable quality (users can manually edit 1-2 items)
- ✅ Tested successfully via gallery picker

**Commit**: e715ee4 - "feat: Optimize Vision parser with state machine + Gemini integration"

---

## 🔧 Ongoing: Camera Permission Issue

### Problem Discovery

**User Report**: Cannot open camera, no permission dialog appears

**Investigation Steps**:
1. ✅ Verified Info.plist has NSCameraUsageDescription
2. ✅ Tried full app restart - no permission dialog
3. ✅ Tried flutter clean + pod install - no change
4. ✅ Found root cause: **Untrusted Developer Certificate**

### Root Cause #1: Developer Certificate (FIXED)

**Issue**: iOS showed "Untrusted Developer" dialog blocking entire app

**Solution**:
- Settings → General → Device Management
- Trust "Apple Development: thanh.quoc731@gmail.com"
- App now runs without trust error ✅

### Root Cause #2: Camera Permission Not Requested (ONGOING)

**Current State**:
- App is trusted and runs ✅
- iOS shows permission dialogs (Local Network appeared) ✅
- **BUT Camera permission never requested** ❌
- App does NOT appear in: Settings → Privacy & Security → Camera

**What This Means**:
The `Permission.camera.request()` call is either:
1. Not being executed at all
2. Failing silently without errors
3. Being blocked by iOS for unknown reason

**Code Path** (`camera_capture_screen.dart`):
```dart
_initializeCamera() {
  hasCameraPermission() → returns false
  requestCameraPermission() → Should trigger iOS dialog, but doesn't
  Shows error screen instead
}
```

**Next Step**: Add debug logging to see execution flow

---

## 📋 Next Session Tasks

### Immediate: Debug Camera Permission

1. **Add Debug Logging** to `camera_capture_screen.dart`:
   ```dart
   debugPrint('🎥 [Camera] Checking permission...');
   debugPrint('🎥 [Camera] Has permission: $hasPermission');
   debugPrint('🎥 [Camera] Requesting permission...');
   debugPrint('🎥 [Camera] Permission granted: $granted');
   ```

2. **Add Try-Catch** around permission request to catch silent failures

3. **Run with Logging**:
   ```bash
   flutter run
   # Watch console output when tapping "Quét hóa đơn"
   ```

4. **Analyze Logs** to identify where the flow breaks

### Possible Solutions (Based on Logs)

**If requestCameraPermission() returns false immediately**:
- Check permission_handler version compatibility
- Verify iOS deployment target (should be 12.0+)
- Check for iOS restrictions in Screen Time

**If requestCameraPermission() throws exception**:
- Fix the specific error
- Add error handling

**If requestCameraPermission() never executes**:
- Check if _initializeCamera() is being called
- Verify screen lifecycle (mounted check)

---

## 🎯 Known Working Features

1. ✅ **Receipt Scanning via Gallery**: User tested successfully
2. ✅ **Vision AI Parser**: Extracts items correctly (~90% accuracy)
3. ✅ **Weighted Items**: Uses "so tien" column correctly
4. ✅ **App Runs**: Developer certificate trusted
5. ✅ **Permission Dialogs Work**: Local Network dialog appeared

**Workaround**: Users can scan receipts using "Chọn từ thư viện" (gallery picker) until camera permission is fixed.

---

## 📝 Files to Work On

**Next Edit**:
- `lib/screens/scanning/camera_capture_screen.dart` - Add debug logging

**After Debugging**:
- Potentially: `lib/services/scanning/permission_service.dart` - Fix permission request
- Potentially: `ios/Podfile` - Add permission_handler config if needed

---

## 💾 Git Status

**Branch**: feature/receipt-scanning  
**Last Commit**: e715ee4 (Vision parser optimization)  
**Uncommitted**: None (all work committed)  
**Next Commit**: Camera permission debug logging (after adding logs)

---

## 🔑 Key Learnings

1. **iOS Developer Certificate**: Must be trusted before app can request ANY permissions
2. **Vision Parser**: State machine approach works better than algorithmic rules for Vision AI
3. **Rightmost Number**: Critical for Vietnamese receipts with multiple price columns
4. **Debugging Strategy**: Start with logging to understand execution flow before fixing

---

**Session End**: 2025-11-16  
**Next Session**: Add camera debug logging, analyze output, fix permission request
