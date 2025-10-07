# Supabase Email Confirmation Setup

## Issue
After sign-up, users cannot sign in immediately because Supabase requires email confirmation by default.

## Solution: Disable Email Confirmation for Development

Follow these steps in your Supabase Dashboard:

### Step 1: Navigate to Authentication Settings
1. Go to your Supabase Dashboard
2. Select your project
3. Click on **Authentication** in the left sidebar
4. Click on **Settings** (under Authentication)

### Step 2: Disable Email Confirmation
1. Scroll down to **Email Auth**
2. Find the setting **Enable email confirmations**
3. **Toggle it OFF** (disable it)
4. Click **Save** at the bottom

### Step 3: Enable Auto-Confirm for Existing Users (Optional)
If you have users who already signed up but can't log in:

1. Go to **Authentication** → **Users**
2. For each user, click the three dots menu (⋮)
3. Select **Confirm Email**
4. The user can now sign in

## For Production

**Important:** For production, you should:
1. **Enable email confirmation** for security
2. Set up email templates in Supabase
3. Configure your email provider (SMTP or Supabase's built-in service)
4. Add proper email verification flow in your app

## Alternative: Manual User Confirmation

If you want to keep email confirmation enabled, you can manually confirm users:

### Via SQL Editor:
```sql
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email = 'user@example.com';
```

### Via Supabase Dashboard:
1. Go to Authentication → Users
2. Click on the user
3. Click "Confirm Email"

## Current App Behavior

The app now:
- ✅ Creates user account during sign-up
- ✅ Waits for database trigger to create profile
- ✅ Saves user session locally
- ✅ Navigates to main app
- ✅ Loads real user data in profile view

## Testing

After disabling email confirmation:
1. Try signing up with a new email
2. You should be immediately signed in
3. Profile data should be visible in the Profile view
4. No "Invalid login credentials" error should appear

