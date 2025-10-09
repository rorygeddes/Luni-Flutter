-- ============================================
-- WHO AM I? - Find Your Current User
-- ============================================

-- This shows which user is currently signed in
-- Based on your terminal output: 7ade6005-a7fb-4808-935e-29702075068a

SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE id = '7ade6005-a7fb-4808-935e-29702075068a';

-- This shows ALL OTHER users (who you CAN search for)
SELECT 
  id,
  email,
  username,
  full_name
FROM profiles
WHERE id != '7ade6005-a7fb-4808-935e-29702075068a';

-- ============================================
-- RESULT INTERPRETATION:
-- ============================================
-- 
-- First query = YOU (the signed-in user)
-- Second query = OTHER USERS (who you can search for)
-- 
-- You CANNOT search for yourself!
-- You can only search for OTHER users.
-- 
-- ============================================

