-- Check which transactions will be counted as "new" (after opening balance date)

SELECT 
  a.name as account_name,
  a.opening_balance_date,
  COUNT(t.id) as new_transactions_count,
  COALESCE(SUM(t.amount), 0) as new_transactions_total
FROM accounts a
LEFT JOIN transactions t ON a.id = t.account_id 
  AND t.date > a.opening_balance_date::date
GROUP BY a.id, a.name, a.opening_balance_date
ORDER BY a.name;

-- Show the actual new transactions (if any)
SELECT 
  a.name as account_name,
  t.date,
  t.description,
  t.amount,
  t.original_currency
FROM accounts a
JOIN transactions t ON a.id = t.account_id 
  AND t.date > a.opening_balance_date::date
ORDER BY a.name, t.date DESC;
