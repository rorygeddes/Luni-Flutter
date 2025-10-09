# Opening Balance System - Complete Guide

## 🎯 **Overview**

The new balance tracking system works like this:

```
Account Balance = Opening Balance + New Transactions (after opening date)
```

### **Key Concepts:**

1. **Opening Balance**: The account balance when first connected to Plaid
2. **Opening Balance Date**: Timestamp when the account was connected
3. **Historical Transactions**: Last 90 days from Plaid (for viewing only, NOT counted)
4. **New Transactions**: Any transactions synced AFTER the opening balance date (COUNTED)

---

## 📊 **How It Works:**

### **Initial Setup (First Bank Connection):**
1. User connects bank via Plaid
2. Plaid returns:
   - Current account balance: `$1,200.00`
   - Last 90 days of transactions (135 transactions)
3. System saves:
   - `opening_balance`: `$1,200.00`
   - `opening_balance_date`: `2025-10-08 14:30:00`
   - All 135 transactions (for historical view only)

### **Dynamic Balance Calculation:**
```dart
// Opening balance (snapshot at connection time)
opening_balance = $1,200.00

// Only count transactions AFTER opening_balance_date
new_transactions_after_opening = [
  // None yet, since all 135 transactions are before the opening date
]

// Final balance
current_balance = $1,200.00 + $0.00 = $1,200.00
```

### **After First Sync (Next Day):**
1. User taps "Sync Transactions"
2. Plaid returns 2 new transactions:
   - Coffee: -$5.00
   - Gas: -$45.00
3. System adds them with date `2025-10-09`
4. New balance calculation:
```dart
opening_balance = $1,200.00

new_transactions_after_opening = [
  Coffee: -$5.00,
  Gas: -$45.00
]

current_balance = $1,200.00 + (-$5.00) + (-$45.00) = $1,150.00
```

---

## 💾 **Database Schema:**

### **Accounts Table:**
```sql
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  institution_id TEXT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  subtype TEXT,
  balance NUMERIC DEFAULT 0,           -- Static balance (not used for display)
  currency TEXT DEFAULT 'CAD',
  opening_balance NUMERIC DEFAULT 0,   -- ✨ NEW: Balance at connection time
  opening_balance_date TIMESTAMP,      -- ✨ NEW: When account was connected
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Transactions Table:**
```sql
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  account_id TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  original_currency TEXT DEFAULT 'CAD',
  description TEXT,
  date DATE NOT NULL,                  -- Transaction date
  category TEXT,
  subcategory TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔧 **Setup Instructions:**

### **1. Run the SQL:**
```sql
-- Add opening balance columns
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS opening_balance NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS opening_balance_date TIMESTAMP DEFAULT NOW();

-- Add currency support
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'CAD';

ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS original_currency TEXT DEFAULT 'CAD';

-- Set opening balance to current balance for existing accounts
UPDATE accounts 
SET 
  opening_balance = balance,
  opening_balance_date = NOW(),
  currency = 'CAD'
WHERE opening_balance IS NULL OR opening_balance = 0;

UPDATE transactions 
SET original_currency = 'CAD' 
WHERE original_currency IS NULL;
```

### **2. Reconnect Your Bank:**
For best results, delete and reconnect your bank account so:
- Opening balance is set correctly
- Opening balance date is TODAY
- Historical transactions are just for viewing
- New syncs will properly add to the balance

---

## 🎯 **User Flow:**

### **Day 1: Connect Bank**
- User connects TD Bank
- Plaid returns balance: $2,615.97 (US TFSA)
- System saves:
  - `opening_balance`: $2,615.97
  - `opening_balance_date`: 2025-10-08 14:30:00
- User sees 135 transactions in history (last 90 days)
- **Account balance shown**: $2,615.97 USD

### **Day 2: Sync Transactions**
- User taps "Sync"
- Plaid returns 3 new transactions:
  - Dividend: +$12.50
  - Fee: -$2.00
  - Trade: -$100.00
- System calculates:
  - Opening: $2,615.97
  - New: +$12.50 - $2.00 - $100.00 = -$89.50
  - **Account balance shown**: $2,526.47 USD

### **Day 30: View All Accounts**
- User has:
  - TD Chequing (CAD): Opening $35.90 + New -$150.00 = **-$114.10 CAD**
  - TD TFSA (USD): Opening $2,615.97 + New -$89.50 = **$2,526.47 USD**
  - TD Visa (CAD): Opening $855.09 + New +$50.00 = **$905.09 CAD**
- **"All Accounts" (CAD)**:
  - Convert USD to CAD: $2,526.47 × 1.36 = $3,436.00 CAD
  - Total: -$114.10 + $3,436.00 + $905.09 = **$4,226.99 CAD**

---

## ✅ **Benefits:**

1. **Accurate Balances**: Opening balance matches bank at connection time
2. **No Double Counting**: Historical transactions are for viewing only
3. **Real-time Updates**: New transactions properly update the balance
4. **Multi-Currency**: USD accounts converted to CAD for "All Accounts"
5. **Audit Trail**: Can see when account was connected and what was the initial balance

---

## 🔍 **Troubleshooting:**

### **Balance doesn't match bank?**
- Check `opening_balance_date` - is it correct?
- Check new transactions - are they being counted?
- Reconnect the bank account to reset opening balance

### **Historical transactions affecting balance?**
- They shouldn't! Only transactions AFTER `opening_balance_date` count
- Verify the date filter in `calculateDynamicBalance()`

### **Currency conversion issues?**
- USD accounts converted using live exchange rates
- Exchange rate API: `api.exchangerate.host`
- Fallback rate if API fails: 1:1

---

## 🚀 **Next Steps:**

1. Run `FIX_BALANCE_TRACKING.sql` in Supabase
2. Test the app - balances should show opening balance
3. Tap "Sync" to get new transactions
4. Verify balance updates correctly
5. (Optional) Reconnect bank for clean slate

