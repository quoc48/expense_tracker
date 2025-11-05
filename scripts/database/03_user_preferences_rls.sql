-- ============================================================================
-- User Preferences: Row Level Security (RLS) Policies
-- ============================================================================
-- IMPORTANT: RLS requires TWO layers of security:
-- 1. GRANT (table-level permissions) - "Can you access the table?"
-- 2. Policies (row-level security) - "Which rows can you access?"
-- 
-- Missing GRANT will cause: PostgrestException code: 42501
-- See: claudedocs/supabase_rls_checklist.md for complete guide
-- ============================================================================
-- Purpose: Allow authenticated users to manage their own preferences
-- 
-- Security Model:
-- - Users can only access their OWN preferences (auth.uid() = user_id)
-- - No user can see another user's budget or settings
-- - All operations require authentication
--
-- Created: 2025-11-02
-- Phase: Budget Feature - Phase 2 (RLS Fix)
-- ============================================================================

-- STEP 1: Grant table-level permissions to authenticated users
-- This is REQUIRED before RLS policies will work!
-- Without this, you'll get error 42501: "permission denied for table"
GRANT SELECT, INSERT, UPDATE ON user_preferences TO authenticated;

-- STEP 2: Create RLS policies for row-level access control

-- Policy 1: SELECT (Read)
-- Allow users to read their own preferences
CREATE POLICY "Users can view own preferences"
ON user_preferences
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy 2: INSERT (Create)  
-- Allow users to create their own preferences
-- WITH CHECK ensures the user_id being inserted matches the authenticated user
CREATE POLICY "Users can insert own preferences"
ON user_preferences
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy 3: UPDATE (Modify)
-- Allow users to update their own preferences
-- USING checks before update, WITH CHECK ensures updated values are valid
CREATE POLICY "Users can update own preferences"
ON user_preferences
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Note: We don't create a DELETE policy because users shouldn't delete
-- their preferences. If needed in the future, add:
-- 
-- CREATE POLICY "Users can delete own preferences"
-- ON user_preferences
-- FOR DELETE
-- TO authenticated
-- USING (auth.uid() = user_id);

-- ============================================================================
-- Verification Query (run this after to verify policies are active)
-- ============================================================================
-- SELECT * FROM user_preferences WHERE user_id = auth.uid();
-- 
-- Expected: Should return your preferences row (or empty if not created yet)
-- If error: Policies not applied correctly
-- ============================================================================
