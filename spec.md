# Expense Tracker - Advanced Features Specification

## 📊 Project Status

**MVP Status**: ✅ Complete (Milestones 1-3)
**Current Phase**: Planning Milestone 4-7 (Cloud Sync + Advanced Features)
**Next Milestone**: M4 - Supabase Infrastructure

---

## 🎯 Overview

This specification outlines advanced features for the Expense Tracker app, focusing on:
1. **Cloud Sync with Supabase** - Real-time synchronization across devices
2. **Notion Data Migration** - Import existing expense data from Notion
3. **Vietnamese Category Support** - Preserve 14 Vietnamese categories from Notion
4. **Advanced Features** - Recurring expenses and budget tracking

---

## 🌏 Vietnamese Categories (From Notion)

### Current Notion Categories (14 total)

| Vietnamese Name | English Translation | Icon | Color | Notes |
|----------------|-------------------|------|-------|-------|
| Thực phẩm | Food | restaurant | #FF6B6B | General food items |
| Sức khỏe | Health | medical_services | #4ECDC4 | Healthcare, medicine |
| Thời trang | Fashion | checkroom | #95E1D3 | Clothing, accessories |
| Giải trí | Entertainment | movie | #F38181 | Movies, games, hobbies |
| Tiền nhà | Housing | home | #AA96DA | Rent, mortgage |
| Hoá đơn | Bills | receipt_long | #FCBAD3 | Utilities, services |
| Biểu gia đình | Family | family_restroom | #A8D8EA | Family expenses |
| Giáo dục | Education | school | #FFCB85 | Courses, books |
| TẾT | Tet Holiday | celebration | #FF6B6B | Vietnamese New Year |
| Quà vật | Gifts | card_giftcard | #FFE66D | Presents, donations |
| Tạp hoá | Groceries | local_grocery_store | #C7CEEA | Daily supplies |
| Đi lại | Transportation | directions_car | #B4F8C8 | Commute, fuel |
| Du lịch | Travel | flight | #FBE7C6 | Tourism, trips |
| Cà phê | Coffee | local_cafe | #A0E7E5 | Coffee shops, cafes |

**Design Decision**: Keep all 14 Vietnamese categories to preserve data accuracy during Notion migration.

---

## 🗄️ Supabase Database Schema

### Architecture: Normalized Tables

**Decision**: Use separate tables for categories and types instead of enums in the expense table.

**Reasons**:
- ✅ Enables custom user categories in the future
- ✅ Supports bilingual names (Vietnamese + English)
- ✅ Better data integrity with foreign key constraints
- ✅ Easier to add metadata (icons, colors, sorting)
- ✅ Supabase enforces referential integrity

### Table Schemas

#### 1. `categories` Table
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),  -- NULL = system category
  name_vi TEXT NOT NULL,                    -- Vietnamese name (primary)
  name_en TEXT,                             -- English name (for i18n)
  icon_name TEXT NOT NULL,                  -- Material Icon identifier
  color_hex TEXT NOT NULL,                  -- Display color (#RRGGBB)
  is_system BOOLEAN DEFAULT false,          -- System categories cannot be deleted
  display_order INTEGER NOT NULL,           -- Sort order in UI
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP                      -- Soft delete
);

-- Indexes
CREATE INDEX idx_categories_user_id ON categories(user_id);
CREATE INDEX idx_categories_display_order ON categories(display_order);

-- RLS Policies
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all categories"
  ON categories FOR SELECT
  USING (user_id IS NULL OR user_id = auth.uid());

CREATE POLICY "Users can manage their own categories"
  ON categories FOR ALL
  USING (user_id = auth.uid());
