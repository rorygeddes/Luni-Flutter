-- Find the $1.00 transaction and related E-TFR transactions

-- 1. Look for exact $1.00 or -$1.00 transactions
SELECT 
  'EXACT $1.00 TRANSACTIONS' as search_type,
  id,
  date,
  description,
  amount,
  original_currency,
  merchant_name,
  account_id
FROM transactions
WHERE amount = 1.00 OR amount = -1.00
ORDER BY date DESC;

-- 2. Look for E-TFR transactions (like your $1.00 one)
SELECT 
  'E-TFR TRANSACTIONS' as search_type,
  id,
  date,
  description,
  amount,
  original_currency,
  merchant_name,
  account_id
FROM transactions
WHERE description ILIKE '%E-TFR%'
ORDER BY date DESC;

-- 3. Look for transactions with "SEND" in description
SELECT 
  'SEND TRANSACTIONS' as search_type,
  id,
  date,
  description,
  amount,
  original_currency,
  merchant_name,
  account_id
FROM transactions
WHERE description ILIKE '%SEND%'
ORDER BY date DESC;

-- 4. Look for very recent transactions (last 3 days)
SELECT 
  'RECENT TRANSACTIONS (LAST 3 DAYS)' as search_type,
  id,
  date,
  description,
  amount,
  original_currency,
  merchant_name,
  account_id
FROM transactions
WHERE date >= CURRENT_DATE - INTERVAL '3 days'
ORDER BY date DESC, amount DESC;

-- 5. Look for transactions with amounts between $0.50 and $1.50 (in case it's not exactly $1.00)
SELECT 
  'TRANSACTIONS $0.50 - $1.50' as search_type,
  id,
  date,
  description,
  amount,
  original_currency,
  merchant_name,
  account_id
FROM transactions
WHERE (amount BETWEEN 0.50 AND 1.50) OR (amount BETWEEN -1.50 AND -0.50)
ORDER BY date DESC, amount DESC;
