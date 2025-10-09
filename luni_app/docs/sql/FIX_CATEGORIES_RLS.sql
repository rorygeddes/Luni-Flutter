-- ============================================
-- FIX CATEGORIES RLS POLICIES
-- ============================================
-- This ensures users can see default categories (user_id IS NULL)
-- and their own custom categories

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own categories" ON categories;
DROP POLICY IF EXISTS "Users can view default categories" ON categories;
DROP POLICY IF EXISTS "Users can insert their own categories" ON categories;
DROP POLICY IF EXISTS "Users can update their own categories" ON categories;
DROP POLICY IF EXISTS "Users can delete their own categories" ON categories;

-- Create new policies
-- 1. Allow users to view DEFAULT categories (user_id IS NULL) AND their own categories
CREATE POLICY "Users can view categories"
ON categories FOR SELECT
USING (
  user_id IS NULL OR user_id = auth.uid()
);

-- 2. Allow users to insert their own categories
CREATE POLICY "Users can insert own categories"
ON categories FOR INSERT
WITH CHECK (user_id = auth.uid());

-- 3. Allow users to update their own categories (not default ones)
CREATE POLICY "Users can update own categories"
ON categories FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. Allow users to delete their own categories (not default ones)
CREATE POLICY "Users can delete own categories"
ON categories FOR DELETE
USING (user_id = auth.uid());

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'categories';

