# Backend Migration Guide

## 🎯 Architecture Change Summary

**BEFORE:**
- Flutter app had direct Supabase access using anon keys
- Frontend handled authentication directly
- Credentials exposed in client code

**AFTER:**
- Backend server handles all Supabase operations using SECRET keys
- Frontend calls backend APIs
- Credentials secured on server only

## 🔐 Security Improvements

| Before | After |
|--------|-------|
| ❌ Anon key in frontend | ✅ SECRET key in backend only |
| ❌ Direct database access | ✅ API-controlled access |
| ❌ Client-side auth | ✅ Server-side auth with JWT |
| ❌ RLS bypass attempts | ✅ Full admin control in backend |

## 📋 What Changed

### 1. Removed from Flutter:
- ❌ Direct Supabase client initialization
- ❌ `supabase_flutter` package usage in main.dart
- ❌ Anon key configuration
- ❌ Direct auth service calls to Supabase

### 2. Added to Backend:
- ✅ Node.js Express server
- ✅ Supabase client with SECRET key
- ✅ JWT authentication
- ✅ API endpoints for auth and Plaid
- ✅ Secure credential management

### 3. Updated in Flutter:
- ✅ New `BackendAuthService` for API calls
- ✅ Backend URL in `.env`
- ✅ HTTP-based authentication
- ✅ Token-based session management

## 🚀 Setup Instructions

### Step 1: Set Up Backend

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.template .env

# Edit .env with your credentials
nano .env
```

**Required in backend `.env`:**
```bash
# Use SECRET key, NOT anon key!
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SECRET_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  # SERVICE ROLE key

PORT=3000
JWT_SECRET=your-random-secret-change-this
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox
```

**Get Supabase SECRET Key:**
1. Go to: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
2. Find "**service_role**" section (NOT anon/public)
3. Copy the "secret" value
4. Paste as `SUPABASE_SECRET_KEY` in `.env`

### Step 2: Start Backend

```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server runs on: `http://localhost:3000`

### Step 3: Update Flutter .env

In `luni_app/assets/.env`:

```bash
# Add backend URL
BACKEND_URL=http://localhost:3000

# Remove these (backend handles them now):
# SUPABASE_URL=...
# SUPABASE_ANON_KEY=...

# Keep Plaid credentials (for direct Flutter integration if needed)
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox
```

### Step 4: Update Flutter Code

The following services have been updated:

#### Authentication (Use BackendAuthService)

**OLD (Direct Supabase):**
```dart
await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);
```

**NEW (Backend API):**
```dart
import 'package:luni_app/services/backend_auth_service.dart';

final result = await BackendAuthService.signInWithEmailPassword(
  email,
  password,
);

if (result['success']) {
  // User signed in, token stored automatically
  final user = result['user'];
}
```

#### Sign Up

**NEW:**
```dart
final result = await BackendAuthService.signUpWithEmailPassword(
  email,
  password,
  {
    'username': username,
    'full_name': fullName,
    'school': school,
    'age': age,
  },
);
```

#### Get Profile

**NEW:**
```dart
final profile = await BackendAuthService.getUserProfile();
```

#### Update Profile

**NEW:**
```dart
final success = await BackendAuthService.updateUserProfile({
  'full_name': 'New Name',
  'school': 'New School',
});
```

#### Sign Out

**NEW:**
```dart
await BackendAuthService.signOut();
```

#### Check Authentication

**NEW:**
```dart
if (BackendAuthService.isAuthenticated) {
  // User is logged in
}
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/signup` - Create new user
- `POST /api/auth/signin` - Sign in user
- `POST /api/auth/signout` - Sign out user
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update profile
- `GET /api/auth/user` - Get current user

### Plaid
- `POST /api/plaid/create-link-token` - Create Plaid link token
- `POST /api/plaid/exchange-public-token` - Exchange public token

All endpoints (except signup/signin) require:
```
Authorization: Bearer <jwt_token>
```

## 🔧 Environment Variables Reference

### Backend `.env` (SECRET KEYS)

```bash
PORT=3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SECRET_KEY=service_role_secret_key_here  # ⚠️ SECRET KEY
JWT_SECRET=your-jwt-secret
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox
NODE_ENV=development
```

### Flutter `assets/.env` (NO KEYS)

```bash
BACKEND_URL=http://localhost:3000  # Or production URL
PLAID_CLIENT_ID=your_plaid_client_id  # Optional, for direct integration
PLAID_SECRET=your_plaid_secret  # Optional, for direct integration
PLAID_ENVIRONMENT=sandbox
```

## 🧪 Testing the Migration

### 1. Test Backend

```bash
# Start backend
cd backend
npm run dev

# In another terminal, test signup
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123",
    "profile": {
      "username": "testuser",
      "full_name": "Test User"
    }
  }'

# Test signin
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }'
```

### 2. Test Flutter App

```bash
# Ensure backend is running
# Run Flutter app
cd luni_app
flutter run -d chrome

# Try to sign in/sign up
# Check console for "Backend URL: http://localhost:3000"
```

## 🚨 Important Security Notes

### ✅ DO:
- Use **SERVICE_ROLE SECRET key** in backend `.env`
- Keep backend `.env` file secure and git-ignored
- Use strong JWT_SECRET in production
- Enable HTTPS in production
- Validate all inputs server-side

### ❌ DON'T:
- Put SECRET keys in Flutter code
- Commit backend `.env` to git
- Use anon keys in backend
- Expose backend `.env` publicly
- Skip input validation

## 🐛 Troubleshooting

### "Connection refused" Error
- Ensure backend is running on port 3000
- Check BACKEND_URL in Flutter `.env` matches backend

### "Invalid token" Error
- Check JWT_SECRET is same in backend
- Ensure token is included in Authorization header
- Token may have expired (7 days default)

### "Supabase error" in Backend
- Verify you're using SECRET key, not anon key
- Check SUPABASE_URL is correct
- Ensure database tables exist

### "No profile data" Error
- Check profiles table exists in Supabase
- Verify RLS is disabled (backend uses SECRET key)
- Check profile was created during signup

## 📦 Deployment Checklist

### Backend Deployment:
- [ ] Set up production server (Heroku/Railway/AWS/etc.)
- [ ] Set environment variables in production
- [ ] Use strong JWT_SECRET
- [ ] Enable HTTPS
- [ ] Set up rate limiting
- [ ] Configure CORS for production frontend URL
- [ ] Set PLAID_ENVIRONMENT=production

### Flutter Deployment:
- [ ] Update BACKEND_URL to production URL
- [ ] Remove any hardcoded credentials
- [ ] Test authentication flow
- [ ] Test Plaid integration
- [ ] Build and deploy app

## 🎉 Benefits of This Architecture

1. **Security**: SECRET keys never exposed to users
2. **Control**: Full admin access to Supabase from backend
3. **Flexibility**: Easy to add business logic server-side
4. **Scalability**: Backend can handle complex operations
5. **Debugging**: Server logs for all operations
6. **Updates**: Can update auth logic without app updates

## 📚 Additional Resources

- [Backend README](backend/README.md) - Detailed backend documentation
- [ENV_TEMPLATE](luni_app/ENV_TEMPLATE.md) - Environment variable guide
- [BackendAuthService](luni_app/lib/services/backend_auth_service.dart) - Flutter auth service
- [Backend Server](backend/server.js) - Node.js backend code

---

**Migration Status**: ✅ Complete
**Security Level**: 🔒 High (SECRET keys in backend only)
**Ready for Production**: After deployment checklist

