# Mobile OAuth Fix - Safari Connection Error

## 🐛 Issue: "Safari can't open the page because it couldn't connect to the server"

This error occurs on iPhone/Android when trying to sign in with Google because the OAuth redirect isn't configured correctly for mobile.

## ✅ Solution Applied

### Code Changes Made:

1. **Updated `lib/services/auth_service.dart`:**
   - Added `kIsWeb` check for platform-specific redirect handling
   - Changed `authScreenLaunchMode` to `LaunchMode.externalApplication`
   - Web uses `null` for redirect (automatic handling)
   - Mobile uses custom scheme: `io.supabase.luni://login-callback`

```dart
await _supabase.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: kIsWeb ? null : 'io.supabase.luni://login-callback',
  authScreenLaunchMode: LaunchMode.externalApplication,
);
```

## 🔧 Additional Supabase Configuration Needed

### Step 1: Add Redirect URL in Supabase Dashboard

1. Go to **Supabase Dashboard** → **Authentication** → **URL Configuration**
2. Under **Redirect URLs**, add:
   ```
   io.supabase.luni://login-callback
   ```
3. Click **Save**

### Step 2: Configure Site URL (Important!)

In the same **URL Configuration** section:

1. Set **Site URL** to your production domain or use a placeholder:
   ```
   https://luni.app
   ```
   (Or use your actual domain when ready)

2. This is required for mobile OAuth to work properly

### Step 3: Verify Mobile Configuration

**iOS** (already done in `ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.luni</string>
    </array>
  </dict>
</array>
```

**Android** (already done in `android/app/src/main/AndroidManifest.xml`):
```xml
<activity 
    android:name="com.supabase.gotrue.GoTrueAuthActivity"
    android:exported="true"
    android:launchMode="singleTask">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="io.supabase.luni" android:host="login-callback"/>
    </intent-filter>
</activity>
```

## 🔄 Alternative Solution: Universal Links (Recommended for Production)

If the custom URL scheme still doesn't work, use **Universal Links** (iOS) / **App Links** (Android):

### iOS Universal Links Setup:

1. **In Supabase:**
   - Redirect URL: `https://yourdomain.com/auth/callback`

2. **In Xcode:**
   - Enable Associated Domains
   - Add: `applinks:yourdomain.com`

3. **Host apple-app-site-association file** on your domain

### Android App Links Setup:

1. **In Supabase:**
   - Redirect URL: `https://yourdomain.com/auth/callback`

2. **In AndroidManifest.xml:**
   ```xml
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW"/>
       <category android:name="android.intent.category.DEFAULT"/>
       <category android:name="android.intent.category.BROWSABLE"/>
       <data android:scheme="https" 
             android:host="yourdomain.com" 
             android:pathPrefix="/auth/callback"/>
   </intent-filter>
   ```

3. **Host assetlinks.json** on your domain

## 🧪 Testing Steps

### After applying the fix:

1. **Rebuild the app completely:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **On iPhone:**
   - Click "Sign in with Google"
   - Should open Safari/Chrome
   - Sign in with Google
   - Should redirect back to app

3. **Check console logs:**
   - Should see: "User signed in: [email]"
   - Should see: "Profile created successfully"

## 🐛 Still Having Issues?

### Debug Checklist:

- [ ] Supabase Google OAuth is enabled
- [ ] Client ID and Secret are configured
- [ ] Redirect URL `io.supabase.luni://login-callback` is added in Supabase
- [ ] Site URL is configured in Supabase
- [ ] App was rebuilt after changes (`flutter clean`)
- [ ] iOS/Android deep linking is properly configured
- [ ] Check Supabase logs for OAuth errors

### Common Issues:

1. **"Invalid redirect URI"**
   - Solution: Double-check `io.supabase.luni://login-callback` is in Supabase → Authentication → URL Configuration

2. **OAuth popup closes immediately**
   - Solution: Check Google Cloud Console → Authorized redirect URIs includes your Supabase URL

3. **App doesn't open after OAuth**
   - Solution: Verify iOS/Android deep link configuration
   - Try rebuilding the app

4. **"Site URL not configured"**
   - Solution: Set Site URL in Supabase → Authentication → URL Configuration

## 📱 For Development Testing

If you want to test quickly without setting up all the OAuth infrastructure:

1. **Use Web version (Chrome)** - works immediately
2. **Use Email/Password sign-in** - already working
3. **Configure Google OAuth properly** for production mobile use

## 🎯 Next Steps

1. Add the redirect URL in Supabase Dashboard
2. Set the Site URL in Supabase
3. Rebuild the app: `flutter clean && flutter run`
4. Test Google Sign-In on iPhone
5. Check logs for any errors

The app should now properly redirect back from Safari/Chrome to your app after Google authentication! 🚀

