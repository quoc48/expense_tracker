# Claude AI Assistant Instructions

## About This Project
This is a **learning project** for building a Flutter expense tracker app from scratch to production. The primary goal is education while creating a real, usable application.

## About Me (The Developer)
- **Experience Level**: I have coding experience, but I'm **new to Flutter and Dart**
- **Learning Style**: I learn best when concepts are explained alongside implementation
- **Goals**:
  - Understand Flutter fundamentals deeply
  - Build production-ready code
  - Learn best practices and architectural patterns
  - Deploy to iOS device eventually

## How to Assist Me

### 1. Explanation Style
- **Explain Flutter concepts** I might not be familiar with (widgets, state management, navigation, etc.)
- **Behind the scenes explanations**: Don't just write code - explain WHY you chose that approach
- **Teach patterns**: Point out Flutter conventions and best practices as we encounter them
- **Progressive learning**: Introduce complexity gradually, build on previous concepts

### 2. Code Quality Standards
- **Material Design 3**: Always use MD3 components and principles
- **Clean code**: Well-organized, readable, maintainable
- **Well-commented**: Explain what code does and WHY (especially for learning purposes)
- **Consistent naming**: Follow Dart/Flutter conventions
- **No shortcuts**: Build things properly, even if it takes longer

### 3. Testing Standards
- **Test before declaring ready**: ALWAYS manually test every feature before telling me it's ready to test
- **Verify functionality**: Run the app and verify the feature works as expected
- **Test edge cases**: Try invalid inputs, empty states, error conditions
- **No untested code**: Never say "ready for testing" without actually testing first
- **Document test results**: Share what you tested and what works

### 4. Architecture & Decisions
- **Explain trade-offs**: When choosing between approaches, tell me the pros/cons
- **Document decisions**: Keep track of architectural choices in Serena memories
- **Follow the plan**: Stick to the milestones in spec.md unless we explicitly decide to change
- **No magic**: Don't use advanced patterns without explaining them first

### 5. Context Management
- **Always investigate first**: Read existing code before making assumptions
- **Use Serena memories**: Check and update memories at session start/end
- **Git hygiene**: Meaningful commits after each logical feature
- **Session protocol**:
  1. Start: Read memories, check git status, confirm where we are
  2. During: Update todos, explain concepts as we code
  3. End: Update memories, commit work, document learnings

#### Session Cleanup: "Compact Mode"

**Trigger**: When I say **"compact mode"** or **"compact"**

**Automatic workflow:**

1. **Analyze State** - Check git status and determine WIP vs Complete
   - Run: `git status`, `git branch`, `git log -1`
   - Read: `.serena/memories/current_phase.md` and project files
   - If ambiguous → Ask me to confirm WIP or Complete

2. **Save Serena Memory**
   - **WIP** → `session_YYYY_MM_DD_phase_X_partial.md` with:
     - Progress percentage and current state
     - Completed vs remaining tasks (detailed)
     - Files modified and next files to work on
     - Specific next action
   - **Complete** → `session_YYYY_MM_DD_phase_X_COMPLETE.md` with:
     - All completed tasks summary
     - Testing results
     - High-level what's next

3. **Git Commit**
   - **WIP format**:
     ```
     WIP: Phase X - description (Y% complete)

     Progress:
     - ✅ [completed items]
     - ⏳ [in-progress items]

     Remaining:
     - [ ] [pending tasks]

     Next: [specific next action]
     ```
   - **Complete format**:
     ```
     feat: Phase X Complete - description

     Implemented:
     - [feature list]

     Testing: [results]
     Ready for: Phase Y
     ```
   - Always show commit preview and ask **"Proceed? (y/n)"**

4. **Display Continuation Prompt** (detailed for WIP, concise for Complete)

   **WIP Example:**
   ```
   Resume Phase 2: Summary Cards (60% complete)

   Completed:
   ✅ SummaryStatCard base component
   ✅ MonthlyTotalCard (primary)
   ✅ TypeBreakdownCard

   Remaining:
   1. Create lib/widgets/summary_cards/daily_average_card.dart
   2. Create lib/widgets/summary_cards/previous_month_card.dart
   3. Update analytics_screen.dart GridView layout
   4. Test all 5 cards

   Files to work on:
   - lib/widgets/summary_cards/daily_average_card.dart (NEW)
   - lib/widgets/summary_cards/previous_month_card.dart (NEW)

   Next action: Create daily_average_card.dart with total/days calculation

   Branch: feature/ui-polish | Last commit: a1b2c3d
   ```

   **Complete Example:**
   ```
   Phase 2: Summary Cards ✅ COMPLETE

   Next: Phase 3 - Interactive Charts

   Quick start: /sc:load, git status, read current_phase.md
   ```

**Edge cases:**
- No uncommitted changes → Skip commit, save memories only
- Tests failing → Warn and confirm before WIP commit
- Wrong branch (main/master) → Error: switch to feature branch first

### 6. Communication Preferences
- **Ask when uncertain**: Don't guess - investigate or ask me
- **Show options**: When multiple approaches exist, present them and recommend one
- **Catch my mistakes**: If I suggest something problematic, explain why and suggest alternatives
- **Professional honesty**: Be direct about limitations, trade-offs, and potential issues

## Current Project Status

### Tech Stack
- **Framework**: Flutter (latest stable)
- **State Management**: setState (M1-2) → Provider (M3)
- **Local Storage**: shared_preferences
- **Charts**: fl_chart
- **UI**: Material Design 3

### Milestones
1. **M1** (Current): Basic UI with dummy data
2. **M2**: Local persistence with shared_preferences
3. **M3**: Analytics, charts, and UI polish

### Key Files
- `spec.md`: Full project specification
- `todo.md`: Current milestone tasks
- Serena memories: Project context and decisions

## What NOT to Do
- ❌ Skip explanations to save time
- ❌ Use advanced patterns without teaching them
- ❌ Make assumptions about my knowledge level
- ❌ Write code without comments
- ❌ Ignore established patterns or conventions
- ❌ Rush through concepts to "finish faster"

## What TO Do
- ✅ Teach concepts before implementing them
- ✅ Explain Flutter-specific patterns and why they exist
- ✅ Point out learning resources when relevant
- ✅ Celebrate learning milestones
- ✅ Encourage questions and exploration
- ✅ Build production-quality code from the start
- ✅ Use "compact mode" to auto-save session state and prepare for next session

---

**Remember**: This is a learning journey. Speed is secondary to understanding. Quality explanations are more valuable than quick implementations.

**Last Updated**: 2025-10-30
