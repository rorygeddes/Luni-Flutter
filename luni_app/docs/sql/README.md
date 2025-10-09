# SQL Scripts

All database scripts for Supabase. Run these in the Supabase SQL Editor.

## 🚀 Quick Access

### Most Commonly Used
1. **`RESET_TRANSACTIONS_QUEUE.sql`** - Reset all transactions to uncategorized
2. **`ADD_DEFAULT_CATEGORIES_SIMPLE.sql`** - Add default categories
3. **`COMPLETE_ACCOUNT_FIX.sql`** - Fix all account-related issues

## 📋 Script Categories

### Core Setup (Run Once)
- `setup_messaging_database.sql`
- `setup_friends_system.sql`
- `setup_categories_database.sql`

### Transaction Management
- `RESET_TRANSACTIONS_QUEUE.sql`
- `FIX_DATABASE_NOW.sql`
- `fix_database_schema.sql`

### Account & Balance Fixes
- `COMPLETE_ACCOUNT_FIX.sql`
- `FIX_BALANCE_TRACKING.sql`
- `FIX_CREDIT_CARD_BALANCES.sql`
- `FIX_DATE_COMPARISON.sql`

### Currency Support
- `ADD_CURRENCY_SUPPORT.sql`
- `SIMPLE_CURRENCY_SETUP.sql`
- `FIX_US_TFSA_CURRENCY.sql`
- `CHECK_US_TFSA_CURRENCY.sql`

### Categories System
- `ADD_DEFAULT_CATEGORIES_SIMPLE.sql` ⭐ Most used
- `FIX_CATEGORIES_RLS.sql`
- `CHECK_CATEGORIES.sql`
- `ENSURE_DEFAULT_CATEGORIES.sql`

### User & Profile Management
- `FIX_PROFILES_RLS.sql`
- `CHECK_USERS_FOR_SEARCH.sql`
- `CHECK_USER_MISMATCH.sql`
- `WHO_AM_I.sql`
- `TEST_SEARCH_QUERY.sql`

### Messaging System
- `setup_messaging_database.sql`
- `CLEAN_MESSAGING_SETUP.sql`
- `CREATE_MESSAGING_TABLES.sql`

### Debug & Diagnostics
- `DEBUG_BALANCE_CALCULATION.sql`
- `DEBUG_CREDIT_CARD_TRANSACTIONS.sql`
- `DEBUG_DATE_COMPARISON.sql`
- `DEBUG_US_TFSA_BALANCE.sql`
- `DIAGNOSE_TRANSACTIONS.sql`
- `CHECK_NEW_TRANSACTIONS.sql`
- `FIND_1_DOLLAR_TRANSACTION.sql`

### Emergency Fixes
- `URGENT_FIX.sql`
- `COMPLETE_FIX.sql`
- `FINAL_SQL_FIX.sql`
- `RUN_THIS_SQL.sql`

### Legacy/Archive
- `NEW_SQL_ONLY.sql`
- `RESET_OPENING_BALANCE_DATE.sql`
- `new_supabase_setup.sql`

## 💡 Usage Tips

1. **Always backup** before running destructive scripts
2. **Check current user** with `WHO_AM_I.sql` before updates
3. **Verify changes** with appropriate `CHECK_*.sql` scripts
4. **Debug issues** with `DEBUG_*.sql` scripts before fixing

## 🔄 Common Workflows

### Fresh Setup
1. Run all `setup_*.sql` scripts
2. Run `ADD_DEFAULT_CATEGORIES_SIMPLE.sql`
3. Run `FIX_PROFILES_RLS.sql`

### Reset Transaction Queue
1. Run `RESET_TRANSACTIONS_QUEUE.sql`
2. Refresh app to see all transactions in queue

### Fix Account Balances
1. Run `COMPLETE_ACCOUNT_FIX.sql`
2. Verify with `DEBUG_BALANCE_CALCULATION.sql`

### Debug Issues
1. Identify issue area (balance, categories, users, etc.)
2. Run appropriate `CHECK_*.sql` or `DEBUG_*.sql` script
3. Apply relevant `FIX_*.sql` script
4. Verify with original debug script

