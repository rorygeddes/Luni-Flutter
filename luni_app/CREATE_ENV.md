# Create .env File

## ✅ KEEP `.env` in `assets/` folder ONLY

### Step 1: Create the file

**Location:** `/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env`

**Method 1: Using Terminal**
```bash
cat > "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env" << 'EOF'
# Backend Configuration
BACKEND_URL=http://localhost:3000

# Supabase Configuration (Backend Only - Uses SECRET KEYS)
SUPABASE_URL=https://cpsjbwtezrnajaiolsim.supabase.co
SUPABASE_SECRET_KEY=your_actual_secret_key_here

# JWT Secret
JWT_SECRET=luni-jwt-secret-change-this-in-production-12345

# Plaid Configuration
PLAID_CLIENT_ID=68d58e80972f670024093ef0
PLAID_SECRET=810a68d605cbff90d5a4f487bd5f1f
PLAID_ENVIRONMENT=sandbox

# App Configuration
APP_ENVIRONMENT=development
PORT=3000
EOF
```

**Method 2: Create Manually**
1. Open Text Editor
2. Create new file
3. Copy the content above
4. Save as: `/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env`

### Step 2: Add Your Supabase SECRET Key

1. Go to: https://supabase.com/dashboard/project/cpsjbwtezrnajaiolsim/settings/api
2. Find "**service_role**" section
3. Copy the "**secret**" value (NOT anon key)
4. Replace `your_actual_secret_key_here` in the `.env` file

### Step 3: Verify

```bash
# Check file exists
ls -la "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env"

# View content (careful - contains secrets!)
cat "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env"
```

### Step 4: Start Backend

```bash
cd "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/backend"
npm start
```

## Why `assets/.env`?

✅ **Flutter reads it:** Already configured in `pubspec.yaml`  
✅ **Backend reads it:** Updated `server.js` to load from `../assets/.env`  
✅ **Single file:** One source of truth  
✅ **Git-ignored:** Secure, won't be committed  

## DELETE these locations:
- ❌ `luni_app/backend/.env` (if exists)
- ❌ `backend/.env` in project root (if exists)

## KEEP this location:
- ✅ `luni_app/assets/.env` (ONLY THIS ONE)

