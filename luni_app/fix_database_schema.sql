-- Fix transactions table schema
-- Add missing columns that the app expects

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_categorized BOOLEAN DEFAULT FALSE;

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_split BOOLEAN DEFAULT FALSE;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_transactions_categorized 
ON transactions(user_id, is_categorized);

CREATE INDEX IF NOT EXISTS idx_transactions_account 
ON transactions(user_id, account_id, date DESC);

-- Verify the schema
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'transactions'
ORDER BY ordinal_position;

