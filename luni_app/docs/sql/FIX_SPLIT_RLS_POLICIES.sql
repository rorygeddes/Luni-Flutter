-- Fix infinite recursion in split_transactions RLS policies
-- The issue: split_transactions references split_participants, which references split_transactions (circular!)

-- Drop ALL old policies first (to prevent "already exists" errors)
DROP POLICY IF EXISTS "Users can view their split transactions" ON split_transactions;
DROP POLICY IF EXISTS "Users can create split transactions" ON split_transactions;
DROP POLICY IF EXISTS "Payers can update their split transactions" ON split_transactions;

DROP POLICY IF EXISTS "Users can view split participants they are involved in" ON split_participants;
DROP POLICY IF EXISTS "Payers can view all participants in their splits" ON split_participants;
DROP POLICY IF EXISTS "Payers can create split participants" ON split_participants;
DROP POLICY IF EXISTS "Participants can update their settlement status" ON split_participants;

-- Recreate with no circular references
-- For split_transactions: Just check if user is payer (simple, no recursion)
CREATE POLICY "Users can view their split transactions"
ON split_transactions FOR SELECT
USING (payer_id = auth.uid());

CREATE POLICY "Users can create split transactions"
ON split_transactions FOR INSERT
WITH CHECK (payer_id = auth.uid());

CREATE POLICY "Payers can update their split transactions"
ON split_transactions FOR UPDATE
USING (payer_id = auth.uid());

-- For split_participants: Check if user is participant (simple, no recursion)
CREATE POLICY "Users can view split participants they are involved in"
ON split_participants FOR SELECT
USING (user_id = auth.uid());

-- Add a separate policy for payers to see ALL participants in their splits
CREATE POLICY "Payers can view all participants in their splits"
ON split_participants FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM split_transactions st 
    WHERE st.id = split_participants.split_transaction_id 
    AND st.payer_id = auth.uid()
  )
);

CREATE POLICY "Payers can create split participants"
ON split_participants FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM split_transactions st
    WHERE st.id = split_participants.split_transaction_id
    AND st.payer_id = auth.uid()
  )
);

CREATE POLICY "Participants can update their settlement status"
ON split_participants FOR UPDATE
USING (user_id = auth.uid());

SELECT 'Split RLS policies fixed - no more infinite recursion!' as status;

