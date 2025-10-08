# 🔄 Transaction Sync Guide

## 📋 **Your Questions Answered:**

### **Q1: Do I need to reconnect my bank?**

**YES - to get 90 days of history:**

Your current connection only fetched transactions at the moment of connection. The new 90-day fetch only runs during the **initial connection**.

**What to do:**
1. ❌ Disconnect your current bank
2. ✅ Reconnect with production credentials
3. ✅ It will fetch all 90 days of transactions

---

### **Q2: How do I sync new transactions?**

**Two ways:**

### **Method 1: Manual Sync** (Available Now)

1. Go to **Track screen**
2. Tap the **🔄 Sync icon** (top right, next to filter)
3. App syncs last 30 days from all connected banks
4. New transactions appear automatically

### **Method 2: Automatic Sync** (Future)

Coming soon:
- Background sync every 24 hours
- Webhook-based real-time updates
- Push notifications for new transactions

---

## 🔄 **How Sync Works:**

```
1. You tap Sync button
   ↓
2. App fetches access_token from database
   ↓
3. For each connected bank:
   - Calls Plaid /transactions/get
   - Gets last 30 days
   - Upserts to database (no duplicates)
   ↓
4. Shows: "✅ X new transactions synced"
   ↓
5. New transactions appear in:
   - Track screen (uncategorized)
   - Add screen (queue for categorization)
```

---

## 📊 **What Gets Synced:**

**Initial Connection (90 days):**
- All transactions from last 90 days
- Up to 500 per account
- All accounts you selected

**Manual Sync (30 days):**
- New transactions from last 30 days
- Checks all connected banks
- Only adds new transactions (no duplicates)

---

## 🎯 **Step-by-Step: Get Your 90 Days**

### **Step 1: Disconnect Current Bank**

*Option A: Delete from Database (Recommended)*
```sql
-- In Supabase SQL Editor:
DELETE FROM transactions WHERE user_id = 'your_user_id';
DELETE FROM accounts WHERE user_id = 'your_user_id';
DELETE FROM institutions WHERE user_id = 'your_user_id';
```

*Option B: Keep data, just reconnect*
- App will merge old + new data
- No duplicates (uses transaction IDs)

### **Step 2: Update .env to Production**

```env
PLAID_ENVIRONMENT=production
PLAID_SECRET=your_production_secret
```

### **Step 3: Restart App**

```bash
# Full restart (not hot reload)
flutter run
```

### **Step 4: Reconnect Your Bank**

1. Home → "Connect Bank Account"
2. Search for your real bank
3. Authenticate with real credentials
4. Wait for sync to complete

**Watch Console:**
```
📅 Fetching transactions from 2024-10-XX to 2025-01-XX (90 days)...
📊 Retrieved 234 transactions
Total transactions available: 234
💾 Saving Plaid data to Supabase...
📝 Processing 234 transactions...
  ✓ Saved: Starbucks ($12.50)
  ✓ Saved: Uber ($45.99)
  ... (234 more)
✅ 234 transactions saved
```

### **Step 5: View Your Transactions**

1. **Track screen** → Tap any account
2. See all 90 days of transactions
3. **Add screen** → Start categorizing!

---

## 🔄 **Daily Usage:**

### **Every Morning (or when you want):**

1. Open app → Track screen
2. Tap **🔄 Sync** button
3. Wait 2-5 seconds
4. New transactions appear
5. Go to Add screen → Categorize them

### **What Gets Synced:**
- Yesterday's coffee ☕
- Last night's Uber 🚗
- Weekend shopping 🛍️
- Any transactions from last 30 days

---

## 📱 **Visual Guide:**

### **Track Screen (Top Right):**
```
Track                    [🔄] [☰]
```
- 🔄 = Sync button (NEW!)
- ☰ = Filter (future feature)

### **When You Tap Sync:**
```
🔄 Syncing new transactions...
   ↓ (2-5 seconds)
✅ Transactions synced successfully!
```

---

## 💡 **Pro Tips:**

### **Best Practices:**

1. **Sync daily** - Keep transactions up to date
2. **Categorize immediately** - Don't let queue build up
3. **Check all accounts** - Tap each one after sync

### **What If:**

**No new transactions?**
- Normal if you haven't spent money
- Sync checks anyway for completeness

**Sync fails?**
- Check internet connection
- Try again in a few minutes
- Plaid might be rate limiting

**Missing transactions?**
- Bank might not have posted yet
- Pending transactions appear after 1-2 days
- Sync again tomorrow

---

## 🎯 **Summary:**

### **One-Time Setup:**
1. ✅ Disconnect old bank
2. ✅ Update to production
3. ✅ Reconnect for 90 days

### **Daily Use:**
1. ✅ Tap sync button
2. ✅ Categorize new transactions
3. ✅ Track spending

---

## 🚀 **Future Enhancements:**

Coming soon:
- ⏰ Auto-sync every 24 hours
- 🔔 Push notifications for new transactions
- 📊 Spending alerts
- 🔗 Webhook integration for real-time updates

**For now, manual sync works perfectly!** 🎉

