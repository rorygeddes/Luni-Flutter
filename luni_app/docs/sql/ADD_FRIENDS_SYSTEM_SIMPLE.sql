-- SIMPLE FRIENDS SYSTEM (Messages removed to avoid conflicts)
-- Run this in Supabase SQL Editor

-- 1. Create friends table
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- 2. Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies for friends
DROP POLICY IF EXISTS "Users can view their own friend relationships" ON friends;
DROP POLICY IF EXISTS "Users can add friends" ON friends;
DROP POLICY IF EXISTS "Users can update friend status" ON friends;
DROP POLICY IF EXISTS "Users can remove friends" ON friends;

CREATE POLICY "Users can view their own friend relationships"
ON friends FOR SELECT
USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can add friends"
ON friends FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update friend status"
ON friends FOR UPDATE
USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can remove friends"
ON friends FOR DELETE
USING (user_id = auth.uid() OR friend_id = auth.uid());

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);

-- 5. Drop existing function if exists (to change return type)
DROP FUNCTION IF EXISTS get_user_friends();

-- Create helper function
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
  SELECT 
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
  ORDER BY p.username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Test
SELECT 'Friends system installed successfully!' as status;

