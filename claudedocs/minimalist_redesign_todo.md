# Minimalist Redesign - Todo List

**Start Date**: November 2025
**Estimated Duration**: 11.5 hours
**Branch**: `feature/minimalist-redesign`

---

## 📊 Progress Overview

- **Total Tasks**: 75
- **Completed**: 0
- **In Progress**: 0
- **Remaining**: 75
- **Progress**: 0%

---

## 🎯 Pre-Implementation (30 min)

### Documentation
- [ ] Create `minimalist_redesign_plan.md` ✅ DONE
- [ ] Create `minimalist_redesign_todo.md` ✅ DONE
- [ ] Create `lib/theme/minimalist/README.md`
- [ ] Create branch `feature/minimalist-redesign`
- [ ] Commit documentation files

---

## 📦 Phase A: Foundation Setup (2 hours)

### Package Installation (15 min)
- [ ] Add `phosphor_flutter: ^2.1.0` to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Verify package imports work
- [ ] Test basic Phosphor icon rendering

### Theme Structure (45 min)
- [ ] Create `lib/theme/minimalist/` directory
- [ ] Create `lib/theme/minimalist/minimalist_colors.dart`
  - [ ] Define grayscale palette (gray50-gray900)
  - [ ] Define semantic colors (success, warning, error)
  - [ ] Add color helper methods
- [ ] Create `lib/theme/minimalist/minimalist_typography.dart`
  - [ ] Define 3 font weights only
  - [ ] Create 5 text size levels
  - [ ] Set up text theme

### Icon System (45 min)
- [ ] Create `lib/theme/minimalist/minimalist_icons.dart`
  - [ ] Import Phosphor icons
  - [ ] Create navigation icon mappings
  - [ ] Create category icon mappings
  - [ ] Create action icon mappings
  - [ ] Create form field icon mappings
  - [ ] Add expense type icons

### Theme Configuration (15 min)
- [ ] Create `lib/theme/minimalist/minimalist_theme.dart`
  - [ ] Configure ColorScheme
  - [ ] Set up ThemeData
  - [ ] Configure component themes
- [ ] Update `lib/theme/app_theme.dart` to include minimalist option
- [ ] Test theme switching

### Checkpoint
- [ ] All foundation files created
- [ ] Theme can be activated
- [ ] Icons display correctly
- [ ] Commit: "feat: Add minimalist theme foundation"

---

## 🎨 Phase B: Icon Migration (2 hours)

### Navigation Bar (30 min)
- [ ] Update `lib/screens/main_navigation_screen.dart`
  - [ ] Replace expenses tab icon (receipt)
  - [ ] Replace analytics tab icon (chartPie)
  - [ ] Implement light/fill state switching
  - [ ] Test navigation visual states

### Category Icons (45 min)
- [ ] Update `lib/models/expense.dart`
  - [ ] Import minimalist_icons.dart
  - [ ] Update `categoryIcon` getter
  - [ ] Map all 14 categories to Phosphor icons
  - [ ] Test category display in lists
- [ ] Verify icons in expense list screen
- [ ] Verify icons in analytics screen

### Form Icons (30 min)
- [ ] Update `lib/screens/add_expense_screen.dart`
  - [ ] Replace description field icon
  - [ ] Replace amount field icon
  - [ ] Replace category dropdown icon
  - [ ] Replace date picker icon
  - [ ] Replace notes field icon
- [ ] Update `lib/screens/edit_expense_screen.dart` similarly

### Action Icons (15 min)
- [ ] Replace FAB add icon
- [ ] Replace settings icon
- [ ] Replace logout icon
- [ ] Replace delete swipe icon
- [ ] Replace edit icon

### Checkpoint
- [ ] All Material Icons replaced
- [ ] Icons consistent across app
- [ ] Visual hierarchy maintained
- [ ] Commit: "feat: Complete Phosphor icon migration"

---

## 🎨 Phase C: Color Simplification (2 hours)

### Remove Category Colors (45 min)
- [ ] Update `lib/theme/constants/app_colors.dart`
  - [ ] Comment out category color map
  - [ ] Create grayscale category backgrounds
  - [ ] Update category color getter
- [ ] Update `lib/widgets/category_chart.dart`
  - [ ] Use gray bars instead of colored
  - [ ] Black for selected/active state
  - [ ] Remove gradient definitions

### Fix Expense Type Colors (30 min)
- [ ] Fix color conflict in `expense.dart`
  - [ ] Remove hardcoded Colors.green/blue/red
  - [ ] Use consistent gray shades
  - [ ] Add icon differentiation instead
- [ ] Update `lib/widgets/summary_cards/type_breakdown_card.dart`
  - [ ] Remove colored progress bars
  - [ ] Use gray with black accent
  - [ ] Add Phosphor type icons

### Update Budget Indicators (30 min)
- [ ] Update `lib/widgets/budget_alert_banner.dart`
  - [ ] Remove gradient backgrounds
  - [ ] Use subtle background colors
  - [ ] Simplify to flat design
  - [ ] Remove pulse animation
- [ ] Update `lib/widgets/summary_cards/monthly_overview_card.dart`
  - [ ] Gray progress bar under limit
  - [ ] Black when near limit
  - [ ] Red only when over

### Chart Simplification (15 min)
- [ ] Update `lib/widgets/trends_chart.dart`
  - [ ] Remove gradient fill
  - [ ] Use single line color
  - [ ] Simplify dot indicators
- [ ] Update `lib/widgets/category_chart.dart`
  - [ ] Remove bar gradients
  - [ ] Flat gray bars

