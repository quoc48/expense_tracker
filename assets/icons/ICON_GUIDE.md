# App Icon Creation Guide

## Quick Option 1: Use AppIcon.co (Recommended - 2 minutes)

1. **Go to:** https://www.appicon.co/#app-icon
2. **Design your icon:**
   - Choose "Icon" mode
   - Search for "wallet" icon
   - Or search for "receipt", "money", "payment"
   - Pick a style you like
   - Customize colors (use your app theme color)
   - Background: Solid color or gradient

3. **Export:**
   - Click "Generate"
   - Download the 1024x1024 PNG
   - Rename it to `app_icon.png`
   - Place it in `assets/icons/app_icon.png`

4. **Back in terminal:**
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

---

## Quick Option 2: Use Emoji as Icon (Fastest - 30 seconds)

1. **Go to:** https://favicon.io/emoji-favicons/
2. **Pick emoji:** 👛 (wallet) or 💰 (money bag) or 💳 (credit card)
3. **Download PNG**
4. **Resize to 1024x1024** (use any image editor or online tool)
5. **Save as:** `assets/icons/app_icon.png`

---

## Quick Option 3: Create in Figma/Canva (Custom - 5 minutes)

### Figma:
1. Create 1024x1024 frame
2. Draw simple wallet shape or use icon plugin
3. Export as PNG @ 1x

### Canva:
1. Create custom size: 1024x1024 px
2. Search "wallet icon" in elements
3. Customize colors
4. Download as PNG

---

## Design Guidelines

**Colors (from your app theme):**
- Primary: Use your app's primary color
- Background: Solid color or gradient
- Keep it simple - will be viewed at small sizes

**Style:**
- Minimalist (matches your app!)
- Clear at small sizes (60x60)
- Works on both light and dark backgrounds
- No text (icon only)
- No transparency (iOS requirement)

**Wallet Icon Ideas:**
- Simple wallet outline
- Receipt/document icon
- Money/coins symbol
- Vietnamese Dong symbol (₫)
- Credit card icon

---

## Current Status

**Waiting for:** `assets/icons/app_icon.png` (1024x1024 PNG)

Once you place the icon file, run:
```bash
flutter pub get
dart run flutter_launcher_icons
```

This will automatically generate all required iOS icon sizes!
