# ⚠️ IMPORTANT: Run These SQL Scripts First!

Before using the Friends and Split features, you must run these SQL scripts in your Supabase SQL editor:

## 1. Friends System (REQUIRED for Social tab Friends feature)
```sql
-- Run this first
docs/sql/ADD_FRIENDS_SYSTEM.sql
```

**Error you'll see if not run:**
```
Could not find the function public.get_user_friends
```

## 2. Split System (if not already run)
```sql
-- Run this for Split features
docs/sql/ADD_SPLIT_SYSTEM_SAFE.sql
```

## 3. Duplicate Detection (if not already run)
```sql
-- Run this for Transaction Queue duplicate detection
docs/sql/ADD_DUPLICATE_DETECTION_SYSTEM_SAFE.sql
```

---

## How to Run:
1. Go to your Supabase project dashboard
2. Click "SQL Editor" in the left sidebar
3. Click "New Query"
4. Copy the contents of the SQL file
5. Paste into the editor
6. Click "Run" or press `Cmd+Enter`
7. Check for success message ✅

---

## Verification:
After running, you should see these tables in your database:
- `friends` (friend relationships)
- `messages` (direct messages)
- `group_messages` (group chats)
- `groups` (split groups)
- `group_members` (group membership)
- `split_transactions` (split records)
- `split_participants` (who's in each split)
- `deleted_transactions` (recoverable deleted items)

And these RPC functions:
- `get_user_friends()`
- `get_conversation_list()`
- `find_potential_duplicates()`
- `move_to_deleted_transactions()`
- `recover_deleted_transaction()`
- `get_user_balance_with()`