### Checkpoint
- [ ] All category colors removed
- [ ] Charts monochromatic
- [ ] Budget colors simplified
- [ ] Commit: "feat: Implement grayscale color system"

---

## ✏️ Phase D: Typography & Layout (1.5 hours)

### Font Weight Reduction (30 min)
- [ ] Update `lib/theme/constants/app_typography.dart`
  - [ ] Reduce to 3 weights (400, 500, 600)
  - [ ] Update all text styles
  - [ ] Remove bold (700) weight
  - [ ] Remove light (300) weight

### Text Hierarchy Simplification (30 min)
- [ ] Reduce display styles to 1 (32px hero)
- [ ] Simplify headline styles (20px)
- [ ] Standardize body text (16px)
- [ ] Update caption styles (14px, 12px)
- [ ] Remove unnecessary variations

### Spacing Adjustments (30 min)
- [ ] Increase whitespace between sections
- [ ] Standardize card padding (16px)
- [ ] Unify list item spacing
- [ ] Adjust screen padding
- [ ] Add breathing room to dense areas

### Checkpoint
- [ ] Only 3 font weights in use
- [ ] Text hierarchy clear
- [ ] Improved whitespace
- [ ] Commit: "feat: Simplify typography hierarchy"

---

## 💎 Phase E: Component Polish (2 hours)

### Card Flattening (45 min)
- [ ] Update `lib/widgets/summary_cards/summary_stat_card.dart`
  - [ ] Remove gradient backgrounds
  - [ ] Flatten to white background
  - [ ] Add subtle gray border
  - [ ] Simplify shadow to single layer
- [ ] Update all summary cards similarly
- [ ] Update expense list item cards

### Shadow Simplification (30 min)
- [ ] Create single shadow style
- [ ] Update all elevated components
- [ ] Remove multi-layer shadows
- [ ] Reduce shadow opacity
- [ ] Test visual hierarchy

### Form Field Updates (30 min)
- [ ] Update `lib/widgets/enhanced_text_field.dart`
  - [ ] Remove focus glow effect
  - [ ] Use simple black underline
  - [ ] Simplify error states
- [ ] Update dropdown fields similarly
- [ ] Test form interactions

### Animation Cleanup (15 min)
- [ ] Remove unnecessary animations
- [ ] Simplify remaining transitions
- [ ] Remove pulse effects
- [ ] Keep only essential motion

### Checkpoint
- [ ] All cards flattened
- [ ] Shadows simplified
- [ ] Forms minimalist
- [ ] Commit: "feat: Polish components for minimalism"

---

## ✅ Phase F: Testing & Validation (1.5 hours)

### Visual Consistency (30 min)
- [ ] Check all screens for consistency
- [ ] Verify icon alignment
- [ ] Check text hierarchy
- [ ] Validate spacing uniformity
- [ ] Screenshot all screens

### Accessibility Testing (30 min)
- [ ] Run contrast checker (WCAG AA)
- [ ] Test with large text
- [ ] Verify touch targets
- [ ] Check color blind modes
- [ ] Test screen reader

### Dark Mode (15 min)
- [ ] Switch to dark mode
- [ ] Verify all colors adapt
- [ ] Check contrast in dark
- [ ] Fix any broken elements

### Performance Testing (15 min)
- [ ] Measure render times
- [ ] Check animation smoothness
- [ ] Profile memory usage
- [ ] Compare to baseline

### Checkpoint
- [ ] All tests passing
- [ ] Accessibility compliant
- [ ] Performance improved
- [ ] Commit: "test: Validate minimalist redesign"

---

## 🧹 Cleanup & Documentation (30 min)

### Code Cleanup
- [ ] Remove old unused styles
- [ ] Delete deprecated color definitions
- [ ] Clean up commented code
- [ ] Optimize imports

### Documentation Updates
- [ ] Update README with new theme
- [ ] Create migration guide
- [ ] Document design decisions
- [ ] Add screenshots to docs

### Memory & Learning
- [ ] Update Serena memories
- [ ] Document lessons learned
- [ ] Create style guide
- [ ] Note future improvements

### Final Tasks
- [ ] Create PR description
- [ ] Add before/after screenshots
- [ ] Update version number
- [ ] Final commit and push

---

## 📈 Metrics to Track

### Before Redesign
- Colors used: ___
- Font weights: ___
- Render time: ___ ms
- Bundle size: ___ KB

### After Redesign
- Colors used: ___
- Font weights: ___
- Render time: ___ ms
- Bundle size: ___ KB

### Improvements
- Color reduction: ___%
- Performance gain: ___%
- Size reduction: ___%
- Contrast improvement: ___

---

## 🚨 Potential Issues & Solutions

### Issue: Icons not rendering
**Solution**: Check Phosphor import, verify pubspec.yaml

### Issue: Colors look too plain
**Solution**: Adjust gray shades, add subtle accent

### Issue: Text hard to read
**Solution**: Increase contrast, adjust gray values

### Issue: Lost visual hierarchy
**Solution**: Emphasize typography differences

### Issue: Dark mode broken
**Solution**: Test all theme colors for both modes

---

## ✅ Definition of Done

Each phase is complete when:
1. All checkboxes marked
2. Visual review passed
3. No console errors
4. Code committed
5. Screenshots taken

Redesign is complete when:
1. All phases done
2. Testing passed
3. Documentation updated
4. PR approved
5. Merged to develop

---

## 📝 Notes Section

### Decisions Made
-

### Issues Encountered
-

### Lessons Learned
-

### Future Improvements
-

---

**Last Updated**: [Timestamp]
**Current Phase**: Pre-Implementation
**Next Action**: Create minimalist theme README