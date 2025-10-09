# 🚀 Production Setup Steps

## ⚠️ **IMPORTANT: Fix Database Schema First!**

Your database is missing required columns. **Run this SQL in Supabase SQL Editor:**

```sql
-- Add missing columns
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_categorized BOOLEAN DEFAULT FALSE;

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS is_split BOOLEAN DEFAULT FALSE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_categorized 
ON transactions(user_id, is_categorized);

CREATE INDEX IF NOT EXISTS idx_transactions_account 
ON transactions(user_id, account_id, date DESC);
```

---

## 📝 **Step 1: Update `.env` File**

Update your `.env` file in `luni_app/` directory:

```env
# Plaid Production Keys
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_production_secret_key
PLAID_ENVIRONMENT=production

# Supabase Keys
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# OpenAI (for AI categorization - optional for now)
OPENAI_API_KEY=your_openai_api_key
```

---

## 🔄 **Step 2: Configure Plaid Dashboard**

### **In Plaid Dashboard (https://dashboard.plaid.com/team/api):**

1. **API Section** → Add redirect URI:
   ```
   https://rorygeddes.github.io/Luni-Flutter/plaid-oauth-site/
   ```

2. **Enable Products:**
   - ✅ Transactions
   - ✅ Auth (optional, for account verification)

3. **Set Allowed Countries:**
   - ✅ Canada (CA)
   - ✅ United States (US)

---

## 🏦 **Step 3: Connect Your Real Bank**

1. **Fully restart the app** (not hot reload):
   ```bash
   flutter run
   ```

2. **Home Screen** → "Connect Bank Account"

3. **Search for your bank** (TD, RBC, Scotiabank, BMO, CIBC, etc.)

4. **Authenticate** with your real credentials

5. **Grant permission** for Plaid to access:
   - Account balances
   - Transaction history (90 days)

---

## 📊 **What Will Happen:**

### **During Connection:**
```
1. Plaid Link opens
   ↓
2. You authenticate with your bank
   ↓
3. App exchanges public token for access token
   ↓
4. Fetches ALL accounts
   ↓
5. Fetches last 90 DAYS of transactions (up to 500)
   ↓
6. Saves to Supabase as UNCATEGORIZED
   ↓
7. Console logs show:
   📊 Retrieved X transactions
   Total transactions available: X
   💾 Saving Plaid data to Supabase...
   📝 Processing X transactions...
     ✓ Saved: Starbucks ($12.50)
     ✓ Saved: Uber ($45.99)
   ✅ X transactions saved
```

---

## 🎯 **Step 4: View & Categorize Transactions**

### **Track Screen:**
1. **Tap any account** → See all transactions from that account
2. **Gold border** = categorized
3. **White/black** = uncategorized (needs review)

### **Add Screen (Queue):**
1. Shows **5 uncategorized transactions** at a time
2. AI suggests category (basic for now, OpenAI integration coming)
3. **Tap "Accept"** → Transaction becomes categorized
4. **Appears in Track** with gold border
5. **Repeat** until all categorized

### **Home Screen:**
1. **Category Spending section** appears once you have categorized transactions
2. Shows last 30 days breakdown by category
3. Updates in real-time

---

## 🔍 **Troubleshooting:**

### **No transactions showing?**

**Check console for:**
```
📊 Retrieved 0 transactions
```

**Possible causes:**
1. **Bank hasn't synced yet** - Wait 2-5 minutes and reconnect
2. **90-day history empty** - Some accounts have no recent transactions
3. **Plaid API error** - Check error message in console

**Solution:**
- Try disconnecting and reconnecting
- Check if your bank account actually has transactions in the last 90 days
- Verify Plaid production credentials are correct

### **Database errors?**

**Error:** `column transactions.is_categorized does not exist`

**Solution:** Run the SQL script from Step 1 in Supabase

### **OAuth redirect errors?**

**Error:** `OAuth redirect URI must be configured`

**Solution:** Add redirect URI in Plaid Dashboard (Step 2)

---

## 📱 **Expected Results:**

After connecting your real bank:
- ✅ See your actual accounts with real balances
- ✅ See 90 days of real transactions (up to 500 per account)
- ✅ Categorize transactions with AI assistance
- ✅ Track spending by category
- ✅ No fake/mock data

---

## 💡 **Transaction Retrieval Details:**

Following your `old_method.md` approach:

```dart
// Request sent to Plaid:
{
  'access_token': 'access-production-xxx',
  'start_date': '2024-10-XX',  // 90 days ago
  'end_date': '2025-01-XX',    // Today
  'options': {
    'count': 500,              // Up to 500 transactions
    'offset': 0,
    'include_original_description': true,
  }
}
```

**Plaid Response:**
- All transactions from all linked accounts
- Last 90 days
- Includes merchant names, amounts, dates
- Saved as uncategorized (is_categorized = false)

**Following workflow.md:**
1. Transactions imported → uncategorized
2. Queue shows 5 at a time
3. AI categorizes (basic for now)
4. User approves → categorized
5. Shows in Track with gold border
6. Category spending updates

---

## 🎉 **You're Ready!**

1. ✅ Run SQL to fix database
2. ✅ Update `.env` with production keys
3. ✅ Configure Plaid Dashboard
4. ✅ Restart app
5. ✅ Connect your real bank
6. ✅ See 90 days of transactions!

**No more sandbox, no more fake data!** 🚀

