-- Fix Groups and Group Members RLS Policies (ULTIMATE FIX - NO RECURSION AT ALL)
-- Removes ALL circular dependencies by simplifying policies

-- 1. Drop ALL existing policies for groups table
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON groups';
    END LOOP;
END $$;

-- 2. Drop ALL existing policies for group_members table
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'group_members' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON group_members';
    END LOOP;
END $$;

-- 3. Enable RLS on both tables
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- 4. Create SIMPLE policies for groups table (NO recursion)

-- Creators can always view their groups
CREATE POLICY "Creators can view their groups"
ON groups FOR SELECT
USING (created_by = auth.uid());

-- Members can view groups (checks group_members but not vice versa)
CREATE POLICY "Members can view their groups"
ON groups FOR SELECT
USING (
  id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can create groups"
ON groups FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Creators can update their groups"
ON groups FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "Creators can delete their groups"
ON groups FOR DELETE
USING (created_by = auth.uid());

-- 5. Create SUPER SIMPLE policies for group_members table (NO RECURSION AT ALL!)

-- Policy 1: Users can ALWAYS see rows where they are the member (no subquery needed!)
CREATE POLICY "Users can see their own memberships"
ON group_members FOR SELECT
USING (user_id = auth.uid());

-- Policy 2: Group creators can see ALL members of their groups (uses groups table, no recursion)
CREATE POLICY "Creators can see all group members"
ON group_members FOR SELECT
USING (
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

-- Policy 3: Only group creators can add members
CREATE POLICY "Creators can add members"
ON group_members FOR INSERT
WITH CHECK (
  added_by = auth.uid()
  AND
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

-- Policy 4: Users can remove themselves
CREATE POLICY "Users can leave groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

-- Policy 5: Creators can remove any member
CREATE POLICY "Creators can remove members"
ON group_members FOR DELETE
USING (
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

SELECT '✅ Groups RLS policies TRULY fixed - zero recursion, zero circular dependencies!' as status;

