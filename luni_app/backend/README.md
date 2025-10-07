# Luni Backend API

Backend server for the Luni Flutter app that uses Supabase **SECRET KEYS** for secure authentication and data access.

## 🔐 Architecture

- **Frontend (Flutter)**: Does NOT have direct Supabase access
- **Backend (Node.js)**: Uses Supabase SECRET keys to manage auth and data
- **Security**: All sensitive operations happen on the backend

## 📋 Prerequisites

- Node.js 18+
- npm or yarn
- Supabase project with SECRET key

## 🚀 Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend/` directory:

```bash
# Backend Configuration
PORT=3000

# Supabase Configuration (BACKEND ONLY - Uses SECRET KEYS)
# IMPORTANT: Use the SERVICE_ROLE SECRET key, NOT the anon key
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SECRET_KEY=your_service_role_secret_key_here

# JWT Secret for authentication tokens
JWT_SECRET=your-random-jwt-secret-change-in-production

# Plaid Configuration
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox

# OpenAI Configuration (Optional)
OPENAI_API_KEY=your_openai_api_key

# App Configuration
NODE_ENV=development
```

### 3. Get Supabase SECRET Key

1. Go to: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
2. Look for "**service_role secret**" (NOT anon/public key)
3. Copy it to your `.env` file as `SUPABASE_SECRET_KEY`

⚠️ **IMPORTANT**: This key has full admin access - NEVER expose it in frontend code!

### 4. Run the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The server will run on `http://localhost:3000`

## 📡 API Endpoints

### Authentication

#### POST `/api/auth/signup`
Sign up a new user

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "profile": {
    "username": "johndoe",
    "full_name": "John Doe",
    "school": "University",
    "age": 22
  }
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "username": "johndoe",
    ...
  }
}
```

#### POST `/api/auth/signin`
Sign in existing user

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    ...
  }
}
```

#### POST `/api/auth/signout`
Sign out user (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

#### GET `/api/auth/profile`
Get user profile (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

#### PUT `/api/auth/profile`
Update user profile (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "full_name": "John Updated",
  "school": "New University"
}
```

#### GET `/api/auth/user`
Get current authenticated user (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

### Plaid Integration

#### POST `/api/plaid/create-link-token`
Create Plaid Link token (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "link_token": "link-sandbox-..."
}
```

#### POST `/api/plaid/exchange-public-token`
Exchange Plaid public token for access token (requires auth token)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "public_token": "public-sandbox-..."
}
```

**Response:**
```json
{
  "success": true,
  "item_id": "item_id_here"
}
```

## 🔒 Security Features

### Supabase SECRET Key Usage
- ✅ Backend uses SECRET key for full admin access
- ✅ Bypasses Row Level Security (RLS) - backend controls access
- ✅ Can create users, manage auth, access all data
- ❌ Never exposed to frontend

### JWT Authentication
- Backend issues JWT tokens to authenticated users
- Frontend includes token in `Authorization: Bearer <token>` header
- Tokens expire after 7 days (configurable)

### Best Practices
1. **Never commit `.env` file** to git (already in `.gitignore`)
2. **Use strong JWT_SECRET** in production
3. **Enable HTTPS** in production
4. **Add rate limiting** for production
5. **Validate all inputs** server-side

## 🔄 Flutter Integration

Update Flutter app to use backend:

```dart
// In assets/.env
BACKEND_URL=http://localhost:3000  // Or your production URL

// In Flutter code
final response = await http.post(
  Uri.parse('${dotenv.env['BACKEND_URL']}/api/auth/signin'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({
    'email': email,
    'password': password,
  }),
);
```

## 🧪 Testing

### Test Signup
```bash
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
```

### Test Signin
```bash
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }'
```

## 📦 Deployment

### Environment Variables
Set these in your production environment:
- `PORT`
- `SUPABASE_URL`
- `SUPABASE_SECRET_KEY`
- `JWT_SECRET`
- `PLAID_CLIENT_ID`
- `PLAID_SECRET`
- `PLAID_ENVIRONMENT=production`

### Recommended Platforms
- **Heroku**: Easy deployment with environment variables
- **Railway**: Simple Node.js deployment
- **Vercel**: Serverless functions
- **AWS/GCP**: Full control

## 🐛 Troubleshooting

### "Invalid Supabase credentials"
- Make sure you're using the SERVICE_ROLE SECRET key, not anon key
- Check that SUPABASE_URL is correct

### "User not found"
- Ensure user exists in Supabase auth
- Check that profile was created in profiles table

### "Plaid error"
- Verify PLAID_CLIENT_ID and PLAID_SECRET are correct
- Check PLAID_ENVIRONMENT is set correctly (sandbox/production)

## 📝 License

Private and proprietary

