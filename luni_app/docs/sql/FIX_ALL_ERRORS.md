# Fix All Current Errors - Quick Guide

## 🔧 Database Fixes (Run in Supabase SQL Editor)

Run these SQL scripts **in order**:

### 1. Fix Friends System (Duplicate Friends Issue)
```sql
-- File: docs/sql/ADD_FRIENDS_SYSTEM_SIMPLE.sql
-- This deduplicates friends when both users add each other
```
**Run this file in Supabase!**

### 2. Fix Split RLS Policies (Infinite Recursion Error)
```sql
-- File: docs/sql/FIX_SPLIT_RLS_POLICIES.sql
-- This fixes the circular reference in split RLS policies
```
**Run this file in Supabase!**

### 3. Fix Groups RLS Policies (Infinite Recursion Error)
```sql
-- File: docs/sql/FIX_GROUPS_RLS.sql
-- This fixes the circular reference in groups and group_members RLS policies
```
**Run this file in Supabase!** (This is critical for creating groups)

---

## 🚀 Quick Test

After running the SQL fixes:

1. **Hot restart your app**
2. Go to **Split screen**
3. Try **creating a group**
4. Try **splitting a transaction**

---

## ✅ Expected Results

- ✅ No infinite recursion errors
- ✅ Friends show up only once (no duplicates)
- ✅ Groups load correctly
- ✅ Split transactions work
- ✅ Group members display properly

---

## 📝 Summary of What Was Fixed

1. **Friends System**
   - Added DISTINCT ON to eliminate duplicate friends
   - Fixed when both users add each other

2. **Split Transactions**
   - Removed circular RLS policy references
   - Simplified to prevent infinite recursion

3. **Group Creation**
   - New feature to create groups with friends
   - Beautiful UI with friend selection
   - Fully functional with haptic feedback

---

## 🆘 If Errors Persist

Run this diagnostic query in Supabase:

```sql
-- Check if policies exist
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('split_transactions', 'split_participants', 'group_members', 'friends')
ORDER BY tablename, policyname;
```

This will show all existing policies so we can debug further!

