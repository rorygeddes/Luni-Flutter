-- Add AI description column to transactions table for the transaction queue system

-- Add ai_description column (AI-cleaned, user-editable)
ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS ai_description TEXT;

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_transactions_ai_description 
ON transactions(ai_description);

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'transactions' 
AND column_name IN ('description', 'ai_description', 'category', 'subcategory', 'is_categorized', 'is_split');

-- Show example of how the data should look
SELECT 
  'EXAMPLE DATA STRUCTURE' as note,
  description as raw_description,
  ai_description,
  category as parent_category,
  subcategory as sub_category,
  is_categorized,
  is_split
FROM transactions
LIMIT 3;

