# Physical iPhone Deployment Guide

**Goal:** Install and run Expense Tracker on your actual iPhone
**Time:** 10-20 minutes (first time)
**Difficulty:** Easy with free Apple Developer account

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:

- [ ] **iPhone** - Any iPhone running iOS 13.0 or later
- [ ] **USB-C to Lightning cable** (or USB-C to USB-C for iPhone 15+)
- [ ] **Apple ID** - Your iCloud account (free account is fine!)
- [ ] **Xcode installed** - You already have this ✅
- [ ] **iPhone unlocked** - So you can interact with prompts

---

## 🔧 Step 1: Enable Developer Mode on iPhone (iOS 16+)

**Only for iOS 16 and newer iPhones**

1. **Connect iPhone** to Mac via USB cable
2. **Unlock iPhone** and tap "Trust This Computer"
3. On iPhone, go to: **Settings → Privacy & Security**
4. Scroll down to find: **Developer Mode**
5. **Toggle it ON**
6. iPhone will prompt to restart - **Tap Restart**
7. After restart, confirm "Turn On Developer Mode"

**Note:** If you don't see "Developer Mode", your iOS version doesn't require it (iOS 15 or earlier).

---

## 💻 Step 2: Configure Code Signing in Xcode

### Option A: Automatic Signing (Recommended - Easiest)

1. **Open project in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode, click on **"Runner"** in the left sidebar (blue icon)

3. Select the **"Runner"** target (under TARGETS, not PROJECTS)

4. Click **"Signing & Capabilities"** tab at the top

5. **Check** the box: ☑️ "Automatically manage signing"

6. Under "Team", click the dropdown:
   - If you see your Apple ID → **Select it**
   - If empty → Click **"Add an Account..."**

7. **Sign in with your Apple ID:**
   - Enter your iCloud email and password
   - If you have 2FA, enter the code

8. **Select your Team:**
   - After signing in, you'll see: "Your Name (Personal Team)"
   - Click to select it

9. **Verify** you see:
   - ✅ Signing Certificate: "Apple Development"
   - ✅ Provisioning Profile: "iOS Team Provisioning Profile"
   - ✅ Bundle Identifier: com.quocphan.expense-tracker

**If you see any yellow/red warnings:**
- Click "Try Again"
- Or click "Download Manual Profiles"
- Xcode will fix most issues automatically

---

## 📱 Step 3: Connect and Detect Your iPhone

1. **Connect iPhone** via USB cable

2. **Unlock iPhone**

3. **Trust this Mac** (prompt on iPhone):
   - Tap "Trust"
   - Enter iPhone passcode

4. **Verify Flutter can see your device:**
   ```bash
   flutter devices
   ```

   You should see something like:
   ```
   Quoc's iPhone (mobile) • 00008030-... • ios • iOS 18.1
   ```

**Troubleshooting:**
- If device not detected:
  - Unplug and replug USB cable
  - Make sure iPhone is unlocked
  - Try a different USB port
  - Restart Xcode: `killall Xcode`

---

## 🚀 Step 4: Build and Deploy to iPhone

### Method 1: Using Flutter CLI (Recommended)

```bash
# Build and install on device
flutter run -d <device-id>

# Or if only one device connected:
flutter run
```

**First build will take 2-3 minutes** (compiling for ARM64).

You'll see:
```
Launching lib/main.dart on Quoc's iPhone in debug mode...
Running Xcode build...
Xcode build done.
Installing and launching...
```

### Method 2: Using VS Code

1. Open VS Code
2. Connect iPhone via USB
3. Click device selector in bottom-right (shows "iPhone 16" currently)
4. Select your physical iPhone from the list
5. Press F5 or click "Run → Start Debugging"

---

## 🔐 Step 5: Trust Developer Certificate (First Time Only)

After the app installs, when you try to open it, you'll see:

**"Untrusted Developer"** alert

**Fix this once:**

1. On iPhone, go to: **Settings → General → VPN & Device Management**
2. Under "DEVELOPER APP", tap your **Apple ID email**
3. Tap **"Trust [Your Email]"**
4. Tap **"Trust"** on the confirmation dialog

**Now open the app again** - it will launch! 🎉

---

## ✅ Step 6: Verify Everything Works

Once the app launches, test:

