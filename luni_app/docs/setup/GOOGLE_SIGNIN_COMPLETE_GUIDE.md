# 🔐 Complete Google Sign-In Setup Guide

## 📋 Table of Contents
1. [Quick Fix for localhost Issue](#quick-fix)
2. [Full Supabase Configuration](#supabase-config)
3. [Google Cloud Console Setup](#google-cloud)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

---

## ⚡ Quick Fix for localhost:3000 Issue {#quick-fix}

### The Problem
Your OAuth redirects to `localhost:3000/?code=...` which doesn't exist on mobile.

### The Solution (5 minutes)

**In Supabase Dashboard:**

1. Go to **Authentication** → **URL Configuration**

2. Set **Redirect URLs** to (one per line):
   ```
   io.supabase.luni://login-callback
   http://localhost:3000
   https://luni.ca
   ```

3. Set **Site URL** to:
   ```
   io.supabase.luni://login-callback
   ```

4. Click **Save**

5. Rebuild app:
   ```bash
   flutter clean && flutter run
   ```

6. Test on iPhone - it should now work! ✅

---

## 🔧 Full Supabase Configuration {#supabase-config}

### 1. Enable Google Provider

1. **Supabase Dashboard** → **Authentication** → **Providers**
2. Find **Google** and toggle it **ON**

### 2. Configure Redirect URLs

**Authentication** → **URL Configuration** → **Redirect URLs**

Add these URLs (one per line):

```
io.supabase.luni://login-callback          # Mobile deep link
http://localhost:3000                       # Local web development
http://localhost:3000/auth/callback        # Alternative web
https://luni.ca                            # Production web
https://luni.ca/auth/callback              # Production web alternative
```

### 3. Configure Site URL

Set **Site URL** to one of:
- `io.supabase.luni://login-callback` (for mobile-first)
- `https://luni.ca` (for production web)

### 4. Additional Site URLs (Optional)

Add to **Additional Site URLs** for multi-platform support:
```
io.supabase.luni://login-callback
http://localhost:3000
https://luni.ca
```

---

## 🔑 Google Cloud Console Setup {#google-cloud}

### Step 1: Create Google Cloud Project

1. Go to https://console.cloud.google.com/
2. Create new project or select existing one
3. Name it "Luni App" or similar

### Step 2: Enable Google+ API

1. Go to **APIs & Services** → **Library**
2. Search for "Google+ API" or "Google Identity"
3. Click **Enable**

### Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Choose **Web application**
4. Set **Name**: "Luni Web Client"

### Step 4: Configure Authorized Origins

Add **Authorized JavaScript origins**:
```
https://YOUR-PROJECT.supabase.co
http://localhost:3000
```

Replace `YOUR-PROJECT` with your actual Supabase project ID.

### Step 5: Configure Redirect URIs

Add **Authorized redirect URIs**:
```
https://YOUR-PROJECT.supabase.co/auth/v1/callback
http://localhost:3000
http://localhost:3000/auth/callback
```

### Step 6: Get Credentials

1. Click **CREATE**
2. Copy **Client ID**
3. Copy **Client Secret**

### Step 7: Add to Supabase

1. Back in **Supabase** → **Authentication** → **Providers** → **Google**
2. Paste **Client ID**
3. Paste **Client Secret**
4. Click **Save**

---

## 🧪 Testing {#testing}

### Web (Chrome)
1. Run: `flutter run -d chrome`
2. Click "Sign in with Google"
3. Google popup appears
4. Sign in
5. Redirects automatically
6. ✅ Should be logged in

### Mobile (iPhone)
1. Run: `flutter run` (selects iPhone)
2. Click "Sign in with Google"
3. Safari/Chrome opens
4. Sign in with Google
5. App should open automatically
6. ✅ Should be logged in

### Expected Console Output
```
Google OAuth redirect URL: io.supabase.luni://login-callback
User signed in: your-email@gmail.com
Profile created successfully: your_username
```

---

## 🐛 Troubleshooting {#troubleshooting}

### Issue 1: "Safari can't connect to server"
**Cause:** Wrong redirect URL in Supabase  
**Fix:** Add `io.supabase.luni://login-callback` to Redirect URLs

### Issue 2: Redirects to localhost:3000
**Cause:** Site URL set to localhost  
**Fix:** Change Site URL to `io.supabase.luni://login-callback`

### Issue 3: "Invalid redirect URI"
**Cause:** Redirect URL mismatch  
**Fix:** Ensure exact match in:
- Supabase Redirect URLs
- Google Cloud Console Authorized redirect URIs
- Your code

### Issue 4: App doesn't open after OAuth
**Cause:** Deep linking not configured  
**Fix:** Check:
- iOS `Info.plist` has `CFBundleURLSchemes` ✅ (already done)
- Android `AndroidManifest.xml` has OAuth activity ✅ (already done)
- Rebuild app after changes

### Issue 5: "No profile created"
**Cause:** Database trigger or manual creation failed  
**Fix:** Check Supabase logs, verify RLS policies allow INSERT

### Issue 6: OAuth works but shows error immediately
**Cause:** Auth state listener firing too early  
**Fix:** Already handled in `main.dart` with proper state management

---

## 📱 Platform-Specific Notes

### iOS
- Deep link scheme: `io.supabase.luni`
- Configured in: `ios/Runner/Info.plist` ✅
- Uses Safari/Chrome for OAuth
- Automatically returns to app via deep link

### Android
- Deep link scheme: `io.supabase.luni://login-callback`
- Configured in: `android/app/src/main/AndroidManifest.xml` ✅
- Uses Chrome/default browser for OAuth
- Automatically returns to app via deep link

### Web
- No deep linking needed
- Supabase handles redirect automatically
- Works on localhost:3000 and production

---

## ✅ Final Checklist

### Supabase
- [ ] Google provider enabled
- [ ] Client ID and Secret configured
- [ ] Redirect URLs include `io.supabase.luni://login-callback`
- [ ] Site URL is set
- [ ] Changes saved

### Google Cloud Console
- [ ] OAuth credentials created
- [ ] Authorized origins include Supabase URL
- [ ] Redirect URIs include Supabase callback URL

### App Configuration
- [ ] iOS `Info.plist` has deep link ✅ (done)
- [ ] Android `AndroidManifest.xml` has OAuth activity ✅ (done)
- [ ] `auth_service.dart` uses platform-specific redirects ✅ (done)
- [ ] `main.dart` listens for auth state changes ✅ (done)

### Testing
- [ ] App rebuilt after changes
- [ ] Google Sign-In tested on web
- [ ] Google Sign-In tested on iPhone
- [ ] Profile created successfully
- [ ] No console errors

---

## 🎉 You're Done!

Once all checkboxes are ticked, Google Sign-In should work perfectly on:
- ✅ Web (Chrome)
- ✅ iPhone (Safari/Chrome)
- ✅ Android (Chrome/default browser)

Users can now sign in with one click using their Google account! 🚀

---

## 📚 Quick Reference

**Key URLs:**
- Supabase Dashboard: https://supabase.com/dashboard
- Google Cloud Console: https://console.cloud.google.com/
- Deep Link Scheme: `io.supabase.luni://login-callback`

**Key Files:**
- Auth Service: `lib/services/auth_service.dart`
- Sign-In Screen: `lib/screens/auth/sign_in_screen.dart`
- Main App: `lib/main.dart`
- iOS Config: `ios/Runner/Info.plist`
- Android Config: `android/app/src/main/AndroidManifest.xml`

**Helpful Docs:**
- `QUICK_OAUTH_SETUP.md` - 5-minute quick fix
- `OAUTH_LOCALHOST_FIX.md` - Detailed localhost issue fix
- `MOBILE_OAUTH_FIX.md` - Mobile-specific solutions
- `GOOGLE_SIGNIN_SETUP.md` - Original setup guide

