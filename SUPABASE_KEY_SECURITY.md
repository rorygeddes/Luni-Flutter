# Supabase Key Security - Best Practices

## 🔑 Understanding Supabase Keys

### Anon Key (Public/Client-Side)
- ✅ **Safe for frontend apps** (Flutter, React, etc.)
- ✅ **Protected by Row Level Security (RLS)**
- ✅ **Limited to user-level permissions**
- ✅ **Can be in client code** (but not in git!)
- 📍 **Use Case:** Your Flutter app, mobile apps, web apps

### Secret/Service Key (Private/Server-Side)
- ❌ **NEVER use in frontend**
- ❌ **NEVER commit to git**
- ❌ **NEVER expose to users**
- ✅ **Only for backend/server code**
- ⚠️ **Bypasses all RLS policies**
- 📍 **Use Case:** Backend APIs, cron jobs, admin scripts

## ✅ Your Current Setup (CORRECT)

Your app is already configured correctly:

```dart
// In .env file (git-ignored) ✅
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key  // This is CORRECT for Flutter

// In main.dart ✅
await dotenv.load(fileName: ".env");
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,  // ANON key is correct
);
```

## 🔒 The Problem Wasn't the Key Type

The security issue was **committing credentials to git**, NOT using the wrong key type.

### What Was Wrong:
```dart
// ❌ BAD: In app_config.template.dart (committed to git)
static const String supabaseAnonKey = 'eyJhbGci...';  // Real credential in git!
```

### What's Correct:
```dart
// ✅ GOOD: In app_config.template.dart (template only)
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

// ✅ GOOD: Real credentials in .env (git-ignored)
SUPABASE_ANON_KEY=eyJhbGci...
```

## 🛡️ Securing Your Anon Key

Even though anon keys are meant for client-side use, protect them with RLS:

### 1. Enable Row Level Security (RLS)

```sql
-- In Supabase SQL Editor
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
```

### 2. Create RLS Policies

```sql
-- Users can only read their own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only view their own transactions
CREATE POLICY "Users can view own transactions"
ON transactions FOR SELECT
USING (auth.uid() = user_id);
```

### 3. Test RLS Policies

```sql
-- Test that users can't access other users' data
-- This should return only the current user's data
SELECT * FROM profiles;
```

## 🔐 When to Use Secret Key

**ONLY use secret keys in:**

1. **Backend APIs** (Node.js, Python, etc.)
   ```javascript
   // server.js (backend only!)
   const supabase = createClient(
     process.env.SUPABASE_URL,
     process.env.SUPABASE_SERVICE_KEY  // Secret key - server only!
   );
   ```

2. **Admin Scripts**
   ```python
   # admin_script.py (server only!)
   supabase = create_client(
     os.getenv('SUPABASE_URL'),
     os.getenv('SUPABASE_SERVICE_KEY')
   )
   ```

3. **Cron Jobs / Background Tasks**

**NEVER use secret keys in:**
- ❌ Flutter/React/Vue/Angular apps
- ❌ Mobile apps (iOS/Android)
- ❌ Browser extensions
- ❌ Any code that runs on user devices

## 📋 Security Checklist

### Current Status:
- ✅ Anon key in `.env` file (correct approach)
- ✅ `.env` file is git-ignored
- ✅ Template file has placeholders only
- ⚠️ Need to rotate exposed anon key
- ⚠️ Need to enable RLS policies

### Action Items:

#### 1. Rotate Your Anon Key (DO NOW)
```bash
# Go to Supabase Dashboard
https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api

# Click "Reset" next to anon/public key
# Copy new key to your .env file
```

#### 2. Enable RLS on All Tables
```sql
-- Run in Supabase SQL Editor
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
```

#### 3. Create RLS Policies (Use your new_supabase_setup.sql)
```bash
# Your setup script already has RLS policies!
# Just run it in Supabase SQL Editor
```

#### 4. Test Access
```bash
# In your Flutter app, verify users can only see their own data
# Try accessing another user's data (should fail)
```

## 🎯 Summary

### ✅ DO:
- Use **anon key** in Flutter app
- Store credentials in `.env` file
- Keep `.env` git-ignored
- Enable RLS on all tables
- Create proper RLS policies
- Rotate keys when exposed

### ❌ DON'T:
- Use secret key in Flutter app
- Commit credentials to git
- Share credentials publicly
- Disable RLS in production
- Trust client-side validation

## 🔄 Your Next Steps

1. **Rotate anon key** in Supabase dashboard
2. **Update `.env`** with new anon key
3. **Keep using anon key** (it's correct!)
4. **Enable RLS** if not already enabled
5. **Test** that RLS policies work

Your app architecture is correct - you just need to rotate the exposed key and ensure RLS is enabled!

