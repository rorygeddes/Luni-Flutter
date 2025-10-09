# Deploy Plaid OAuth to luni.ca

## 🎯 What You Need to Add to Your luni.ca Directory

### **File Structure for luni.ca:**
```
luni.ca/
├── plaid-oauth.html    ← Add this file
└── (your existing files)
```

### **Step 1: Add the OAuth File**

**Copy this file to your luni.ca website:**
- **Source:** `/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/plaid-oauth-site/plaid-oauth.html`
- **Destination:** `https://luni.ca/plaid-oauth.html`

### **Step 2: Verify the File**

After uploading, test that it's accessible:
- Visit: **https://luni.ca/plaid-oauth.html**
- You should see the "Completing Bank Connection" page
- Check browser console for any JavaScript errors

### **Step 3: Update Plaid Dashboard**

1. Go to: **https://dashboard.plaid.com/team/api**
2. **Remove:** Any old redirect URIs (localhost, GitHub Pages, etc.)
3. **Add:** `https://luni.ca/plaid-oauth`
4. Click **Save changes**
5. **Wait 1-2 minutes** for changes to propagate

### **Step 4: Test Your App**

1. Run your Flutter app
2. Try connecting a bank account
3. Should now work without redirect URI errors!

---

## 📋 Deployment Methods for luni.ca

### **Method A: Direct File Upload**
If you have access to your luni.ca server:
```bash
# Upload the file directly to your web server
scp plaid-oauth.html user@luni.ca:/path/to/website/
```

### **Method B: Git Push (if luni.ca is a Git repo)**
```bash
# If luni.ca is managed with Git
cd /path/to/luni-ca-repo
cp /path/to/plaid-oauth.html .
git add plaid-oauth.html
git commit -m "Add Plaid OAuth redirect page"
git push origin main
```

### **Method C: FTP/SFTP**
```bash
# Upload via FTP client
# File: plaid-oauth.html
# Destination: /public_html/plaid-oauth.html (or similar)
```

### **Method D: Web Hosting Panel**
1. Login to your hosting control panel (cPanel, etc.)
2. Go to File Manager
3. Navigate to your website's root directory
4. Upload `plaid-oauth.html`

---

## 🔧 Technical Details

### **What the File Does:**
1. **Receives OAuth callback** from banks during Plaid Link flow
2. **Validates OAuth state** to prevent CSRF attacks
3. **Completes Plaid Link** with the received state
4. **Redirects back to app** with success/error via deep link

### **URL Structure:**
- **OAuth Callback:** `https://luni.ca/plaid-oauth?oauth_state_id=abc123`
- **Deep Link Back:** `lunifin://plaid-callback?public_token=xyz789`

### **Security Features:**
- ✅ Validates OAuth state ID
- ✅ Checks for link token
- ✅ Handles all error cases
- ✅ Secure redirect to mobile app

---

## 🚨 Troubleshooting

### **"File not found" Error:**
- Check file is uploaded to correct location
- Verify file permissions (should be readable)
- Try accessing: `https://luni.ca/plaid-oauth.html`

### **"OAuth redirect URI must be configured":**
- Add `https://luni.ca/plaid-oauth` to Plaid Dashboard
- Wait 2 minutes after saving
- Remove any old/localhost URLs

### **"Missing oauth_state_id parameter":**
- This means the OAuth page is working but needs state validation
- The file I provided handles this automatically

### **Deep link not opening app:**
- Check iOS Info.plist has `lunifin` scheme
- Check Android manifest has intent filter
- Test deep link: `lunifin://test`

---

## ✅ Success Checklist

- [ ] File uploaded to `https://luni.ca/plaid-oauth.html`
- [ ] File accessible in browser (shows loading page)
- [ ] Plaid Dashboard updated with `https://luni.ca/plaid-oauth`
- [ ] App code updated to use luni.ca redirect URI
- [ ] Test bank connection in app

---

## 📱 Complete Flow

```
1. User clicks "Connect Bank" in Luni app
2. App creates link token with redirect: https://luni.ca/plaid-oauth
3. Plaid Link opens, user authenticates with bank
4. Bank redirects to: https://luni.ca/plaid-oauth?oauth_state_id=xxx
5. Your OAuth page completes the flow
6. Page redirects to: lunifin://plaid-callback?public_token=xxx
7. App receives deep link and exchanges token
8. ✅ Bank connected successfully!
```

---

## 🎉 That's It!

Once you upload `plaid-oauth.html` to your luni.ca website and update the Plaid Dashboard, your OAuth integration will work perfectly!

**The file is ready to upload - just copy it to your luni.ca domain!** 🚀
