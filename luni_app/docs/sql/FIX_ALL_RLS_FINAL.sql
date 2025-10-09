-- FIX ALL RLS POLICIES - FINAL VERSION
-- Run this in Supabase SQL Editor to fix all infinite recursion errors

-- ============================================
-- 1. DROP ALL EXISTING POLICIES FOR GROUPS
-- ============================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON groups';
    END LOOP;
END $$;

-- ============================================
-- 2. DROP ALL EXISTING POLICIES FOR GROUP_MEMBERS
-- ============================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'group_members' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON group_members';
    END LOOP;
END $$;

-- ============================================
-- 3. ENABLE RLS
-- ============================================
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. CREATE SIMPLE POLICIES FOR GROUPS (NO RECURSION)
-- ============================================

-- Policy: Creators can view groups they created
CREATE POLICY "Creators can view their groups"
ON groups FOR SELECT
USING (created_by = auth.uid());

-- Policy: Users can create groups
CREATE POLICY "Users can create groups"
ON groups FOR INSERT
WITH CHECK (created_by = auth.uid());

-- Policy: Creators can update their groups
CREATE POLICY "Creators can update their groups"
ON groups FOR UPDATE
USING (created_by = auth.uid());

-- Policy: Creators can delete their groups
CREATE POLICY "Creators can delete their groups"
ON groups FOR DELETE
USING (created_by = auth.uid());

-- ============================================
-- 5. CREATE SIMPLE POLICIES FOR GROUP_MEMBERS (NO RECURSION)
-- ============================================

-- Policy: Users can see their own memberships
CREATE POLICY "Users can see their own memberships"
ON group_members FOR SELECT
USING (user_id = auth.uid());

-- Policy: Anyone can add members (we'll control this in the app)
CREATE POLICY "Users can add members"
ON group_members FOR INSERT
WITH CHECK (added_by = auth.uid());

-- Policy: Users can leave groups
CREATE POLICY "Users can leave groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

-- ============================================
-- DONE!
-- ============================================
SELECT '✅ All RLS policies fixed - NO MORE RECURSION!' as status;

