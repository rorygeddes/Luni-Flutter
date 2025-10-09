-- Simple Friends System (No messaging conflicts)
-- This creates just the friends table and helper function

-- 1. Create friends table if not exists
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- 2. Drop existing policies
DROP POLICY IF EXISTS "Users can view their own friendships" ON friends;
DROP POLICY IF EXISTS "Users can create friend requests" ON friends;
DROP POLICY IF EXISTS "Users can update their friend requests" ON friends;
DROP POLICY IF EXISTS "Users can delete their friendships" ON friends;

-- 3. Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
CREATE POLICY "Users can view their own friendships"
ON friends FOR SELECT
USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can create friend requests"
ON friends FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their friend requests"
ON friends FOR UPDATE
USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can delete their friendships"
ON friends FOR DELETE
USING (user_id = auth.uid() OR friend_id = auth.uid());

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);

-- 5. Drop existing function if exists (to change return type)
DROP FUNCTION IF EXISTS get_user_friends();

-- Create helper function (deduplicates friends)
CREATE OR REPLACE FUNCTION get_user_friends()
RETURNS TABLE (
  friend_user_id UUID,
  username TEXT,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (p.id)
    p.id as friend_user_id,
    p.username,
    p.email,
    p.full_name,
    p.avatar_url
  FROM friends f
  JOIN profiles p ON (
    CASE 
      WHEN f.user_id = auth.uid() THEN p.id = f.friend_id
      ELSE p.id = f.user_id
    END
  )
  WHERE (f.user_id = auth.uid() OR f.friend_id = auth.uid())
    AND f.status = 'accepted'
  ORDER BY p.id, p.username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Test
SELECT 'Friends system installed successfully!' as status;


