# Update Plaid Credentials

To use your real Plaid credentials, update the `assets/.env` file.

## Update the assets/.env file
1. Edit the file `assets/.env` in your Flutter project
2. Replace the placeholder values with your actual Plaid credentials:

```
PLAID_CLIENT_ID=your_actual_client_id
PLAID_SECRET=your_actual_secret
PLAID_ENVIRONMENT=sandbox
```

## Testing with Plaid Sandbox
Once you have your credentials set up, you can test with:
- Username: `user_good`
- Password: `pass_good`

This will connect to Plaid's sandbox environment for testing.

## Note
The `.env` file is now located in the `assets/` folder so it can be loaded properly by Flutter Web.
