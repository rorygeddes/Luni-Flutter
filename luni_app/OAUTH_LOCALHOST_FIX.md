# OAuth Localhost Redirect Fix

## 🐛 Issue: OAuth redirects to `localhost:3000` instead of the app

When you sign in with Google on mobile, you see:
```
localhost:3000/?code=d7eab97b-e054-451d-804f-e38aded1293e
```

This happens because Supabase has `localhost:3000` configured as a redirect URL instead of your mobile deep link.

## ✅ Solution: Configure Supabase Redirect URLs Correctly

### Step 1: Go to Supabase Dashboard

1. Open **Supabase Dashboard** at https://supabase.com/dashboard
2. Select your **Luni project**
3. Go to **Authentication** → **URL Configuration**

### Step 2: Configure Redirect URLs

In the **Redirect URLs** section, you need to add:

#### For Mobile (iPhone/Android):
```
io.supabase.luni://login-callback
```

#### For Local Development (Web):
```
http://localhost:3000/auth/callback
http://localhost:3000
```

#### For Production (when ready):
```
https://luni.ca/auth/callback
https://luni.ca
```

**Important:** Have ALL of these in the list. Each one on a new line.

### Step 3: Configure Site URL

In the same **URL Configuration** section:

Set **Site URL** to:
```
io.supabase.luni://login-callback
```

Or if you prefer, use your production URL:
```
https://luni.ca
```

### Step 4: Save Changes

Click **Save** at the bottom of the page.

---

## 🔧 Alternative: Update App to Handle Web Redirect

If you want to keep using `localhost:3000` for development, you need to update the app to handle both web and mobile redirects:

### Option A: Use Platform-Specific Redirects (Recommended)

Update `lib/services/auth_service.dart`:

```dart
// Sign in with Google OAuth
static Future<void> signInWithGoogle() async {
  try {
    final redirectUrl = kIsWeb 
      ? 'http://localhost:3000/auth/callback'  // Web
      : 'io.supabase.luni://login-callback';   // Mobile
    
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  } catch (e) {
    print('Google sign-in error: $e');
    rethrow;
  }
}
```

### Option B: Remove localhost and use only deep links

This is the cleanest approach for mobile:

1. In Supabase, **remove** `localhost:3000` from Redirect URLs
2. **Add only**: `io.supabase.luni://login-callback`
3. Set Site URL to: `io.supabase.luni://login-callback`

Then update the code to always use the deep link:

```dart
// Sign in with Google OAuth
static Future<void> signInWithGoogle() async {
  try {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.luni://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  } catch (e) {
    print('Google sign-in error: $e');
    rethrow;
  }
}
```

---

## 🧪 Testing After Fix

1. **Make the changes in Supabase Dashboard**
2. **Wait 1-2 minutes** for Supabase to propagate changes
3. **Rebuild your app**: 
   ```bash
   flutter clean
   flutter run
   ```
4. **Test on iPhone**:
   - Click "Sign in with Google"
   - Sign in with Google account
   - Should redirect to your app (not localhost)
   - Console should show: "User signed in: [email]"

---

## 📱 Expected Behavior

### Current (Wrong):
```
User clicks Google Sign-In
  ↓
Opens Safari/Chrome
  ↓
Signs in with Google
  ↓
Redirects to: localhost:3000/?code=...  ❌ (doesn't exist on phone)
  ↓
Error: Can't connect to server
```

### After Fix:
```
User clicks Google Sign-In
  ↓
Opens Safari/Chrome
  ↓
Signs in with Google
  ↓
Redirects to: io.supabase.luni://login-callback?code=...  ✅
  ↓
Opens your app
  ↓
App creates profile and logs in
```

---

## 🔍 Verify Configuration

After making changes, check:

1. **Supabase Dashboard** → **Authentication** → **URL Configuration**
   - Redirect URLs includes: `io.supabase.luni://login-callback`
   - Site URL is set (can be deep link or domain)

2. **Google Cloud Console** → **OAuth Credentials**
   - Authorized redirect URIs includes: `https://YOUR-PROJECT.supabase.co/auth/v1/callback`

3. **Your App**
   - iOS `Info.plist` has `CFBundleURLSchemes` with `io.supabase.luni`
   - Android `AndroidManifest.xml` has the deep link activity

---

## 🚀 Quick Fix Summary

**Immediate fix (5 minutes):**
1. Go to Supabase → Authentication → URL Configuration
2. Add `io.supabase.luni://login-callback` to Redirect URLs
3. Set Site URL to `io.supabase.luni://login-callback`
4. Save and wait 1-2 minutes
5. Rebuild app: `flutter clean && flutter run`
6. Test Google Sign-In on iPhone

---

## 💡 For Production (luni.ca)

When you're ready to deploy to luni.ca:

1. **Set up domain** and SSL certificate
2. **In Supabase**:
   - Add to Redirect URLs: `https://luni.ca/auth/callback`
   - Update Site URL to: `https://luni.ca`
3. **Update app** to use production redirect
4. **Keep mobile deep link** for app: `io.supabase.luni://login-callback`

You can have multiple redirect URLs for different platforms! 🎉

