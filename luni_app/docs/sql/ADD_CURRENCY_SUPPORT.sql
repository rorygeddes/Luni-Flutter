-- Add currency support to accounts table
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'CAD';

-- Add currency support to transactions table  
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS original_currency TEXT DEFAULT 'CAD';

-- Update existing accounts to have CAD currency
UPDATE accounts 
SET currency = 'CAD' 
WHERE currency IS NULL;

-- Update existing transactions to have CAD currency
UPDATE transactions 
SET original_currency = 'CAD' 
WHERE original_currency IS NULL;

-- Create index for currency queries
CREATE INDEX IF NOT EXISTS idx_accounts_currency 
ON accounts(currency);

CREATE INDEX IF NOT EXISTS idx_transactions_currency 
ON transactions(original_currency);

-- Verify the changes
SELECT 
  'accounts' as table_name,
  COUNT(*) as total_records,
  COUNT(CASE WHEN currency = 'CAD' THEN 1 END) as cad_records,
  COUNT(CASE WHEN currency = 'USD' THEN 1 END) as usd_records,
  COUNT(CASE WHEN currency IS NULL THEN 1 END) as null_records
FROM accounts

UNION ALL

SELECT 
  'transactions' as table_name,
  COUNT(*) as total_records,
  COUNT(CASE WHEN original_currency = 'CAD' THEN 1 END) as cad_records,
  COUNT(CASE WHEN original_currency = 'USD' THEN 1 END) as usd_records,
  COUNT(CASE WHEN original_currency IS NULL THEN 1 END) as null_records
FROM transactions;
