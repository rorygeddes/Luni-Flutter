# Fix Credit Card Balance ($1027.83) - Duplicate Transaction Issue

## 🔍 Problem

Your credit card balance should be **$1027.83** but the app is showing a different amount. This is likely caused by **duplicate transactions** being synced from Plaid.

## 📋 Step-by-Step Fix

### Step 1: Check for Duplicates

Run this SQL in your **Supabase SQL Editor**:

```sql
-- File: CHECK_DUPLICATE_TRANSACTIONS.sql
```

Open the file `/docs/sql/CHECK_DUPLICATE_TRANSACTIONS.sql` and run it in Supabase. This will show you:
- ✅ All duplicate transactions
- ✅ Current credit card balance calculation
- ✅ Difference from expected $1027.83

### Step 2: Remove Duplicates

Once you've confirmed there are duplicates, run:

```sql
-- File: REMOVE_DUPLICATE_TRANSACTIONS.sql
```

⚠️ **IMPORTANT**: This will:
1. Keep the **oldest** transaction (by `created_at`)
2. Delete any newer duplicates
3. Show you the corrected balance

### Step 3: Verify the Fix

After running the removal script, check that:
- ✅ Credit card balance = **-$1027.83** (negative = debt)
- ✅ No more duplicate transactions
- ✅ App shows correct balance

## 🎯 Expected Results

### Before Fix:
```
Credit Card Balance: $XXX.XX (WRONG)
Duplicate Transactions: Yes
Total Transactions: YYY (including duplicates)
```

### After Fix:
```
Credit Card Balance: -$1027.83 ✅
Duplicate Transactions: None ✅
Total Transactions: ZZZ (unique only)
```

## 🔧 How Duplicates Happen

### Common Causes:

1. **Multiple Syncs**: Running sync multiple times for the same period
2. **Reconnecting Bank**: Disconnecting and reconnecting pulls transactions again
3. **Overlapping Date Ranges**: Sync periods that overlap
4. **Upsert Issues**: Transaction ID not being used for deduplication

### The Fix:

The app uses **`upsert`** which should prevent duplicates, but if the transaction ID changes or is missing, duplicates can occur.

## 🚀 Prevention

### To Prevent Future Duplicates:

1. **Check Transaction IDs**: Ensure Plaid transaction IDs are being saved correctly
2. **Sync Once**: Don't run manual sync multiple times for the same period
3. **Database Constraint**: Add a unique constraint on `(date, description, amount, account_id)`

### Add Unique Constraint (Optional):

```sql
-- Prevent future duplicates at database level
ALTER TABLE transactions
ADD CONSTRAINT unique_transaction 
UNIQUE (date, description, amount, account_id);
```

⚠️ **Note**: This will prevent duplicate inserts but may cause errors if legitimate duplicate transactions exist (e.g., two identical coffee purchases on the same day).

## 📊 Understanding the Balance Calculation

### How Credit Card Balance Works:

```
Current Balance = Opening Balance + New Transactions
```

**Example:**
```
Opening Balance: -$1000.00  (credit card debt)
New Transaction: -$27.83     (new purchase)
----------------------------------------
Current Balance: -$1027.83   ✅
```

### What the App Shows:

- **Internal**: Balance is negative (`-$1027.83`)
- **Display**: Shows positive in red (`$1027.83`)

## 🔍 Debug Queries

### Check Current Balance:

```sql
SELECT 
  name,
  balance,
  opening_balance,
  opening_balance_date
FROM accounts 
WHERE type = 'credit' OR subtype = 'credit card';
```

### Count Transactions:

```sql
SELECT 
  COUNT(*) as total,
  COUNT(DISTINCT id) as unique_ids,
  COUNT(*) - COUNT(DISTINCT id) as duplicates
FROM transactions
WHERE account_id IN (
  SELECT id FROM accounts 
  WHERE type = 'credit' OR subtype = 'credit card'
);
```

## 📝 Files Created

1. **`CHECK_DUPLICATE_TRANSACTIONS.sql`** - Diagnostic queries
2. **`REMOVE_DUPLICATE_TRANSACTIONS.sql`** - Fix script
3. **`FIX_CREDIT_CARD_BALANCE_1027.83.md`** - This guide

## ✅ Checklist

- [ ] Run `CHECK_DUPLICATE_TRANSACTIONS.sql` to see duplicates
- [ ] Review the output to understand what will be removed
- [ ] Run `REMOVE_DUPLICATE_TRANSACTIONS.sql` to fix
- [ ] Verify balance is `-$1027.83`
- [ ] Test in the app (refresh/reload)
- [ ] Consider adding unique constraint to prevent future duplicates

## 🆘 If Balance Is Still Wrong

If after removing duplicates the balance is still not $1027.83, check:

1. **Opening Balance Date**: Is it set correctly?
2. **Transaction Dates**: Are transactions being counted correctly?
3. **Currency Conversion**: Are all transactions in the same currency?
4. **Missing Transactions**: Are all transactions present?

Run this to diagnose:

```sql
-- Show all transactions affecting the balance
SELECT 
  date,
  description,
  amount,
  CASE 
    WHEN date >= (SELECT opening_balance_date FROM accounts WHERE type = 'credit' LIMIT 1) 
    THEN 'COUNTED ✅'
    ELSE 'IGNORED ❌'
  END as counted
FROM transactions
WHERE account_id IN (SELECT id FROM accounts WHERE type = 'credit')
ORDER BY date DESC;
```

---

**Need Help?** Check the other SQL diagnostic files in `/docs/sql/`

