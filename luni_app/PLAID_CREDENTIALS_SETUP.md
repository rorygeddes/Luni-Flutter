# Plaid Credentials Setup - URGENT

## Current Issue
Your Plaid credentials are **INVALID**. The app is failing because:
- Error: `INVALID_API_KEYS` - "invalid client_id or secret provided"
- Current credentials in `.env` file are not valid Plaid sandbox credentials

## Immediate Solution Required

### Step 1: Get Valid Plaid Credentials
1. Go to [https://dashboard.plaid.com/](https://dashboard.plaid.com/)
2. Sign up for a free account (if you don't have one)
3. Go to "Keys" section
4. Copy your **SANDBOX** credentials:
   - `client_id` (starts with letters/numbers)
   - `secret` (longer string)

### Step 2: Update Your .env File
Edit the file: `/Users/rorygeddes/Workspace/Vancouver/Luni Flutter/luni_app/assets/.env`

Update to your REAL Plaid sandbox credentials:
```
PLAID_CLIENT_ID=your_real_sandbox_client_id
PLAID_SECRET=your_real_sandbox_secret
PLAID_ENVIRONMENT=sandbox
```

### Step 3: Test
After updating, the app should work with Plaid's test credentials:
- Username: `user_good`
- Password: `pass_good`

## Why This Happened
The current credentials in your `.env` file are not valid Plaid API keys. They look like placeholder or invalid values that won't work with Plaid's API.

## Alternative: Use Demo Mode
If you want to test without real Plaid credentials, you can use the "Use Demo Account" button in the app, which simulates a bank connection without real API calls.
