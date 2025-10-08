-- Debug the date comparison issue
-- This will show us exactly why the $1 transaction isn't being counted

-- 1. Get the TD Chequing account details
SELECT 
  id as account_id,
  name,
  opening_balance,
  opening_balance_date,
  opening_balance_date::date as opening_date_only,
  currency
FROM accounts 
WHERE name LIKE '%TD STUDENT CHEQUING%';

-- 2. Get the specific $1 transaction details
SELECT 
  id as transaction_id,
  account_id,
  date as transaction_date,
  date::date as transaction_date_only,
  description,
  amount,
  original_currency
FROM transactions 
WHERE amount = -1.00 
  AND description LIKE '%E-TFR%'
ORDER BY date DESC
LIMIT 1;

-- 3. Show the date comparison logic
WITH account_info AS (
  SELECT 
    id,
    opening_balance_date::date as opening_date
  FROM accounts 
  WHERE name LIKE '%TD STUDENT CHEQUING%'
  LIMIT 1
),
transaction_info AS (
  SELECT 
    date::date as transaction_date,
    amount,
    description
  FROM transactions 
  WHERE amount = -1.00 
    AND description LIKE '%E-TFR%'
  ORDER BY date DESC
  LIMIT 1
)
SELECT 
  a.opening_date,
  t.transaction_date,
  t.amount,
  t.description,
  CASE 
    WHEN t.transaction_date > a.opening_date THEN 'SHOULD BE INCLUDED (transaction is newer)'
    WHEN t.transaction_date = a.opening_date THEN 'SAME DATE (might be included)'
    ELSE 'SHOULD BE EXCLUDED (transaction is older)'
  END as comparison_result,
  t.transaction_date > a.opening_date as is_newer
FROM account_info a, transaction_info t;

-- 4. Show all transactions for this account with date comparison
WITH account_info AS (
  SELECT 
    id as account_id,
    opening_balance_date::date as opening_date
  FROM accounts 
  WHERE name LIKE '%TD STUDENT CHEQUING%'
  LIMIT 1
)
SELECT 
  t.date::date as transaction_date,
  t.description,
  t.amount,
  CASE 
    WHEN t.date::date > a.opening_date THEN 'NEW (after opening)'
    WHEN t.date::date = a.opening_date THEN 'SAME DAY'
    ELSE 'OLD (before opening)'
  END as status,
  t.date::date > a.opening_date as is_newer
FROM transactions t
JOIN account_info a ON t.account_id = a.account_id
ORDER BY t.date DESC
LIMIT 10;
