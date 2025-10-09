# 🔍 Duplicate Detection System - Complete Guide

## 📋 Overview

The Duplicate Detection System automatically identifies potential duplicate transactions during sync and allows users to confirm or reject them. Confirmed duplicates are moved to a recoverable "Deleted Items" location.

## ✨ Features

### 1. **Automatic Detection During Sync**
- Checks for exact duplicates (same transaction ID)
- Detects potential duplicates (same amount, description, within 3 days)
- Match scoring system (100 = exact match, 90-80 = high confidence)

### 2. **Priority Queue**
- Potential duplicates appear **first** in transaction queue
- Marked with a special indicator
- High priority for user review

### 3. **User Confirmation**
- **Yes (Duplicate)**: Moves to Deleted Items
- **No (Not Duplicate)**: Marks as verified, normal processing

### 4. **Deleted Items (Recoverable)**
- All deleted duplicates stored safely
- Can recover if balance is off
- Permanent deletion option available

---

## 🚀 Setup

### Step 1: Run the SQL Setup Script

In Supabase SQL Editor, run:

```sql
-- File: /docs/sql/ADD_DUPLICATE_DETECTION_SYSTEM.sql
```

This creates:
- ✅ `is_potential_duplicate` flag on transactions
- ✅ `deleted_transactions` table
- ✅ Database functions for duplicate detection
- ✅ Recovery functions
- ✅ Proper indexes and RLS policies

### Step 2: Update Your App

The Flutter code has been updated with:
- ✅ Duplicate detection during sync
- ✅ Backend methods for handling duplicates
- ✅ Methods for deleted transactions management

---

## 📊 How It Works

### Detection Algorithm

```
For each new transaction during sync:
  1. Check if transaction_id already exists → Skip
  2. Find potential duplicates:
     - Same account_id
     - Same amount
     - Same or similar description
     - Within 3 days
  3. Calculate match score:
     - 100: Exact match (same date, amount, description)
     - 90: Same amount/description, within 3 days
     - 80: Same amount, similar description, within 3 days
     - 70: Same amount, within 1 day
  4. If score ≥ 80 → Flag as potential duplicate
  5. Add to database with flag set
```

### Match Scoring Examples

| Scenario | Match Score | Action |
|----------|-------------|--------|
| Exact duplicate (all fields match) | 100 | ⚠️ Flagged |
| Same transaction, different date | 90 | ⚠️ Flagged |
| Similar description, same amount | 80 | ⚠️ Flagged |
| Same amount only, 1 day apart | 70 | ℹ️ Not flagged |

---

## 🎯 User Workflow

### Transaction Queue View

```
┌─────────────────────────────────────┐
│   POTENTIAL DUPLICATE - HIGH PRIORITY│
│                                     │
│  🚨 BELL MEDIA                      │
│     -$9.04                          │
│     Oct 8, 2025                     │
│                                     │
│  Possible duplicate of:             │
│  BELL MEDIA - Oct 7, 2025           │
│                                     │
│  Is this a duplicate?               │
│  [Yes, Remove]  [No, Keep]          │
└─────────────────────────────────────┘
```

### User Actions

#### 1. **Confirm Duplicate (Yes)**
```dart
await BackendService.confirmDuplicate(transactionId);
```
- Transaction moves to `deleted_transactions`
- Balance recalculates automatically
- User can recover later if needed

#### 2. **Reject Duplicate (No)**
```dart
await BackendService.rejectDuplicate(transactionId);
```
- Clears duplicate flag
- Proceeds to normal categorization
- Marked as verified

---

## 🗑️ Deleted Items

### View Deleted Transactions

```dart
final deletedItems = await BackendService.getDeletedTransactions();
```

Shows:
- All transactions deleted as duplicates
- Deletion date and reason
- Option to recover or permanently delete

### Deleted Items Screen

```
┌─────────────────────────────────────┐
│   DELETED ITEMS                     │
│                                     │
│  BELL MEDIA                         │
│  -$9.04 • Oct 8, 2025               │
│  Deleted: Duplicate                 │
│  [Recover]  [Delete Permanently]    │
│                                     │
│  SUPABASE                           │
│  -$63.05 • Oct 7, 2025              │
│  Deleted: Duplicate                 │
│  [Recover]  [Delete Permanently]    │
└─────────────────────────────────────┘
```

### Recovery

#### Recover Transaction
```dart
await BackendService.recoverDeletedTransaction(transactionId);
```
- Moves back to `transactions` table
- Appears in transaction queue
- Balance updates immediately

#### Permanent Deletion
```dart
await BackendService.permanentlyDeleteTransaction(transactionId);
```
- Removes from `deleted_transactions`
- Cannot be recovered
- Confirms user action

---

## 🛠️ Backend Methods

### Duplicate Detection
```dart
// Get transactions with duplicates prioritized
final transactions = await BackendService.getUncategorizedTransactionsWithPriority();
```

### Confirm Duplicate
```dart
bool success = await BackendService.confirmDuplicate(transactionId);
```

### Reject Duplicate
```dart
bool success = await BackendService.rejectDuplicate(transactionId);
```

