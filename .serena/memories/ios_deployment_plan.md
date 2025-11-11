# iOS Deployment Plan - Phase H

**Branch:** feature/ios-deployment
**Created:** 2025-01-11
**Goal:** Deploy expense tracker app to iPhone device
**Estimated Time:** 3-5 days

---

## 🎯 Deployment Phases

### Phase 1: App Icon & Assets (Day 1) ⏳
**Goal:** Create professional app icon and assets

**Tasks:**
1. Design or find app icon (1024x1024 base)
2. Generate all required iOS sizes automatically
3. Update `ios/Runner/Assets.xcassets/AppIcon.appiconset`
4. Add app icon using tool or manually

**Tools Options:**
- Online: AppIcon.co (free, generates all sizes)
- Manual: Xcode Asset Catalog
- Flutter package: `flutter_launcher_icons`

**Success Criteria:**
- ✅ App icon shows on home screen (not default Flutter logo)
- ✅ All required sizes generated
- ✅ Icon follows iOS guidelines (no transparency, proper margins)

---

### Phase 2: Launch Screen (Day 1-2) ⏳
**Goal:** Professional splash screen on app startup

**Tasks:**
1. Design launch screen (simple logo + app name)
2. Update `ios/Runner/Assets.xcassets/LaunchImage.imageset`
3. Configure launch screen storyboard
4. Test launch animation

**Design Guidelines:**
- Simple, clean design
- Matches app theme
- Fast loading (< 1 second)
- Material Design 3 aesthetic

**Success Criteria:**
- ✅ Launch screen displays correctly
- ✅ Smooth transition to main app
- ✅ Works in light and dark mode

---

### Phase 3: iOS Configuration (Day 2) ⏳
**Goal:** Configure app metadata and settings

**Files to Update:**
- `ios/Runner/Info.plist` - App permissions, capabilities
- `ios/Runner.xcodeproj/project.pbxproj` - Bundle ID, team, signing

**Configuration Checklist:**
1. **Bundle Identifier:** com.yourname.expensetracker
2. **Display Name:** Expense Tracker
3. **Version:** 1.0.0
4. **Build Number:** 1
5. **Minimum iOS Version:** 13.0 (or 14.0)
6. **App Permissions:**
   - No camera (not needed)
   - No location (not needed)
   - No photos (not needed)
   - Internet access (for Supabase)

**Success Criteria:**
- ✅ App name shows correctly on device
- ✅ Version information correct
- ✅ Bundle ID unique and valid

---

### Phase 4: Simulator Testing (Day 2-3) ⏳
**Goal:** Verify app works correctly in iOS simulator

**Test Scenarios:**
1. **Authentication Flow:**
   - Login works
   - Signup works
   - Session persists

2. **Expense Management:**
   - Create expense
   - Edit expense
   - Delete expense
   - List displays correctly

3. **Analytics:**
   - Charts render correctly
   - Month navigation works
   - Budget displays correctly

4. **Theme Switching:**
   - Light mode works
   - Dark mode works
   - System mode follows device
   - Theme persists

5. **Performance:**
   - App launches quickly (< 3 seconds)
   - Scrolling is smooth
   - No crashes or errors

**Commands:**
```bash
# Open iOS simulator
open -a Simulator

# Run app in simulator
flutter run -d ios

# Hot reload for testing
r (in terminal)

# Hot restart
R (in terminal)
```

**Success Criteria:**
- ✅ All features work in simulator
- ✅ No crashes or errors
- ✅ Performance is smooth
- ✅ App icon and launch screen display

---

### Phase 5: Physical Device Deployment (Day 3-5) ⏳
**Goal:** Deploy to your actual iPhone

**Prerequisites:**
1. **Apple Developer Account** (free tier is fine)
2. **iPhone connected via USB cable**
3. **iPhone in Developer Mode** (Settings → Privacy & Security → Developer Mode)
4. **Xcode installed** (should already have it)
5. **Trust this Mac** (on iPhone when prompted)

**Deployment Steps:**

**Step 1: Configure Signing**
```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Runner" in Project Navigator
2. Select "Runner" target
3. Go to "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. Select your Apple ID team
6. Bundle Identifier will be auto-configured

**Step 2: Connect iPhone**
1. Connect iPhone via USB cable
2. Unlock iPhone
3. Trust this Mac (dialog on iPhone)
4. iPhone appears in Xcode device list

**Step 3: Build and Deploy**
```bash
# In VS Code terminal
flutter devices
# Should show your iPhone

