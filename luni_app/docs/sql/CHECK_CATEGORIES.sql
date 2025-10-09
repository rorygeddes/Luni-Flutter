-- ============================================
-- CHECK CATEGORIES IN DATABASE
-- ============================================

-- 1. Count total categories
SELECT COUNT(*) as total_categories FROM categories;

-- 2. Check if categories table exists and has the right structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- 3. Show all categories
SELECT id, user_id, parent_key, name, icon, is_default, is_active, created_at
FROM categories
ORDER BY parent_key, name;

-- 4. Count by parent category
SELECT parent_key, COUNT(*) as count
FROM categories
GROUP BY parent_key
ORDER BY parent_key;

-- 5. Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'categories';