### View Deleted Items
```dart
List<Map<String, dynamic>> deleted = await BackendService.getDeletedTransactions();
```

### Recover Transaction
```dart
bool recovered = await BackendService.recoverDeletedTransaction(transactionId);
```

### Permanent Delete
```dart
bool deleted = await BackendService.permanentlyDeleteTransaction(transactionId);
```

---

## 📱 UI Components Needed

### 1. **Duplicate Warning Card**
Location: Transaction Queue (top priority)

Features:
- 🚨 Visual indicator (red/orange border)
- Shows original transaction for comparison
- Clear Yes/No buttons
- Match score indicator (optional)

### 2. **Deleted Items Screen**
Location: Profile or Settings → Deleted Items

Features:
- List of all deleted transactions
- Deletion reason and date
- Recover button
- Permanent delete confirmation

### 3. **Recovery Confirmation**
```
┌─────────────────────────────────────┐
│   Recover Transaction?              │
│                                     │
│  BELL MEDIA - $9.04                 │
│                                     │
│  This will add the transaction back │
│  to your account and update your    │
│  balance.                           │
│                                     │
│  [Cancel]  [Recover]                │
└─────────────────────────────────────┘
```

---

## 🔍 SQL Queries for Debugging

### Check Potential Duplicates
```sql
SELECT * FROM transactions
WHERE is_potential_duplicate = TRUE
ORDER BY duplicate_checked_at DESC;
```

### Find Duplicates for a Transaction
```sql
SELECT * FROM find_potential_duplicates(
  'account_id',
  '2025-10-08'::DATE,
  -9.04,
  'BELL MEDIA',
  'current_transaction_id'
);
```

### View Deleted Items
```sql
SELECT * FROM deleted_transactions
WHERE user_id = 'your_user_id'
AND can_recover = TRUE
ORDER BY deleted_at DESC;
```

### Recover a Transaction
```sql
SELECT recover_deleted_transaction('transaction_id');
```

---

## ⚡ Performance Considerations

### Indexes Created
- `idx_transactions_potential_duplicate` - Fast duplicate lookup
- `idx_transactions_duplicate_search` - Efficient duplicate detection
- `idx_deleted_transactions_user` - Quick deleted items retrieval
- `idx_deleted_transactions_recoverable` - Filter recoverable items

### Optimization
- Duplicate detection only checks last 3 days
- Limited to 5 potential matches per transaction
- Match score calculation is efficient
- Database functions handle complex logic

---

## 🎓 Best Practices

### For Users
1. **Review duplicates promptly** - They appear at top of queue
2. **Check balance** - If it seems off, check deleted items
3. **Recover quickly** - Don't wait if you made a mistake
4. **Permanent delete carefully** - Only when sure

### For Developers
1. **Always flag, never auto-delete** - Let users decide
2. **Prioritize in queue** - High priority for review
3. **Make recovery easy** - One tap to restore
4. **Log everything** - Track deleted_reason and timestamps

---

## 🐛 Troubleshooting

### "Duplicate not detected"
- Check match score threshold (currently 80)
- Verify date range (currently 3 days)
- Check if transaction IDs match exactly

### "Can't recover transaction"
- Check `can_recover` flag in deleted_transactions
- Verify transaction isn't permanently deleted
- Check user permissions (RLS policies)

### "Balance still wrong after deletion"
- Transaction might not be counted in balance calculation
- Check `opening_balance_date` vs transaction date
- Run balance recalculation query

---

## 📊 Statistics & Monitoring

### Track Duplicate Detection Rate
```sql
SELECT 
  COUNT(*) FILTER (WHERE is_potential_duplicate = TRUE) as duplicates_flagged,
  COUNT(*) as total_transactions,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_potential_duplicate = TRUE) / COUNT(*), 2) as duplicate_rate
FROM transactions
WHERE created_at > NOW() - INTERVAL '30 days';
```

### User Confirmation Rates
```sql
SELECT 
  deleted_reason,
  COUNT(*) as count
FROM deleted_transactions
WHERE deleted_at > NOW() - INTERVAL '30 days'
GROUP BY deleted_reason;
```

---

## ✅ Testing Checklist

- [ ] SQL setup script runs successfully
- [ ] Duplicate detection works during sync
- [ ] Potential duplicates appear first in queue
- [ ] Confirm duplicate moves to deleted_transactions
- [ ] Reject duplicate clears flag
- [ ] Deleted items screen shows all deleted transactions
- [ ] Recovery works and updates balance
- [ ] Permanent deletion removes completely
- [ ] RLS policies enforce user isolation
- [ ] Performance is acceptable with many transactions

---

## 🚀 Future Enhancements

1. **Smart Learning** - Remember user decisions for similar transactions
2. **Bulk Actions** - Confirm/reject multiple duplicates at once
3. **Auto-deletion** - After 30 days in deleted items
4. **Analytics** - Show duplicate patterns to help prevent
5. **Merchant Matching** - Use merchant data for better detection

---

**Created**: October 9, 2025  
**Version**: 1.0  
**Status**: Ready for Implementation

