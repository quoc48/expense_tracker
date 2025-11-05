-- ============================================================================
-- Grant Table Permissions to Authenticated Users
-- ============================================================================
-- Purpose: Grant table-level access to authenticated users
-- This is REQUIRED for RLS to work! Without this, you get error 42501.
--
-- Run this after creating any new user-specific table.
-- See: claudedocs/supabase_rls_checklist.md for complete guide
--
-- Created: 2025-11-02
-- ============================================================================

-- Grant permissions on user_preferences table
-- This fixes the "permission denied" error we encountered
GRANT SELECT, INSERT, UPDATE ON user_preferences TO authenticated;

-- Grant permissions on expenses table (if not already granted)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON expenses TO authenticated;

-- Grant permissions on categories table (if not already granted)
-- GRANT SELECT ON categories TO authenticated;

-- Grant permissions on expense_types table (if not already granted)
-- GRANT SELECT ON expense_types TO authenticated;

-- ============================================================================
-- Template for Future Tables
-- ============================================================================
-- When you create a new user-specific table, uncomment and modify:
--
-- GRANT SELECT, INSERT, UPDATE, DELETE ON your_new_table TO authenticated;
--
-- Common tables that will need this:
-- - budgets
-- - recurring_expenses
-- - notifications_settings
-- - user_categories (if custom)
-- ============================================================================

-- ============================================================================
-- Verification Query
-- ============================================================================
-- Run this to verify permissions are granted:
--
-- SELECT 
--   grantee, 
--   table_name,
--   privilege_type 
-- FROM information_schema.role_table_grants 
-- WHERE grantee = 'authenticated'
--   AND table_schema = 'public'
-- ORDER BY table_name, privilege_type;
-- ============================================================================
