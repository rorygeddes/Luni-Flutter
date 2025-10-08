-- Fix the US TFSA account currency from CAD to USD
-- This will enable currency conversion to CAD

-- 1. Update the currency for US TFSA account
UPDATE accounts
SET currency = 'USD'
WHERE name LIKE '%US TFSA%';

-- 2. Verify the change
SELECT 
  id,
  name,
  type,
  subtype,
  balance,
  currency,
  opening_balance,
  opening_balance_date
FROM accounts 
WHERE name LIKE '%US TFSA%';

-- 3. Show what the conversion should look like
-- (This is just for reference - the app will do the actual conversion)
SELECT 
  'Expected conversion' as status,
  balance as usd_amount,
  'USD' as from_currency,
  ROUND(balance * 1.37, 2) as expected_cad_amount,
  'CAD' as to_currency,
  'Rate: ~1.37' as exchange_rate_note
FROM accounts 
WHERE name LIKE '%US TFSA%';