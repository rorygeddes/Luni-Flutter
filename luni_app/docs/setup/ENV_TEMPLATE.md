# Environment Variables Template

Create a file named `.env` in the `assets/` folder with the following content:

```bash
# Backend Configuration
BACKEND_URL=http://localhost:3000

# Supabase Configuration (Backend Only - Uses SECRET KEYS)
# These credentials are used by the BACKEND, not the Flutter app directly
# IMPORTANT: Use SECRET keys here, NOT anon keys
SUPABASE_URL=your_supabase_url_here
SUPABASE_SECRET_KEY=your_supabase_secret_key_here

# Plaid Configuration
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox  # sandbox, development, or production

# OpenAI Configuration (Optional)
OPENAI_API_KEY=your_openai_api_key

# App Configuration
APP_ENVIRONMENT=development
```

## Important Notes:

### Supabase Keys
- **USE SECRET KEY** (not anon key) in the `.env` file
- Secret key is for backend use only
- Get it from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
- Look for "service_role secret" key

### Backend URL
- For development: `http://localhost:3000`
- For production: Your deployed backend URL

### Security
- **NEVER commit the `.env` file to git**
- The `.env` file is already in `.gitignore`
- Secret keys should ONLY be in backend/server code

