# Luni Plaid OAuth Redirect

This is the OAuth redirect page for Luni's Plaid integration.

## Purpose

This page handles the OAuth callback from banks during the Plaid Link flow. When users connect their bank accounts, some banks require OAuth authentication which redirects to this page.

## How it works

1. User connects bank in Luni app
2. Plaid Link opens and user authenticates with bank
3. Bank redirects to this page with OAuth state
4. This page completes the Plaid Link flow
5. Page redirects back to Luni app with success/error

## Deployment

This page is deployed on GitHub Pages and accessible at:
`https://rorygeddes.github.io/Luni-Flutter/plaid-oauth-site/`

## Configuration

Update your Plaid Dashboard with the redirect URI:
`https://rorygeddes.github.io/Luni-Flutter/plaid-oauth-site/`

## Files

- `index.html` - The main OAuth redirect page
- `README.md` - This documentation

## Security

This page:
- Handles OAuth state validation
- Stores tokens temporarily for redirect
- Provides secure callback to mobile app
- Includes error handling for all failure cases
