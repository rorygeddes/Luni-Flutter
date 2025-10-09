import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _userKey = 'current_user';

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Check if username is available
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      print('Checking username availability for: $username');
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      print('Username check response: $response');
      return response == null;
    } catch (e) {
      print('Error checking username availability: $e');
      // If there's an error, assume username is available to avoid blocking signup
      return true;
    }
  }

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      print('Starting sign-up process for: $email');
      
      // First check if username is available
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user in auth.users with email auto-confirm
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email confirmation for development
        data: {
          'full_name': fullName,
          'username': username,
        },
      );

      print('Sign-up response: ${response.user?.id}');
      print('User email: ${response.user?.email}');
      print('User metadata: ${response.user?.userMetadata}');
      print('Session: ${response.session != null ? "Active" : "None"}');

      if (response.user != null) {
        print('User created successfully');
        
        // Save user to local storage
        await _saveUserToLocal(response.user!);
        
        // Wait for the database trigger to create the profile
        print('Waiting for database trigger to create profile...');
        await Future.delayed(const Duration(seconds: 2));
        
        // Verify profile was created
        final profile = await getUserProfile(response.user!.id);
        if (profile != null) {
          print('Profile created successfully: ${profile.username}');
        } else {
          print('Warning: Profile may not have been created by trigger');
        }
      }

      return response;
    } catch (e) {
      print('Sign-up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _saveUserToLocal(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearUserFromLocal();
    } catch (e) {
      rethrow;
    }
  }

  // Wait for user to be fully committed to database
  static Future<void> _waitForUserCommitment(User user) async {
    print('Waiting for user commitment...');
    
    // Wait a fixed amount of time for user to be committed
    // This is more reliable than trying to query auth.users directly
    await Future.delayed(const Duration(seconds: 3));
    
    print('User commitment wait completed');
  }

  // Create user profile with real data
  static Future<void> _createUserProfile(User user, String fullName, String username) async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        final userModel = UserModel(
          id: user.id,
          email: user.email,
          fullName: fullName,
          username: username,
          avatarUrl: null, // Will be null initially
        );

        await _supabase
            .from('profiles')
            .insert(userModel.toJson());

        print('Profile created successfully for user: ${user.id}');
        return; // Success, exit the retry loop
      } catch (e) {
        attempts++;
        print('Profile creation attempt $attempts failed: $e');
        
        if (attempts >= maxAttempts) {
          print('Profile creation failed after $maxAttempts attempts');
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
  }

  // Save user to local storage
  static Future<void> _saveUserToLocal(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.id);
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear user from local storage
  static Future<void> _clearUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get user profile with real data
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId) // Fixed: profiles.id is the primary key, not user_id
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from('profiles')
          .update(user.toJson())
          .eq('id', user.id); // Fixed: profiles.id is the primary key, not user_id
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      print('❌ No current user in auth');
      return null;
    }
    
    print('🔐 Auth user ID: ${user.id}');
    print('🔐 Auth user email: ${user.email}');
    
    final profile = await getUserProfile(user.id);
    
    if (profile != null) {
      print('✅ Profile loaded: ${profile.username} (${profile.fullName}) - Email: ${profile.email}');
    } else {
      print('❌ No profile found for user ID: ${user.id}');
    }
    
    return profile;
  }

  // Sign in with Google OAuth
  static Future<void> signInWithGoogle() async {
    try {
      // Use platform-specific redirect URLs
      // For mobile: use deep link scheme
      // For web: Supabase handles automatically
      final redirectUrl = kIsWeb 
          ? null  // Web: automatic handling by Supabase
          : 'io.supabase.luni://login-callback';  // Mobile: deep link
      
      print('Google OAuth redirect URL: $redirectUrl');
      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  // Handle OAuth callback and create profile if needed
  static Future<void> handleOAuthCallback() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Check if profile exists
      final profile = await getUserProfile(user.id);
      
      if (profile == null) {
        // Create profile from Google user metadata
        final fullName = user.userMetadata?['full_name'] as String? ?? 
                        user.userMetadata?['name'] as String? ?? 
                        'User';
        final email = user.email ?? '';
        final avatarUrl = user.userMetadata?['avatar_url'] as String? ?? 
                         user.userMetadata?['picture'] as String?;
        
        // Generate username from email or name
        String username = email.split('@')[0].toLowerCase();
        username = username.replaceAll(RegExp(r'[^a-z0-9_]'), '');
        
        // Ensure username is unique
        int counter = 1;
        String finalUsername = username;
        while (!await isUsernameAvailable(finalUsername)) {
          finalUsername = '${username}_$counter';
          counter++;
        }

        // Create profile
        await _createUserProfile(user, fullName, finalUsername);
        
        // Update user metadata with avatar if available
        if (avatarUrl != null) {
          final userModel = await getUserProfile(user.id);
          if (userModel != null) {
            await updateUserProfile(userModel.copyWith(avatarUrl: avatarUrl));
          }
        }
      }
    } catch (e) {
      print('Error handling OAuth callback: $e');
    }
  }
}
