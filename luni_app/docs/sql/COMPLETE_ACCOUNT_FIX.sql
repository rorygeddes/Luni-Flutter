-- COMPLETE ACCOUNT FIX - Applies to ALL account types
-- This ensures all accounts work with the >= date logic and credit cards show proper debt

-- 1. Fix credit card balances to be negative (debt)
UPDATE accounts 
SET 
  balance = -ABS(balance),
  opening_balance = -ABS(opening_balance)
WHERE (type = 'credit' OR subtype = 'credit card') 
  AND balance > 0;

-- 2. Ensure ALL accounts have proper opening balance dates
-- Set opening balance date to yesterday for all accounts that don't have one
UPDATE accounts 
SET opening_balance_date = '2025-10-07 00:00:00'::timestamp
WHERE opening_balance_date IS NULL 
   OR opening_balance_date = '1970-01-01 00:00:00'::timestamp;

-- 3. Show the current state of all accounts
SELECT 
  name,
  type,
  subtype,
  balance,
  opening_balance,
  opening_balance_date,
  currency,
  CASE 
    WHEN type = 'credit' OR subtype = 'credit card' THEN 'Credit Card (Debt)'
    WHEN type = 'depository' THEN 'Checking/Savings'
    WHEN type = 'investment' THEN 'Investment'
    ELSE 'Other'
  END as account_category
FROM accounts 
ORDER BY 
  CASE 
    WHEN type = 'credit' OR subtype = 'credit card' THEN 1
    WHEN type = 'depository' THEN 2
    WHEN type = 'investment' THEN 3
    ELSE 4
  END,
  name;

-- 4. Verify the fix worked
SELECT 
  'Account Fix Summary' as status,
  COUNT(*) as total_accounts,
  COUNT(CASE WHEN type = 'credit' OR subtype = 'credit card' THEN 1 END) as credit_cards,
  COUNT(CASE WHEN type = 'depository' THEN 1 END) as depository_accounts,
  COUNT(CASE WHEN type = 'investment' THEN 1 END) as investment_accounts,
  COUNT(CASE WHEN opening_balance_date IS NOT NULL THEN 1 END) as accounts_with_opening_dates
FROM accounts;
