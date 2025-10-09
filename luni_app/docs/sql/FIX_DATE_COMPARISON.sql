-- Fix the date comparison to include ALL transactions from October 7th onwards
-- The issue is that opening_balance_date has a time component that's excluding same-day transactions

-- 1. First, let's see what the opening balance date looks like
SELECT 
  name,
  opening_balance_date,
  opening_balance_date::date as date_only,
  opening_balance_date::timestamp as full_timestamp
FROM accounts 
WHERE name LIKE '%TD REWARDS VISA%';

-- 2. Update the opening balance date to be at the START of October 7th (00:00:00)
UPDATE accounts 
SET opening_balance_date = '2025-10-07 00:00:00'::timestamp
WHERE name LIKE '%TD REWARDS VISA%';

-- 3. Now test the query with the corrected date
WITH credit_card AS (
  SELECT 
    id,
    opening_balance,
    opening_balance_date::date as opening_date
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
  WHERE t.date >= cc.opening_date  -- This should now include October 7th transactions
)
SELECT 
  cc.opening_balance,
  nt.total_new_amount,
  nt.transaction_count,
  cc.opening_balance + nt.total_new_amount as calculated_balance,
  'Should now be $988.6' as expected_result
FROM credit_card cc, new_transactions nt;

-- 4. Show all transactions for the credit card to verify
WITH credit_card AS (
  SELECT id FROM accounts WHERE name LIKE '%TD REWARDS VISA%' LIMIT 1
)
SELECT 
  t.date,
  t.description,
  t.amount,
  CASE 
    WHEN t.date >= '2025-10-07' THEN 'NEW (should be included)'
    ELSE 'OLD (should be excluded)'
  END as transaction_type
FROM transactions t
JOIN credit_card cc ON t.account_id = cc.id
ORDER BY t.date DESC;
