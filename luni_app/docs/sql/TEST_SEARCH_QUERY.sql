-- ============================================
-- TEST SEARCH QUERY - DEBUG
-- ============================================

-- 1. Check what the app is searching for
-- This simulates the exact query the app runs

-- First, get the current user ID (replace with your actual user ID)
-- You can find this by running: SELECT id FROM auth.users WHERE email = 'rorygeddes16@gmail.com';

-- 2. Test search for "bobwings16"
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE username ILIKE '%bobwings16%' OR full_name ILIKE '%bobwings16%'
ORDER BY username
LIMIT 20;

-- 3. Test search for "bob"
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE username ILIKE '%bob%' OR full_name ILIKE '%bob%'
ORDER BY username
LIMIT 20;

-- 4. Test search with current user exclusion
-- Replace 'YOUR_USER_ID_HERE' with your actual user ID
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE (username ILIKE '%bob%' OR full_name ILIKE '%bob%')
  AND id != 'YOUR_USER_ID_HERE'
ORDER BY username
LIMIT 20;

-- 5. Get all users to see what's available
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
ORDER BY username;

-- ============================================
-- INSTRUCTIONS:
-- ============================================
-- 
-- 1. Run query #2 - should find "bobwings16"
-- 2. If it returns results, the database is fine
-- 3. If no results, check if username is correct
-- 4. Run query #5 to see all usernames
-- 
-- If query #2 works but app doesn't, there's a
-- problem with the app's search implementation.
-- 
-- ============================================

