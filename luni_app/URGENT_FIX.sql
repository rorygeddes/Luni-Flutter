-- URGENT FIX: Add missing columns and set opening balance properly
-- This will fix the dynamic balance calculation

-- 1. Add missing columns (ignore errors if they exist)
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS opening_balance NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS opening_balance_date TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'CAD';

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS original_currency TEXT DEFAULT 'CAD';

-- 2. Set opening balance to current balance for existing accounts
-- This preserves your opening balance from when you first connected
UPDATE accounts 
SET 
  opening_balance = balance,
  opening_balance_date = '2025-10-07 00:00:00'::timestamp,  -- Set to yesterday
  currency = CASE 
    WHEN name = 'US TFSA' THEN 'USD'
    ELSE 'CAD'
  END
WHERE opening_balance = 0 OR opening_balance IS NULL;

-- 3. Update transaction currencies
UPDATE transactions 
SET original_currency = 'CAD' 
WHERE original_currency IS NULL;

-- 4. Create index for performance
CREATE INDEX IF NOT EXISTS idx_transactions_account_date 
ON transactions(account_id, date);

-- 5. Verify the fix
SELECT 
  name,
  balance as current_balance,
  opening_balance,
  opening_balance_date,
  currency,
  'Should show opening balance from yesterday' as note
FROM accounts
ORDER BY name;
