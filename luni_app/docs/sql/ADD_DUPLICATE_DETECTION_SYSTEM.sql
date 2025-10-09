-- Add duplicate detection and deleted transactions system

-- 1. Add flag for potential duplicates to transactions table
ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS is_potential_duplicate BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS duplicate_of_transaction_id TEXT,
ADD COLUMN IF NOT EXISTS duplicate_checked_at TIMESTAMP;

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
  deleted_reason TEXT, -- 'duplicate', 'user_request', etc.
  original_transaction_data JSONB, -- Store full original data for recovery
  can_recover BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_potential_duplicate 
ON transactions(is_potential_duplicate) 
WHERE is_potential_duplicate = TRUE;

CREATE INDEX IF NOT EXISTS idx_transactions_duplicate_search 
ON transactions(account_id, date, amount, description);

CREATE INDEX IF NOT EXISTS idx_deleted_transactions_user 
ON deleted_transactions(user_id, deleted_at DESC);

CREATE INDEX IF NOT EXISTS idx_deleted_transactions_recoverable 
ON deleted_transactions(user_id, can_recover) 
WHERE can_recover = TRUE;

-- 4. Add RLS policies for deleted_transactions
ALTER TABLE deleted_transactions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own deleted transactions
CREATE POLICY "Users can view own deleted transactions"
ON deleted_transactions FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own deleted transactions
CREATE POLICY "Users can insert own deleted transactions"
ON deleted_transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own deleted transactions (for recovery)
CREATE POLICY "Users can update own deleted transactions"
ON deleted_transactions FOR UPDATE
USING (auth.uid() = user_id);

-- Users can delete their own deleted transactions (permanent deletion)
CREATE POLICY "Users can delete own deleted transactions"
ON deleted_transactions FOR DELETE
USING (auth.uid() = user_id);

-- 5. Create function to find potential duplicates
CREATE OR REPLACE FUNCTION find_potential_duplicates(
  p_account_id TEXT,
  p_date DATE,
  p_amount NUMERIC,
  p_description TEXT,
  p_transaction_id TEXT
) RETURNS TABLE (
  id TEXT,
  date DATE,
  description TEXT,
  amount NUMERIC,
  days_difference INTEGER,
  match_score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.date,
    t.description,
    t.amount,
    ABS(EXTRACT(DAY FROM (t.date - p_date))::INTEGER) as days_difference,
    CASE
      -- Exact match (same date, amount, description)
      WHEN t.date = p_date AND t.amount = p_amount AND t.description = p_description THEN 100
      -- Same amount and description, within 3 days
      WHEN t.amount = p_amount AND t.description = p_description AND ABS(EXTRACT(DAY FROM (t.date - p_date))) <= 3 THEN 90
      -- Same amount, similar description, within 3 days
      WHEN t.amount = p_amount AND SIMILARITY(t.description, p_description) > 0.8 AND ABS(EXTRACT(DAY FROM (t.date - p_date))) <= 3 THEN 80
      -- Same amount, within 1 day
      WHEN t.amount = p_amount AND ABS(EXTRACT(DAY FROM (t.date - p_date))) <= 1 THEN 70
      ELSE 0
    END as match_score
  FROM transactions t
  WHERE 
    t.account_id = p_account_id
    AND t.id != p_transaction_id
    AND ABS(EXTRACT(DAY FROM (t.date - p_date))) <= 3
    AND t.amount = p_amount
    AND NOT EXISTS (
      SELECT 1 FROM deleted_transactions dt WHERE dt.id = t.id
    )
  ORDER BY match_score DESC, days_difference ASC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- 6. Create function to move transaction to deleted_transactions
CREATE OR REPLACE FUNCTION move_to_deleted_transactions(
  p_transaction_id TEXT,
  p_reason TEXT DEFAULT 'duplicate'
) RETURNS BOOLEAN AS $$
DECLARE
  v_transaction_data JSONB;
BEGIN
  -- Get the full transaction data
  SELECT to_jsonb(t.*) INTO v_transaction_data
  FROM transactions t
  WHERE id = p_transaction_id;
  
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
    original_transaction_data
  )
  SELECT 
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
    p_reason,
    v_transaction_data
  FROM transactions
  WHERE id = p_transaction_id;
  
  -- Delete from transactions
  DELETE FROM transactions WHERE id = p_transaction_id;
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 7. Create function to recover transaction from deleted_transactions
CREATE OR REPLACE FUNCTION recover_deleted_transaction(
  p_transaction_id TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  -- Insert back into transactions from deleted_transactions
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
  )
  SELECT 
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
    (original_transaction_data->>'created_at')::TIMESTAMP,
    NOW()
  FROM deleted_transactions
  WHERE id = p_transaction_id AND can_recover = TRUE;
  
  -- Remove from deleted_transactions
  DELETE FROM deleted_transactions WHERE id = p_transaction_id;
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 8. Test the system
SELECT 'Duplicate detection system installed successfully!' as status;

-- Show example usage:
-- SELECT * FROM find_potential_duplicates('account_id', '2025-10-08'::DATE, -9.04, 'BELL MEDIA', 'current_transaction_id');
-- SELECT move_to_deleted_transactions('transaction_id', 'duplicate');
-- SELECT recover_deleted_transaction('transaction_id');

