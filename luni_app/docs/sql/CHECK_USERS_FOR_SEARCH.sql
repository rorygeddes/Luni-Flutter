-- ============================================
-- CHECK USERS AVAILABLE FOR SEARCH
-- Run this to see what users can be searched
-- ============================================

-- 1. See all users in the profiles table
SELECT 
  id,
  email,
  username,
  full_name,
  created_at
FROM profiles
ORDER BY created_at DESC;

-- 2. Count total users
SELECT COUNT(*) as total_users FROM profiles;

-- 3. Check for users with username set
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE username IS NOT NULL
ORDER BY username;

-- 4. Check for users without username
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE username IS NULL;

-- 5. Test search query (replace 'rory' with actual username)
-- This is what the app does when you search
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE username ILIKE '%rory%' OR full_name ILIKE '%rory%'
ORDER BY username
LIMIT 20;

-- ============================================
-- INSTRUCTIONS:
-- ============================================
-- 
-- 1. Run query #1 to see ALL users
-- 2. Look at the 'username' column
-- 3. Try searching for one of those usernames in the app
-- 4. If username is NULL, that's the problem!
-- 
-- To fix NULL usernames, run this:
-- UPDATE profiles SET username = LOWER(SPLIT_PART(email, '@', 1)) WHERE username IS NULL;
-- 
-- ============================================

