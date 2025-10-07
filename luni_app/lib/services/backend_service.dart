import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendService {
  // Backend API base URL - you'll need to set up a backend server
  static String get _backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
  
  // For development/testing with direct Supabase access (backend only)
  static String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get _supabaseSecretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';
  
  // Get Plaid credentials from .env file
  static String get _plaidClientId => dotenv.env['PLAID_CLIENT_ID'] ?? '';
  static String get _plaidSecret => dotenv.env['PLAID_SECRET'] ?? '';
  static String get _plaidEnvironment => dotenv.env['PLAID_ENVIRONMENT'] ?? 'sandbox';
  
  static String get _plaidBaseUrl {
    switch (_plaidEnvironment) {
      case 'production':
        return 'https://production.plaid.com';
      case 'development':
        return 'https://development.plaid.com';
      default:
        return 'https://sandbox.plaid.com';
    }
  }
  
  // Authentication - get current user from backend
  static Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Create link token endpoint (via backend)
  static Future<String> createLinkToken(String userId) async {
    try {
      print('Creating link token via backend');
      print('Using Plaid environment: $_plaidEnvironment');
      print('User ID: $userId');

      // Check if Plaid credentials are configured
      if (_plaidClientId.isEmpty || _plaidSecret.isEmpty) {
        throw Exception('Plaid credentials not configured. Please update .env file with your actual PLAID_CLIENT_ID, PLAID_SECRET, and PLAID_ENVIRONMENT.');
      }

      // Get user email from Supabase if available
      String userEmail = 'user@example.com';
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        if (user?.email != null) {
          userEmail = user!.email!;
        }
      } catch (e) {
        print('Could not get user email: $e');
      }

      // Create real link token using Plaid API
      final requestBody = {
        'client_id': _plaidClientId,
        'secret': _plaidSecret,
        'client_name': 'Luni App',
        'products': ['transactions'],
        'country_codes': ['US', 'CA'],
        'language': 'en',
        'user': {
          'client_user_id': userId,
          'email_address': userEmail,
        },
        // Add redirect URI for mobile OAuth banks
        'redirect_uri': 'lunifin://plaid-oauth',
      };
      
      print('Plaid request: ${json.encode(requestBody).replaceAll(_plaidSecret, '***')}');
      
      final response = await http.post(
        Uri.parse('$_plaidBaseUrl/link/token/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final linkToken = data['link_token'] as String;
        print('✅ Generated real link token: ${linkToken.substring(0, 20)}...');
        return linkToken;
      } else {
        final errorBody = json.decode(response.body);
        final errorCode = errorBody['error_code'] ?? 'UNKNOWN';
        final errorMessage = errorBody['error_message'] ?? response.body;
        final displayMessage = errorBody['display_message'] ?? errorMessage;
        
        print('❌ Plaid API error: ${response.statusCode}');
        print('Error code: $errorCode');
        print('Error message: $errorMessage');
        print('Display message: $displayMessage');
        
        throw Exception('Plaid error: $displayMessage');
      }
      
      // Production code would look like this:
      /*
      final response = await http.post(
        Uri.parse('$_backendUrl/create_link_token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.accessToken}',
        },
        body: json.encode({
          'user_id': user.id,
          'client_name': 'Luni App',
          'products': ['transactions', 'accounts'],
          'country_codes': ['US', 'CA'],
          'language': 'en',
          'user': {
            'client_user_id': user.id,
            'email': user.email,
          },
          'webhook': 'https://your-backend-url.com/webhook',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['link_token'] as String;
      } else {
        throw Exception('Failed to create link token: ${response.body}');
      }
      */
    } catch (e) {
      print('❌ Error creating link token: $e');
      // Don't return a fallback token - let the error propagate so user sees it
      rethrow;
    }
  }
  
  // Exchange public token endpoint (via backend)
  static Future<Map<String, dynamic>> exchangePublicToken(String publicToken) async {
    try {
      print('Exchanging public token via backend');
      print('Public token: ${publicToken.substring(0, 20)}...');

      // Check if Plaid credentials are configured
      if (_plaidClientId.isEmpty || _plaidSecret.isEmpty) {
        throw Exception('Plaid credentials not configured. Please update assets/.env file with your actual PLAID_CLIENT_ID, PLAID_SECRET, and PLAID_ENVIRONMENT. See UPDATE_PLAID_CREDENTIALS.md for instructions.');
      }

      // Exchange public token for access token using real Plaid API
      final response = await http.post(
        Uri.parse('$_plaidBaseUrl/item/public_token/exchange'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': _plaidClientId,
          'secret': _plaidSecret,
          'public_token': publicToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final itemId = data['item_id'] as String;
        
        print('Successfully exchanged public token for access token');
        
        // Get accounts using the access token
        final accountsResponse = await http.post(
          Uri.parse('$_plaidBaseUrl/accounts/get'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'client_id': _plaidClientId,
            'secret': _plaidSecret,
            'access_token': accessToken,
          }),
        );
        
        // Get transactions using the access token
        final transactionsResponse = await http.post(
          Uri.parse('$_plaidBaseUrl/transactions/get'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'client_id': _plaidClientId,
            'secret': _plaidSecret,
            'access_token': accessToken,
            'start_date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0],
            'end_date': DateTime.now().toIso8601String().split('T')[0],
          }),
        );
        
        final accountsData = accountsResponse.statusCode == 200 ? json.decode(accountsResponse.body) : {'accounts': []};
        final transactionsData = transactionsResponse.statusCode == 200 ? json.decode(transactionsResponse.body) : {'transactions': []};
        
        return {
          'access_token': accessToken,
          'item_id': itemId,
          'user_email': 'user@example.com',
          'accounts': accountsData['accounts'],
          'transactions': transactionsData['transactions'],
        };
      } else {
        print('Plaid API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to exchange public token: ${response.body}');
      }
    } catch (e) {
      print('Error exchanging public token: $e');
      throw e;
    }
  }
}
