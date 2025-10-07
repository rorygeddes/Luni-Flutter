import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend Authentication Service
/// Handles all authentication through a backend API that uses Supabase secret keys
class BackendAuthService {
  static String get _backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
  
  static String? _currentToken;
  static Map<String, dynamic>? _currentUser;
  
  // Get current auth token
  static String? get currentToken => _currentToken;
  
  // Get current user
  static Map<String, dynamic>? get currentUser => _currentUser;
  
  // Sign in with email and password
  static Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentToken = data['token'];
        _currentUser = data['user'];
        return {'success': true, 'user': data['user']};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Sign in failed'};
      }
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
  
  // Sign up with email and password
  static Future<Map<String, dynamic>> signUpWithEmailPassword(
    String email,
    String password,
    Map<String, dynamic> profile,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'profile': profile,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentToken = data['token'];
        _currentUser = data['user'];
        return {'success': true, 'user': data['user']};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Sign up failed'};
      }
    } catch (e) {
      print('Sign up error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
  
  // Sign in with Google (OAuth)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Step 1: Get Google OAuth URL from backend
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/google/url'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // TODO: Open OAuth URL in browser/webview and handle callback
        return {'success': true, 'authUrl': data['url']};
      } else {
        return {'success': false, 'error': 'Failed to get Google auth URL'};
      }
    } catch (e) {
      print('Google sign in error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
  
  // Handle Google OAuth callback
  static Future<Map<String, dynamic>> handleGoogleCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/google/callback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentToken = data['token'];
        _currentUser = data['user'];
        return {'success': true, 'user': data['user']};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? 'OAuth callback failed'};
      }
    } catch (e) {
      print('Google callback error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      if (_currentToken != null) {
        await http.post(
          Uri.parse('$_backendUrl/api/auth/signout'),
          headers: {
            'Authorization': 'Bearer $_currentToken',
          },
        );
      }
    } catch (e) {
      print('Sign out error: $e');
    } finally {
      _currentToken = null;
      _currentUser = null;
    }
  }
  
  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (_currentToken == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $_currentToken',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }
  
  // Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_currentToken == null) return false;
    
    try {
      final response = await http.put(
        Uri.parse('$_backendUrl/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $_currentToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updates),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
  
  // Check if user is authenticated
  static bool get isAuthenticated => _currentToken != null && _currentUser != null;
}

