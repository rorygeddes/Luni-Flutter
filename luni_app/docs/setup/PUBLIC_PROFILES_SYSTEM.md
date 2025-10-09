# 🔒 Public Profiles & Privacy System

## Overview
Users now have **public** and **private** profile fields. Other users can only see public information when searching or messaging.

---

## 📋 Public vs Private Fields

### ✅ **Public Fields** (visible to everyone)
- `id` - User's unique identifier
- `username` - User's chosen username
- `full_name` - User's display name
- `avatar_url` - Profile picture URL
- `etransfer_id` - E-Transfer ID for payments

### 🔒 **Private Fields** (only visible to the user themselves)
- `email` - User's email address
- `created_at` - Account creation date
- Any other sensitive information

---

## 🗄️ Database Changes

### Added Column
```sql
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS etransfer_id TEXT;
```

### Updated RLS Policies
```sql
-- Anyone can view profiles (app filters to public fields)
CREATE POLICY "Anyone can view public profiles" 
ON profiles FOR SELECT 
USING (true);

-- Users can only edit their own profile
CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

-- Users can only create their own profile
CREATE POLICY "Users can insert own profile" 
ON profiles FOR INSERT 
WITH CHECK (auth.uid() = id);
```

---

## 💻 Code Changes

### 1. **UserModel** (`lib/models/user_model.dart`)
Added `etransferId` field:
```dart
@JsonKey(name: 'etransfer_id')
final String? etransferId;
```

### 2. **MessagingService** (`lib/services/messaging_service.dart`)
All queries now only SELECT public fields:
```dart
.select('id, username, full_name, avatar_url, etransfer_id')
```

This applies to:
- `searchUsers()` - User search
- `getAllUsers()` - Get all profiles
- `getConversations()` - Fetch conversation participants

---

## 🔐 Security Model

### How It Works
1. **Database Level**: RLS allows viewing all profiles
2. **Application Level**: Queries explicitly SELECT only public fields
3. **Result**: Users can search/message others, but can't access private data like emails

### Why This Approach?
- ✅ Enables user search and discovery
- ✅ Protects sensitive information (email, etc.)
- ✅ Allows messaging without friend requests
- ✅ Shows E-Transfer ID for payments

---

## 📱 User Experience

### What Users Can See About Others
1. **Search Results**: Username, Full Name, Avatar
2. **Chat List**: Username, Full Name, Avatar, Last Message
3. **User Profile**: Username, Full Name, Avatar, E-Transfer ID

### What Users Can See About Themselves
1. All public fields +
2. Email address
3. Account creation date
4. Any other private settings

---

## 🚀 Setup Instructions

1. Run `FIX_PROFILES_RLS.sql` in Supabase SQL Editor
2. Verify policies were created successfully
3. Test queries show public data only
4. Hot restart the app

---

## ✅ Testing

### Test 1: Search for Other Users
```
1. Go to Social → Discover
2. Tap search button
3. Search for another user's username
4. User should appear with name, username, avatar
5. Email should NOT be visible
```

### Test 2: View Conversation
```
1. Send a message to another user
2. Check conversation list
3. Other user's name and avatar should show
4. Email should NOT be visible
```

### Test 3: View Own Profile
```
1. Go to Profile tab
2. You should see your email
3. You should see all your data
```

---

## 🎯 Benefits

1. **Privacy**: Email addresses are protected
2. **Discovery**: Users can find each other by username
3. **Payments**: E-Transfer ID is visible for easy payments
4. **Messaging**: No friend request needed - anyone can message anyone
5. **Security**: RLS ensures users can only edit their own profile

---

**Status**: ✅ Implemented
**Last Updated**: October 8, 2025

