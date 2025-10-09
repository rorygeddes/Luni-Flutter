# Fix Plaid OAuth Flow - Missing oauth_state_id

## 🚨 Root Cause Identified

The issue is that Plaid is not passing the `oauth_state_id` parameter when redirecting to your OAuth page. This happens when:

1. **Plaid Link is not configured correctly**
2. **The OAuth flow wasn't initiated properly**
3. **The redirect URI doesn't match exactly**
4. **Link token is not stored properly**

## 🔧 Solutions

### **Step 1: Upload Debug Page to luni.ca**

Upload the debug page to help diagnose the issue:
- **File:** `debug-oauth.html`
- **URL:** `https://luni.ca/debug-oauth.html`

### **Step 2: Check Your Plaid Dashboard Configuration**

Make sure your Plaid Dashboard has:
- ✅ **Redirect URI:** `https://luni.ca/plaid-oauth` (exact match)
- ✅ **No trailing slash**
- ✅ **HTTPS (required for production)**
- ✅ **Remove any localhost URLs**

### **Step 3: Test the OAuth Flow Properly**

The OAuth flow only works when:
- ✅ User selects a bank that uses OAuth (not all banks do)
- ✅ Plaid Link is opened from your Flutter app (not directly in browser)
- ✅ Link token is stored before opening Plaid Link

### **Step 4: Banks That Use OAuth**

Test with banks that definitely use OAuth:

**Sandbox Banks:**
- **"First Platypus Bank"** (TD Bank)
- **"Tartan Bank"** (RBC)
- **"Houndstooth Bank"** (BMO)

**Production Banks:**
- **TD Bank**
- **RBC**
- **BMO**
- **CIBC**
- **Scotia Bank**

### **Step 5: Debug Steps**

1. **Test the Debug Page:**
   Visit: `https://luni.ca/debug-oauth.html`
   
   This will show you:
   - What parameters Plaid is passing
   - Whether link token is in storage
   - What's missing from the OAuth flow

2. **Check Your Flutter App Configuration:**
   Make sure your Flutter app:
   - ✅ Creates link token with correct redirect URI
   - ✅ Stores link token before opening Plaid Link
   - ✅ Opens Plaid Link from the app (not browser)

3. **Test the Complete Flow:**
   - Open your Flutter app
   - Click "Connect Bank Account"
   - Select a bank that uses OAuth (like "First Platypus Bank" in sandbox)
   - Complete the bank login
   - Should redirect to: `https://luni.ca/plaid-oauth?oauth_state_id=xxx`

## 🔍 Common Issues & Solutions

### **Issue 1: Not Storing Link Token**
**Problem:** Your HTML needs the link_token in localStorage
**Solution:** Update your Flutter app to store the token:

```dart
// In your Flutter app, before opening Plaid Link:
await _storeLinkTokenForOAuth(linkToken);

static Future<void> _storeLinkTokenForOAuth(String linkToken) async {
  // Store in shared preferences or pass as URL parameter
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('plaid_link_token', linkToken);
}
```

### **Issue 2: Wrong Redirect URI**
**Problem:** Mismatch between Flutter config and Plaid Dashboard
**Solution:** Make sure both use exactly:
- **Flutter:** `https://luni.ca/plaid-oauth`
- **Plaid Dashboard:** `https://luni.ca/plaid-oauth`

### **Issue 3: Testing with Wrong Banks**
**Problem:** Not all banks use OAuth
**Solution:** Test with banks that definitely use OAuth:
- Use "First Platypus Bank" in sandbox
- Use TD Bank, RBC, or BMO in production

### **Issue 4: OAuth State Not Being Passed**
**Problem:** Plaid not passing oauth_state_id parameter
**Solution:** This usually means:
1. **Wrong redirect URI** in Plaid Dashboard
2. **Link token not stored** before opening Plaid Link
3. **Testing with non-OAuth bank**

## 🧪 Testing Checklist

### **Pre-Test Setup:**
- [ ] Debug page uploaded to `https://luni.ca/debug-oauth.html`
- [ ] OAuth page uploaded to `https://luni.ca/plaid-oauth`
- [ ] Plaid Dashboard updated with correct redirect URI
- [ ] Flutter app updated to store link token

### **Test Flow:**
1. [ ] Open Flutter app
2. [ ] Click "Connect Bank Account"
3. [ ] Select "First Platypus Bank" (OAuth bank)
4. [ ] Complete bank login
5. [ ] Check if redirects to: `https://luni.ca/plaid-oauth?oauth_state_id=xxx`

### **Debug Page Test:**
1. [ ] Visit `https://luni.ca/debug-oauth.html`
2. [ ] Check what parameters are missing
3. [ ] Verify link token storage
4. [ ] Test with different URL parameters

## 🚨 Most Likely Issues

Based on the error, the most likely issues are:

1. **Plaid Dashboard Configuration:**
   - Wrong redirect URI
   - Missing redirect URI
   - Not saved properly

2. **Flutter App Configuration:**
   - Not storing link token
   - Wrong redirect URI in code
   - Opening Plaid Link incorrectly

3. **Bank Selection:**
   - Testing with non-OAuth bank
   - Using wrong test credentials

## 🎯 Next Steps

1. **Upload both files to luni.ca:**
   - `plaid-oauth.html`
   - `debug-oauth.html`

2. **Test the debug page:**
   - Visit `https://luni.ca/debug-oauth.html`
   - See what's missing

3. **Fix the specific issue** based on debug results

4. **Test with OAuth bank** (First Platypus Bank)

5. **Verify complete flow** works end-to-end

## 📱 Expected Flow

```
1. User clicks "Connect Bank" in Flutter app
2. App creates link token with redirect: https://luni.ca/plaid-oauth
3. App stores link token
4. App opens Plaid Link
5. User selects OAuth bank (First Platypus Bank)
6. User completes bank login
7. Bank redirects to: https://luni.ca/plaid-oauth?oauth_state_id=xxx
8. OAuth page completes the flow
9. Page redirects to: lunifin://plaid-callback?public_token=xxx
10. App receives deep link and exchanges token
11. ✅ Bank connected successfully!
```

**The debug page will tell you exactly what's missing in your OAuth flow!** 🔍
