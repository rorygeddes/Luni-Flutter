DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON groups';
    END LOOP;
END $$;

DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'group_members' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON group_members';
    END LOOP;
END $$;

ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view groups they created"
ON groups FOR SELECT
USING (created_by = auth.uid());

CREATE POLICY "Users can create groups"
ON groups FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Creators can update groups"
ON groups FOR UPDATE
USING (created_by = auth.uid());

CREATE POLICY "Creators can delete groups"
ON groups FOR DELETE
USING (created_by = auth.uid());

CREATE POLICY "Users can see their memberships"
ON group_members FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Creators can add members"
ON group_members FOR INSERT
WITH CHECK (
  added_by = auth.uid()
  AND
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

CREATE POLICY "Users can leave groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

CREATE POLICY "Creators can remove members"
ON group_members FOR DELETE
USING (
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

SELECT 'Groups fixed - ZERO recursion!' as status;

