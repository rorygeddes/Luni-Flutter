-- Diagnostic script to check transaction sync and balance calculation

-- 1. Check if opening_balance columns exist and are set
SELECT 
  'ACCOUNTS CHECK' as section,
  name,
  balance,
  opening_balance,
  opening_balance_date,
  currency,
  CASE 
    WHEN opening_balance IS NULL THEN '❌ MISSING'
    WHEN opening_balance = 0 THEN '⚠️  ZERO'
    ELSE '✅ SET'
  END as opening_balance_status
FROM accounts
ORDER BY name;

-- 2. Check recent transactions (last 5 days)
SELECT 
  'RECENT TRANSACTIONS' as section,
  t.date,
  t.description,
  t.amount,
  t.original_currency,
  a.name as account_name
FROM transactions t
JOIN accounts a ON t.account_id = a.id
WHERE t.date >= CURRENT_DATE - INTERVAL '5 days'
ORDER BY t.date DESC, t.amount DESC
LIMIT 20;

-- 3. Check transactions by account
SELECT 
  'TRANSACTIONS BY ACCOUNT' as section,
  a.name as account_name,
  COUNT(t.id) as total_transactions,
  COUNT(CASE WHEN t.date > a.opening_balance_date::date THEN 1 END) as new_transactions,
  COALESCE(SUM(CASE WHEN t.date > a.opening_balance_date::date THEN t.amount ELSE 0 END), 0) as new_transactions_sum
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.name, a.opening_balance_date
ORDER BY a.name;

-- 4. Check for the specific $1.00 transaction
SELECT 
  'FIND $1.00 TRANSACTION' as section,
  t.date,
  t.description,
  t.amount,
  a.name as account_name
FROM transactions t
JOIN accounts a ON t.account_id = a.id
WHERE t.amount = 1.00 OR t.amount = -1.00
ORDER BY t.date DESC;
