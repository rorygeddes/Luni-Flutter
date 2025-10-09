# Google Sign-In Setup Guide

## ✅ What's Been Integrated

### 1. **AuthService Updates** (`lib/services/auth_service.dart`)
- ✅ Added `signInWithGoogle()` method
- ✅ Added `handleOAuthCallback()` to create profiles for Google users
- ✅ Auto-generates username from email
- ✅ Checks username availability and adds numbers if taken
- ✅ Extracts avatar from Google metadata

### 2. **SignInScreen Updates** (`lib/screens/auth/sign_in_screen.dart`)
- ✅ Added Google Sign-In button with "OR" divider
- ✅ Styled button with Google branding
- ✅ Added `_signInWithGoogle()` method

### 3. **Main App Updates** (`lib/main.dart`)
- ✅ Auth state listener for OAuth redirects
- ✅ Automatic profile creation for Google users
- ✅ Navigation to main app after successful OAuth

### 4. **Android Configuration** (`android/app/src/main/AndroidManifest.xml`)
- ✅ Added OAuth callback activity
- ✅ Deep link scheme: `io.supabase.luni://login-callback`

### 5. **iOS Configuration** (`ios/Runner/Info.plist`)
- ✅ Added CFBundleURLTypes for deep linking
- ✅ URL scheme: `io.supabase.luni`

---

## 🔧 Supabase Dashboard Setup

### Step 1: Enable Google Provider

1. Go to your Supabase Dashboard
2. Click **Authentication** → **Providers**
3. Find **Google** in the list
4. Toggle it **ON**

### Step 2: Create Google OAuth Credentials

#### A. Go to Google Cloud Console
1. Visit https://console.cloud.google.com/
2. Create a new project or select existing one
3. Enable **Google+ API** (or Google Identity API)

#### B. Create OAuth 2.0 Client ID
1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Choose **Web application**
4. Add **Authorized JavaScript origins**:
   ```
   https://YOUR-PROJECT.supabase.co
   ```
5. Add **Authorized redirect URIs**:
   ```
   https://YOUR-PROJECT.supabase.co/auth/v1/callback
   ```
6. Click **CREATE**
7. Copy the **Client ID** and **Client Secret**

#### C. Add Credentials to Supabase
1. Back in Supabase Dashboard → Authentication → Providers → Google
2. Paste **Client ID** (from Google)
3. Paste **Client Secret** (from Google)
4. Click **Save**

### Step 3: Configure Redirect URLs (for mobile)

In Supabase Dashboard → Authentication → URL Configuration:

Add to **Redirect URLs**:
```
io.supabase.luni://login-callback
```

---

## 📱 Testing

### Web (Automatic)
- Just click "Sign in with Google"
- Google popup opens
- After auth, redirects back automatically

### Mobile (Android/iOS)
1. Click "Sign in with Google"
2. Opens browser/Google app
3. User signs in
4. Redirects back to app using `io.supabase.luni://login-callback`

---

## 🔍 How It Works

### Flow Diagram
```
1. User clicks "Sign in with Google"
   ↓
2. AuthService.signInWithGoogle() called
   ↓
3. Supabase opens Google OAuth
   ↓
4. User authenticates with Google
   ↓
5. Google redirects to Supabase callback
   ↓
6. Supabase verifies token
   ↓
7. Supabase redirects to app (io.supabase.luni://login-callback)
   ↓
8. App receives auth state change
   ↓
9. AuthService.handleOAuthCallback() creates profile
   ↓
10. User navigated to MainLayout
```

### Profile Creation
When a user signs in with Google for the first time:
- ✅ Checks if profile exists
- ✅ If not, creates profile with:
  - **Full Name**: From Google metadata
  - **Username**: Generated from email (e.g., `john` from `john@gmail.com`)
  - **Email**: From Google
  - **Avatar URL**: From Google profile picture
  - **Created At**: Current timestamp

---

## 🎨 UI Customization

### Current Design
- "Sign in with Google" button with Google icon
- Outlined style (white background, gray border)
- OR divider between email/password and Google sign-in

### To Use Real Google Branding
Replace the Google icon with an official Google SVG:
```dart
// In sign_in_screen.dart, replace Image.network with:
Image.asset(
  'assets/icons/google_logo.png', // Add Google logo to assets
  width: 24.w,
  height: 24.h,
)
```

---

## 🛡️ Security (Already Configured)

### Database Policies (in `new_supabase_setup.sql`)
```sql
-- Users can only view their own profile
CREATE POLICY "Users can view own profile" ON profiles 
  FOR SELECT USING (auth.uid() = id);

-- Users can only insert their own profile
CREATE POLICY "Users can insert own profile" ON profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);
```

These policies ensure:
- ✅ Each user can only access their own data
- ✅ Google users can't view other users' profiles
- ✅ Automatic enforcement by Supabase

---

## ✅ Testing Checklist

- [ ] Configure Google OAuth in Supabase Dashboard
- [ ] Add Client ID and Client Secret
- [ ] Add redirect URL: `io.supabase.luni://login-callback`
- [ ] Test on web (Chrome)
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Verify profile is created in Supabase
- [ ] Verify avatar URL is saved
- [ ] Verify user can sign out and sign in again

---

## 🐛 Troubleshooting

### Issue: "OAuth error" or "Invalid redirect"
**Solution:** Ensure `io.supabase.luni://login-callback` is added to Supabase → Authentication → URL Configuration → Redirect URLs

### Issue: Google sign-in works but no profile created
**Solution:** Check Supabase logs. The database trigger should auto-create profiles. If not, `handleOAuthCallback()` will create it manually.

### Issue: "Username already taken" for Google users
**Solution:** The code auto-adds numbers to username (e.g., `john`, `john_1`, `john_2`). Check if the logic is running properly.

### Issue: Deep linking not working on mobile
**Solution:** 
- Android: Verify AndroidManifest.xml has the activity
- iOS: Verify Info.plist has CFBundleURLTypes
- Rebuild the app after changes

---

## 📚 Additional Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth Setup](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

---

## 🎉 Summary

You now have:
- ✅ Full Google Sign-In integration
- ✅ Automatic profile creation
- ✅ Avatar extraction from Google
- ✅ Username generation
- ✅ Deep linking for mobile
- ✅ Secure database policies

Just configure the Google OAuth credentials in Supabase and you're ready to test!

