# Environment Setup

## Create .env file

Create a file named `.env` in the `luni_app` folder with the following content:

```bash
# Backend Configuration
BACKEND_URL=http://localhost:3000

# Supabase Configuration (Frontend uses ANON key, Backend uses SECRET key)
SUPABASE_URL=https://cpsjbwtezrnajaiolsim.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SECRET_KEY=your_secret_key_here

# JWT Secret
JWT_SECRET=luni-jwt-secret-12345

# Plaid Configuration
PLAID_CLIENT_ID=68d58e80972f670024093ef0
PLAID_SECRET=810a68d605cbff90d5a4f487bd5f1f
PLAID_ENVIRONMENT=sandbox

# App Configuration
APP_ENVIRONMENT=development
PORT=3000
```

## Get your Supabase keys

1. Go to: https://supabase.com/dashboard/project/cpsjbwtezrnajaiolsim/settings/api
2. Copy the **anon/public** key and replace `your_anon_key_here`
3. Copy the **service_role** key and replace `your_secret_key_here`

## File Structure

```
luni_app/
├── .env                    # ← Create this file here
├── backend/
│   └── server.js          # ← Loads .env from parent directory
├── lib/
│   └── main.dart          # ← Loads .env from root directory
└── pubspec.yaml           # ← References .env in assets
```

## Testing

After creating the `.env` file:

1. Start backend: `cd luni_app/backend && npm start`
2. Start Flutter: `cd luni_app && flutter run -d chrome`
