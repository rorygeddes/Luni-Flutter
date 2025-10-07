✅ Plaid OAuth + Flutter Integration — Complete Developer To-Do List
🧩 0. Pre-Setup (Plaid Dashboard)

Go to Plaid Dashboard → Team Settings → API Keys

Ensure you have:

✅ client_id

✅ secret

✅ sandbox environment enabled

If rotating secrets: wait until rotation in progress ends before deploying new code.

Under Allowed Android package names, add your Flutter app ID (e.g., com.luni.app).

Under Allowed redirect URIs, add:

https://yourdomain.com/oauth.html


(or a localhost URL for testing, e.g., http://localhost:5000/oauth.html)

🔒 1. Backend Setup (Flask or Supabase Edge)

Plaid requires a backend to securely handle tokens.

1.1. Install SDK
pip install plaid-python flask

1.2. Create .env
PLAID_CLIENT_ID=your_client_id
PLAID_SECRET=your_secret
PLAID_ENV=sandbox
PLAID_REDIRECT_URI=https://yourdomain.com/oauth.html

1.3. Create /create_link_token endpoint
@app.route('/create_link_token', methods=['POST'])
def create_link_token():
    try:
        response = client.LinkToken.create({
            'user': {'client_user_id': str(uuid.uuid4())},
            'client_name': 'Luni',
            'products': ['transactions'],
            'country_codes': ['CA'],  # or ['US'] if testing OAuth in sandbox
            'language': 'en',
            'redirect_uri': os.getenv('PLAID_REDIRECT_URI'),
        })
        return jsonify({'link_token': response['link_token']})
    except Exception as e:
        return jsonify({'error': str(e)})

1.4. Create /exchange_public_token endpoint
@app.route('/exchange_public_token', methods=['POST'])
def exchange_public_token():
    public_token = request.json['public_token']
    exchange_response = client.Item.public_token.exchange(public_token)
    access_token = exchange_response['access_token']
    return jsonify({'access_token': access_token})

📱 2. Flutter Setup
2.1. Install package

Add to pubspec.yaml:

flutter_plaid_link: ^3.1.0
http: ^1.2.0


Run:

flutter pub get

2.2. Android Configuration

In android/app/src/main/AndroidManifest.xml add inside <activity>:

<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https"
        android:host="yourdomain.com"
        android:path="/oauth.html" />
</intent-filter>


Also add your package name (com.luni.app) to Plaid Dashboard under Allowed Android package names.

2.3. iOS Configuration

In ios/Runner/Info.plist, add:

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>https</string>
    </array>
  </dict>
</array>


Enable Associated Domains:

applinks:yourdomain.com


Host an Apple App Association File at:

https://yourdomain.com/.well-known/apple-app-site-association

2.4. Flutter Code Example
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_plaid_link/flutter_plaid_link.dart';

Future<void> connectBankAccount() async {
  final response = await http.post(Uri.parse('https://your-backend.com/create_link_token'));
  final linkToken = jsonDecode(response.body)['link_token'];

  final onSuccess = (PublicToken publicToken, Metadata metadata) async {
    final exchangeRes = await http.post(
      Uri.parse('https://your-backend.com/exchange_public_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'public_token': publicToken.publicToken}),
    );
    print('Access token: ${exchangeRes.body}');
  };

  final onExit = (LinkExit exit) {
    print('Plaid exit: ${exit.error?.displayMessage}');
  };

  final config = LinkConfiguration(
    token: linkToken,
    onSuccess: onSuccess,
    onExit: onExit,
  );

  await PlaidLink.open(configuration: config);
}

🌐 3. OAuth Redirect Page

Create a simple page: oauth.html

<!DOCTYPE html>
<html>
  <head><title>Plaid OAuth Redirect</title></head>
  <body>
    <script>
      const linkToken = localStorage.getItem('link_token');
      const handler = Plaid.create({
        token: linkToken,
        receivedRedirectUri: window.location.href,
        onSuccess: function(public_token) {
          fetch("/exchange_public_token", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({ public_token }),
          }).then(() => window.location.href = "/success");
        },
      });
      handler.open();
    </script>
  </body>
</html>


✅ This lets OAuth-enabled banks redirect users back to your app to complete the Link flow.

🧪 4. Test in Sandbox

Use First Platypus Bank - OAuth App2App (ins_132241) for testing App-to-App.

Use dummy credentials or leave blank — Sandbox accepts any login.

Check Plaid Dashboard → Logs to confirm connection succeeded.

Retrieve transactions with:

client.Transactions.get(access_token, start_date, end_date)

🚀 5. Production Readiness Checklist

 Backend uses https (required for OAuth)

 Redirect URI registered in Plaid Dashboard

 OAuth tested for both iOS and Android

 Tokens stored securely (not in frontend)

 Security questionnaire submitted (for US OAuth)

 App metadata completed (name, logo, support email)

 Plaid MSA signed and approved

 Use new secret (after “rotation in progress” finishes)