```

**Seed Data (14 Vietnamese Categories)**:
```sql
INSERT INTO categories (name_vi, name_en, icon_name, color_hex, is_system, display_order)
VALUES
  ('Thực phẩm', 'Food', 'restaurant', '#FF6B6B', true, 1),
  ('Sức khỏe', 'Health', 'medical_services', '#4ECDC4', true, 2),
  ('Thời trang', 'Fashion', 'checkroom', '#95E1D3', true, 3),
  ('Giải trí', 'Entertainment', 'movie', '#F38181', true, 4),
  ('Tiền nhà', 'Housing', 'home', '#AA96DA', true, 5),
  ('Hoá đơn', 'Bills', 'receipt_long', '#FCBAD3', true, 6),
  ('Biểu gia đình', 'Family', 'family_restroom', '#A8D8EA', true, 7),
  ('Giáo dục', 'Education', 'school', '#FFCB85', true, 8),
  ('TẾT', 'Tet Holiday', 'celebration', '#FF6B6B', true, 9),
  ('Quà vật', 'Gifts', 'card_giftcard', '#FFE66D', true, 10),
  ('Tạp hoá', 'Groceries', 'local_grocery_store', '#C7CEEA', true, 11),
  ('Đi lại', 'Transportation', 'directions_car', '#B4F8C8', true, 12),
  ('Du lịch', 'Travel', 'flight', '#FBE7C6', true, 13),
  ('Cà phê', 'Coffee', 'local_cafe', '#A0E7E5', true, 14);
```

#### 2. `expense_types` Table
```sql
CREATE TABLE expense_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,           -- "phat_sinh", "phai_chi", "lang_phi"
  name_vi TEXT NOT NULL,              -- Vietnamese display name
  name_en TEXT,                       -- English display name
  color_hex TEXT NOT NULL,            -- Type color
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now()
);

-- RLS: Public read-only
ALTER TABLE expense_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view expense types"
  ON expense_types FOR SELECT
  USING (true);
```

**Seed Data**:
```sql
INSERT INTO expense_types (key, name_vi, name_en, color_hex) VALUES
  ('phat_sinh', 'Phát sinh', 'Incurred', '#4CAF50'),
  ('phai_chi', 'Phải chi', 'Must Pay', '#FFC107'),
  ('lang_phi', 'Lãng phí', 'Wasted', '#F44336');
```

#### 3. `expenses` Table
```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id),
  type_id UUID NOT NULL REFERENCES expense_types(id),
  description TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP,               -- Soft delete

  -- Sync metadata
  local_id TEXT,                      -- Original local UUID (for migration)
  last_synced_at TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date DESC);
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_created_at ON expenses(created_at DESC);

-- RLS Policies
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own expenses"
  ON expenses FOR SELECT
  USING (user_id = auth.uid() AND deleted_at IS NULL);

CREATE POLICY "Users can insert own expenses"
  ON expenses FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own expenses"
  ON expenses FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can soft delete own expenses"
  ON expenses FOR UPDATE
  USING (user_id = auth.uid() AND deleted_at IS NULL);
```

#### 4. `budgets` Table (Milestone 6)
```sql
CREATE TABLE budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id),
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  month DATE NOT NULL,                -- First day of month
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),

  UNIQUE(user_id, category_id, month)  -- One budget per category per month
);

CREATE INDEX idx_budgets_user_month ON budgets(user_id, month);

ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own budgets"
  ON budgets FOR ALL
  USING (user_id = auth.uid());
```

#### 5. `recurring_expenses` Table (Milestone 6)
```sql
CREATE TABLE recurring_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id),
  type_id UUID NOT NULL REFERENCES expense_types(id),
  description TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
  start_date DATE NOT NULL,
  end_date DATE,                      -- NULL = no end date
  last_created_date DATE,             -- Track when last expense was created
  is_active BOOLEAN DEFAULT true,
  note TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_recurring_active ON recurring_expenses(user_id, is_active);

ALTER TABLE recurring_expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own recurring expenses"
  ON recurring_expenses FOR ALL
  USING (user_id = auth.uid());
