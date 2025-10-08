-- Reset opening balance date to today (this will fix the balance calculation)
-- This marks TODAY as the starting point for new transactions

UPDATE accounts 
SET opening_balance_date = NOW()
WHERE opening_balance_date IS NOT NULL;

-- Verify the update
SELECT 
  name,
  opening_balance,
  opening_balance_date,
  currency
FROM accounts
ORDER BY name;
