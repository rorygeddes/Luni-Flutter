# AI Agent Security - Data Access Control

## 🔒 **Security Overview**

The Luni AI Agent has access to your complete financial database, but **it can ONLY access YOUR data** - never another user's data.

---

## ✅ **How It's Protected**

### 1. **Supabase Authentication**
Every API call to the database includes the user's JWT (JSON Web Token):
```dart
final supabase = Supabase.instance.client; // Includes user's JWT automatically
```

### 2. **Row Level Security (RLS)**
Supabase RLS policies enforce data isolation at the database level:
- **Transactions**: `WHERE user_id = auth.uid()`
- **Accounts**: `WHERE user_id = auth.uid()`
- **Friends**: `WHERE user_id = auth.uid() OR friend_user_id = auth.uid()`
- **Groups**: `WHERE id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())`
- **Split Transactions**: `WHERE payer_id = auth.uid() OR id IN (...)`

### 3. **Backend Service Layer**
All AI agent tools call `BackendService` methods, which:
- Use the authenticated Supabase client
- Are automatically filtered by the current user's ID
- Cannot be bypassed to access other users' data

---

## 🛡️ **What the AI CAN Access (Your Data Only)**

### Financial Data:
✅ Your transactions  
✅ Your account balances  
✅ Your spending categories  
✅ Your uncategorized transactions  

### Social Data:
✅ Your friends list  
✅ Your groups  
✅ Your split transaction history  
✅ Your pending splits  

---

## ❌ **What the AI CANNOT Access**

❌ Other users' transactions  
❌ Other users' account balances  
❌ Other users' friends or groups  
❌ Any data from users not in your friend list or groups  
❌ System-level database information  

---

## 🔍 **Technical Implementation**

### Agent Tool Execution
```dart
/// 🔒 SECURITY: All data access is automatically filtered by the current user.
/// BackendService uses Supabase.instance.client which includes the user's JWT token.
/// Supabase Row Level Security (RLS) policies enforce that users can ONLY access
/// their own data (transactions, accounts, friends, groups, etc.).
/// No user can access another user's data through the AI agent.
static Future<Map<String, dynamic>> _executeAgentTool(
  String functionName,
  Map<String, dynamic> arguments,
) async {
  // All calls to BackendService are automatically user-scoped
  final data = await BackendService.getSomeData();
  // ^^^ This ONLY returns data for the authenticated user
}
```

### Example: Getting Transactions
```dart
case 'get_transactions':
  // This call is automatically filtered to current user's transactions
  final transactions = await BackendService.getTransactions(limit: 500);
  
  // Supabase RLS ensures the query becomes:
  // SELECT * FROM transactions WHERE user_id = current_user_id LIMIT 500
```

---

## 🧪 **Testing User Isolation**

You can verify this yourself:
1. Sign in as User A
2. Ask AI: "Show me my transactions"
3. Sign out, sign in as User B
4. Ask AI: "Show me my transactions"

**Result**: Each user sees only their own transactions. User B cannot access User A's data.

---

## 📊 **Database Tables with RLS**

All tables have RLS enabled:
- ✅ `transactions`
- ✅ `accounts`
- ✅ `categories`
- ✅ `friends`
- ✅ `groups`
- ✅ `group_members`
- ✅ `split_transactions`
- ✅ `split_participants`
- ✅ `ai_conversations`
- ✅ `ai_messages`

---

## 🚨 **If You Find a Security Issue**

If you ever discover that the AI can access another user's data:
1. **Stop using the AI immediately**
2. Report the issue to the development team
3. Include the exact query you used

---

## 📝 **Summary**

**The AI is secure by design:**
- ✅ Database-level security (RLS)
- ✅ Authentication-based filtering (JWT)
- ✅ Service-layer isolation (BackendService)
- ✅ No direct database access from AI
- ✅ Automatic user scoping on all queries

**Your data is private and safe.** The AI can only see what you can see in the app.

