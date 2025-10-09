-- Fix existing credit card balances to be negative (debt)
-- This will make credit card opening balances negative so the dynamic calculation works correctly

-- First, let's see the current state
SELECT 
  name,
  type,
  subtype,
  balance,
  opening_balance,
  opening_balance_date,
  currency
FROM accounts 
WHERE type = 'credit' OR subtype = 'credit card'
ORDER BY name;

-- Update credit card balances to be negative (debt)
UPDATE accounts 
SET 
  balance = -ABS(balance),
  opening_balance = -ABS(opening_balance)
WHERE (type = 'credit' OR subtype = 'credit card') 
  AND balance > 0;

-- Show the updated state
SELECT 
  name,
  type,
  subtype,
  balance,
  opening_balance,
  opening_balance_date,
  currency
FROM accounts 
WHERE type = 'credit' OR subtype = 'credit card'
ORDER BY name;

-- Verify the fix worked
SELECT 
  'Credit Card Balance Fix Applied' as status,
  COUNT(*) as credit_cards_updated
FROM accounts 
WHERE (type = 'credit' OR subtype = 'credit card') 
  AND balance < 0;
