-- ============================================
-- RESET ALL TRANSACTIONS TO UNCATEGORIZED
-- ============================================
-- This will make all transactions appear in the transaction queue again

-- Reset all transactions to uncategorized state
UPDATE transactions
SET 
  category = NULL,
  subcategory = NULL,
  is_categorized = FALSE,
  is_split = FALSE,
  updated_at = NOW()
WHERE user_id = auth.uid();

-- Verify the reset
SELECT 
  COUNT(*) as total_transactions,
  COUNT(CASE WHEN is_categorized = FALSE THEN 1 END) as uncategorized_count,
  COUNT(CASE WHEN category IS NULL THEN 1 END) as null_category_count
FROM transactions
WHERE user_id = auth.uid();

-- Show a sample of the reset transactions
SELECT 
  id,
  description,
  amount,
  date,
  category,
  subcategory,
  is_categorized,
  is_split
FROM transactions
WHERE user_id = auth.uid()
ORDER BY date DESC
LIMIT 10;