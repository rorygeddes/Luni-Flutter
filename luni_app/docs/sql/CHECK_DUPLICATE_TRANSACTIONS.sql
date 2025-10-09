-- Check for duplicate transactions and verify credit card balance should be $1027.83

-- 1. Find all duplicate transactions (same date, description, amount)
SELECT 
  'DUPLICATE TRANSACTIONS' as section,
  t1.id as transaction_id_1,
  t2.id as transaction_id_2,
  t1.date,
  t1.description,
  t1.amount,
  a.name as account_name,
  COUNT(*) OVER (PARTITION BY t1.date, t1.description, t1.amount, t1.account_id) as duplicate_count
FROM transactions t1
JOIN transactions t2 ON 
  t1.date = t2.date AND
  t1.description = t2.description AND
  t1.amount = t2.amount AND
  t1.account_id = t2.account_id AND
  t1.id != t2.id
JOIN accounts a ON t1.account_id = a.id
ORDER BY t1.date DESC, duplicate_count DESC;

-- 2. Find duplicates by transaction ID (Plaid should have unique transaction_id)
SELECT 
  'DUPLICATE BY TRANSACTION ID' as section,
  id,
  COUNT(*) as count
FROM transactions
GROUP BY id
HAVING COUNT(*) > 1;

-- 3. Get credit card details and all transactions
WITH credit_card AS (
  SELECT 
    id,
    name,
    opening_balance,
    opening_balance_date,
    balance
  FROM accounts 
  WHERE type = 'credit' OR subtype = 'credit card'
  LIMIT 1
)
SELECT 
  'CREDIT CARD DETAILS' as section,
  cc.name,
  cc.opening_balance,
  cc.opening_balance_date,
  cc.balance as stored_balance,
  COUNT(t.id) as total_transactions,
  COUNT(DISTINCT t.id) as unique_transactions,
  COUNT(t.id) - COUNT(DISTINCT t.id) as duplicate_count,
  SUM(t.amount) as total_transaction_amount
FROM credit_card cc
LEFT JOIN transactions t ON t.account_id = cc.id
GROUP BY cc.id, cc.name, cc.opening_balance, cc.opening_balance_date, cc.balance;

-- 4. List ALL credit card transactions with duplicate indicators
WITH credit_card AS (
  SELECT id FROM accounts WHERE type = 'credit' OR subtype = 'credit card' LIMIT 1
),
transaction_counts AS (
  SELECT 
    date,
    description,
    amount,
    COUNT(*) as occurrences
  FROM transactions t
  JOIN credit_card cc ON t.account_id = cc.id
  GROUP BY date, description, amount
)
SELECT 
  'ALL CREDIT CARD TRANSACTIONS' as section,
  t.id,
  t.date,
  t.description,
  t.amount,
  t.original_currency,
  tc.occurrences,
  CASE 
    WHEN tc.occurrences > 1 THEN '⚠️ DUPLICATE'
    ELSE '✅ UNIQUE'
  END as status,
  CASE 
    WHEN t.date >= (SELECT opening_balance_date FROM accounts WHERE id IN (SELECT id FROM credit_card)) THEN 'COUNTED'
    ELSE 'IGNORED (before opening date)'
  END as counted_in_balance
FROM transactions t
JOIN credit_card cc ON t.account_id = cc.id
JOIN transaction_counts tc ON 
  t.date = tc.date AND
  t.description = tc.description AND
  t.amount = tc.amount
ORDER BY t.date DESC, t.amount DESC;

-- 5. Calculate what the balance SHOULD be
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
    COUNT(*) as transaction_count,
    COUNT(DISTINCT t.id) as unique_transaction_count
  FROM transactions t
  JOIN credit_card cc ON t.account_id = cc.id
  WHERE t.date >= cc.opening_balance_date::date
)
SELECT 
  'BALANCE CALCULATION' as section,
  cc.name as account_name,
  cc.opening_balance,
  cc.opening_balance_date,
  nt.transaction_count as total_transactions_counted,
  nt.unique_transaction_count as unique_transactions_counted,
  nt.total_new_amount as transaction_total,
  cc.opening_balance + nt.total_new_amount as calculated_balance,
  -1027.83 as expected_balance,
  (cc.opening_balance + nt.total_new_amount) - (-1027.83) as difference_from_expected
FROM credit_card cc, new_transactions nt;

-- 6. Find potential causes of duplicate amount
SELECT 
  'TRANSACTIONS THAT MIGHT BE DUPLICATED' as section,
  date,
  description,
  amount,
  COUNT(*) as count,
  STRING_AGG(id, ', ') as transaction_ids
FROM transactions
WHERE account_id IN (SELECT id FROM accounts WHERE type = 'credit' OR subtype = 'credit card')
GROUP BY date, description, amount
HAVING COUNT(*) > 1
ORDER BY count DESC, date DESC;

