-- Debug credit card transactions to see why it's showing $941.29 instead of $988.6

-- 1. Get the credit card account details
SELECT 
  id,
  name,
  type,
  subtype,
  balance,
  opening_balance,
  opening_balance_date,
  currency
FROM accounts 
WHERE name LIKE '%TD REWARDS VISA%'
LIMIT 1;

-- 2. Get the account ID for the credit card
WITH credit_card AS (
  SELECT id FROM accounts WHERE name LIKE '%TD REWARDS VISA%' LIMIT 1
)
SELECT 
  t.date,
  t.description,
  t.amount,
  CASE 
    WHEN t.date >= '2025-10-07' THEN 'NEW (after opening balance date)'
    ELSE 'OLD (before opening balance date)'
  END as transaction_type,
  t.date >= '2025-10-07' as is_new
FROM transactions t
JOIN credit_card cc ON t.account_id = cc.id
ORDER BY t.date DESC;

-- 3. Calculate what the balance should be
WITH credit_card AS (
  SELECT 
    id,
    opening_balance,
    opening_balance_date
  FROM accounts 
  WHERE name LIKE '%TD REWARDS VISA%'
  LIMIT 1
),
new_transactions AS (
  SELECT 
    COALESCE(SUM(t.amount), 0) as total_new_amount,
    COUNT(*) as transaction_count
  FROM transactions t
  JOIN credit_card cc ON t.account_id = cc.id
  WHERE t.date >= cc.opening_balance_date::date
)
SELECT 
  cc.opening_balance,
  nt.total_new_amount,
  nt.transaction_count,
  cc.opening_balance + nt.total_new_amount as calculated_balance,
  'Expected: $988.6' as expected_result
FROM credit_card cc, new_transactions nt;
