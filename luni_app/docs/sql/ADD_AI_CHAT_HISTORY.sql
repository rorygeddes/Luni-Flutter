-- AI Chat History System
-- Stores conversations and messages for the AI assistant

-- 1. Create ai_conversations table
CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'New Chat',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create ai_messages table
CREATE TABLE IF NOT EXISTS ai_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for ai_conversations
DROP POLICY IF EXISTS "Users can view their own conversations" ON ai_conversations;
DROP POLICY IF EXISTS "Users can create their own conversations" ON ai_conversations;
DROP POLICY IF EXISTS "Users can update their own conversations" ON ai_conversations;
DROP POLICY IF EXISTS "Users can delete their own conversations" ON ai_conversations;

CREATE POLICY "Users can view their own conversations"
ON ai_conversations FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Users can create their own conversations"
ON ai_conversations FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own conversations"
ON ai_conversations FOR UPDATE
USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own conversations"
ON ai_conversations FOR DELETE
USING (user_id = auth.uid());

-- 5. RLS Policies for ai_messages
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON ai_messages;
DROP POLICY IF EXISTS "Users can create messages in their conversations" ON ai_messages;
DROP POLICY IF EXISTS "Users can delete messages in their conversations" ON ai_messages;

CREATE POLICY "Users can view messages in their conversations"
ON ai_messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM ai_conversations
    WHERE ai_conversations.id = ai_messages.conversation_id
    AND ai_conversations.user_id = auth.uid()
  )
);

CREATE POLICY "Users can create messages in their conversations"
ON ai_messages FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM ai_conversations
    WHERE ai_conversations.id = ai_messages.conversation_id
    AND ai_conversations.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete messages in their conversations"
ON ai_messages FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM ai_conversations
    WHERE ai_conversations.id = ai_messages.conversation_id
    AND ai_conversations.user_id = auth.uid()
  )
);

-- 6. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_updated_at ON ai_conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation_id ON ai_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_ai_messages_created_at ON ai_messages(created_at);

-- 7. Create function to update conversation timestamp
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE ai_conversations
  SET updated_at = NOW()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create trigger to auto-update conversation timestamp when message is added
DROP TRIGGER IF EXISTS update_conversation_timestamp_trigger ON ai_messages;
CREATE TRIGGER update_conversation_timestamp_trigger
AFTER INSERT ON ai_messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

-- Done!
SELECT '✅ AI Chat History system installed successfully!' as status;

