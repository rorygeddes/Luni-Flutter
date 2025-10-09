-- ============================================
-- ADD DEFAULT CATEGORIES - SIMPLE VERSION
-- ============================================
-- This version uses a simpler approach without complex constraints

-- ============================================
-- PARENT CATEGORIES + SUBCATEGORIES
-- ============================================

-- Living
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'living', 'Living', '🏠', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'living' AND name = 'Living' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'living', 'Rent', '🏘️', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'living' AND name = 'Rent' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'living', 'Wifi', '📶', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'living' AND name = 'Wifi' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'living', 'Utilities', '💡', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'living' AND name = 'Utilities' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'living', 'Phone', '📱', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'living' AND name = 'Phone' AND user_id IS NULL);

-- Education
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'education', 'Education', '📚', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'education' AND name = 'Education' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'education', 'Tuition', '🎓', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'education' AND name = 'Tuition' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'education', 'Supplies', '✏️', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'education' AND name = 'Supplies' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'education', 'Books', '📖', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'education' AND name = 'Books' AND user_id IS NULL);

-- Food
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'food', 'Food', '🍔', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'food' AND name = 'Food' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'food', 'Groceries', '🛒', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'food' AND name = 'Groceries' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'food', 'Coffee', '☕', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'food' AND name = 'Coffee' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'food', 'Restaurants', '🍽️', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'food' AND name = 'Restaurants' AND user_id IS NULL);

-- Transportation
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'transportation', 'Transportation', '🚗', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'transportation' AND name = 'Transportation' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'transportation', 'Bus Pass', '🚌', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'transportation' AND name = 'Bus Pass' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'transportation', 'Gas', '⛽', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'transportation' AND name = 'Gas' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'transportation', 'Rideshare', '🚕', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'transportation' AND name = 'Rideshare' AND user_id IS NULL);

-- Healthcare
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'healthcare', 'Healthcare', '💊', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'healthcare' AND name = 'Healthcare' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'healthcare', 'Gym', '🏋️', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'healthcare' AND name = 'Gym' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'healthcare', 'Medication', '💊', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'healthcare' AND name = 'Medication' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'healthcare', 'Haircuts', '💇', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'healthcare' AND name = 'Haircuts' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'healthcare', 'Toiletries', '🧴', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'healthcare' AND name = 'Toiletries' AND user_id IS NULL);

-- Entertainment
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'entertainment', 'Entertainment', '🎬', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'entertainment' AND name = 'Entertainment' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'entertainment', 'Events', '🎫', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'entertainment' AND name = 'Events' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'entertainment', 'Night Out', '🌃', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'entertainment' AND name = 'Night Out' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'entertainment', 'Shopping', '🛍️', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'entertainment' AND name = 'Shopping' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'entertainment', 'Subscriptions', '📺', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'entertainment' AND name = 'Subscriptions' AND user_id IS NULL);

-- Income
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'income', 'Income', '💰', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'income' AND name = 'Income' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'income', 'Job Income', '💼', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'income' AND name = 'Job Income' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'income', 'Family Support', '👨‍👩‍👧', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'income' AND name = 'Family Support' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'income', 'Investments', '📈', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'income' AND name = 'Investments' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'income', 'Bonus', '🎁', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'income' AND name = 'Bonus' AND user_id IS NULL);

-- Other
INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'other', 'Other', '📦', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'other' AND name = 'Other' AND user_id IS NULL);

INSERT INTO categories (user_id, parent_key, name, icon, is_default, is_active, created_at)
SELECT NULL, 'other', 'Miscellaneous', '🔧', true, true, NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE parent_key = 'other' AND name = 'Miscellaneous' AND user_id IS NULL);

-- ============================================
-- VERIFY THE CATEGORIES
-- ============================================

-- View all categories
SELECT 
    CASE 
        WHEN parent_key = LOWER(REPLACE(name, ' ', '')) THEN '🔹 PARENT'
        ELSE '  ↳ subcategory'
    END as type,
    parent_key,
    name,
    icon
FROM categories 
WHERE user_id IS NULL
ORDER BY parent_key, 
         CASE WHEN parent_key = LOWER(REPLACE(name, ' ', '')) THEN 0 ELSE 1 END,
         name;

