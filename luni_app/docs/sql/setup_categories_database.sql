-- ✅ STEP 1: Fix transactions table (from previous issues)
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_categorized BOOLEAN DEFAULT FALSE;

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_split BOOLEAN DEFAULT FALSE;

ALTER TABLE transactions 
ALTER COLUMN institution_id DROP NOT NULL;

-- ✅ STEP 2: Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_key TEXT NOT NULL, -- e.g., 'living_essentials', 'food', 'entertainment'
  name TEXT NOT NULL, -- e.g., 'Rent', 'Groceries', 'Movies'
  icon TEXT, -- emoji or icon name
  is_default BOOLEAN DEFAULT FALSE, -- true for system defaults
  is_active BOOLEAN DEFAULT TRUE, -- user can deselect categories
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, parent_key, name) -- Prevent duplicate categories per user
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_categories_user 
ON categories(user_id, parent_key);

CREATE INDEX IF NOT EXISTS idx_categories_active 
ON categories(user_id, is_active);

-- ✅ STEP 3: Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for categories
CREATE POLICY "Users can view their own categories"
  ON categories FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own categories"
  ON categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own categories"
  ON categories FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own categories"
  ON categories FOR DELETE
  USING (auth.uid() = user_id);

-- ✅ STEP 4: Insert default categories (from workflow.md)
-- These are NULL user_id so they're available to all users

-- Living Essentials
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_living_rent', NULL, 'living_essentials', 'Rent', '🏠', TRUE, TRUE),
('cat_living_wifi', NULL, 'living_essentials', 'Wifi', '📡', TRUE, TRUE),
('cat_living_utilities', NULL, 'living_essentials', 'Utilities', '💡', TRUE, TRUE),
('cat_living_phone', NULL, 'living_essentials', 'Phone', '📱', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Education
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_edu_tuition', NULL, 'education', 'Tuition', '🎓', TRUE, TRUE),
('cat_edu_supplies', NULL, 'education', 'Supplies', '✏️', TRUE, TRUE),
('cat_edu_books', NULL, 'education', 'Books', '📖', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Food
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_food_groceries', NULL, 'food', 'Groceries', '🛒', TRUE, TRUE),
('cat_food_coffee', NULL, 'food', 'Coffee & Lunch Out', '☕', TRUE, TRUE),
('cat_food_restaurants', NULL, 'food', 'Restaurants & Dinner', '🍽️', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Transportation
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_trans_bus', NULL, 'transportation', 'Bus Pass', '🚌', TRUE, TRUE),
('cat_trans_gas', NULL, 'transportation', 'Gas', '⛽', TRUE, TRUE),
('cat_trans_rideshare', NULL, 'transportation', 'Rideshare', '🚗', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Healthcare
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_health_gym', NULL, 'healthcare', 'Gym', '💪', TRUE, TRUE),
('cat_health_medication', NULL, 'healthcare', 'Medication', '💊', TRUE, TRUE),
('cat_health_haircuts', NULL, 'healthcare', 'Haircuts', '✂️', TRUE, TRUE),
('cat_health_toiletries', NULL, 'healthcare', 'Toiletries', '🧴', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Entertainment (Accounts to watch)
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_ent_events', NULL, 'entertainment', 'Events', '🎫', TRUE, TRUE),
('cat_ent_nightout', NULL, 'entertainment', 'Night Out', '🌃', TRUE, TRUE),
('cat_ent_shopping', NULL, 'entertainment', 'Shopping', '🛍️', TRUE, TRUE),
('cat_ent_substances', NULL, 'entertainment', 'Substances', '🍺', TRUE, TRUE),
('cat_ent_subscriptions', NULL, 'entertainment', 'Subscriptions', '📺', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Vacation (Custom trips can be added by user)
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_vac_general', NULL, 'vacation', 'General Travel', '✈️', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Income
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_income_job', NULL, 'income', 'Job Income', '💼', TRUE, TRUE),
('cat_income_family', NULL, 'income', 'Family Support', '👨‍👩‍👧', TRUE, TRUE),
('cat_income_savings', NULL, 'income', 'Savings/Investment Gain', '📈', TRUE, TRUE),
('cat_income_bonus', NULL, 'income', 'Bonus', '🎁', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- ✅ STEP 5: Update transactions table to reference categories
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS category_id TEXT REFERENCES categories(id);

CREATE INDEX IF NOT EXISTS idx_transactions_category 
ON transactions(category_id);

-- ✅ STEP 6: Verify setup
SELECT 
  parent_key,
  COUNT(*) as subcategory_count
FROM categories
WHERE user_id IS NULL
GROUP BY parent_key
ORDER BY parent_key;

SELECT COUNT(*) as total_default_categories FROM categories WHERE user_id IS NULL;