# Deploy to device
flutter run -d <device-id>
# Or select device in VS Code and Run
```

**Step 4: Trust Developer on iPhone**
1. Open app → "Untrusted Developer" message
2. Go to Settings → General → VPN & Device Management
3. Tap your Apple ID
4. Tap "Trust"
5. Confirm trust
6. App now launches!

**Success Criteria:**
- ✅ App installs on physical device
- ✅ App icon shows on home screen
- ✅ App launches without errors
- ✅ All features work on device
- ✅ Real-world testing complete

---

## 🛠️ Technical Considerations

### App Icon Requirements (iOS)
**Required Sizes:**
- 1024x1024 (App Store)
- 180x180 (iPhone app)
- 167x167 (iPad Pro)
- 152x152 (iPad)
- 120x120 (iPhone notifications)
- 87x87 (iPhone settings)
- 80x80 (iPad notifications)
- 76x76 (iPad app)
- 60x60 (iPhone spotlight)
- 58x58 (iPhone settings)
- 40x40 (iPad spotlight)
- 29x29 (iPhone/iPad settings)
- 20x20 (Notifications)

**Design Guidelines:**
- No transparency (must be opaque)
- No rounded corners (iOS adds automatically)
- Visual safe zone: 10% margin from edges
- Simple, recognizable at small sizes
- Works in both light and dark backgrounds

### Launch Screen Best Practices
- Show logo or brand identity
- Minimal text (app name optional)
- Fast loading (static image, no animations)
- Matches app's first screen for smooth transition
- Supports light and dark appearance

### Bundle ID Format
Format: `com.yourname.appname`
Example: `com.quocphan.expensetracker`

Must be:
- Unique (not used by other apps)
- Lowercase
- No spaces or special characters
- Reverse domain notation

### Code Signing (Free vs Paid)
**Free Apple Developer Account:**
- ✅ Deploy to own devices
- ✅ Test on physical devices
- ✅ 7-day certificate (re-sign weekly)
- ❌ Cannot publish to App Store
- ❌ Limited app capabilities

**Paid Account ($99/year):**
- ✅ 1-year certificate
- ✅ Publish to App Store
- ✅ TestFlight beta testing
- ✅ All app capabilities

For learning and personal use, **free account is sufficient**.

---

## 📱 Device Testing Checklist

Test on physical device:
- [ ] App launches successfully
- [ ] Authentication works
- [ ] Create/edit/delete expenses
- [ ] Charts render correctly
- [ ] Theme switching works
- [ ] Internet connectivity handling
- [ ] App performance (speed, smoothness)
- [ ] Battery usage reasonable
- [ ] No memory leaks or crashes
- [ ] Keyboard behavior correct
- [ ] Screen rotation (if supported)
- [ ] Background/foreground transitions
- [ ] Push notifications (if implemented)

---

## 🎨 App Icon Design Ideas

**Option 1: Simple Currency Symbol**
- Vietnamese đồng symbol (₫)
- Clean, minimalist design
- Solid background color (brand color)

**Option 2: Wallet/Receipt Icon**
- Stylized wallet or receipt
- Matches expense tracking theme
- Modern, flat design

**Option 3: Chart/Graph Icon**
- Ascending bar chart
- Represents analytics
- Professional look

**Option 4: Piggy Bank**
- Traditional savings symbol
- Friendly, approachable
- Easily recognizable

**Recommendation:** Simple currency symbol (₫) with gradient background matching your app's minimalist theme.

---

## 🚀 Quick Start Commands

**Check devices:**
```bash
flutter devices
```

**Run on simulator:**
```bash
flutter run -d ios
```

**Run on physical device:**
```bash
flutter run -d <device-id>
```

**Build release version:**
```bash
flutter build ios --release
```

**Clean build (if issues):**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios
```

---

## 📝 Common Issues & Solutions

### Issue: "Untrusted Developer"
**Solution:** Settings → General → VPN & Device Management → Trust

### Issue: "Failed to launch on device"
**Solution:** Enable Developer Mode on iPhone (iOS 16+)
Settings → Privacy & Security → Developer Mode → On → Restart

### Issue: Code signing error
**Solution:** 
1. Open `ios/Runner.xcworkspace` in Xcode
2. Update Bundle Identifier to be unique
3. Select your Apple ID team
4. Enable "Automatically manage signing"

### Issue: Pod install failures
**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Issue: "Could not find iPhone"
**Solution:**
1. Reconnect USB cable
2. Trust this Mac on iPhone
3. Run `flutter devices` to verify
4. Restart Xcode

---

## 🎓 Learning Outcomes

By completing iOS deployment, you'll learn:

1. **iOS App Structure** - How Flutter apps are packaged for iOS
2. **Asset Management** - App icons, launch screens, resources
3. **Code Signing** - Apple's developer certificate system
4. **Device Management** - Deploying to simulators vs physical devices
5. **Build Configurations** - Debug vs Release builds
6. **Real-world Testing** - Performance on actual hardware
7. **Professional Deployment** - Production-ready app distribution

---

## 📊 Success Metrics

**Deployment Complete When:**
- ✅ App icon displays on iPhone home screen
- ✅ Launch screen shows on app startup
- ✅ All features work on physical device
- ✅ No crashes during normal use
- ✅ Theme switching works correctly
- ✅ Performance is smooth and responsive
- ✅ App survives background/foreground transitions
- ✅ User can use app for real expense tracking

---

**Next Steps After Deployment:**
1. Daily usage testing (1 week)
2. Gather personal feedback
3. Identify missing features or bugs
4. Plan next enhancement phase

**Estimated Total Time:** 3-5 days
- Day 1: App icon + Launch screen
- Day 2: Configuration + Simulator testing
- Day 3-5: Physical device deployment + testing

---

**Last Updated:** 2025-01-11
**Branch:** feature/ios-deployment
**Status:** Ready to start Phase 1 (App Icon)
