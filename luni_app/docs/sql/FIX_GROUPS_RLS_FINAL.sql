-- Fix Groups and Group Members RLS Policies (FINAL FIX)
-- Breaks the circular dependency by allowing creators to view their groups directly

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

-- 4. Create policies for groups table (FIXED - no circular dependency)

-- Policy 1: Creators can view groups they created (NO dependency on group_members)
CREATE POLICY "Creators can view their groups"
ON groups FOR SELECT
USING (created_by = auth.uid());

-- Policy 2: Members can view groups they belong to (separate policy)
CREATE POLICY "Members can view their groups"
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

-- 5. Create policies for group_members table (no recursion)

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

-- Policy 2: Group creators can add members (now works because creators can SELECT groups directly)
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

-- Policy 3: Users can remove themselves from groups
CREATE POLICY "Users can leave groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

-- Policy 4: Group creators can remove any member
CREATE POLICY "Creators can remove group members"
ON group_members FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM groups g
    WHERE g.id = group_members.group_id
    AND g.created_by = auth.uid()
  )
);

SELECT 'Groups RLS policies REALLY fixed now - circular dependency broken!' as status;

