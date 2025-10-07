👤 STEP 4 — Add Google Sign-In Button
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

final supabase = Supabase.instance.client;

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await supabase.auth.signInWithOAuth(
        Provider.google,
        // optional: for deep linking (mobile)
        redirectTo: 'io.supabase.luni://login-callback',
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text('Sign in with Google'),
          onPressed: () => _signInWithGoogle(context),
        ),
      ),
    );
  }
}

🔁 STEP 5 — Handle Redirect (Mobile vs Web)
🖥️ For Web

Supabase handles redirects automatically — no extra setup.

📱 For Android/iOS

You need a redirect scheme so Supabase can reopen your app after Google auth.

1️⃣ Android

Open android/app/src/main/AndroidManifest.xml, add:

<activity android:name="com.supabase.flutter.supabase_flutter_web.AuthCallbackActivity"
    android:exported="true">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="io.supabase.luni" android:host="login-callback"/>
    </intent-filter>
</activity>

2️⃣ iOS

Open ios/Runner/Info.plist, add:

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.luni</string>
    </array>
  </dict>
</array>


Use the same redirect scheme you set earlier:
redirectTo: 'io.supabase.luni://login-callback'.

🧩 STEP 6 — Get User Session

After successful login:

final user = supabase.auth.currentUser;
print('User email: ${user?.email}');


To listen for auth state changes:

supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  if (session != null) {
    print('User signed in: ${session.user.email}');
  } else {
    print('User signed out');
  }
});

🛠️ STEP 7 — Secure Database with Policies (Optional but Important)

In your Supabase SQL Editor, link user profiles:

CREATE POLICY "Users can view their own data"
ON profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
ON profiles
FOR INSERT WITH CHECK (auth.uid() = id);


This ensures each Google user can only access their own data.

🎨 Optional UX Touches

Use the Google Fonts or a real Google button design.

Store display_name, avatar_url from user.userMetadata.

Add “Continue as [name]” button after first login.

✅ Final Behavior Summary
Action	Result
User taps Google button	Opens browser or Google popup
Google Auth success	Redirects → Supabase verifies token
Supabase session created	User auto-signed in
Session persisted	Across app restarts
supabase.auth.currentUser	Always contains latest user