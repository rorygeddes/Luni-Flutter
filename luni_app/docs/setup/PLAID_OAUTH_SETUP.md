# Plaid OAuth Setup for Production - Fix Redirect URI Error

## 🚨 Current Error
```
OAuth redirect URI must be configured in the developer dashboard
```

You're seeing this because Plaid production requires OAuth redirect URIs to be registered in the dashboard.

---

## ✅ Quick Fix (5 Minutes)

### Step 1: Add Redirect URI to Plaid Dashboard
1. Go to: **https://dashboard.plaid.com/team/api**
2. Scroll to **"Allowed redirect URIs"** section
3. Click **"Configure"** or **"Add redirect URI"**
4. Add: `https://luni.ca/plaid-oauth`
5. Click **"Save changes"**

⚠️ **Important:** Wait 1-2 minutes after saving for changes to propagate!

---

## 🌐 Option 1: Simple Web Redirect (Recommended for Now)

This is the quickest way to get production working.

### What You Need:
1. A live website at `https://luni.ca`
2. A simple HTML page at `https://luni.ca/plaid-oauth`
3. Deep linking back to your app

### Create `plaid-oauth.html` on your website:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Connecting Bank Account...</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 2rem;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 16px;
      backdrop-filter: blur(10px);
    }
    .spinner {
      border: 4px solid rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      border-top: 4px solid white;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 0 auto 1rem;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    h1 { margin: 0 0 0.5rem; font-size: 24px; }
    p { margin: 0; opacity: 0.9; font-size: 16px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="spinner"></div>
    <h1>Completing Bank Connection</h1>
    <p>Redirecting you back to Luni App...</p>
  </div>
  
  <script src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"></script>
  <script>
    (function() {
      // Get the link token and OAuth state from URL params
      const urlParams = new URLSearchParams(window.location.search);
      const oauthStateId = urlParams.get('oauth_state_id');
      
      // Get link token from localStorage (set by app before opening Plaid)
      const linkToken = localStorage.getItem('plaid_link_token');
      
      if (!linkToken) {
        console.error('No link token found');
        alert('Error: Missing link token. Please try connecting your bank again.');
        // Redirect back to app
        window.location.href = 'lunifin://plaid-callback?error=missing_token';
        return;
      }
      
      // Reinitialize Plaid Link with OAuth redirect
      const handler = Plaid.create({
        token: linkToken,
        receivedRedirectUri: window.location.href,
        onSuccess: function(public_token, metadata) {
          console.log('Plaid OAuth success:', metadata);
          
          // Store the public token
          localStorage.setItem('plaid_public_token', public_token);
          localStorage.setItem('plaid_metadata', JSON.stringify(metadata));
          
          // Redirect back to app with success
          const callbackUrl = 'lunifin://plaid-callback?public_token=' + 
                            encodeURIComponent(public_token) +
                            '&institution=' + encodeURIComponent(metadata.institution.name);
          
          window.location.href = callbackUrl;
        },
        onExit: function(err, metadata) {
          console.log('Plaid OAuth exit:', err, metadata);
          
          // Redirect back to app with error
          const errorMsg = err ? err.display_message : 'User cancelled';
          window.location.href = 'lunifin://plaid-callback?error=' + 
                               encodeURIComponent(errorMsg);
        },
      });
      
      // Open the Link flow to complete OAuth
      handler.open();
    })();
  </script>
</body>
</html>
```

### Update Your Flutter Code to Store Link Token:

Add this to your `PlaidService`:

```dart
// Before opening Plaid Link, store the token for OAuth redirect
static Future<void> launchPlaidLink({
  required Function(String) onSuccess,
  required Function(String) onExit,
  required Function(String) onEvent,
}) async {
  try {
    final linkToken = await createLinkToken();
    
    if (kIsWeb) {
      // For web, store link token in localStorage for OAuth redirect
      await _storeOAuthState(linkToken);
      await _launchPlaidLinkWeb(linkToken, onSuccess, onExit, onEvent);
    } else {
      // Mobile: Store for OAuth redirect page
      await _storeOAuthState(linkToken);
      await _launchPlaidLinkMobile(linkToken, onSuccess, onExit, onEvent);
    }
  } catch (e) {
    print('Error launching Plaid Link: $e');
    onExit('Failed to launch Plaid Link: $e');
  }
}

static Future<void> _storeOAuthState(String linkToken) async {
  // For web: use browser localStorage
  if (kIsWeb) {
    // Use js package or store in session
    // localStorage.setItem('plaid_link_token', linkToken);
  }
  // For mobile: this is handled by the redirect page
}
```

---

## 🌐 Option 2: Use a Generic OAuth Redirect Page

If you don't have `luni.ca` set up yet, you can use a temporary domain:

### Quick Deploy Options:

1. **Vercel** (Free & Fast):
   ```bash
   # Create oauth.html with the code above
   vercel deploy
   # Use the generated URL: https://your-app.vercel.app/plaid-oauth
   ```

2. **Netlify** (Free & Fast):
   ```bash
   # Create oauth.html
   netlify deploy
   # Use the generated URL: https://your-app.netlify.app/plaid-oauth
   ```

3. **GitHub Pages** (Free):
   - Create a repo with `plaid-oauth.html`
   - Enable GitHub Pages
   - Use: `https://yourusername.github.io/plaid-oauth.html`

### Update .env with your temporary URL:
```bash
PLAID_REDIRECT_URI=https://your-temp-domain.vercel.app/plaid-oauth
```

### Update backend_service.dart:
```dart
'redirect_uri': _plaidEnvironment == 'production' 
    ? 'https://your-temp-domain.vercel.app/plaid-oauth'
    : 'lunifin://plaid-oauth',
```

---

## 📱 Mobile Deep Linking Setup

### iOS (Info.plist) - Already Done ✅
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

### Android (AndroidManifest.xml) - Already Done ✅
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="lunifin" android:host="plaid-callback" />
</intent-filter>
```

### Handle Deep Link Callback in Flutter:

Add to your `main.dart`:

```dart
// Listen for deep link callbacks from OAuth redirect
void _setupDeepLinkListener() {
  // You may need to add uni_links package
  // Or handle it in your navigation service
  
  // When app receives lunifin://plaid-callback?public_token=xxx
  // Extract the public token and call exchangePublicToken
}
```

---

## 🧪 Testing Production OAuth

### Test Flow:
1. User clicks "Connect Bank" in app
2. App creates link token
3. App opens Plaid Link
4. User selects bank and authenticates
5. Bank redirects to: `https://luni.ca/plaid-oauth?oauth_state_id=xxx`
6. Your OAuth page completes Plaid Link
7. Page redirects to: `lunifin://plaid-callback?public_token=xxx`
8. App receives deep link and exchanges token

### Test Banks That Require OAuth:
- Chase
- Bank of America
- Wells Fargo
- Capital One
- Most major US banks

### Test Banks That DON'T Require OAuth:
- Many credit unions
- Smaller regional banks

---

## ⚠️ Important Production Notes

### 1. HTTPS is Required
- ❌ `http://luni.ca/plaid-oauth` - Won't work
- ✅ `https://luni.ca/plaid-oauth` - Required

### 2. URL Must Be Publicly Accessible
- Can't use `localhost` or `127.0.0.1`
- Must be a real domain with SSL certificate

### 3. Multiple Redirect URIs Allowed
You can add multiple for testing:
- `https://luni.ca/plaid-oauth` (production)
- `https://staging.luni.ca/plaid-oauth` (staging)
- `https://your-dev-domain.vercel.app/plaid-oauth` (development)

### 4. Android Package Name
Also add to Plaid Dashboard → **Allowed Android package names**:
- `com.luni.app` (or whatever your app ID is)

---

## 🚀 Quick Start Checklist

- [ ] Add `https://luni.ca/plaid-oauth` to Plaid Dashboard
- [ ] Create `plaid-oauth.html` page on your website
- [ ] Verify page is accessible: Open `https://luni.ca/plaid-oauth` in browser
- [ ] Test deep linking: Try `lunifin://plaid-callback?test=true` on device
- [ ] Update app to store link token before opening Plaid
- [ ] Test full OAuth flow with a real bank

---

## 🆘 Troubleshooting

### "OAuth redirect URI must be configured"
→ You didn't add the URI to dashboard or it's still propagating (wait 2 min)

### "Redirect URI mismatch"
→ The URI in your code doesn't exactly match the one in dashboard (check for trailing slashes)

### "ERR_CONNECTION_REFUSED" on redirect
→ Your OAuth page isn't deployed or URL is wrong

### Deep link doesn't open app
→ Check URI scheme is configured correctly in iOS/Android

### "link_token invalid" on redirect page
→ Link token expired (30 min lifetime) or wasn't stored properly

---

## 📚 Resources

- **Plaid OAuth Docs:** https://plaid.com/docs/link/oauth/
- **Flutter Deep Linking:** https://docs.flutter.dev/cookbook/navigation/set-up-universal-links
- **Plaid Dashboard:** https://dashboard.plaid.com/team/api

---

## 💡 Pro Tip: Use ngrok for Local Testing

If you want to test locally before deploying:

```bash
# Install ngrok
brew install ngrok

# Start your local server
python3 -m http.server 8080

# Expose it
ngrok http 8080

# Use the HTTPS URL in Plaid Dashboard
# https://abc123.ngrok.io/plaid-oauth.html
```

---

**Once you add the redirect URI to the Plaid Dashboard, your production Plaid integration will work!** 🎉

