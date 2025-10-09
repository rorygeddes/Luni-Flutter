-- Fix infinite recursion in split_transactions RLS policies
-- The issue: split_transactions references split_participants, which references split_transactions (circular!)

-- Drop old policies
DROP POLICY IF EXISTS "Users can view their split transactions" ON split_transactions;
DROP POLICY IF EXISTS "Users can view split participants they are involved in" ON split_participants;

-- Recreate with no circular references
-- For split_transactions: Just check if user is payer (simple, no recursion)
CREATE POLICY "Users can view their split transactions"
ON split_transactions FOR SELECT
USING (payer_id = auth.uid());

-- For split_participants: Check if user is participant OR owner of the transaction
CREATE POLICY "Users can view split participants they are involved in"
ON split_participants FOR SELECT
USING (user_id = auth.uid());

-- Add a separate policy for payers to see participants
CREATE POLICY "Payers can view all participants in their splits"
ON split_participants FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM split_transactions st 
    WHERE st.id = split_participants.split_transaction_id 
    AND st.payer_id = auth.uid()
  )
);

SELECT 'Split RLS policies fixed - no more infinite recursion!' as status;

