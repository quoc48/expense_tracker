# Supabase RLS Setup Checklist

**Purpose:** Reference guide for setting up Row Level Security (RLS) on new Supabase tables

**When to use:** Every time you create a new table that stores user-specific data

---

## 🔒 The Two Security Layers

Supabase requires BOTH layers for user data security:

### Layer 1: Table Permissions (GRANT) 🏢
**Purpose:** Controls who can access the table at all  
**Without it:** `PostgrestException code: 42501 - permission denied for table`

### Layer 2: Row Level Security (RLS) 🚪
**Purpose:** Controls which specific rows a user can see/modify  
**Without it:** Users can see ALL rows (major security risk!)

---

## ✅ Complete Setup Checklist

For each new user-specific table:

### Step 1: Create Table
```sql
CREATE TABLE your_table (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- your columns here
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 2: Enable RLS
```sql
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;
```

### Step 3: Grant Table Permissions ⚠️ **DON'T FORGET THIS!**
```sql
-- This is what we forgot with user_preferences!
GRANT SELECT, INSERT, UPDATE, DELETE ON your_table TO authenticated;
```

**Without this GRANT, you'll get error 42501 even with perfect RLS policies!**

### Step 4: Create RLS Policies
```sql
-- Policy 1: SELECT (Read)
CREATE POLICY "Users can view own records"
ON your_table
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy 2: INSERT (Create)
CREATE POLICY "Users can insert own records"
ON your_table
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy 3: UPDATE (Modify)
CREATE POLICY "Users can update own records"
ON your_table
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy 4: DELETE (Optional - only if users should delete)
CREATE POLICY "Users can delete own records"
ON your_table
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

### Step 5: Create Indexes
```sql
-- Index on user_id for fast queries
CREATE INDEX idx_your_table_user_id ON your_table(user_id);

-- Index on updated_at for sorting
CREATE INDEX idx_your_table_updated_at ON your_table(updated_at DESC);
```

### Step 6: Verify Setup
```sql
-- Test 1: Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'your_table';
-- Expected: rowsecurity = true

-- Test 2: Check GRANT permissions
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'your_table' 
  AND grantee = 'authenticated';
-- Expected: SELECT, INSERT, UPDATE (and DELETE if granted)

-- Test 3: Check policies exist
SELECT policyname, cmd AS operation
FROM pg_policies 
WHERE tablename = 'your_table';
-- Expected: 3-4 policies (SELECT, INSERT, UPDATE, optionally DELETE)
```

---

## 🐛 Common Errors & Solutions

### Error 1: `PostgrestException code: 42501 - permission denied for table`

**Cause:** Missing GRANT statement (Table-level permission)

**Solution:**
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON your_table TO authenticated;
```

**Why it happens:** You created RLS policies but forgot to grant table access

---

### Error 2: `Row Level Security policy violation`

**Cause:** RLS policy is blocking the operation

**Possible reasons:**
1. Policy logic is wrong (e.g., wrong column name)
2. `auth.uid()` doesn't match `user_id` in row
3. Missing WITH CHECK clause on INSERT/UPDATE

**Debug:**
```sql
-- Check what auth.uid() returns (must run as authenticated user, not in SQL Editor)
SELECT auth.uid();

-- Check existing data
SELECT user_id FROM your_table LIMIT 5;

-- Verify policies
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'your_table';
```

---

### Error 3: `new row violates row-level security policy`

**Cause:** INSERT/UPDATE policy's WITH CHECK clause is rejecting the operation

**Solution:** Verify the user_id being inserted matches auth.uid()

```sql
-- Correct INSERT
INSERT INTO your_table (user_id, data)
VALUES (auth.uid(), 'some data');

-- Wrong INSERT (will fail)
INSERT INTO your_table (user_id, data)
VALUES ('some-other-uuid', 'some data');
```

---

## 🧪 Testing RLS in Flutter

After setting up RLS, test in your Flutter app:

```dart
// Test 1: Can read own data
final data = await supabase
  .from('your_table')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id);
print('My data: $data'); // Should work

// Test 2: Cannot read others' data (will be empty)
final othersData = await supabase
  .from('your_table')
  .select()
  .eq('user_id', 'some-other-uuid');
print('Others data: $othersData'); // Should be empty, not error

// Test 3: Can insert own data
await supabase.from('your_table').insert({
  'user_id': supabase.auth.currentUser!.id,
  'data': 'test',
}); // Should work

// Test 4: Cannot insert for other users
await supabase.from('your_table').insert({
  'user_id': 'some-other-uuid',
  'data': 'test',
}); // Should fail
```

---

## 📚 Quick Reference

**When creating a new user-specific table, remember:**

1. ✅ CREATE TABLE with user_id column
2. ✅ ALTER TABLE ENABLE ROW LEVEL SECURITY
3. ✅ **GRANT permissions to authenticated** ⚠️ **CRITICAL!**
4. ✅ CREATE POLICY for SELECT, INSERT, UPDATE (and DELETE if needed)
5. ✅ CREATE INDEX on user_id and updated_at
6. ✅ Test in Flutter app

**Copy-paste template:**
```sql
-- 1. Create
CREATE TABLE your_table (...);

-- 2. Enable RLS
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

-- 3. Grant (DON'T FORGET!)
GRANT SELECT, INSERT, UPDATE ON your_table TO authenticated;

-- 4. Policies
CREATE POLICY "Users can view own records" ON your_table FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own records" ON your_table FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own records" ON your_table FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 5. Indexes
CREATE INDEX idx_your_table_user_id ON your_table(user_id);
```

---

## 🎓 Real-World Example: user_preferences

This is the exact issue we debugged on 2025-11-02:

**Problem:**
- Created `user_preferences` table ✅
- Enabled RLS ✅
- Created policies ✅
- **Forgot GRANT** ❌

**Result:**
```
PostgrestException code: 42501 - permission denied for table user_preferences
```

**Solution:**
```sql
GRANT SELECT, INSERT, UPDATE ON user_preferences TO authenticated;
```

**Time spent debugging:** ~1 hour  
**Time to fix once diagnosed:** 30 seconds  
**Time saved by this checklist:** ~1 hour per table! 💰

---

**Last Updated:** 2025-11-02  
**Created during:** Budget Feature - Phase 2  
**Lesson learned from:** user_preferences RLS debugging session
