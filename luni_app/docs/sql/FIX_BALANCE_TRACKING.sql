-- Fix Balance Tracking System
-- This separates "opening balance" from "dynamic balance"

-- Add opening_balance and opening_balance_date columns to accounts
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS opening_balance NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS opening_balance_date TIMESTAMP DEFAULT NOW();

-- Set opening balance to current balance for existing accounts
-- This marks "today" as the starting point for dynamic calculations
UPDATE accounts 
SET 
  opening_balance = balance,
  opening_balance_date = NOW()
WHERE opening_balance IS NULL OR opening_balance = 0;

-- Add index for efficient transaction queries
CREATE INDEX IF NOT EXISTS idx_transactions_account_date 
ON transactions(account_id, date);

-- Verify the setup
SELECT 
  name,
  opening_balance,
  opening_balance_date,
  balance as current_static_balance,
  currency
FROM accounts
ORDER BY name;
