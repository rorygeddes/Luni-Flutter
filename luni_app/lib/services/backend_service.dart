import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

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
      print('Plaid base URL: $_plaidBaseUrl');
      print('User ID: $userId');
      
          if (_plaidEnvironment == 'production') {
            print('⚠️  PRODUCTION MODE: Using real bank connections!');
            print('🇨🇦 Canadian banks supported: TD, RBC, Scotiabank, BMO, CIBC, National Bank, etc.');
          } else {
            print('🧪 ${_plaidEnvironment.toUpperCase()} MODE: Use test credentials');
            print('🇨🇦 Canadian test banks: Tangerine, Scotiabank, TD, RBC, BMO, CIBC');
          }

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
        'client_name': 'Luni',
        'products': ['transactions'],
        'country_codes': ['CA', 'US'], // Canada first, then US
        'language': 'en',
        'user': {
          'client_user_id': userId,
          'email_address': userEmail,
        },
        // OAuth redirect URI - only include for production (sandbox doesn't need OAuth for most banks)
        if (_plaidEnvironment == 'production') ...{
          'redirect_uri': 'https://rorygeddes.github.io/Luni-Flutter/plaid-oauth-site/',
          'webhook': 'https://api.luni.ca/plaid/webhook',
        },
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
        print('Item ID: $itemId');
        print('Access token: ${accessToken.substring(0, 20)}...');
        
        // Get accounts using the access token
        print('📊 Fetching accounts...');
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
        
        if (accountsResponse.statusCode != 200) {
          print('❌ Accounts error: ${accountsResponse.body}');
        }
        
        // Get transactions using the access token (90 days as per workflow.md and old_method.md)
        final startDate = DateTime.now().subtract(const Duration(days: 90)).toIso8601String().split('T')[0];
        final endDate = DateTime.now().toIso8601String().split('T')[0];
        
        print('📅 Fetching transactions from $startDate to $endDate (90 days)...');
        
        final transactionsResponse = await http.post(
          Uri.parse('$_plaidBaseUrl/transactions/get'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'client_id': _plaidClientId,
            'secret': _plaidSecret,
            'access_token': accessToken,
            'start_date': startDate,
            'end_date': endDate,
            'options': {
              'count': 500, // Get up to 500 transactions (from old_method.md)
              'offset': 0,
              'include_original_description': true,
            },
          }),
        );
        
        if (transactionsResponse.statusCode != 200) {
          print('❌ Transactions error: ${transactionsResponse.body}');
        } else {
          final transData = json.decode(transactionsResponse.body);
          print('📊 Retrieved ${transData['transactions']?.length ?? 0} transactions');
          print('Total transactions available: ${transData['total_transactions'] ?? 'unknown'}');
        }
        
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

  // Save Plaid accounts and transactions to Supabase
  static Future<void> savePlaidData({
    required String accessToken,
    required String itemId,
    required List<dynamic> accounts,
    required List<dynamic> transactions,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('💾 Saving Plaid data to Supabase...');

      // Save institution
      // Generate a unique ID for the institution
      final institutionId = 'inst_${DateTime.now().millisecondsSinceEpoch}';
      final institutionData = {
        'id': institutionId,
        'item_id': itemId,
        'user_id': user.id,
        'access_token': accessToken,
        'name': 'Connected Bank', // TODO: Get real institution name from Plaid
        'created_at': DateTime.now().toIso8601String(),
      };
      await supabase.from('institutions').upsert(institutionData);
      print('✅ Institution saved');

      // Save accounts
      for (final account in accounts) {
        final accountData = {
          'id': account['account_id'],
          'user_id': user.id,
          'institution_id': institutionId,
          'name': account['name'] ?? 'Unknown Account',
          'type': account['type'] ?? 'depository',
          'subtype': account['subtype'] ?? 'checking',
          'balance': account['balances']?['current'] ?? 0.0,
          'created_at': DateTime.now().toIso8601String(),
        };
        await supabase.from('accounts').upsert(accountData);
        print('✅ Account saved: ${accountData['name']}');
      }

      // Save transactions (uncategorized)
      if (transactions.isEmpty) {
        print('⚠️  No transactions returned from Plaid.');
        print('💡 This is normal for new accounts. Transactions will sync once available.');
      }
      
      if (transactions.isNotEmpty) {
        print('📝 Processing ${transactions.length} transactions...');
        for (final transaction in transactions) {
          try {
            final transactionData = {
              'id': transaction['transaction_id'],
              'user_id': user.id,
              'account_id': transaction['account_id'],
              'amount': (transaction['amount'] ?? 0.0) * -1, // Plaid uses positive for debits
              'description': transaction['name'] ?? 'Unknown',
              'merchant_name': transaction['merchant_name'],
              'date': transaction['date'] ?? DateTime.now().toIso8601String().split('T')[0],
              'category': null, // Will be set by AI
              'subcategory': null, // Will be set by AI
              // Note: is_categorized and is_split will be added after running SQL fix
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };
            await supabase.from('transactions').upsert(transactionData);
            print('  ✓ Saved: ${transactionData['description']} (\$${transactionData['amount']})');
          } catch (e) {
            print('  ✗ Error saving transaction: $e');
          }
        }
        print('✅ ${transactions.length} transactions saved');
      }

      print('🎉 Plaid data saved successfully!');
    } catch (e) {
      print('❌ Error saving Plaid data: $e');
      throw e;
    }
  }

  // Get user's accounts from Supabase
  static Future<List<Map<String, dynamic>>> getAccounts() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('accounts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      print('📊 Loaded ${response.length} accounts from database');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting accounts: $e');
      return [];
    }
  }

  // Get user's transactions from Supabase
  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .limit(limit);

      print('📊 Loaded ${response.length} transactions from database');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }

  // Get transactions for a specific account
  static Future<List<Map<String, dynamic>>> getTransactionsByAccount(String accountId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('account_id', accountId)
          .order('date', ascending: false);

      print('📊 Loaded ${response.length} transactions for account $accountId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting transactions for account: $e');
      return [];
    }
  }

  // Get uncategorized transactions for the queue
  static Future<List<Map<String, dynamic>>> getUncategorizedTransactions({int limit = 5}) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Try with is_categorized column first, fallback to category IS NULL
      try {
        final response = await supabase
            .from('transactions')
            .select()
            .eq('user_id', user.id)
            .eq('is_categorized', false)
            .order('date', ascending: false)
            .limit(limit);

        print('📋 Loaded ${response.length} uncategorized transactions for queue');
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        // Fallback: if is_categorized column doesn't exist, check if category is null
        print('⚠️  Using fallback query (is_categorized column not found)');
        final response = await supabase
            .from('transactions')
            .select()
            .eq('user_id', user.id)
            .isFilter('category', null)
            .order('date', ascending: false)
            .limit(limit);

        print('📋 Loaded ${response.length} uncategorized transactions for queue');
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('❌ Error getting uncategorized transactions: $e');
      return [];
    }
  }

  // Update transaction with AI categorization
  static Future<void> updateTransactionCategory({
    required String transactionId,
    required String category,
    required String subcategory,
    required String aiDescription,
    bool isSplit = false,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase
          .from('transactions')
          .update({
            'description': aiDescription,
            'category': category,
            'subcategory': subcategory,
            'is_categorized': true,
            'is_split': isSplit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId)
          .eq('user_id', user.id);

      print('✅ Transaction categorized: $transactionId');
    } catch (e) {
      print('❌ Error updating transaction: $e');
      throw e;
    }
  }

  // Sync new transactions for all connected accounts
  static Future<void> syncTransactions() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('🔄 Syncing transactions...');

      // Get all institutions (with access tokens)
      final institutions = await supabase
          .from('institutions')
          .select()
          .eq('user_id', user.id);

      if (institutions.isEmpty) {
        print('⚠️  No connected banks found');
        return;
      }

      int totalNewTransactions = 0;

      for (final institution in institutions) {
        final accessToken = institution['access_token'] as String?;
        if (accessToken == null) continue;

        final itemId = institution['item_id'] as String;
        print('📊 Syncing institution: ${institution['name']} ($itemId)');

        // Get transactions from last 30 days (for sync)
        final startDate = DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
        final endDate = DateTime.now().toIso8601String().split('T')[0];

        final response = await http.post(
          Uri.parse('$_plaidBaseUrl/transactions/get'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'client_id': _plaidClientId,
            'secret': _plaidSecret,
            'access_token': accessToken,
            'start_date': startDate,
            'end_date': endDate,
            'options': {
              'count': 500,
              'offset': 0,
            },
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final transactions = data['transactions'] as List<dynamic>;

          // Save new transactions
          int newCount = 0;
          for (final transaction in transactions) {
            try {
              final transactionData = {
                'id': transaction['transaction_id'],
                'user_id': user.id,
                'account_id': transaction['account_id'],
                'amount': (transaction['amount'] ?? 0.0) * -1,
                'description': transaction['name'] ?? 'Unknown',
                'merchant_name': transaction['merchant_name'],
                'date': transaction['date'] ?? DateTime.now().toIso8601String().split('T')[0],
                'category': null,
                'subcategory': null,
                // Note: is_categorized and is_split will be added after running SQL fix
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              };
              
              // Upsert (insert or update if exists)
              await supabase.from('transactions').upsert(transactionData);
              newCount++;
            } catch (e) {
              // Transaction might already exist, skip
            }
          }
          
          print('  ✅ Synced $newCount new transactions');
          totalNewTransactions += newCount;
        } else {
          print('  ❌ Error: ${response.body}');
        }
      }

      print('✅ Sync complete! $totalNewTransactions new transactions added');
    } catch (e) {
      print('❌ Error syncing transactions: $e');
      throw e;
    }
  }

  // Get all categories (default + user-created)
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get default categories (user_id IS NULL) + user's custom categories
      final response = await supabase
          .from('categories')
          .select()
          .or('user_id.is.null,user_id.eq.${user.id}')
          .eq('is_active', true)
          .order('parent_key')
          .order('name');

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      print('📂 Loaded ${categories.length} categories');
      return categories;
    } catch (e) {
      print('❌ Error getting categories: $e');
      return [];
    }
  }

  // Create a new category
  static Future<void> createCategory({
    required String parentKey,
    required String name,
    String? icon,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final categoryData = {
        'user_id': user.id,
        'parent_key': parentKey,
        'name': name,
        'icon': icon,
        'is_default': false,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('categories').insert(categoryData);
      print('✅ Category created: $name');
    } catch (e) {
      print('❌ Error creating category: $e');
      throw e;
    }
  }

  // Delete a category
  static Future<void> deleteCategory(String categoryId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', user.id); // Only delete user's own categories

      print('✅ Category deleted: $categoryId');
    } catch (e) {
      print('❌ Error deleting category: $e');
      throw e;
    }
  }

  // Get category spending summary (for home screen)
  static Future<Map<String, double>> getCategorySpending() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get last 30 days of categorized transactions
      // Fallback: use category IS NOT NULL if is_categorized column doesn't exist
      try {
        final response = await supabase
            .from('transactions')
            .select()
            .eq('user_id', user.id)
            .eq('is_categorized', true)
            .gte('date', DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0])
            .order('date', ascending: false);

        // Group by category and sum amounts
        final categoryMap = <String, double>{};
        for (final transaction in response) {
          final category = transaction['category'] as String?;
          if (category != null) {
            final amount = (transaction['amount'] ?? 0.0).toDouble().abs();
            categoryMap[category] = (categoryMap[category] ?? 0.0) + amount;
          }
        }

        print('📊 Category spending: $categoryMap');
        return categoryMap;
      } catch (e) {
        // Fallback query without is_categorized column
        print('⚠️  Using fallback query for category spending');
        final response = await supabase
            .from('transactions')
            .select()
            .eq('user_id', user.id)
            .not('category', 'is', null)
            .gte('date', DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0])
            .order('date', ascending: false);

        final categoryMap = <String, double>{};
        for (final transaction in response) {
          final category = transaction['category'] as String?;
          if (category != null) {
            final amount = (transaction['amount'] ?? 0.0).toDouble().abs();
            categoryMap[category] = (categoryMap[category] ?? 0.0) + amount;
          }
        }

        print('📊 Category spending: $categoryMap');
        return categoryMap;
      }
    } catch (e) {
      print('❌ Error getting category spending: $e');
      return {};
    }
  }
}
