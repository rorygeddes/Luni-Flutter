# ⚡ Quick OAuth Setup - Fix localhost:3000 Issue

## 🚨 Problem
Your OAuth is redirecting to `localhost:3000/?code=...` which doesn't work on mobile.

## ✅ 5-Minute Fix

### Step 1: Supabase Dashboard (2 minutes)

1. Go to https://supabase.com/dashboard
2. Open your **Luni project**
3. Click **Authentication** (left sidebar)
4. Click **URL Configuration**

### Step 2: Update Redirect URLs (1 minute)

In the **Redirect URLs** field, paste this (replace existing content):

```
io.supabase.luni://login-callback
http://localhost:3000
https://luni.ca
```

Each URL should be on a new line.

### Step 3: Update Site URL (30 seconds)

Set **Site URL** to:
```
io.supabase.luni://login-callback
```

### Step 4: Save (10 seconds)

Click **Save** at the bottom.

### Step 5: Rebuild App (1 minute)

```bash
cd "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app"
flutter clean
flutter run
```

### Step 6: Test (30 seconds)

1. Open app on iPhone
2. Click "Sign in with Google"
3. Sign in
4. Should now open your app (not localhost)

---

## ✅ Success Checklist

After completing the steps above:

- [ ] Supabase Redirect URLs includes `io.supabase.luni://login-callback`
- [ ] Site URL is set to `io.supabase.luni://login-callback`
- [ ] App rebuilt with `flutter clean && flutter run`
- [ ] Google Sign-In opens Safari/Chrome
- [ ] After signing in, app opens automatically
- [ ] Console shows: "User signed in: [email]"

---

## 🐛 Still Not Working?

### Check These:

1. **Wait 1-2 minutes** after saving Supabase settings
2. **Completely close and reopen** the app on iPhone
3. **Check console logs** for errors
4. **Verify deep link** is configured:
   - iOS: `ios/Runner/Info.plist` has `CFBundleURLSchemes`
   - Android: `android/app/src/main/AndroidManifest.xml` has the activity

### Common Issues:

**"Invalid redirect URI"**
- Solution: Double-check the URL in Supabase exactly matches: `io.supabase.luni://login-callback`

**Still redirects to localhost**
- Solution: Clear browser cache on iPhone, or use Private/Incognito mode

**App doesn't open after sign-in**
- Solution: Rebuild app after making changes: `flutter clean && flutter run`

---

## 📝 What Changed

**Before:**
- Supabase redirected to `localhost:3000` (doesn't work on phone)

**After:**
- Supabase redirects to `io.supabase.luni://login-callback` (opens your app)

---

## 🎯 Summary

The fix is simple:
1. Update Supabase Redirect URLs to include `io.supabase.luni://login-callback`
2. Set Site URL to `io.supabase.luni://login-callback`
3. Rebuild app
4. Test!

That's it! Google Sign-In should now work on your iPhone. 🚀