- [ ] **Launch Screen** - Dark wallet icon appears
- [ ] **App Icon** - Shows on home screen (not Flutter logo)
- [ ] **Login** - Supabase authentication works
- [ ] **Expenses Load** - 912 expenses appear from cloud
- [ ] **Create Expense** - Add a new expense, syncs to cloud
- [ ] **Edit Expense** - Modify an expense
- [ ] **Delete Expense** - Remove an expense
- [ ] **Analytics** - Charts render correctly
- [ ] **Dark Mode** - Toggle in Settings → theme changes instantly
- [ ] **Budget** - View budget in Analytics
- [ ] **Navigation** - All 4 tabs work smoothly
- [ ] **Performance** - Scrolling is smooth, no lag

---

## 🔄 Rebuilding & Reinstalling

### To rebuild and reinstall:

```bash
# Quick rebuild (after code changes)
flutter run -d <device-id>

# Clean rebuild (if issues)
flutter clean
flutter pub get
flutter run -d <device-id>
```

### Hot Reload While Developing:

When app is running via `flutter run`:
- **Press `r`** in terminal → Hot reload (updates UI instantly)
- **Press `R`** in terminal → Hot restart (resets app state)

---

## ⚠️ Common Issues & Solutions

### Issue: "Signing for 'Runner' requires a development team"

**Solution:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Sign in with Apple ID in Xcode preferences
3. Select your team in Signing & Capabilities

---

### Issue: "Could not install app on device"

**Solution:**
- Make sure iPhone is unlocked during installation
- Check USB cable connection
- Enable Developer Mode (iOS 16+)
- Restart iPhone and Mac, try again

---

### Issue: "Unable to launch on device"

**Solution:**
- Trust developer certificate (Settings → General → VPN & Device Management)
- Check iPhone has enough storage (need ~200MB)
- Disconnect other iOS devices

---

### Issue: "Failed to code sign"

**Solution:**
- Make sure you're signed in with Apple ID in Xcode
- Bundle ID must be unique (com.quocphan.expense-tracker)
- Try: Xcode → Product → Clean Build Folder
- Re-enable "Automatically manage signing"

---

### Issue: "App installs but crashes immediately"

**Solution:**
- Check Flutter console for error messages
- Run: `flutter logs` to see device logs
- Verify .env file exists with Supabase credentials
- Check internet connection on iPhone

---

## 📝 Free vs Paid Apple Developer Account

### **Free Account** (What you're using now):

✅ Deploy to your own devices
✅ Test on physical iPhones/iPads
✅ 7-day certificate validity
❌ Can't publish to App Store
❌ Can't use TestFlight
❌ Limited push notifications
❌ Need to re-sign weekly

**Re-signing every 7 days:**
```bash
# Just run this command again:
flutter run -d <device-id>
```

### **Paid Account** ($99/year):

✅ Everything from free account
✅ Publish to App Store
✅ TestFlight beta testing
✅ 1-year certificate validity
✅ Full app capabilities
✅ Analytics and sales reports

**For learning and personal use, free account is perfect!**

---

## 🎯 Success Checklist

You're done when:

- ✅ App installs on your physical iPhone
- ✅ App icon shows on home screen (wallet icon, not Flutter logo)
- ✅ Launch screen displays when opening app
- ✅ App launches without crashes
- ✅ Can login with Supabase
- ✅ Expenses load from cloud
- ✅ Can create/edit/delete expenses
- ✅ Dark mode toggle works
- ✅ All screens accessible
- ✅ Performance is smooth

---

## 🚀 What's Next?

After successful deployment, you can:

1. **Daily Use** - Actually use your app to track expenses!
2. **Test in Real World** - Try in different locations, network conditions
3. **Gather Feedback** - Note any bugs or UX issues
4. **Iterate** - Make improvements based on real usage
5. **Polish Features** - Add loading states, error handling, animations
6. **Consider TestFlight** - If you want beta testers ($99/year account)

---

## 🔗 Useful Commands

```bash
# Check connected devices
flutter devices

# View device logs
flutter logs

# Clean build
flutter clean

# Rebuild dependencies
flutter pub get

# Build release version (faster, smaller)
flutter build ios --release

# Open Xcode project
open ios/Runner.xcworkspace

# Kill and restart Xcode
killall Xcode
```

---

## 📚 Additional Resources

- **Flutter iOS Deployment:** https://docs.flutter.dev/deployment/ios
- **Xcode Help:** https://developer.apple.com/xcode/
- **Apple Developer:** https://developer.apple.com
- **Troubleshooting:** https://flutter.dev/docs/get-started/install/macos

---

**Created:** 2025-01-11
**For:** Expense Tracker iOS Deployment
**Status:** Ready to deploy! 🚀
