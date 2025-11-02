-- ============================================
-- Expense Tracker Database Schema
-- Vietnamese Categories + Types Support
-- ============================================
-- Execute this script in Supabase SQL Editor
-- Project: Expense Tracker
-- Created: 2025-10-26
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: categories
-- ============================================
-- Stores expense categories with Vietnamese names
-- 14 system categories from Notion database

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL = system category
  name_vi TEXT NOT NULL,                                     -- Vietnamese name (primary)
  name_en TEXT,                                              -- English name (for i18n)
  icon_name TEXT NOT NULL,                                   -- Material Icon identifier
  color_hex TEXT NOT NULL,                                   -- Display color (#RRGGBB)
  is_system BOOLEAN DEFAULT false,                           -- System categories cannot be deleted
  display_order INTEGER NOT NULL,                            -- Sort order in UI
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ                                     -- Soft delete
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_display_order ON categories(display_order);
CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON categories(deleted_at) WHERE deleted_at IS NULL;

-- Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all system categories and their own custom categories
CREATE POLICY "Users can view all categories"
  ON categories FOR SELECT
  USING (user_id IS NULL OR user_id = auth.uid());

-- Policy: Users can manage their own custom categories
CREATE POLICY "Users can manage their own categories"
  ON categories FOR ALL
  USING (user_id = auth.uid() AND is_system = false);

COMMENT ON TABLE categories IS 'Expense categories with Vietnamese and English names';
COMMENT ON COLUMN categories.name_vi IS 'Vietnamese category name (primary display)';
COMMENT ON COLUMN categories.name_en IS 'English category name (fallback/i18n)';
COMMENT ON COLUMN categories.is_system IS 'System categories cannot be deleted by users';

-- ============================================
-- TABLE: expense_types
-- ============================================
-- Stores expense type classifications
-- 3 Vietnamese types from Notion

CREATE TABLE IF NOT EXISTS expense_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,                      -- "phat_sinh", "phai_chi", "lang_phi"
  name_vi TEXT NOT NULL,                         -- Vietnamese display name
  name_en TEXT,                                  -- English display name
  color_hex TEXT NOT NULL,                       -- Type color
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Row Level Security (read-only for all authenticated users)
ALTER TABLE expense_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view expense types"
  ON expense_types FOR SELECT
  USING (true);

COMMENT ON TABLE expense_types IS 'Expense type classifications (Phát sinh, Phải chi, Lãng phí)';
COMMENT ON COLUMN expense_types.key IS 'Programmatic identifier for the type';

-- ============================================
-- TABLE: expenses
-- ============================================
-- Main expense transaction records

CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  type_id UUID NOT NULL REFERENCES expense_types(id) ON DELETE RESTRICT,
  description TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ,                        -- Soft delete

  -- Sync metadata
  local_id TEXT,                                 -- Original local UUID (for migration)
  last_synced_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_type_id ON expenses(type_id);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_deleted_at ON expenses(deleted_at) WHERE deleted_at IS NULL;

-- Row Level Security
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own non-deleted expenses
CREATE POLICY "Users can view own expenses"
  ON expenses FOR SELECT
  USING (user_id = auth.uid() AND deleted_at IS NULL);

-- Policy: Users can insert their own expenses
CREATE POLICY "Users can insert own expenses"
  ON expenses FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Policy: Users can update their own expenses
CREATE POLICY "Users can update own expenses"
  ON expenses FOR UPDATE
  USING (user_id = auth.uid());

-- Policy: Users can soft delete their own expenses
CREATE POLICY "Users can soft delete own expenses"
  ON expenses FOR UPDATE
  USING (user_id = auth.uid() AND deleted_at IS NULL);

COMMENT ON TABLE expenses IS 'Main expense transaction records';
COMMENT ON COLUMN expenses.amount IS 'Expense amount in local currency (2 decimal precision)';
COMMENT ON COLUMN expenses.local_id IS 'Original UUID from local device (for migration tracking)';

-- ============================================
-- TABLE: budgets
-- ============================================
-- Monthly budget limits per category (Milestone 6)

CREATE TABLE IF NOT EXISTS budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  month DATE NOT NULL,                           -- First day of month (e.g., 2025-10-01)
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(user_id, category_id, month)            -- One budget per category per month
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_budgets_user_month ON budgets(user_id, month);
CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category_id);

-- Row Level Security
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own budgets
CREATE POLICY "Users can manage own budgets"
  ON budgets FOR ALL
  USING (user_id = auth.uid());

COMMENT ON TABLE budgets IS 'Monthly budget limits per category';
COMMENT ON COLUMN budgets.month IS 'First day of the month for this budget period';

-- ============================================
-- TABLE: recurring_expenses
-- ============================================
-- Templates for automatically creating recurring expenses (Milestone 6)

CREATE TABLE IF NOT EXISTS recurring_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  type_id UUID NOT NULL REFERENCES expense_types(id) ON DELETE RESTRICT,
  description TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
  start_date DATE NOT NULL,
  end_date DATE,                                 -- NULL = no end date
  last_created_date DATE,                        -- Track when last expense was auto-created
  is_active BOOLEAN DEFAULT true,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_recurring_active ON recurring_expenses(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_recurring_next_run ON recurring_expenses(last_created_date, is_active);

-- Row Level Security
ALTER TABLE recurring_expenses ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own recurring expenses
CREATE POLICY "Users can manage own recurring expenses"
  ON recurring_expenses FOR ALL
  USING (user_id = auth.uid());

COMMENT ON TABLE recurring_expenses IS 'Templates for automatically creating recurring expenses';
COMMENT ON COLUMN recurring_expenses.last_created_date IS 'Last date an expense was auto-created from this template';

-- ============================================
-- END OF SCHEMA
-- ============================================
