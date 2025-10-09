-- ============================================
-- FIX PROFILES TABLE RLS FOR PUBLIC PROFILES
-- ============================================
-- Public fields: id, username, full_name, avatar_url, etransfer_id
-- Private fields: email, created_at, etc. (only viewable by owner)

-- Step 1: Add etransfer_id column if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS etransfer_id TEXT;

-- Step 2: Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Step 3: Create new public profile policy
-- Users can view ALL profiles, but the application will only SELECT public fields
CREATE POLICY "Anyone can view public profiles" 
ON profiles FOR SELECT 
USING (true);  -- Everyone can see all profiles

-- Step 4: Users can only update their own profile
CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

-- Step 5: Users can only insert their own profile
CREATE POLICY "Users can insert own profile" 
ON profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Step 6: Verify the policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;

-- Step 7: Test the PUBLIC profile query (what other users see)
SELECT 
    id,
    username,
    full_name,
    avatar_url,
    etransfer_id
FROM profiles
WHERE id != '7ade6005-a7fb-4808-935e-29702075068a'  -- Not yourself
ORDER BY full_name;

-- Step 8: Test the PRIVATE profile query (what you see about yourself)
SELECT 
    id,
    username,
    full_name,
    avatar_url,
    etransfer_id,
    email,
    created_at
FROM profiles
WHERE id = '7ade6005-a7fb-4808-935e-29702075068a'  -- Your own profile
ORDER BY full_name;

