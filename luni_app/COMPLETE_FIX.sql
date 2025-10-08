-- Complete fix for opening balance system
-- This will add the missing columns and preserve your opening balance date from yesterday

-- Add missing columns
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS opening_balance NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS opening_balance_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'CAD';

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS original_currency TEXT DEFAULT 'CAD';

-- Set opening balance to current balance (preserving yesterday's date)
-- This keeps your opening balance date from yesterday intact
UPDATE accounts 
SET 
  opening_balance = balance,
  currency = CASE 
    WHEN name = 'US TFSA' THEN 'USD'
    ELSE 'CAD'
  END
WHERE opening_balance = 0 OR opening_balance IS NULL;

-- Update transaction currencies
UPDATE transactions 
SET original_currency = 'CAD' 
WHERE original_currency IS NULL;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_transactions_account_date 
ON transactions(account_id, date);

-- Verify the setup
SELECT 
  name,
  balance,
  opening_balance,
  opening_balance_date,
  currency
FROM accounts
ORDER BY name;
