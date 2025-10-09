-- Add Friends System for Social Screen

-- 1. Create friends table (tracks friend relationships)
CREATE TABLE IF NOT EXISTS friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'blocked'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- 2. Create messages table (for direct messaging)
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Create group_messages table (for group chats)
CREATE TABLE IF NOT EXISTS group_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Enable RLS
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_messages ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for friends
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

-- 6. RLS Policies for messages
DROP POLICY IF EXISTS "Users can view their messages" ON messages;
DROP POLICY IF EXISTS "Users can send messages" ON messages;
DROP POLICY IF EXISTS "Users can update their messages" ON messages;

CREATE POLICY "Users can view their messages"
ON messages FOR SELECT
USING (sender_id = auth.uid() OR recipient_id = auth.uid());

CREATE POLICY "Users can send messages"
ON messages FOR INSERT
WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update their messages"
ON messages FOR UPDATE
USING (recipient_id = auth.uid());

-- 7. RLS Policies for group_messages
DROP POLICY IF EXISTS "Group members can view group messages" ON group_messages;
DROP POLICY IF EXISTS "Group members can send messages" ON group_messages;

CREATE POLICY "Group members can view group messages"
ON group_messages FOR SELECT
USING (
  group_id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Group members can send messages"
ON group_messages FOR INSERT
WITH CHECK (
  sender_id = auth.uid() AND
  group_id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

-- 8. Create indexes
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_group_messages_group ON group_messages(group_id);
CREATE INDEX IF NOT EXISTS idx_group_messages_created_at ON group_messages(created_at DESC);

-- 9. Create helper functions

-- Get user's friends list
CREATE OR REPLACE FUNCTION get_user_friends()
RETURNS TABLE (
  friend_user_id UUID,
  username TEXT,
  email TEXT,
  profile_image_url TEXT,
  status TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    CASE 
      WHEN f.user_id = auth.uid() THEN f.friend_id
      ELSE f.user_id
    END as friend_user_id,
    p.username,
    p.email,
    p.profile_image_url,
    f.status
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

-- Get conversation preview (last message with each person)
CREATE OR REPLACE FUNCTION get_conversation_list()
RETURNS TABLE (
  other_user_id UUID,
  username TEXT,
  profile_image_url TEXT,
  last_message TEXT,
  last_message_time TIMESTAMP,
  unread_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH last_messages AS (
    SELECT 
      CASE 
        WHEN sender_id = auth.uid() THEN recipient_id
        ELSE sender_id
      END as other_id,
      content,
      created_at,
      ROW_NUMBER() OVER (
        PARTITION BY CASE WHEN sender_id = auth.uid() THEN recipient_id ELSE sender_id END 
        ORDER BY created_at DESC
      ) as rn
    FROM messages
    WHERE sender_id = auth.uid() OR recipient_id = auth.uid()
  ),
  unread_counts AS (
    SELECT 
      sender_id as from_user,
      COUNT(*) as unread
    FROM messages
    WHERE recipient_id = auth.uid() AND is_read = FALSE
    GROUP BY sender_id
  )
  SELECT 
    lm.other_id,
    p.username,
    p.profile_image_url,
    lm.content as last_message,
    lm.created_at as last_message_time,
    COALESCE(uc.unread, 0) as unread_count
  FROM last_messages lm
  JOIN profiles p ON p.id = lm.other_id
  LEFT JOIN unread_counts uc ON uc.from_user = lm.other_id
  WHERE lm.rn = 1
  ORDER BY lm.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Test the system
SELECT 'Friends system installed successfully!' as status;

