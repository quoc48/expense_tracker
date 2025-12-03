-- ============================================================================
-- Recurring Expenses Table and RLS Policies
-- Created: December 2, 2025
-- ============================================================================

-- Drop existing table if it exists (will cascade to any dependent objects)
DROP TABLE IF EXISTS public.recurring_expenses CASCADE;

-- Create the recurring_expenses table
CREATE TABLE IF NOT EXISTS public.recurring_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id),
    type_id UUID NOT NULL REFERENCES public.expense_types(id),
    description TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_created_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create index for faster user queries
CREATE INDEX IF NOT EXISTS idx_recurring_expenses_user_id 
    ON public.recurring_expenses(user_id);

-- Create index for active recurring expenses (used in auto-creation)
CREATE INDEX IF NOT EXISTS idx_recurring_expenses_active 
    ON public.recurring_expenses(user_id, is_active) 
    WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE public.recurring_expenses ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own recurring expenses
CREATE POLICY "Users can view own recurring expenses"
    ON public.recurring_expenses
    FOR SELECT
    USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own recurring expenses
CREATE POLICY "Users can insert own recurring expenses"
    ON public.recurring_expenses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own recurring expenses
CREATE POLICY "Users can update own recurring expenses"
    ON public.recurring_expenses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own recurring expenses
CREATE POLICY "Users can delete own recurring expenses"
    ON public.recurring_expenses
    FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_recurring_expenses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_recurring_expenses_updated_at
    BEFORE UPDATE ON public.recurring_expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_recurring_expenses_updated_at();

-- ============================================================================
-- INSTRUCTIONS:
-- 1. Go to Supabase Dashboard > SQL Editor
-- 2. Paste this entire script
-- 3. Click "Run"
-- 4. Verify table was created in Table Editor
-- ============================================================================
