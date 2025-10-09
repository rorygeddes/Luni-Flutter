-- Remove duplicate transactions and verify credit card balance is $1027.83
-- Run CHECK_DUPLICATE_TRANSACTIONS.sql first to see what will be removed!

-- 1. First, backup your transactions table (just in case)
-- CREATE TABLE transactions_backup AS SELECT * FROM transactions;

-- 2. Remove duplicate transactions (keep the oldest one by created_at)
WITH duplicates AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      PARTITION BY date, description, amount, account_id 
      ORDER BY created_at ASC
    ) as row_num
  FROM transactions
)
DELETE FROM transactions
WHERE id IN (
  SELECT id FROM duplicates WHERE row_num > 1
);

-- 3. Show what was removed
SELECT 
  'DUPLICATES REMOVED' as status,
  COUNT(*) as count_removed
FROM transactions_backup
WHERE id NOT IN (SELECT id FROM transactions);

-- 4. Verify credit card balance after removal
WITH credit_card AS (
  SELECT 
    id,
    name,
    opening_balance,
    opening_balance_date
  FROM accounts 
  WHERE type = 'credit' OR subtype = 'credit card'
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
  'BALANCE AFTER CLEANUP' as section,
  cc.name as account_name,
  cc.opening_balance,
  nt.transaction_count as transactions_counted,
  nt.total_new_amount as transaction_total,
  cc.opening_balance + nt.total_new_amount as calculated_balance,
  -1027.83 as expected_balance,
  CASE 
    WHEN ABS((cc.opening_balance + nt.total_new_amount) - (-1027.83)) < 0.01 THEN '✅ CORRECT'
    ELSE '❌ STILL WRONG'
  END as status
FROM credit_card cc, new_transactions nt;

-- 5. If balance is still wrong, check what's different
SELECT 
  'ALL REMAINING TRANSACTIONS' as section,
  t.date,
  t.description,
  t.amount,
  CASE 
    WHEN t.date >= (SELECT opening_balance_date FROM accounts WHERE type = 'credit' LIMIT 1) THEN 'COUNTED'
    ELSE 'NOT COUNTED (before opening date)'
  END as counted_status
FROM transactions t
WHERE t.account_id IN (SELECT id FROM accounts WHERE type = 'credit' OR subtype = 'credit card')
ORDER BY t.date DESC;

