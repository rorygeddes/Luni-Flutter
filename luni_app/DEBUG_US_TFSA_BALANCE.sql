-- Debug the US TFSA account balance calculation
-- This will show us exactly what values are being used

SELECT 
  'US TFSA Account Details' as info,
  id,
  name,
  type,
  subtype,
  balance as current_balance,
  currency,
  opening_balance,
  opening_balance_date,
  created_at
FROM accounts 
WHERE name LIKE '%US TFSA%';

-- Check if there are any transactions for this account
SELECT 
  'US TFSA Transactions' as info,
  COUNT(*) as transaction_count,
  COALESCE(SUM(amount), 0) as total_amount,
  MIN(date) as earliest_date,
  MAX(date) as latest_date
FROM transactions 
WHERE account_id = (SELECT id FROM accounts WHERE name LIKE '%US TFSA%' LIMIT 1);

-- Show the exact calculation that should happen
SELECT 
  'Expected Calculation' as info,
  opening_balance as usd_opening_balance,
  currency as original_currency,
  ROUND(opening_balance * 1.37, 2) as expected_cad_balance,
  'USD → CAD (rate ~1.37)' as conversion_note
FROM accounts 
WHERE name LIKE '%US TFSA%';
