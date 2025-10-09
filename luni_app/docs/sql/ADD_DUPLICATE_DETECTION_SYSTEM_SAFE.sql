-- Safe version: Add duplicate detection and deleted transactions system
-- This version won't error if objects already exist

-- 1. Add flag for potential duplicates to transactions table
ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS is_potential_duplicate BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS duplicate_of_transaction_id TEXT,
ADD COLUMN IF NOT EXISTS duplicate_checked_at TIMESTAMP;

-- Also add ai_description column if it doesn't exist
ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS ai_description TEXT;

-- 2. Create deleted_transactions table for recoverable deletions
CREATE TABLE IF NOT EXISTS deleted_transactions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  original_currency TEXT NOT NULL DEFAULT 'CAD',
  description TEXT NOT NULL,
  merchant_name TEXT,
  date DATE NOT NULL,
  category TEXT,
  subcategory TEXT,
  is_categorized BOOLEAN DEFAULT FALSE,
  is_split BOOLEAN DEFAULT FALSE,
  notes TEXT,
  deleted_at TIMESTAMP DEFAULT NOW(),
  deleted_reason TEXT,
  original_transaction_data JSONB,
  can_recover BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Enable RLS on deleted_transactions if not already enabled
ALTER TABLE deleted_transactions ENABLE ROW LEVEL SECURITY;

-- 4. Drop existing policies if they exist, then recreate
DROP POLICY IF EXISTS "Users can view own deleted transactions" ON deleted_transactions;
DROP POLICY IF EXISTS "Users can insert own deleted transactions" ON deleted_transactions;
DROP POLICY IF EXISTS "Users can delete own deleted transactions" ON deleted_transactions;

CREATE POLICY "Users can view own deleted transactions"
ON deleted_transactions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own deleted transactions"
ON deleted_transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own deleted transactions"
ON deleted_transactions FOR DELETE
USING (auth.uid() = user_id);

-- 5. Create or replace the RPC functions

-- Function to find potential duplicates
CREATE OR REPLACE FUNCTION find_potential_duplicates(
  p_account_id TEXT,
  p_date DATE,
  p_description TEXT,
  p_amount NUMERIC
)
RETURNS TABLE (
  id TEXT,
  date DATE,
  description TEXT,
  amount NUMERIC,
  created_at TIMESTAMP,
  days_difference INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.date,
    t.description,
    t.amount,
    t.created_at,
    ABS(EXTRACT(DAY FROM (p_date - t.date)))::INTEGER as days_difference
  FROM transactions t
  WHERE t.account_id = p_account_id
    AND t.description = p_description
    AND t.amount = p_amount
    AND ABS(EXTRACT(DAY FROM (p_date - t.date))) <= 3
    AND t.date <= p_date  -- Only look at transactions on or before this date
  ORDER BY t.created_at ASC;  -- Oldest first
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to move transaction to deleted_transactions
CREATE OR REPLACE FUNCTION move_to_deleted_transactions(p_transaction_id TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_transaction RECORD;
BEGIN
  -- Get the transaction
  SELECT * INTO v_transaction
  FROM transactions
  WHERE id = p_transaction_id
    AND user_id = auth.uid();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found or access denied';
  END IF;
  
  -- Insert into deleted_transactions
  INSERT INTO deleted_transactions (
    id,
    user_id,
    account_id,
    amount,
    original_currency,
    description,
    merchant_name,
    date,
    category,
    subcategory,
    is_categorized,
    is_split,
    notes,
    deleted_reason,
    original_transaction_data,
    can_recover
  ) VALUES (
    v_transaction.id,
    v_transaction.user_id,
    v_transaction.account_id,
    v_transaction.amount,
    COALESCE(v_transaction.original_currency, 'CAD'),
    v_transaction.description,
    v_transaction.merchant_name,
    v_transaction.date,
    v_transaction.category,
    v_transaction.subcategory,
    v_transaction.is_categorized,
    v_transaction.is_split,
    v_transaction.notes,
    'duplicate',
    row_to_json(v_transaction),
    TRUE
  );
  
  -- Delete from transactions
  DELETE FROM transactions WHERE id = p_transaction_id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to recover deleted transaction
CREATE OR REPLACE FUNCTION recover_deleted_transaction(p_transaction_id TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_deleted_transaction RECORD;
BEGIN
  -- Get the deleted transaction
  SELECT * INTO v_deleted_transaction
  FROM deleted_transactions
  WHERE id = p_transaction_id
    AND user_id = auth.uid()
    AND can_recover = TRUE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Deleted transaction not found, access denied, or cannot be recovered';
  END IF;
  
  -- Restore to transactions table
  INSERT INTO transactions (
    id,
    user_id,
    account_id,
    amount,
    original_currency,
    description,
    merchant_name,
    date,
    category,
    subcategory,
    is_categorized,
    is_split,
    notes,
    created_at,
    updated_at
  ) VALUES (
    v_deleted_transaction.id,
    v_deleted_transaction.user_id,
    v_deleted_transaction.account_id,
    v_deleted_transaction.amount,
    v_deleted_transaction.original_currency,
    v_deleted_transaction.description,
    v_deleted_transaction.merchant_name,
    v_deleted_transaction.date,
    v_deleted_transaction.category,
    v_deleted_transaction.subcategory,
    v_deleted_transaction.is_categorized,
    v_deleted_transaction.is_split,
    v_deleted_transaction.notes,
    v_deleted_transaction.created_at,
    NOW()
  );
  
  -- Remove from deleted_transactions
  DELETE FROM deleted_transactions WHERE id = p_transaction_id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_duplicate_check 
ON transactions(account_id, description, amount, date);

CREATE INDEX IF NOT EXISTS idx_transactions_potential_duplicate 
ON transactions(is_potential_duplicate, duplicate_checked_at);

CREATE INDEX IF NOT EXISTS idx_deleted_transactions_user_id 
ON deleted_transactions(user_id, deleted_at);

-- 7. Test the system
SELECT 'Duplicate detection system installed successfully!' as status;

