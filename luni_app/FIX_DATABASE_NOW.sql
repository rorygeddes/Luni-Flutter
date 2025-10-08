-- 🚨 URGENT: Run this in Supabase SQL Editor to fix your database

-- Step 1: Add missing columns to transactions table
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_categorized BOOLEAN DEFAULT FALSE;

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_split BOOLEAN DEFAULT FALSE;

-- Step 2: Make institution_id nullable (or remove the constraint)
-- Your transactions don't have institution_id, only account_id
ALTER TABLE transactions 
ALTER COLUMN institution_id DROP NOT NULL;

-- Step 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_categorized 
ON transactions(user_id, is_categorized);

CREATE INDEX IF NOT EXISTS idx_transactions_account 
ON transactions(user_id, account_id, date DESC);

-- Step 4: Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'transactions'
  AND column_name IN ('is_categorized', 'is_split', 'institution_id')
ORDER BY column_name;

-- Step 5: Check if any transactions exist
SELECT COUNT(*) as transaction_count FROM transactions;

