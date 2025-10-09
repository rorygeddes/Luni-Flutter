-- Add Split System: Groups, Members, and Split Transactions

-- 1. Create groups table
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  icon TEXT DEFAULT '👥',
  description TEXT,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create group_members table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT, -- Optional nickname for this person in this group
  added_by UUID NOT NULL REFERENCES auth.users(id),
  joined_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- 3. Create split_transactions table (tracks who owes what)
CREATE TABLE IF NOT EXISTS split_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  payer_id UUID NOT NULL REFERENCES auth.users(id), -- Person who paid
  total_amount NUMERIC NOT NULL,
  split_method TEXT DEFAULT 'equal', -- 'equal', 'custom', 'percentage'
  is_group_visible BOOLEAN DEFAULT FALSE, -- Post to group chat
  group_id UUID REFERENCES groups(id), -- Optional: which group this split is for
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Create split_participants table (individual split details)
CREATE TABLE IF NOT EXISTS split_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  split_transaction_id UUID NOT NULL REFERENCES split_transactions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  amount_owed NUMERIC NOT NULL, -- How much this person owes
  is_settled BOOLEAN DEFAULT FALSE,
  settled_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Enable RLS on all tables
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE split_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE split_participants ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies for groups
DROP POLICY IF EXISTS "Users can view groups they are members of" ON groups;
DROP POLICY IF EXISTS "Users can create groups" ON groups;
DROP POLICY IF EXISTS "Group creators can update their groups" ON groups;
DROP POLICY IF EXISTS "Group creators can delete their groups" ON groups;

CREATE POLICY "Users can view groups they are members of"
ON groups FOR SELECT
USING (
  id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can create groups"
ON groups FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group creators can update their groups"
ON groups FOR UPDATE
USING (auth.uid() = created_by);

CREATE POLICY "Group creators can delete their groups"
ON groups FOR DELETE
USING (auth.uid() = created_by);

-- 7. RLS Policies for group_members
DROP POLICY IF EXISTS "Users can view members of their groups" ON group_members;
DROP POLICY IF EXISTS "Users can add members to groups they created" ON group_members;
DROP POLICY IF EXISTS "Users can remove themselves from groups" ON group_members;

CREATE POLICY "Users can view members of their groups"
ON group_members FOR SELECT
USING (
  group_id IN (
    SELECT group_id FROM group_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can add members to groups they created"
ON group_members FOR INSERT
WITH CHECK (
  group_id IN (
    SELECT id FROM groups WHERE created_by = auth.uid()
  )
);

CREATE POLICY "Users can remove themselves from groups"
ON group_members FOR DELETE
USING (user_id = auth.uid());

-- 8. RLS Policies for split_transactions
DROP POLICY IF EXISTS "Users can view their split transactions" ON split_transactions;
DROP POLICY IF EXISTS "Users can create split transactions" ON split_transactions;
DROP POLICY IF EXISTS "Payers can update their split transactions" ON split_transactions;

CREATE POLICY "Users can view their split transactions"
ON split_transactions FOR SELECT
USING (
  payer_id = auth.uid() OR
  id IN (
    SELECT split_transaction_id FROM split_participants WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can create split transactions"
ON split_transactions FOR INSERT
WITH CHECK (payer_id = auth.uid());

CREATE POLICY "Payers can update their split transactions"
ON split_transactions FOR UPDATE
USING (payer_id = auth.uid());

-- 9. RLS Policies for split_participants
DROP POLICY IF EXISTS "Users can view split participants they are involved in" ON split_participants;
DROP POLICY IF EXISTS "Payers can create split participants" ON split_participants;
DROP POLICY IF EXISTS "Participants can update their settlement status" ON split_participants;

CREATE POLICY "Users can view split participants they are involved in"
ON split_participants FOR SELECT
USING (
  user_id = auth.uid() OR
  split_transaction_id IN (
    SELECT id FROM split_transactions WHERE payer_id = auth.uid()
  )
);

CREATE POLICY "Payers can create split participants"
ON split_participants FOR INSERT
WITH CHECK (
  split_transaction_id IN (
    SELECT id FROM split_transactions WHERE payer_id = auth.uid()
  )
);

CREATE POLICY "Participants can update their settlement status"
ON split_participants FOR UPDATE
USING (user_id = auth.uid());

-- 10. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_groups_created_by ON groups(created_by);
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_split_transactions_payer ON split_transactions(payer_id);
CREATE INDEX IF NOT EXISTS idx_split_transactions_transaction ON split_transactions(transaction_id);
CREATE INDEX IF NOT EXISTS idx_split_participants_user ON split_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_split_participants_split ON split_participants(split_transaction_id);

-- 11. Create function to get user's total owed/owing
CREATE OR REPLACE FUNCTION get_user_balance_with(other_user_id UUID)
RETURNS NUMERIC AS $$
DECLARE
  balance NUMERIC;
BEGIN
  -- Calculate what the current user owes to other_user minus what other_user owes to current user
  SELECT 
    COALESCE(SUM(CASE 
      WHEN sp.user_id = auth.uid() AND st.payer_id = other_user_id THEN sp.amount_owed
      WHEN st.payer_id = auth.uid() AND sp.user_id = other_user_id THEN -sp.amount_owed
      ELSE 0
    END), 0)
  INTO balance
  FROM split_participants sp
  JOIN split_transactions st ON sp.split_transaction_id = st.id
  WHERE sp.is_settled = FALSE
    AND (
      (sp.user_id = auth.uid() AND st.payer_id = other_user_id) OR
      (st.payer_id = auth.uid() AND sp.user_id = other_user_id)
    );
  
  RETURN balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Test the system
SELECT 'Split system installed successfully!' as status;

