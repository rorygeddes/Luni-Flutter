# Plaid Production Setup Guide

## 🚀 You're Now Using Production Mode!

Your app is configured to use **production** Plaid credentials, which means:
- ✅ **Real bank connections** with actual financial institutions
- ✅ **Real transaction data** from users' accounts
- ⚠️ **Real money** - be careful with testing!
- 🔒 **Must comply** with Plaid's production requirements

---

## 📋 Production Checklist

### ✅ Before Going Live

- [ ] **Plaid Production Access Approved**
  - Applied for production access in Plaid Dashboard
  - Received approval email from Plaid
  - Production credentials are active

- [ ] **Webhook Endpoint Setup**
  - Webhook URL configured: `https://api.luni.ca/plaid/webhook`
  - Webhook endpoint is live and responding
  - Webhook signature verification implemented

- [ ] **Redirect URIs Configured**
  - Added `https://luni.ca/plaid-oauth` to Plaid Dashboard (production requires HTTPS!)
  - ⚠️ Custom URI schemes (like `lunifin://`) are NOT allowed in production
  - Tested OAuth flow with production credentials and HTTPS redirect
  - Ensure your website can handle the OAuth callback

- [ ] **Security Measures**
  - All API keys stored securely (not in code)
  - SSL/TLS enabled for all API calls
  - User data encrypted at rest and in transit
  - Compliance with data retention policies

- [ ] **Terms & Privacy**
  - Privacy policy updated with Plaid integration details
  - Terms of service include bank connection terms
  - Users must accept before connecting banks

---

## 🔧 Current Configuration

Your `.env` file should be set to:
```bash
PLAID_CLIENT_ID=your_production_client_id
PLAID_SECRET=your_production_secret
PLAID_ENVIRONMENT=production
```

**Base URL:** `https://production.plaid.com`

---

## ⚠️ Important Production Notes

### 1. **No Test Credentials**
In production, you **cannot** use sandbox test credentials like:
- ❌ `user_good` / `pass_good`
- ❌ Mock bank accounts
- ❌ Test institutions

Users must connect their **real bank accounts** with actual login credentials.

### 2. **Rate Limits**
Production has different rate limits than sandbox:
- Link token creation: 100 requests/minute
- Data fetching: Varies by product
- Monitor your usage in Plaid Dashboard

### 3. **Costs**
Production usage incurs costs:
- Per successful connection
- Per transaction fetched
- Per API call (depending on your plan)
- Check your pricing plan: https://dashboard.plaid.com/billing

### 4. **Bank Maintenance**
Real banks have:
- Scheduled maintenance windows
- Occasional downtime
- Rate limiting on their end
- Different connection speeds

### 5. **HTTPS Redirect URI Required**
**Critical:** Production mode requires HTTPS redirect URIs:
- ❌ `lunifin://plaid-oauth` (custom schemes not allowed)
- ✅ `https://luni.ca/plaid-oauth` (HTTPS required)

You need:
1. A live website at `https://luni.ca`
2. A `/plaid-oauth` endpoint that handles the callback
3. Deep linking to redirect back to your app

### 6. **Error Handling**
Production errors are different:
- `ITEM_LOGIN_REQUIRED` - User needs to re-authenticate
- `INSTITUTION_DOWN` - Bank is temporarily unavailable
- `INSTITUTION_NOT_RESPONDING` - Bank timeout
- `INVALID_FIELD` - Check redirect_uri uses HTTPS
- Handle these gracefully in your UI

---

## 🧪 Testing in Production

### Recommended Approach:
1. **Use a Test Bank Account** (if you have one)
   - Some banks offer developer/test accounts
   - Contact your bank about test accounts

2. **Use Your Personal Account** (carefully!)
   - Create a separate checking account with minimal funds
   - Only for development/testing purposes
   - Monitor it closely

3. **Beta Testing**
   - Start with a small group of beta users
   - Monitor for errors and issues
   - Gradually expand to more users

---

## 🔄 Switching Between Environments