```

---

## 🔄 Notion → Supabase Migration Strategy

### Migration Steps

#### 1. Export Notion Database
1. Open Notion database
2. Click "..." menu → Export
3. Choose format: CSV
4. Download export file

Expected CSV columns:
- Name (Description)
- Amount
- Category (Vietnamese name - one of 14 categories)
- Type (Vietnamese name - one of: Phát sinh, Phải chi, Lãng phí)
- Date
- Notes (optional)

#### 2. Vietnamese Mappings

**Category Mapping** (14 categories)  
Create mapping between Notion Vietnamese categories and Supabase category IDs:

```python
# After seeding categories in Supabase, fetch and create mapping
category_mapping = {
    'Thực phẩm': 'uuid-from-supabase-1',
    'Sức khỏe': 'uuid-from-supabase-2',
    'Thời trang': 'uuid-from-supabase-3',
    'Giải trí': 'uuid-from-supabase-4',
    'Tiền nhà': 'uuid-from-supabase-5',
    'Hoá đơn': 'uuid-from-supabase-6',
    'Biểu gia đình': 'uuid-from-supabase-7',
    'Giáo dục': 'uuid-from-supabase-8',
    'TẾT': 'uuid-from-supabase-9',
    'Quà vật': 'uuid-from-supabase-10',
    'Tạp hoá': 'uuid-from-supabase-11',
    'Đi lại': 'uuid-from-supabase-12',
    'Du lịch': 'uuid-from-supabase-13',
    'Cà phê': 'uuid-from-supabase-14'
}
```

**Expense Type Mapping** (3 types from Notion)  
Map Notion Vietnamese types to Supabase type IDs:

```python
# After seeding expense_types in Supabase, fetch and create mapping
type_mapping = {
    'Phát sinh': 'uuid-for-phat-sinh',    # Incurred/Necessary
    'Phải chi': 'uuid-for-phai-chi',      # Must Pay
    'Lãng phí': 'uuid-for-lang-phi'       # Wasted
}
```

#### 3. Migration Script (Python)
```python
import pandas as pd
from supabase import create_client
import uuid
from datetime import datetime

# Configuration
SUPABASE_URL = "your-project-url"
SUPABASE_KEY = "your-anon-key"
USER_ID = "your-user-uuid"

# Initialize Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Load CSV
df = pd.read_csv('notion_expenses.csv')

# Get category mapping from Supabase (14 Vietnamese categories)
categories = supabase.table('categories').select('id, name_vi').execute()
category_map = {cat['name_vi']: cat['id'] for cat in categories.data}

# Get type mapping from Supabase (3 Vietnamese types)
expense_types = supabase.table('expense_types').select('id, name_vi').execute()
type_map = {t['name_vi']: t['id'] for t in expense_types.data}

# Transform and insert
expenses_to_insert = []
for _, row in df.iterrows():
    expense = {
        'id': str(uuid.uuid4()),
        'user_id': USER_ID,
        'category_id': category_map[row['Category']],
        'type_id': type_map[row['Type']],  # Map Vietnamese type name
        'description': row['Name'],
        'amount': float(row['Amount']),
        'date': row['Date'],
        'note': row.get('Notes', ''),
        'local_id': str(uuid.uuid4())
    }
    expenses_to_insert.append(expense)

# Batch insert
result = supabase.table('expenses').insert(expenses_to_insert).execute()
print(f"✅ Migrated {len(result.data)} expenses")
```

#### 4. Validation
After migration, verify:
- Total expense count matches
- Sum of amounts per category matches
- Date range matches
- No missing categories

---

## 🏗️ Application Architecture

### Tech Stack Updates

#### New Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.0.0      # Supabase client
  connectivity_plus: ^5.0.0     # Network status
  rxdart: ^0.27.0              # Stream management
  equatable: ^2.0.0            # Value equality
```

### Repository Pattern (Clean Architecture)

```
lib/
├── models/
│   ├── expense.dart
│   ├── category.dart          # NEW
│   ├── expense_type.dart      # NEW
│   ├── budget.dart            # NEW (M6)
│   └── recurring_expense.dart # NEW (M6)
├── repositories/
│   ├── expense_repository.dart              # Abstract interface
│   ├── local_expense_repository.dart        # SharedPreferences
│   └── supabase_expense_repository.dart     # Supabase
├── services/
│   ├── auth_service.dart      # Authentication
│   ├── sync_service.dart      # Orchestrates sync
│   └── storage_service.dart   # Local storage (existing)
├── providers/
│   ├── auth_provider.dart     # NEW
│   ├── category_provider.dart # NEW
│   └── expense_provider.dart  # Updated
└── screens/
    ├── auth/
    │   ├── login_screen.dart  # NEW
    │   └── signup_screen.dart # NEW
    └── [existing screens...]
```

### Sync Strategy: Local-First

**Pattern**: Offline-first with background sync

**Flow**:
1. User action → Update local storage immediately
2. UI updates instantly (fast UX)
3. Background sync to Supabase
4. Listen for remote changes → Update local → Update UI

