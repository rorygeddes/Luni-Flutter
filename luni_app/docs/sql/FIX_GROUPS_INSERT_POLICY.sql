DROP POLICY IF EXISTS "Creators can add members" ON group_members;

CREATE POLICY "Creators can add members"
ON group_members FOR INSERT
WITH CHECK (
  added_by = auth.uid()
);

SELECT 'Group members INSERT policy fixed!' as status;

