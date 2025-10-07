// Copy this file to app_config.dart and fill in your credentials
// DO NOT commit app_config.dart to version control

class AppConfig {
  // Development configuration - these should be set via environment variables
  // DO NOT commit real credentials to version control
  
  // For development, you can temporarily set these here, but remember to:
  // 1. Never commit them to git
  // 2. Use environment variables in production
  // 3. Consider using a backend proxy for sensitive operations
  
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE'; // Replace with your actual Supabase URL
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE'; // Replace with your actual Supabase anon key
  
  // Production should use:
  // flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
}
