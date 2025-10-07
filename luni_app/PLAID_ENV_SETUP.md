# Plaid Environment Setup

To use your real Plaid credentials, create a `.env` file in the root of your Flutter project (`/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/.env`) with the following content:

```
# Plaid API Credentials
PLAID_CLIENT_ID=your_plaid_client_id_here
PLAID_SECRET=your_plaid_secret_here
PLAID_ENVIRONMENT=sandbox
```

Replace the placeholder values with your actual Plaid credentials:

1. `PLAID_CLIENT_ID` - Your Plaid client ID
2. `PLAID_SECRET` - Your Plaid secret key
3. `PLAID_ENVIRONMENT` - Set to `sandbox` for development, `development` for testing, or `production` for live

## Example:
```
PLAID_CLIENT_ID=12345678901234567890123456789012
PLAID_SECRET=abcdef1234567890abcdef1234567890
PLAID_ENVIRONMENT=sandbox
```

## Important Notes:
- The `.env` file is already added to `.gitignore` for security
- Make sure to use sandbox credentials for development
- Never commit your `.env` file to version control

Once you've created the `.env` file with your credentials, the app will use real Plaid API calls instead of mock data.
