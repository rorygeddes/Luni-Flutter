-- ✅ NEW SQL - Only run what you haven't run yet

-- Make institution_id nullable (fixes your current error)
ALTER TABLE transactions 
ALTER COLUMN institution_id DROP NOT NULL;

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_key TEXT NOT NULL,
  name TEXT NOT NULL,
  icon TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, parent_key, name)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_categories_user 
ON categories(user_id, parent_key);

CREATE INDEX IF NOT EXISTS idx_categories_active 
ON categories(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_transactions_category 
ON transactions(category_id);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies
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

-- Add category_id column to transactions (if not exists)
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS category_id TEXT REFERENCES categories(id);

-- Insert default categories (ON CONFLICT DO NOTHING means no duplicates)
INSERT INTO categories (id, user_id, parent_key, name, icon, is_default, is_active) VALUES
('cat_living_rent', NULL, 'living_essentials', 'Rent', '🏠', TRUE, TRUE),
('cat_living_wifi', NULL, 'living_essentials', 'Wifi', '📡', TRUE, TRUE),
('cat_living_utilities', NULL, 'living_essentials', 'Utilities', '💡', TRUE, TRUE),
('cat_living_phone', NULL, 'living_essentials', 'Phone', '📱', TRUE, TRUE),
('cat_edu_tuition', NULL, 'education', 'Tuition', '🎓', TRUE, TRUE),
('cat_edu_supplies', NULL, 'education', 'Supplies', '✏️', TRUE, TRUE),
('cat_edu_books', NULL, 'education', 'Books', '📖', TRUE, TRUE),
('cat_food_groceries', NULL, 'food', 'Groceries', '🛒', TRUE, TRUE),
('cat_food_coffee', NULL, 'food', 'Coffee & Lunch Out', '☕', TRUE, TRUE),
('cat_food_restaurants', NULL, 'food', 'Restaurants & Dinner', '🍽️', TRUE, TRUE),
('cat_trans_bus', NULL, 'transportation', 'Bus Pass', '🚌', TRUE, TRUE),
('cat_trans_gas', NULL, 'transportation', 'Gas', '⛽', TRUE, TRUE),
('cat_trans_rideshare', NULL, 'transportation', 'Rideshare', '🚗', TRUE, TRUE),
('cat_health_gym', NULL, 'healthcare', 'Gym', '💪', TRUE, TRUE),
('cat_health_medication', NULL, 'healthcare', 'Medication', '💊', TRUE, TRUE),
('cat_health_haircuts', NULL, 'healthcare', 'Haircuts', '✂️', TRUE, TRUE),
('cat_health_toiletries', NULL, 'healthcare', 'Toiletries', '🧴', TRUE, TRUE),
('cat_ent_events', NULL, 'entertainment', 'Events', '🎫', TRUE, TRUE),
('cat_ent_nightout', NULL, 'entertainment', 'Night Out', '🌃', TRUE, TRUE),
('cat_ent_shopping', NULL, 'entertainment', 'Shopping', '🛍️', TRUE, TRUE),
('cat_ent_substances', NULL, 'entertainment', 'Substances', '🍺', TRUE, TRUE),
('cat_ent_subscriptions', NULL, 'entertainment', 'Subscriptions', '📺', TRUE, TRUE),
('cat_vac_general', NULL, 'vacation', 'General Travel', '✈️', TRUE, TRUE),
('cat_income_job', NULL, 'income', 'Job Income', '💼', TRUE, TRUE),
('cat_income_family', NULL, 'income', 'Family Support', '👨‍👩‍👧', TRUE, TRUE),
('cat_income_savings', NULL, 'income', 'Savings/Investment Gain', '📈', TRUE, TRUE),
('cat_income_bonus', NULL, 'income', 'Bonus', '🎁', TRUE, TRUE)
ON CONFLICT (user_id, parent_key, name) DO NOTHING;

-- Verify setup
SELECT 
  parent_key,
  COUNT(*) as subcategory_count
FROM categories
WHERE user_id IS NULL
GROUP BY parent_key
ORDER BY parent_key;

SELECT COUNT(*) as total_default_categories FROM categories WHERE user_id IS NULL;

