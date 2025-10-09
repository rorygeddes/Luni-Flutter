-- ============================================
-- CHECK USER ID MISMATCH
-- ============================================

-- The app shows user ID: 7ade6005-a7fb-4808-935e-29702075068a
-- You say you're signed in as: rorygeddes16
-- Let's verify which is which

-- 1. Check who user ID 7ade6005-a7fb-4808-935e-29702075068a belongs to
SELECT 
  id,
  email,
  username,
  full_name,
  'This is the user the app thinks you are' as note
FROM profiles
WHERE id = '7ade6005-a7fb-4808-935e-29702075068a';

-- 2. Check who rorygeddes16 is
SELECT 
  id,
  email,
  username,
  full_name,
  'This is who you say you are' as note
FROM profiles
WHERE username = 'rorygeddes16';

-- 3. Show all users
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
ORDER BY username;

-- ============================================
-- EXPECTED RESULTS:
-- ============================================
-- 
-- Query #1 should show which account you're actually signed into
-- Query #2 should show rorygeddes16's details
-- 
-- If they're different, you might be signed into the wrong account!
-- 
-- ============================================