### To Switch Back to Sandbox:
```bash
# In luni_app/.env
PLAID_ENVIRONMENT=sandbox
PLAID_CLIENT_ID=your_sandbox_client_id
PLAID_SECRET=your_sandbox_secret
```

### To Switch to Development:
```bash
# In luni_app/.env
PLAID_ENVIRONMENT=development
PLAID_CLIENT_ID=your_development_client_id
PLAID_SECRET=your_development_secret
```

**Note:** Each environment has different credentials!

---

## 📊 Monitoring Production

### Plaid Dashboard
Monitor your production usage at:
- **Dashboard:** https://dashboard.plaid.com/
- **Activity:** Check recent connections and errors
- **Webhooks:** Monitor webhook deliveries
- **Billing:** Track costs and usage

### Key Metrics to Watch:
- ✅ Successful connections rate
- ❌ Failed connection attempts
- 🔄 Token refresh rates
- ⏱️ Average connection time
- 💰 Monthly costs

---

## 🚨 Common Production Issues

### Issue 1: "Invalid credentials"
**Cause:** Production credentials not approved yet
**Fix:** 
1. Check Plaid Dashboard for approval status
2. Complete all required information
3. Wait for Plaid team approval (1-2 business days)

### Issue 2: "Institution not found"
**Cause:** Bank not available in production
**Fix:**
1. Check if bank is supported: https://plaid.com/institutions/
2. Some sandbox banks don't exist in production
3. User may need to try a different bank

### Issue 3: "Rate limit exceeded"
**Cause:** Too many API calls
**Fix:**
1. Implement caching for link tokens
2. Don't create new link token for every retry
3. Implement exponential backoff

### Issue 4: "Webhook not received"
**Cause:** Webhook endpoint not accessible
**Fix:**
1. Verify webhook URL is publicly accessible
2. Check webhook signature verification
3. Monitor webhook delivery in Plaid Dashboard

---

## 🔒 Security Best Practices

1. **Never log sensitive data in production**
   - No full access tokens in logs
   - No user credentials
   - No bank account numbers

2. **Rotate secrets regularly**
   - Change Plaid secret every 90 days
   - Update webhook secret regularly

3. **Monitor for suspicious activity**
   - Unusual connection patterns
   - Repeated failed attempts
   - Geographic anomalies

4. **Implement retry logic**
   - Exponential backoff for failed requests
   - Maximum retry limits
   - User-friendly error messages

---

## 📞 Support

### Plaid Support:
- **Dashboard:** https://dashboard.plaid.com/support
- **Email:** support@plaid.com
- **Status:** https://status.plaid.com/

### Emergency Issues:
1. Check Plaid status page first
2. Review webhook logs for errors
3. Contact Plaid support with:
   - Client ID (never secret!)
   - Item ID (if applicable)
   - Request ID from error response

---

## 📚 Additional Resources

- **Plaid Production Docs:** https://plaid.com/docs/production/
- **Best Practices:** https://plaid.com/docs/link/best-practices/
- **Security Guide:** https://plaid.com/docs/security/
- **Webhook Guide:** https://plaid.com/docs/api/webhooks/
- **Error Handling:** https://plaid.com/docs/errors/

---

## ⚡ Quick Reference

| Environment | Base URL | Test Accounts | Real Banks | Cost |
|------------|----------|---------------|------------|------|
| Sandbox | sandbox.plaid.com | ✅ Yes | ❌ No | 🆓 Free |
| Development | development.plaid.com | ✅ Yes | ✅ Yes | 💵 Low |
| Production | production.plaid.com | ❌ No | ✅ Yes | 💰 Full |

---

## 🎯 Next Steps

1. ✅ Verify production credentials are working
2. ✅ Test with real bank account (carefully!)
3. ✅ Set up webhook endpoint
4. ✅ Implement error handling for production errors
5. ✅ Monitor usage and costs in dashboard
6. ✅ Prepare customer support for bank connection issues

---

**Remember:** Production mode connects to real banks with real money. Always test thoroughly and monitor closely! 🚀

