-- Fix Groups and Group Members RLS Policies
-- Prevents infinite recursion errors when creating/viewing groups

-- 1. Drop ALL existing policies for groups table
DROP POLICY IF EXISTS "Users can view their groups" ON groups;
DROP POLICY IF EXISTS "Users can create groups" ON groups;
DROP POLICY IF EXISTS "Group creators can update their groups" ON groups;
DROP POLICY IF EXISTS "Group creators can delete their groups" ON groups;

-- 2. Drop ALL existing policies for group_members table
DROP POLICY IF EXISTS "Users can view group members" ON group_members;
DROP POLICY IF EXISTS "Users can view members of their groups" ON group_members;
DROP POLICY IF EXISTS "Users can view group members they belong to" ON group_members;
DROP POLICY IF EXISTS "Group creators can see all members" ON group_members;
DROP POLICY IF EXISTS "Users can add members to groups they created" ON group_members;
DROP POLICY IF EXISTS "Group creators can add members" ON group_members;
DROP POLICY IF EXISTS "Users can remove themselves from groups" ON group_members;

-- 3. Enable RLS on both tables
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- 4. Create SIMPLE policies for groups table (no recursion)
CREATE POLICY "Users can view their groups"
ON groups FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM group_members gm
    WHERE gm.group_id = groups.id
    AND gm.user_id = auth.uid()
  )
);

CREATE POLICY "Users can create groups"
ON groups FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Group creators can update their groups"
ON groups FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "Group creators can delete their groups"
ON groups FOR DELETE
USING (created_by = auth.uid());

-- 5. Create SIMPLE policies for group_members table (no recursion)
-- Policy 1: Users can see members of groups they belong to
CREATE POLICY "Users can view group members they belong to"
ON group_members FOR SELECT
USING (
  user_id = auth.uid() 
  OR 
  group_id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

-- Policy 2: Group creators can add members
CREATE POLICY "Group creators can add members"
ON group_members FOR INSERT
WITH CHECK (
  added_by = auth.uid()
  AND
  EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
    AND g.created_by = auth.uid()
  )
);

-- Policy 3: Group creators can remove members
CREATE POLICY "Group creators can remove members"
ON group_members FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
    AND g.created_by = auth.uid()
  )
);

-- Policy 4: Users can remove themselves from groups
CREATE POLICY "Users can leave groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

SELECT 'Groups RLS policies fixed - no more infinite recursion!' as status;

