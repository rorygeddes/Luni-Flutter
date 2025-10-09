-- ============================================
-- ENSURE DEFAULT CATEGORIES FROM WORKFLOW.MD
-- ============================================
-- This script adds all default parent categories and their common subcategories
-- Based on the workflow.md specification

-- First, add a unique constraint if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'categories_unique_constraint'
    ) THEN
        ALTER TABLE categories 
        ADD CONSTRAINT categories_unique_constraint 
        UNIQUE (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid));
    END IF;
END $$;

-- ============================================
-- PARENT CATEGORIES (Living Essentials)
-- ============================================

-- Living Essentials Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'living', 'Living', '🏠', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Living Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'living', 'Rent', '🏘️', true, true, NOW()),
  (NULL, 'living', 'Wifi', '📶', true, true, NOW()),
  (NULL, 'living', 'Utilities', '💡', true, true, NOW()),
  (NULL, 'living', 'Phone', '📱', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Education)
-- ============================================

-- Education Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'education', 'Education', '📚', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Education Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'education', 'Tuition', '🎓', true, true, NOW()),
  (NULL, 'education', 'Supplies', '✏️', true, true, NOW()),
  (NULL, 'education', 'Books', '📖', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Food)
-- ============================================

-- Food Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'food', 'Food', '🍔', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Food Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'food', 'Groceries', '🛒', true, true, NOW()),
  (NULL, 'food', 'Coffee', '☕', true, true, NOW()),
  (NULL, 'food', 'Restaurants', '🍽️', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Transportation)
-- ============================================

-- Transportation Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'transportation', 'Transportation', '🚗', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Transportation Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'transportation', 'Bus Pass', '🚌', true, true, NOW()),
  (NULL, 'transportation', 'Gas', '⛽', true, true, NOW()),
  (NULL, 'transportation', 'Rideshare', '🚕', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Healthcare)
-- ============================================

-- Healthcare Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'healthcare', 'Healthcare', '💊', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Healthcare Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'healthcare', 'Gym', '🏋️', true, true, NOW()),
  (NULL, 'healthcare', 'Medication', '💊', true, true, NOW()),
  (NULL, 'healthcare', 'Haircuts', '💇', true, true, NOW()),
  (NULL, 'healthcare', 'Toiletries', '🧴', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Entertainment)
-- ============================================

-- Entertainment Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'entertainment', 'Entertainment', '🎬', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Entertainment Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'entertainment', 'Events', '🎫', true, true, NOW()),
  (NULL, 'entertainment', 'Night Out', '🌃', true, true, NOW()),
  (NULL, 'entertainment', 'Shopping', '🛍️', true, true, NOW()),
  (NULL, 'entertainment', 'Subscriptions', '📺', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Income)
-- ============================================

-- Income Parent
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'income', 'Income', '💰', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Income Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'income', 'Job Income', '💼', true, true, NOW()),
  (NULL, 'income', 'Family Support', '👨‍👩‍👧', true, true, NOW()),
  (NULL, 'income', 'Investments', '📈', true, true, NOW()),
  (NULL, 'income', 'Bonus', '🎁', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- PARENT CATEGORIES (Other)
-- ============================================

-- Other Parent (catch-all)
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'other', 'Other', '📦', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- Other Subcategories
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
VALUES 
  (NULL, 'other', 'Miscellaneous', '🔧', true, true, NOW())
ON CONFLICT (parent_key, name, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid)) DO NOTHING;

-- ============================================
-- VERIFY THE CATEGORIES
-- ============================================

-- View all parent categories
SELECT 'PARENT CATEGORIES:' as info;
SELECT parent_key, name, icon, is_default
FROM categories 
WHERE parent_key = name OR parent_key = LOWER(REPLACE(name, ' ', ''))
ORDER BY name;

-- View all subcategories
SELECT 'SUBCATEGORIES:' as info;
SELECT parent_key, name, icon, is_default
FROM categories 
WHERE parent_key != name AND parent_key != LOWER(REPLACE(name, ' ', ''))
ORDER BY parent_key, name;

-- Count by parent
SELECT 'CATEGORY COUNTS:' as info;
SELECT 
  parent_key,
  COUNT(*) as subcategory_count
FROM categories
WHERE parent_key != name AND parent_key != LOWER(REPLACE(name, ' ', ''))
GROUP BY parent_key
ORDER BY parent_key;

