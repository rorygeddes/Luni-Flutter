-- ============================================
-- FRIENDS SYSTEM - DATABASE SETUP
-- ============================================

-- 1. Create friends table
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'accepted', 'blocked'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- 2. Create indexes
CREATE INDEX IF NOT EXISTS idx_friends_user ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend ON friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);

-- 3. Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;

-- 4. Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own friends" ON friends;
DROP POLICY IF EXISTS "Users can add friends" ON friends;
DROP POLICY IF EXISTS "Users can update friend status" ON friends;

-- 5. Create RLS policies
CREATE POLICY "Users can view their own friends" ON friends
  FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can add friends" ON friends
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update friend status" ON friends
  FOR UPDATE
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- ============================================
-- SETUP COMPLETE!
-- ============================================
-- 
-- ✅ Friends table created
-- ✅ Indexes added for performance
-- ✅ RLS policies enabled
-- 
-- Now users can:
-- - Send friend requests
-- - Accept/reject requests
-- - Message anyone (even if not accepted)
-- 
-- ============================================

