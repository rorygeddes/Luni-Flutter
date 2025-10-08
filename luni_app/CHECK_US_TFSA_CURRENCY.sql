-- Check the US TFSA account currency and balance
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

-- Check if there are any transactions for this account
SELECT 
  COUNT(*) as transaction_count,
  SUM(amount) as total_amount,
  MIN(date) as earliest_transaction,
  MAX(date) as latest_transaction
FROM transactions t
JOIN accounts a ON t.account_id = a.id
WHERE a.name LIKE '%US TFSA%';
