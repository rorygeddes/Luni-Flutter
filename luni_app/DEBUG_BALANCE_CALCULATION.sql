-- Debug the TD Chequing account balance calculation
-- This will show us what's happening with the opening balance and transactions

-- First, let's see the account details
SELECT 
  id,
  name,
  balance as current_balance,
  opening_balance,
  opening_balance_date,
  currency,
  created_at
FROM accounts 
WHERE name LIKE '%TD STUDENT CHEQUING%'
ORDER BY created_at;

-- Now let's see ALL transactions for this account
SELECT 
  date,
  description,
  amount,
  original_currency,
  CASE 
    WHEN date > '2025-10-07' THEN 'NEW (after opening balance date)'
    ELSE 'OLD (before opening balance date)'
  END as transaction_type
FROM transactions 
WHERE account_id IN (
  SELECT id FROM accounts WHERE name LIKE '%TD STUDENT CHEQUING%'
)
ORDER BY date DESC;

-- Calculate what the balance should be
-- Opening balance + only NEW transactions (after 2025-10-07)
WITH account_info AS (
  SELECT 
    id,
    opening_balance,
    opening_balance_date
  FROM accounts 
  WHERE name LIKE '%TD STUDENT CHEQUING%'
  LIMIT 1
),
new_transactions AS (
  SELECT 
    COALESCE(SUM(amount), 0) as total_new_amount
  FROM transactions t
  JOIN account_info a ON t.account_id = a.id
  WHERE t.date > a.opening_balance_date::date
)
SELECT 
  a.opening_balance,
  nt.total_new_amount,
  a.opening_balance + nt.total_new_amount as calculated_balance
FROM account_info a, new_transactions nt;
