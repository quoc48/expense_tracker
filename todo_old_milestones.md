# Expense Tracker - Advanced Features TODO

## 🎉 MVP Complete - Milestones 1-3 ✅

**Completed**: October 26, 2025

For MVP task history, see [`docs/mvp/todo.md`](docs/mvp/todo.md)

**MVP Delivered:**
- ✅ Complete CRUD operations
- ✅ Local data persistence
- ✅ Bottom navigation with two tabs
- ✅ Provider state management
- ✅ Analytics dashboard with charts
- ✅ Category breakdown (bar chart)
- ✅ Spending trends (line chart)

---

## 📋 Next Session Preparation

### Before Starting Milestone 4
- [ ] Review [`spec.md`](spec.md) - Advanced features specification
- [ ] Review Vietnamese categories table in spec.md
- [ ] Create Supabase account at [supabase.com](https://supabase.com)
- [ ] Export Notion expense database to CSV
- [ ] Create `develop` branch from `main`
- [ ] Create `feature/supabase-setup` branch from `develop`

---

## Milestone 4: Supabase Infrastructure

**Status**: Not Started
**Estimated Duration**: 2-3 sessions
**Goal**: Set up cloud backend and migrate Notion data

### Phase 4.1: Supabase Project Setup
- [ ] Create Supabase account and new project
- [ ] Configure project settings
- [ ] Set up environment variables in Flutter
  - Create `.env` file
  - Add `SUPABASE_URL`
  - Add `SUPABASE_ANON_KEY`
- [ ] Add `supabase_flutter` dependency to pubspec.yaml
- [ ] Install dependencies (`flutter pub get`)
- [ ] Initialize Supabase in Flutter app

### Phase 4.2: Database Schema Implementation
- [ ] Create `categories` table (14 Vietnamese categories)
- [ ] Create `expense_types` table (3 types with Vietnamese names)
- [ ] Create `expenses` table (with FKs to categories/types)
- [ ] Create `budgets` table (for Milestone 6)
- [ ] Create `recurring_expenses` table (for Milestone 6)
- [ ] Set up all indexes for performance
- [ ] Configure Row Level Security (RLS) policies
- [ ] Test RLS policies

### Phase 4.3: Seed Data
- [ ] Seed 14 Vietnamese categories from spec.md
- [ ] Seed 3 expense types (Vietnamese names)
- [ ] Verify seed data in Supabase dashboard

### Phase 4.4: Notion Data Migration
- [ ] Export Notion database to CSV
- [ ] Review CSV structure and data quality
- [ ] Create Python migration script
  - Install dependencies (`pandas`, `supabase-py`)
  - Map Vietnamese categories to Supabase UUIDs
  - Transform CSV data to match schema
  - Handle data validation
- [ ] Run migration script
- [ ] Validate migrated data
  - Count total expenses
  - Sum by category matches
  - Date range verification
  - No missing categories

### Phase 4.5: Testing & Verification
- [ ] Test database queries in Supabase dashboard
- [ ] Verify RLS policies prevent unauthorized access
- [ ] Confirm all Vietnamese categories display correctly
- [ ] Document any migration issues or data cleaning needed

**Milestone 4 Completion Criteria**:
- ✅ Supabase project fully configured
- ✅ All tables created with correct schema
- ✅ RLS policies tested and working
- ✅ 14 Vietnamese categories seeded
- ✅ Real Notion data migrated successfully
- ✅ Data integrity validated

---

## Milestone 5: Authentication + Cloud Sync

**Status**: Not Started
**Estimated Duration**: 3-4 sessions
**Goal**: Add user auth and real-time synchronization

### Phase 5.1: Authentication Screens
- [ ] Create `lib/screens/auth/` directory
- [ ] Create `login_screen.dart`
- [ ] Create `signup_screen.dart`
- [ ] Create `forgot_password_screen.dart`
- [ ] Add email/password validation
- [ ] Style auth screens with Material Design 3

### Phase 5.2: Auth State Management
- [ ] Create `AuthProvider` or use Supabase auth state
- [ ] Add auth check on app startup
- [ ] Route to login if not authenticated
- [ ] Persist auth session
- [ ] Handle logout functionality
- [ ] Add user profile screen (optional)

### Phase 5.3: Protected Routes
- [ ] Wrap main app with auth check
- [ ] Show login screen for unauthenticated users
- [ ] Navigate to main app after successful login
- [ ] Handle session expiration

### Phase 5.4: Repository Pattern
- [ ] Create `ExpenseRepository` interface
- [ ] Implement `LocalExpenseRepository` (SharedPreferences)
- [ ] Implement `SupabaseExpenseRepository`
- [ ] Update `ExpenseProvider` to use repositories

### Phase 5.5: Sync Service
- [ ] Create `SyncService` class
- [ ] Implement push to Supabase (local → cloud)
- [ ] Implement pull from Supabase (cloud → local)
- [ ] Add conflict resolution (last-write-wins)
- [ ] Handle sync errors and retry logic
- [ ] Add periodic background sync

### Phase 5.6: Offline Support
- [ ] Queue operations when offline
- [ ] Retry failed syncs when online
- [ ] Show sync status indicator in UI
- [ ] Handle network state changes
- [ ] Test offline → online transitions

**Milestone 5 Completion Criteria**:
- ✅ Users can sign up and login
- ✅ Protected routes work correctly
- ✅ Expenses sync to/from Supabase
- ✅ Offline mode works (queue + retry)
- ✅ Real-time updates from other devices
- ✅ Sync status visible to user

---

## Milestone 6: Advanced Features

**Status**: Not Started
**Estimated Duration**: 3-4 sessions
**Goal**: Add recurring expenses and budget tracking

### Phase 6.1: Recurring Expenses
- [ ] Create `RecurringExpense` model
- [ ] Create recurring expense management screen
- [ ] Add recurring expense form (add/edit)
- [ ] Implement auto-creation service
  - Check daily/on app open
  - Create expenses based on frequency
  - Update last_created_date
- [ ] Sync recurring expenses with Supabase
- [ ] Add enable/disable toggle
- [ ] Test frequency logic (daily, weekly, monthly, yearly)

### Phase 6.2: Budget Tracking
- [ ] Create `Budget` model
- [ ] Create budget setup screen
- [ ] Add budget per category
- [ ] Calculate budget vs actual spending
- [ ] Show progress indicators
- [ ] Add budget alerts (80%, 100% thresholds)
- [ ] Display remaining budget per category
- [ ] Sync budgets with Supabase

### Phase 6.3: Analytics Enhancement
- [ ] Add budget lines to charts
- [ ] Show budget vs actual comparison
- [ ] Add monthly budget adherence score
- [ ] Update category chart with budget overlay

**Milestone 6 Completion Criteria**:
- ✅ Recurring expenses auto-create correctly
- ✅ Budgets can be set per category
- ✅ Budget tracking shows real-time progress
- ✅ Alerts trigger at 80% and 100%
- ✅ Analytics show budget comparisons

---

## Milestone 7: Production Polish

**Status**: Not Started
**Estimated Duration**: 2-3 sessions
**Goal**: Make app production-ready for App Store

### Phase 7.1: UI/UX Polish
- [ ] Add loading animations
- [ ] Improve error messages
- [ ] Add smooth transitions between screens
- [ ] Show network status indicator
- [ ] Add pull-to-refresh on expense list
- [ ] Polish empty states
- [ ] Add confirmation dialogs where needed

### Phase 7.2: Onboarding
- [ ] Create onboarding flow for new users
- [ ] Add feature highlights
- [ ] Create tutorial overlays
- [ ] Add skip option

### Phase 7.3: App Assets
- [ ] Design app icon
- [ ] Create launch screen
- [ ] Design App Store screenshots
- [ ] Write app description
- [ ] Create privacy policy (required for cloud sync)

### Phase 7.4: Testing
- [ ] Multi-device sync testing
- [ ] Offline/online transition testing
- [ ] Conflict resolution testing
- [ ] Performance testing
- [ ] Edge case testing
- [ ] TestFlight beta testing

### Phase 7.5: App Store Preparation
- [ ] Configure App Store Connect
- [ ] Upload build to TestFlight
- [ ] Gather beta tester feedback
- [ ] Fix critical bugs
- [ ] Submit for App Store review

**Milestone 7 Completion Criteria**:
- ✅ App is polished and bug-free
- ✅ Onboarding flow complete
- ✅ App assets created
- ✅ Privacy policy published
- ✅ TestFlight testing complete
- ✅ Ready for App Store submission

---

## 🔀 Git Workflow

### Branch Structure
```
main          ← Stable MVP (production-ready)
└── develop   ← Integration branch for M4-7
     ├── feature/supabase-setup
     ├── feature/authentication
     ├── feature/cloud-sync
     ├── feature/recurring-expenses
     └── feature/budget-tracking
```

### Workflow Commands
```bash
# Initial setup (do once)
git checkout main
git checkout -b develop

# For each feature
git checkout develop
git checkout -b feature/supabase-setup
# ... work on feature ...
git add .
git commit -m "Descriptive message"
git checkout develop
git merge feature/supabase-setup

# After milestone complete
git checkout main
git merge develop --no-ff
git tag v2.0.0-beta
```

---

## 📊 Progress Tracking

| Milestone | Status | Completion |
|-----------|--------|------------|
| M1: Basic UI | ✅ Complete | 100% |
| M2: Persistence | ✅ Complete | 100% |
| M3: Analytics | ✅ Complete | 100% |
| M4: Supabase | ⏳ Not Started | 0% |
| M5: Auth + Sync | ⏳ Not Started | 0% |
| M6: Features | ⏳ Not Started | 0% |
| M7: Polish | ⏳ Not Started | 0% |

**Overall Progress**: 3/7 milestones (43%)

---

## 🎯 Next Session Checklist

When starting next session:
1. ✅ Review this todo.md
2. ✅ Read `spec.md` for technical details
3. ✅ Read Serena memory: `milestone_4_7_planning.md`
4. ✅ Ensure Notion data exported
5. ✅ Create Supabase account if not done
6. ✅ Create `develop` branch
7. ✅ Start Milestone 4, Phase 4.1

---

**Last Updated**: October 26, 2025
**Current Focus**: Preparing for Milestone 4
**Next Task**: Review spec.md and create Supabase account
