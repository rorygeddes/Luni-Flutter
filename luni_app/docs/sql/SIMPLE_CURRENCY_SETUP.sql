-- Simple Currency Setup for Luni App
-- Run this in your Supabase SQL Editor

-- Add currency column to accounts table
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'CAD';

-- Add original_currency column to transactions table  
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS original_currency TEXT DEFAULT 'CAD';

-- Update existing NULL values
UPDATE accounts SET currency = 'CAD' WHERE currency IS NULL;
UPDATE transactions SET original_currency = 'CAD' WHERE original_currency IS NULL;

-- Verify the setup
SELECT 
  'Accounts with currency' as status,
  COUNT(*) as count,
  COUNT(CASE WHEN currency = 'CAD' THEN 1 END) as cad_count,
  COUNT(CASE WHEN currency = 'USD' THEN 1 END) as usd_count
FROM accounts;

SELECT 
  'Transactions with currency' as status,
  COUNT(*) as count,
  COUNT(CASE WHEN original_currency = 'CAD' THEN 1 END) as cad_count,
  COUNT(CASE WHEN original_currency = 'USD' THEN 1 END) as usd_count
FROM transactions;
