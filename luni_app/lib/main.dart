import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/luni_home_screen.dart';
import 'screens/track_screen.dart';
import 'screens/split_screen.dart';
import 'screens/social_screen.dart';
import 'screens/add_screen.dart';
import 'screens/budget_modal.dart';
import 'screens/wallet_modal.dart';
import 'screens/main_layout.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/transaction_provider.dart';
import 'services/navigation_service.dart';
import 'services/auth_service.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file in assets folder
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
    print('Plaid Client ID: ${dotenv.env['PLAID_CLIENT_ID']?.substring(0, 10)}...');
    print('Plaid Environment: ${dotenv.env['PLAID_ENVIRONMENT']}');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }
  
  // Initialize Supabase - credentials loaded from environment or config
  try {
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: AppConfig.supabaseUrl);
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: AppConfig.supabaseAnonKey);
    
    // Check if credentials are properly configured (not placeholder values)
    if (supabaseUrl.isNotEmpty && 
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.contains('supabase.co')) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('Supabase initialized successfully');
    } else {
      print('Warning: Supabase credentials not configured. Please update lib/config/app_config.dart');
    }
  } catch (e) {
    print('Warning: Could not initialize Supabase: $e');
  }
  
  runApp(const LuniApp());
}

class LuniApp extends StatelessWidget {
  const LuniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X design size - adjust based on your Figma design
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Luni App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AppInitializer(),
            navigatorKey: NavigationService.navigatorKey,
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        print('User signed in: ${session.user.email}');
        // Handle OAuth callback and create profile if needed
        await AuthService.handleOAuthCallback();
        // Navigate to main app if not already there
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainLayout(currentRoute: '/'),
            ),
          );
        }
      } else {
        print('User signed out');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if Supabase is initialized and user authentication status
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return const SignInScreen();
      }
      
      // User is authenticated, show main app
      return const MainLayout(currentRoute: '/');
    } catch (e) {
      // Supabase not initialized, show configuration screen
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Supabase Not Configured',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Please update lib/config/app_config.dart with your Supabase credentials.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'See SUPABASE_SETUP_INSTRUCTIONS.md for instructions',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }
}