**Conflict Resolution**: Last-write-wins based on `updated_at` timestamp

---

## 📋 Milestone Breakdown

### Milestone 4: Supabase Infrastructure (2-3 sessions)

**Goals**:
- Set up Supabase project and database
- Implement database schema with Vietnamese categories
- Migrate Notion data to Supabase

**Deliverables**:
- Supabase project configured
- All 5 tables created with RLS
- 14 Vietnamese categories seeded
- Real expense data migrated from Notion
- Migration validation complete

**Tasks**:
1. Create Supabase account and project
2. Set up environment variables
3. Create database schema (SQL scripts)
4. Seed categories and types
5. Export Notion data to CSV
6. Write and run migration script
7. Validate data integrity

---

### Milestone 5: Authentication + Cloud Sync (3-4 sessions)

**Goals**:
- Add user authentication
- Implement cloud synchronization
- Support offline mode

**Deliverables**:
- Email/password authentication
- Protected app routes
- Real-time sync between local and Supabase
- Offline queue and retry logic
- Sync status indicators in UI

**Tasks**:
1. Implement auth screens (login, signup)
2. Add AuthProvider for state management
3. Protect routes with auth check
4. Create repository pattern
5. Implement SyncService
6. Add background sync
7. Handle offline/online transitions
8. Add sync status indicators

---

### Milestone 6: Advanced Features (3-4 sessions)

**Goals**:
- Add recurring expenses
- Implement budget tracking

**Deliverables**:
- Recurring expense templates
- Auto-creation of recurring expenses
- Budget setup per category
- Budget vs actual tracking
- Budget alerts and indicators

**Tasks**:

**Recurring Expenses**:
1. Create RecurringExpense model and UI
2. Add recurring expense management screen
3. Implement auto-creation service
4. Sync with Supabase

**Budget Tracking**:
1. Create Budget model and UI
2. Add budget setup screen
3. Calculate budget vs actual
4. Show progress indicators
5. Add budget alerts (80%, 100%)
6. Enhance analytics with budget lines

---

### Milestone 7: Production Polish (2-3 sessions)

**Goals**:
- Finalize app for production
- Prepare for App Store

**Deliverables**:
- Complete error handling
- Loading states and animations
- Network status handling
- Onboarding flow
- App icon and launch screens
- Privacy policy
- App Store assets

**Tasks**:
1. Add polish (animations, transitions)
2. Improve error messages
3. Add onboarding tutorial
4. Create app icon
5. Design launch screen
6. Write privacy policy
7. Create App Store screenshots
8. TestFlight beta testing
9. Final QA testing

---

## 🔀 Git Branching Strategy

### Workflow

```bash
main          # Stable MVP (production-ready)
└── develop   # Integration branch for M4-7
     ├── feature/supabase-setup
     ├── feature/authentication
     ├── feature/cloud-sync
     ├── feature/recurring-expenses
     └── feature/budget-tracking
```

### Branch Naming Convention
- `feature/supabase-setup`
- `feature/auth-system`
- `feature/cloud-sync`
- `feature/recurring-expenses`
- `feature/budget-tracking`
- `bugfix/sync-conflict-handling`

### Process
1. Create `develop` from `main`
2. For each feature: create branch from `develop`
3. Complete feature → merge to `develop`
4. After milestone complete → merge `develop` to `main`
5. Tag releases: `v2.0.0-beta`, `v2.0.0`

---

## ⏱️ Timeline Estimate

| Milestone | Duration | Deliverable |
|-----------|----------|-------------|
| M4 | 2-3 sessions | Supabase + Migration |
| M5 | 3-4 sessions | Auth + Sync |
| M6 | 3-4 sessions | Advanced Features |
| M7 | 2-3 sessions | Production Polish |
| **Total** | **10-14 sessions** | **Production App** |

---

## 🎓 Learning Outcomes (M4-7)

**New skills you'll gain**:
- Supabase (PostgreSQL, RLS, real-time)
- Cloud authentication and JWT
- Sync patterns (local-first, conflict resolution)
- Repository pattern (clean architecture)
- Background services in Flutter
- Production deployment (App Store)

---

**Last Updated**: October 26, 2025
**Status**: Ready to begin Milestone 4
**Next Step**: Create Supabase account and export Notion data
