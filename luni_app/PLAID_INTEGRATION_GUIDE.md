# Plaid Integration Guide

This guide explains how to implement real Plaid Link integration in the Luni Flutter app.

## Current Implementation

The app currently uses a **mock implementation** that simulates the Plaid Link flow for development purposes. This allows you to test the UI and data flow without needing actual Plaid credentials.

## Real Plaid Integration Steps

### 1. Backend Setup

You need to create a backend service with two endpoints:

#### Create Link Token Endpoint (`/create_link_token`)
```javascript
// Example Node.js/Express endpoint
app.post('/create_link_token', async (req, res) => {
  try {
    const { user_id } = req.body;
    
    const response = await fetch('https://production.plaid.com/link/token/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
      body: JSON.stringify({
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        client_name: 'Luni App',
        products: ['transactions', 'accounts'],
        country_codes: ['US', 'CA'],
        language: 'en',
        user: {
          client_user_id: user_id,
        },
      }),
    });
    
    const data = await response.json();
    res.json({ link_token: data.link_token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### Exchange Public Token Endpoint (`/exchange_public_token`)
```javascript
// Example Node.js/Express endpoint
app.post('/exchange_public_token', async (req, res) => {
  try {
    const { public_token, user_id } = req.body;
    
    // Exchange public token for access token
    const tokenResponse = await fetch('https://production.plaid.com/item/public_token/exchange', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
      body: JSON.stringify({
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        public_token: public_token,
      }),
    });
    
    const tokenData = await tokenResponse.json();
    const access_token = tokenData.access_token;
    
    // Fetch accounts
    const accountsResponse = await fetch('https://production.plaid.com/accounts/get', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
      body: JSON.stringify({
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        access_token: access_token,
      }),
    });
    
    const accountsData = await accountsResponse.json();
    
    // Fetch transactions
    const transactionsResponse = await fetch('https://production.plaid.com/transactions/get', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
      body: JSON.stringify({
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        access_token: access_token,
        start_date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        end_date: new Date().toISOString().split('T')[0],
      }),
    });
    
    const transactionsData = await transactionsResponse.json();
    
    res.json({
      access_token,
      item_id: tokenData.item_id,
      accounts: accountsData.accounts,
      transactions: transactionsData.transactions,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 2. Update Backend Service

Replace the mock implementation in `lib/services/backend_service.dart`:

```dart
// Update the _backendUrl constant
static const String _backendUrl = 'https://your-actual-backend-url.com';

// Update createLinkToken method
static Future<String> createLinkToken() async {
  final user = _supabase.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  final response = await http.post(
    Uri.parse('$_backendUrl/create_link_token'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${user.accessToken}',
    },
    body: json.encode({
      'user_id': user.id,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['link_token'] as String;
  } else {
    throw Exception('Failed to create link token: ${response.body}');
  }
}

// Update exchangePublicToken method
static Future<Map<String, dynamic>> exchangePublicToken(String publicToken) async {
  final user = _supabase.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  final response = await http.post(
    Uri.parse('$_backendUrl/exchange_public_token'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${user.accessToken}',
    },
    body: json.encode({
      'public_token': publicToken,
      'user_id': user.id,
    }),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to exchange public token: ${response.body}');
  }
}
```

### 3. Update PlaidService for Mobile

Replace the mock implementation in `lib/services/plaid_service.dart`:

```dart
// Update _launchPlaidLinkMobile method
static Future<void> _launchPlaidLinkMobile(
  String linkToken,
  Function(String) onSuccess,
  Function(String) onExit,
  Function(String) onEvent,
) async {
  try {
    final linkConfiguration = LinkTokenConfiguration(
      token: linkToken,
    );

    PlaidLink.open(
      linkConfiguration,
      onSuccess: (LinkSuccess success) {
        print('Plaid Link Success: ${success.publicToken}');
        onSuccess(success.publicToken ?? '');
      },
      onExit: (LinkExit exit) {
        print('Plaid Link Exit: ${exit.error?.displayMessage}');
        final reason = exit.error?.displayMessage ?? 'User cancelled';
        onExit(reason);
      },
      onEvent: (LinkEvent event) {
        print('Plaid Link Event: ${event.toString()}');
        onEvent(event.toString());
      },
    );
  } catch (e) {
    print('Error in mobile Plaid Link: $e');
    onExit('Mobile Plaid Link error: $e');
  }
}
```

### 4. Environment Variables

Set up your Plaid credentials:

```bash
# Backend environment variables
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret_key
PLAID_ENV=sandbox  # or production
```

### 5. Testing

1. **Sandbox Mode**: Use Plaid's sandbox environment for testing with fake bank accounts
2. **Production Mode**: Use real bank accounts (requires Plaid production approval)

## Current Mock Flow

The current implementation simulates:
- Link token creation
- Plaid Link opening/connecting
- Public token exchange
- Account and transaction data retrieval

This allows you to:
- Test the UI flow
- Verify database integration
- Develop features without Plaid credentials

## Next Steps

1. Set up your backend with Plaid credentials
2. Replace the mock implementations with real API calls
3. Test with Plaid's sandbox environment
4. Deploy to production when ready

The app is structured to make this transition seamless - just update the backend service URLs and uncomment the production code!
