-- ✅ FINAL FIX - Only the critical missing pieces

-- 1. Make institution_id nullable (CRITICAL - fixes your 135 transaction errors!)
ALTER TABLE transactions 
ALTER COLUMN institution_id DROP NOT NULL;

-- 2. Add category_id column to transactions (if not exists)
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS category_id TEXT REFERENCES categories(id);

-- 3. Create index for category lookups
CREATE INDEX IF NOT EXISTS idx_transactions_category 
ON transactions(category_id);

-- 4. Verify what you have
SELECT 
  parent_key,
  COUNT(*) as subcategory_count
FROM categories
WHERE user_id IS NULL
GROUP BY parent_key
ORDER BY parent_key;

SELECT COUNT(*) as total_default_categories FROM categories WHERE user_id IS NULL;

-- 5. Check transactions table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'transactions'
  AND column_name IN ('is_categorized', 'is_split', 'institution_id', 'category_id')
ORDER BY column_name;

