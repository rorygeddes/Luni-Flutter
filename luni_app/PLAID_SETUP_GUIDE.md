# Plaid Integration Setup Guide

## 🚨 Current Issues Fixed

Based on the `plaid_fixes.md` analysis, we've fixed the following issues:

1. ✅ **Mock user token** - Now using real user ID from Supabase auth
2. ✅ **Redirect URI** - Added `lunifin://plaid-oauth` for mobile OAuth banks
3. ✅ **User email** - Now fetching from Supabase current user
4. ✅ **Error handling** - Added detailed Plaid error logging
5. ✅ **Link token generation** - Using real Plaid API with proper parameters

## 📋 Getting Valid Plaid Credentials

### Step 1: Sign up for Plaid Dashboard
1. Go to https://dashboard.plaid.com/signup
2. Create an account (it's free for sandbox/development)
3. Complete the signup process

### Step 2: Get Your Credentials
1. Go to https://dashboard.plaid.com/team/keys
2. Copy your **Sandbox** credentials:
   - `client_id` (looks like: `6492e8ab1a2bc3001234abcd`)
   - `secret` (looks like: `abc123def456ghi789jkl012mno345`)

### Step 3: Update Your .env File
Edit `/luni_app/.env` and replace the Plaid credentials:

```bash
# Plaid Configuration
PLAID_CLIENT_ID=your_actual_client_id_here
PLAID_SECRET=your_actual_secret_here
PLAID_ENVIRONMENT=sandbox
```

### Step 4: Configure Redirect URI in Plaid Dashboard
1. Go to https://dashboard.plaid.com/team/api
2. Scroll to **Allowed redirect URIs**
3. Add these URIs:
   - `lunifin://plaid-oauth` (for mobile)
   - `http://localhost:3000` (for web testing)
4. Click **Save changes**

## 🧪 Testing Plaid Integration

### Sandbox Test Credentials
When you open Plaid Link in sandbox mode, use these test credentials:

**For successful connection:**
- Username: `user_good`
- Password: `pass_good`

**For specific test scenarios:**
- Username: `user_custom` - Customizable test data
- Username: `user_locked` - Tests locked account
- Username: `user_error` - Tests error handling

### What Should Happen
1. Click "Connect Your Bank" button
2. Plaid Link modal opens
3. Select any bank (e.g., "Chase")
4. Enter test credentials (`user_good` / `pass_good`)
5. Select accounts to link
6. Plaid Link closes and returns a public token
7. App exchanges public token for access token
8. App fetches accounts and transactions

## 🐛 Debugging Errors

### Error: "INVALID_API_KEYS"
- Your `client_id` or `secret` is wrong
- Double-check you copied them correctly from dashboard
- Make sure there are no extra spaces or quotes

### Error: "INVALID_REDIRECT_URI"
- You haven't added `lunifin://plaid-oauth` to Plaid Dashboard
- Go to https://dashboard.plaid.com/team/api and add it

### Error: "link_token invalid or expired"
- Link tokens expire after 30 minutes
- The app creates a fresh token each time, so this shouldn't happen
- If it does, check that your system clock is correct

### Error: Shows bank list but crashes when selecting
- This usually means your Plaid environment mismatch
- Verify `PLAID_ENVIRONMENT=sandbox` in `.env`
- Verify you're using sandbox credentials from dashboard

## 📱 Mobile-Specific Setup

### iOS (Info.plist)
Already configured in `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>lunifin</string>
    </array>
  </dict>
</array>
```

### Android (AndroidManifest.xml)
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="lunifin" android:host="plaid-oauth" />
</intent-filter>
```

## 🔍 Checking Console Output

When you click "Connect Your Bank", look for these logs:

✅ **Success:**
```
Creating link token via backend
Using Plaid environment: sandbox
User ID: abc123-def456-ghi789
✅ Generated real link token: link-sandbox-12345678...
Launching Plaid Link Mobile with token: link-sandb...
Plaid Link Success: public-sandbox-abc123...
Exchanging public token via backend
✅ Successfully exchanged public token for access token
```

❌ **Error:**
```
Creating link token via backend
❌ Plaid API error: 400
Error code: INVALID_API_KEYS
Error message: invalid client_id or secret provided
Display message: An error occurred. Please try again later.
```

## 🎯 Next Steps After Setup

1. **Test in sandbox** with `user_good` / `pass_good`
2. **Request production access** from Plaid Dashboard (takes 1-2 business days)
3. **Update to development** credentials for testing with real banks
4. **Apply for production** access when ready to launch
5. **Switch to production** credentials in `.env`

## 📚 Additional Resources

- Plaid Documentation: https://plaid.com/docs/
- Sandbox Test Credentials: https://plaid.com/docs/sandbox/test-credentials/
- Plaid Dashboard: https://dashboard.plaid.com/
- Flutter Plaid Plugin: https://pub.dev/packages/plaid_flutter

## ⚠️ Security Notes

1. **Never commit your `.env` file** - It's already in `.gitignore`
2. **Rotate your secret** if it's ever exposed
3. **Use SECRET keys only in backend** - Never in frontend
4. **Use ANON keys in frontend** for Supabase
5. **Monitor Plaid Dashboard** for suspicious activity

