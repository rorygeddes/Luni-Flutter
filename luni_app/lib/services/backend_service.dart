import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'openai_service.dart';

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
          final currentBalance = account['balances']?['current'] ?? 0.0;
          final accountType = account['type'] ?? 'depository';
          final accountSubtype = account['subtype'] ?? 'checking';
          
          // For credit cards, make the balance negative (debt)
          // For all accounts, ensure opening balance is set correctly
          final isCreditCard = accountType == 'credit' || accountSubtype == 'credit card';
          final adjustedBalance = isCreditCard && currentBalance > 0 ? -currentBalance : currentBalance;
          final adjustedOpeningBalance = isCreditCard && currentBalance > 0 ? -currentBalance : currentBalance;
          
          final accountData = {
            'id': account['account_id'],
            'user_id': user.id,
            'institution_id': institutionId,
            'name': account['name'] ?? 'Unknown Account',
            'type': accountType,
            'subtype': accountSubtype,
            'balance': adjustedBalance,
            'currency': account['balances']?['iso_currency_code'] ?? 'CAD',
            'opening_balance': adjustedOpeningBalance, // Set opening balance (negative for credit cards)
            'opening_balance_date': DateTime.now().toIso8601String(), // Mark this as the starting point
            'created_at': DateTime.now().toIso8601String(),
          };
          await supabase.from('accounts').upsert(accountData);
          print('✅ Account saved: ${accountData['name']} (${isCreditCard ? 'Credit Card' : 'Depository'}) - Balance: \$${adjustedBalance}');
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
              'original_currency': transaction['iso_currency_code'] ?? 'CAD',
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

        // Calculate dynamic balance for each account with currency conversion
        List<Map<String, dynamic>> accountsWithDynamicBalance = [];
        String baseCurrency = 'CAD'; // Default base currency
        
        for (final account in response) {
          String accountId = account['id'];
          String accountCurrency = account['currency'] ?? 'CAD';
          
          print('🔍 DEBUG: Processing account ${account['name']} (ID: $accountId) with currency $accountCurrency');
          
          // Calculate dynamic balance in the account's original currency
          double dynamicBalance = await calculateDynamicBalance(accountId, accountCurrency);
          
          print('🔍 Account ${account['name']}: balance=\$${dynamicBalance.toStringAsFixed(2)}, currency=$accountCurrency, baseCurrency=$baseCurrency');
          
          // Convert to CAD for display if needed
          double balanceInCAD = dynamicBalance;
          if (accountCurrency != baseCurrency) {
            final exchangeRate = await getExchangeRate(accountCurrency, baseCurrency);
            balanceInCAD = dynamicBalance * exchangeRate;
            print('💱 Account ${account['name']}: \$${dynamicBalance.toStringAsFixed(2)} ${accountCurrency} → \$${balanceInCAD.toStringAsFixed(2)} ${baseCurrency} (rate: $exchangeRate)');
          } else {
            print('💰 Account ${account['name']}: No conversion needed (already in ${baseCurrency})');
          }
          
          // Update the account with CAD balance for display
          account['balance'] = balanceInCAD;
          account['original_balance'] = dynamicBalance; // Keep original for reference
          account['display_currency'] = baseCurrency; // Show CAD
          accountsWithDynamicBalance.add(account);
        }

      print('📊 Loaded ${accountsWithDynamicBalance.length} accounts from database with dynamic balances');
      return accountsWithDynamicBalance;
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

  // Get transactions for a specific category/subcategory
  static Future<List<TransactionModel>> getTransactionsByCategory(
    String subcategoryName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('subcategory', subcategoryName)
          .eq('is_categorized', true); // Only include categorized transactions

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('date', ascending: false);

      print('📊 Loaded ${response.length} categorized transactions for $subcategoryName');
      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting transactions for category: $e');
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

          // Save new transactions with duplicate detection
          int newCount = 0;
          int duplicatesDetected = 0;
          
          for (final transaction in transactions) {
            try {
              final transactionId = transaction['transaction_id'];
              final accountId = transaction['account_id'];
              final amount = (transaction['amount'] ?? 0.0) * -1;
              final description = transaction['name'] ?? 'Unknown';
              final date = transaction['date'] ?? DateTime.now().toIso8601String().split('T')[0];
              
              // Check if transaction already exists (exact match by ID)
              final existingById = await supabase
                  .from('transactions')
                  .select('id')
                  .eq('id', transactionId)
                  .maybeSingle();
              
              if (existingById != null) {
                print('  ⏭️  Skipped (already exists): $description (\$$amount)');
                continue;
              }
              
              // Check for potential duplicates (same account, amount, description, within 3 days)
              final potentialDuplicates = await supabase
                  .rpc('find_potential_duplicates', params: {
                    'p_account_id': accountId,
                    'p_date': date,
                    'p_amount': amount,
                    'p_description': description,
                    'p_transaction_id': transactionId,
                  });
              
              bool isPotentialDuplicate = false;
              String? duplicateOfId;
              
              if (potentialDuplicates != null && potentialDuplicates.isNotEmpty) {
                final firstMatch = potentialDuplicates[0];
                final matchScore = firstMatch['match_score'] ?? 0;
                
                // If match score >= 80, flag as potential duplicate
                if (matchScore >= 80) {
                  isPotentialDuplicate = true;
                  duplicateOfId = firstMatch['id'];
                  duplicatesDetected++;
                  print('  🚨 Potential duplicate detected: $description (\$$amount) - Match score: $matchScore');
                }
              }
              
              final transactionData = {
                'id': transactionId,
                'user_id': user.id,
                'account_id': accountId,
                'amount': amount,
                'original_currency': transaction['iso_currency_code'] ?? 'CAD',
                'description': description,
                'merchant_name': transaction['merchant_name'],
                'date': date,
                'category': null,
                'subcategory': null,
                'is_potential_duplicate': isPotentialDuplicate,
                'duplicate_of_transaction_id': duplicateOfId,
                'duplicate_checked_at': isPotentialDuplicate ? DateTime.now().toIso8601String() : null,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              };
              
              // Insert transaction (with duplicate flag if applicable)
              await supabase.from('transactions').insert(transactionData);
              
              if (isPotentialDuplicate) {
                print('  ⚠️  Added with duplicate flag: $description (\$$amount)');
              } else {
                print('  ✅ Saved: $description (\$$amount) on $date');
              }
              
              newCount++;
            } catch (e) {
              print('  ⚠️  Error processing transaction: $e');
            }
          }
          
          print('  ✅ Synced $newCount new transactions ($duplicatesDetected potential duplicates flagged)');
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

      print('📂 BackendService: Fetching categories for user ${user.id}');

      // Get default categories (user_id IS NULL) + user's custom categories
      final response = await supabase
          .from('categories')
          .select()
          .or('user_id.is.null,user_id.eq.${user.id}')
          .eq('is_active', true)
          .order('parent_key')
          .order('name');

      print('📂 BackendService: Raw response count: ${(response as List).length}');

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      print('📂 BackendService: Loaded ${categories.length} categories');
      if (categories.isNotEmpty) {
        print('📂 First 5 categories:');
        for (var i = 0; i < categories.length && i < 5; i++) {
          print('   - ${categories[i].name} (parent: ${categories[i].parentKey})');
        }
      }
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

  // Get exchange rate from API (free tier)
  static Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      if (fromCurrency == toCurrency) return 1.0;
      
      // Using a more reliable free exchange rate API
      final response = await http.get(
        Uri.parse('https://api.fxratesapi.com/latest?base=$fromCurrency&symbols=$toCurrency'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 DEBUG: Exchange rate API response: $data');
        
        // Check if the response has the expected structure
        if (data != null && data['rates'] != null && data['rates'][toCurrency] != null) {
          final rate = data['rates'][toCurrency];
          print('💱 Exchange rate $fromCurrency to $toCurrency: $rate');
          return rate.toDouble();
        } else {
          print('⚠️  Exchange rate API returned unexpected format: $data');
        }
      } else {
        print('❌ Exchange rate API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting exchange rate: $e');
    }
    
    // Fallback to a reasonable USD to CAD rate if API fails
    if (fromCurrency == 'USD' && toCurrency == 'CAD') {
      print('🔄 Using fallback USD to CAD rate: 1.37');
      return 1.37;
    }
    
    return 1.0; // Fallback to 1:1 for other currencies
  }

  // Calculate dynamic balance for an account based on opening balance + new transactions
  static Future<double> calculateDynamicBalance(String accountId, String baseCurrency) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('🔍 DEBUG: Calculating balance for account $accountId with base currency $baseCurrency');
      
      // Get account info including opening balance and date
      final accountResponse = await supabase
          .from('accounts')
          .select('currency, opening_balance, opening_balance_date, name')
          .eq('id', accountId)
          .single();
      
      final accountCurrency = accountResponse['currency'] ?? 'CAD';
      double openingBalance = accountResponse['opening_balance'] ?? 0.0;
      final openingBalanceDateStr = accountResponse['opening_balance_date'];
      final accountName = accountResponse['name'] ?? 'Unknown';
      
      print('🔍 DEBUG: Raw data for $accountName - currency: $accountCurrency, opening_balance: $openingBalance, date: $openingBalanceDateStr');
      
      // Convert opening balance to base currency if needed
      if (accountCurrency != baseCurrency) {
        final exchangeRate = await getExchangeRate(accountCurrency, baseCurrency);
        print('🔍 DEBUG: Converting $openingBalance $accountCurrency to $baseCurrency using rate $exchangeRate');
        openingBalance = openingBalance * exchangeRate;
        print('🔍 DEBUG: Converted opening balance: $openingBalance $baseCurrency');
      } else {
        print('🔍 DEBUG: No conversion needed - already in $baseCurrency');
      }
      
      // If no opening balance date is set, return the opening balance only
      if (openingBalanceDateStr == null) {
        print('💰 Dynamic balance for account $accountId: \$${openingBalance.toStringAsFixed(2)} $baseCurrency (opening balance only, no date set)');
        return openingBalance;
      }
      
      DateTime openingBalanceDate;
      try {
        openingBalanceDate = DateTime.parse(openingBalanceDateStr);
      } catch (e) {
        print('⚠️  Invalid opening balance date for account $accountId: $openingBalanceDateStr');
        print('💰 Dynamic balance for account $accountId: \$${openingBalance.toStringAsFixed(2)} $baseCurrency (opening balance only, invalid date)');
        return openingBalance;
      }
      
      // Get only transactions ON OR AFTER the opening balance date (applies to ALL account types)
      // Use the date part only to ensure we include the full opening balance date
      final openingDateOnly = openingBalanceDate.toIso8601String().split('T')[0];
      final transactions = await supabase
          .from('transactions')
          .select('amount, original_currency, date')
          .eq('account_id', accountId)
          .gte('date', openingDateOnly); // Transactions on or after opening balance date
      
      print('🔍 Found ${transactions.length} transactions after opening balance date for account $accountId');
      
      double newTransactionsTotal = 0.0;
      
      for (final transaction in transactions) {
        double amount = transaction['amount'] ?? 0.0;
        String transactionCurrency = transaction['original_currency'] ?? accountCurrency;
        
        // Convert to base currency if needed
        if (transactionCurrency != baseCurrency) {
          final exchangeRate = await getExchangeRate(transactionCurrency, baseCurrency);
          amount = amount * exchangeRate;
        }
        
        newTransactionsTotal += amount;
      }
      
      final totalBalance = openingBalance + newTransactionsTotal;
      
      // For credit cards, we want to maintain the negative balance internally
      // but display positive numbers in red to the user
      print('💰 Dynamic balance for account $accountId: \$${totalBalance.toStringAsFixed(2)} $baseCurrency');
      print('   📊 Opening balance: \$${openingBalance.toStringAsFixed(2)} $baseCurrency');
      print('   📈 New transactions: \$${newTransactionsTotal.toStringAsFixed(2)} $baseCurrency (${transactions.length} transactions)');
      print('   🧮 Total: \$${openingBalance.toStringAsFixed(2)} + \$${newTransactionsTotal.toStringAsFixed(2)} = \$${totalBalance.toStringAsFixed(2)}');
      return totalBalance;
    } catch (e) {
      print('❌ Error calculating dynamic balance: $e');
      return 0.0;
    }
  }

  // Get "All" account with combined balance and transactions
  static Future<Map<String, dynamic>> getAllAccount() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get all accounts with currency info
      final accounts = await supabase
          .from('accounts')
          .select('id, balance, type, subtype, currency, name')
          .eq('user_id', user.id);
          
      print('🔍 BackendService: Found ${accounts.length} accounts for combined balance');

      // Calculate combined balance with currency conversion
      double combinedBalance = 0.0;
      String baseCurrency = 'CAD'; // Default base currency
      
      for (final account in accounts) {
        String accountId = account['id'];
        String accountName = account['name'] ?? 'Unknown';
        String accountType = account['type'] ?? 'depository';
        String accountSubtype = account['subtype'] ?? 'checking';
        String accountCurrency = account['currency'] ?? 'CAD';
        
        print('🔍 DEBUG: Processing account $accountName (ID: $accountId) for combined balance');
        
        // Calculate dynamic balance from transactions (already converted to CAD)
        double dynamicBalanceInCAD = await calculateDynamicBalance(accountId, baseCurrency);
        
        print('  - Account $accountName: \$${dynamicBalanceInCAD.toStringAsFixed(2)} $baseCurrency (${accountType}/${accountSubtype}) [${accountCurrency}]');
        
        // The dynamic balance is already in CAD, so no additional conversion needed
        // For credit cards, balance is negative (debt) - subtract from combined balance
        // For checking/savings, balance is positive (money available) - add to combined balance
        if (accountType == 'credit' || accountSubtype == 'credit card') {
          combinedBalance += dynamicBalanceInCAD; // Credit card debt is negative, so this subtracts
        } else {
          combinedBalance += dynamicBalanceInCAD; // Checking/savings is positive, so this adds
        }
      }
      
      print('💰 BackendService: Combined balance = \$${combinedBalance.toStringAsFixed(2)} $baseCurrency');

      // Get total transaction count
      final transactionCount = await supabase
          .from('transactions')
          .select('id')
          .eq('user_id', user.id)
          .count();

      return {
        'id': 'all_accounts',
        'user_id': user.id,
        'institution_id': 'combined_institution',
        'name': 'All Accounts',
        'type': 'combined',
        'subtype': 'all',
        'balance': combinedBalance,
        'currency': baseCurrency,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting all account: $e');
      throw e;
    }
  }

  // Get transactions for "All" account (from all accounts)
  static Future<List<Map<String, dynamic>>> getAllAccountTransactions({int limit = 50}) async {
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

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting all account transactions: $e');
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

  // Get uncategorized transactions with potential duplicates prioritized
  static Future<List<Map<String, dynamic>>> getUncategorizedTransactionsWithPriority() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get potential duplicates first (high priority)
      final duplicates = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('is_potential_duplicate', true)
          .order('duplicate_checked_at', ascending: false)
          .limit(5);

      // Get regular uncategorized transactions
      final regular = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .or('category.is.null,is_categorized.eq.false')
          .eq('is_potential_duplicate', false)
          .order('date', ascending: false)
          .limit(5 - duplicates.length);

      // Combine with duplicates first
      return <Map<String, dynamic>>[
        ...duplicates.cast<Map<String, dynamic>>(),
        ...regular.cast<Map<String, dynamic>>(),
      ];
    } catch (e) {
      print('❌ Error getting prioritized transactions: $e');
      throw e;
    }
  }

  // Get transaction queue with AI processing (5 at a time)
  static Future<List<Map<String, dynamic>>> getTransactionQueue() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📋 Loading transaction queue...');

      // Get potential duplicates first (high priority)
      final duplicates = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('is_potential_duplicate', true)
          .order('duplicate_checked_at', ascending: false)
          .limit(5);

      // Get regular uncategorized transactions
      final remaining = 5 - duplicates.length;
      final regular = remaining > 0
          ? await supabase
              .from('transactions')
              .select()
              .eq('user_id', user.id)
              .or('category.is.null,is_categorized.eq.false')
              .eq('is_potential_duplicate', false)
              .order('date', ascending: false)
              .limit(remaining)
          : [];

      // Combine transactions (explicit typing to ensure correct return type)
      final List<Map<String, dynamic>> allTransactions = [
        ...(duplicates as List).cast<Map<String, dynamic>>(),
        ...(regular as List).cast<Map<String, dynamic>>(),
      ];

      // Get user profile for AI context
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Process each transaction with AI if ai_description doesn't exist
      // BUT DON'T SAVE TO DATABASE - only provide suggestions for user to review
      for (var transaction in allTransactions) {
        // Only process if AI description doesn't exist yet
        if (transaction['ai_description'] == null || transaction['ai_description'].isEmpty) {
          final aiResult = await OpenAIService.processTransaction(
            rawDescription: transaction['description'] ?? 'Unknown',
            amount: (transaction['amount'] ?? 0.0).toDouble(),
            merchantName: transaction['merchant_name'],
            userProfile: profile,
          );

          // Update local object ONLY (don't save to database until user submits)
          transaction['ai_description'] = aiResult['ai_description'];
          transaction['category'] = aiResult['category'];
          transaction['subcategory'] = aiResult['subcategory'];
          transaction['ai_suggestion_only'] = true; // Flag that this is AI suggestion, not user-confirmed

          print('💡 AI suggested: ${transaction['description']} → ${aiResult['ai_description']}');
        }
      }

      print('📋 Queue loaded: ${allTransactions.length} transactions');
      return allTransactions;
    } catch (e) {
      print('❌ Error getting transaction queue: $e');
      throw e;
    }
  }

  // Submit categorized transactions from queue
  static Future<bool> submitCategorizedTransactions(List<Map<String, dynamic>> transactions) async {
    try {
      final supabase = Supabase.instance.client;

      for (var transaction in transactions) {
        await supabase
            .from('transactions')
            .update({
              'ai_description': transaction['ai_description'],
              'category': transaction['category'],
              'subcategory': transaction['subcategory'],
              'is_categorized': true,
              'is_split': transaction['is_split'] ?? false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', transaction['id']);

        print('✅ Submitted: ${transaction['ai_description']}');
      }

      return true;
    } catch (e) {
      print('❌ Error submitting transactions: $e');
      return false;
    }
  }

  // Get split queue (transactions marked for splitting)
  static Future<List<TransactionModel>> getSplitQueue() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📋 Loading split queue...');

      // Get only 5 transactions at a time (like transaction queue)
      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('is_split', true)
          .eq('is_categorized', true)
          .order('date', ascending: false)
          .limit(5);

      final transactions = (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      print('📋 Split queue loaded: ${transactions.length} transactions (max 5 at a time)');
      return transactions;
    } catch (e) {
      print('❌ Error getting split queue: $e');
      return [];
    }
  }

  // Get count of remaining uncategorized transactions
  static Future<int> getUncategorizedCount() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return 0;

      final result = await supabase
          .from('transactions')
          .select('id')
          .eq('user_id', user.id)
          .or('category.is.null,is_categorized.eq.false') as List<dynamic>;

      return result.length;
    } catch (e) {
      print('❌ Error getting uncategorized count: $e');
      return 0;
    }
  }

  // Confirm duplicate and move to deleted_transactions
  static Future<bool> confirmDuplicate(String transactionId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final result = await supabase.rpc('move_to_deleted_transactions', params: {
        'p_transaction_id': transactionId,
        'p_reason': 'duplicate',
      });

      print('✅ Transaction moved to deleted items');
      return result == true;
    } catch (e) {
      print('❌ Error confirming duplicate: $e');
      return false;
    }
  }

  // Reject duplicate flag (mark as not duplicate)
  static Future<bool> rejectDuplicate(String transactionId) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('transactions')
          .update({
            'is_potential_duplicate': false,
            'duplicate_of_transaction_id': null,
            'duplicate_checked_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId);

      print('✅ Transaction marked as not a duplicate');
      return true;
    } catch (e) {
      print('❌ Error rejecting duplicate: $e');
      return false;
    }
  }

  // Get deleted transactions (recoverable)
  static Future<List<Map<String, dynamic>>> getDeletedTransactions() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final result = await supabase
          .from('deleted_transactions')
          .select()
          .eq('user_id', user.id)
          .eq('can_recover', true)
          .order('deleted_at', ascending: false);

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting deleted transactions: $e');
      throw e;
    }
  }

  // Recover deleted transaction
  static Future<bool> recoverDeletedTransaction(String transactionId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final result = await supabase.rpc('recover_deleted_transaction', params: {
        'p_transaction_id': transactionId,
      });

      print('✅ Transaction recovered');
      return result == true;
    } catch (e) {
      print('❌ Error recovering transaction: $e');
      return false;
    }
  }

  // Permanently delete from deleted_transactions
  static Future<bool> permanentlyDeleteTransaction(String transactionId) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('deleted_transactions')
          .delete()
          .eq('id', transactionId);

      print('✅ Transaction permanently deleted');
      return true;
    } catch (e) {
      print('❌ Error permanently deleting transaction: $e');
      return false;
    }
  }

  // ============== FRIENDS MANAGEMENT ==============

  // Get user's friends (accepted only)
  static Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase.rpc('get_user_friends');

      print('📋 Loaded ${(response as List).length} friends');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting friends: $e');
      return [];
    }
  }

  // Send friend request
  static Future<bool> sendFriendRequest(String friendUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if request already exists
      final existing = await supabase
          .from('friends')
          .select()
          .eq('user_id', user.id)
          .eq('friend_id', friendUserId)
          .maybeSingle();

      if (existing != null) {
        print('ℹ️ Friend request already exists');
        return true; // Return true since request exists (not an error)
      }

      await supabase.from('friends').insert({
        'user_id': user.id,
        'friend_id': friendUserId,
        'status': 'pending',
      });

      print('✅ Friend request sent');
      return true;
    } catch (e) {
      print('❌ Error sending friend request: $e');
      return false;
    }
  }

  // Get pending friend requests (requests TO current user)
  static Future<List<Map<String, dynamic>>> getPendingFriendRequests() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get pending friend requests
      final requests = await supabase
          .from('friends')
          .select('user_id, friend_id, status, created_at')
          .eq('friend_id', user.id)
          .eq('status', 'pending');

      // Get profile info for each requester
      final List<Map<String, dynamic>> enrichedRequests = [];
      for (var request in requests as List) {
        final requesterId = request['user_id'];
        final profile = await supabase
            .from('profiles')
            .select('id, username, email, full_name, avatar_url')
            .eq('id', requesterId)
            .maybeSingle();
        
        if (profile != null) {
          enrichedRequests.add({
            ...request,
            'requester_profile': profile,
          });
        }
      }

      print('📬 Loaded ${enrichedRequests.length} pending friend requests');
      return enrichedRequests;
    } catch (e) {
      print('❌ Error getting friend requests: $e');
      return [];
    }
  }

  // Accept friend request
  static Future<bool> acceptFriendRequest(String friendUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase
          .from('friends')
          .update({'status': 'accepted'})
          .eq('user_id', friendUserId)
          .eq('friend_id', user.id);

      print('✅ Friend request accepted');
      return true;
    } catch (e) {
      print('❌ Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  static Future<bool> rejectFriendRequest(String friendUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase
          .from('friends')
          .delete()
          .eq('user_id', friendUserId)
          .eq('friend_id', user.id);

      print('✅ Friend request rejected');
      return true;
    } catch (e) {
      print('❌ Error rejecting friend request: $e');
      return false;
    }
  }

  // ============== SPLIT & GROUP MANAGEMENT ==============

  // Get all groups the user is a member of
  static Future<List<Map<String, dynamic>>> getUserGroups() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('groups')
          .select('*')
          .order('name');

      print('📋 Loaded ${(response as List).length} groups');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting groups: $e');
      return [];
    }
  }

  // Get members of a specific group
  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final supabase = Supabase.instance.client;

      // Get all group members first
      final members = await supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId) as List<dynamic>;

      if (members.isEmpty) {
        print('📋 No members found for group $groupId');
        return [];
      }

      final memberIds = members.map((m) => m['user_id'] as String).toList();

      // Manually fetch profile info for all members
      final profiles = await supabase
          .from('profiles')
          .select('id, username, email, full_name, avatar_url')
          .inFilter('id', memberIds) as List<dynamic>;

      print('📋 Loaded ${profiles.length} members for group $groupId');
      return profiles.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting group members: $e');
      return [];
    }
  }

  // Create a new group
  static Future<String?> createGroup({
    required String name,
    String? icon,
    String? description,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('groups')
          .insert({
            'name': name,
            'icon': icon ?? '👥',
            'description': description,
            'created_by': user.id,
          })
          .select()
          .single();

      final groupId = response['id'] as String;

      // Add creator as first member
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': user.id,
        'added_by': user.id,
      });

      print('✅ Group created: $name');
      return groupId;
    } catch (e) {
      print('❌ Error creating group: $e');
      return null;
    }
  }

  // Add member to group
  static Future<bool> addGroupMember({
    required String groupId,
    required String userId,
    String? nickname,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'nickname': nickname,
        'added_by': user.id,
      });

      print('✅ Member added to group');
      return true;
    } catch (e) {
      print('❌ Error adding group member: $e');
      return false;
    }
  }

  // Submit split transaction
  static Future<bool> submitSplitTransaction({
    required String transactionId,
    required List<String> participantUserIds,
    String? groupId,
    bool isGroupVisible = false,
    String splitMethod = 'equal',
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get transaction amount
      final transaction = await supabase
          .from('transactions')
          .select('amount')
          .eq('id', transactionId)
          .single();

      final totalAmount = (transaction['amount'] as num).toDouble().abs();

      // Create split_transaction record
      print('📝 Creating split_transaction: groupId=$groupId, payer=${user.id}, amount=$totalAmount');
      
      final splitTxn = await supabase
          .from('split_transactions')
          .insert({
            'transaction_id': transactionId,
            'payer_id': user.id,
            'total_amount': totalAmount,
            'split_method': splitMethod,
            'is_group_visible': isGroupVisible,
            'group_id': groupId,
          })
          .select()
          .single();

      final splitTxnId = splitTxn['id'] as String;
      print('✅ Split transaction created with ID: $splitTxnId');

      // Calculate equal split amount
      final amountPerPerson = totalAmount / participantUserIds.length;

      // Create split_participants for each person
      print('📝 Adding ${participantUserIds.length} participants...');
      for (final participantId in participantUserIds) {
        await supabase.from('split_participants').insert({
          'split_transaction_id': splitTxnId,
          'user_id': participantId,
          'amount_owed': amountPerPerson,
        });
        print('   ✅ Added participant: $participantId (\$${amountPerPerson.toStringAsFixed(2)})');
      }

      // Update transaction to remove from split queue
      await supabase
          .from('transactions')
          .update({'is_split': false})
          .eq('id', transactionId);

      print('✅ Split created: \$${totalAmount.toStringAsFixed(2)} among ${participantUserIds.length} people${groupId != null ? ' (Group: $groupId)' : ''}');
      return true;
    } catch (e) {
      print('❌ Error submitting split: $e');
      return false;
    }
  }

  // Get group details with members and balances
  static Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get group info
      final group = await supabase
          .from('groups')
          .select('*')
          .eq('id', groupId)
          .single();

      // Get all group members with their profile info
      final members = await supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId) as List<dynamic>;

      final memberIds = members.map((m) => m['user_id'] as String).toList();
      
      // Get profile info for all members
      final profiles = await supabase
          .from('profiles')
          .select('id, username, full_name, avatar_url')
          .inFilter('id', memberIds) as List<dynamic>;

      // Get all split transactions for this group
      final splits = await supabase
          .from('split_transactions')
          .select('''
            *,
            transaction:transactions(id, description, amount, date, ai_description),
            split_participants(user_id, amount_owed, is_settled)
          ''')
          .eq('group_id', groupId)
          .order('created_at', ascending: false) as List<dynamic>;

      // Calculate balances for each member
      final Map<String, double> balances = {};
      for (final profile in profiles) {
        balances[profile['id'] as String] = 0.0;
      }

      // Calculate who owes who
      for (final split in splits) {
        final participants = (split['split_participants'] as List<dynamic>?) ?? [];
        for (final participant in participants) {
          final userId = participant['user_id'] as String;
          final amountOwed = (participant['amount_owed'] as num).toDouble();
          final isSettled = participant['is_settled'] as bool? ?? false;
          
          if (!isSettled) {
            if (userId == user.id) {
              // You are owed this amount
              balances[userId] = (balances[userId] ?? 0.0) + amountOwed;
            } else {
              // They owe you this amount
              balances[userId] = (balances[userId] ?? 0.0) - amountOwed;
            }
          }
        }
      }

      return {
        'group': group,
        'members': profiles,
        'balances': balances,
        'transactions': splits,
      };
    } catch (e) {
      print('❌ Error getting group details: $e');
      rethrow;
    }
  }

  // Get split history with a specific person
  static Future<Map<String, dynamic>> getPersonSplitHistory(String otherUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get other user's profile
      final profile = await supabase
          .from('profiles')
          .select('id, username, full_name, avatar_url')
          .eq('id', otherUserId)
          .single();

      // Get all split transactions where both users are participants
      final splits = await supabase
          .from('split_transactions')
          .select('''
            *,
            transaction:transactions(id, description, amount, date, ai_description),
            split_participants!inner(user_id, amount_owed, is_settled)
          ''')
          .or('payer_id.eq.${user.id},payer_id.eq.$otherUserId')
          .order('created_at', ascending: false) as List<dynamic>;

      // Filter to only splits involving both users
      final relevantSplits = splits.where((split) {
        final participants = (split['split_participants'] as List<dynamic>?) ?? [];
        final userIds = participants.map((p) => p['user_id'] as String).toSet();
        return userIds.contains(user.id) && userIds.contains(otherUserId);
      }).toList();

      // Calculate total balance
      double totalBalance = 0.0;
      for (final split in relevantSplits) {
        final payerId = split['payer_id'] as String;
        final participants = (split['split_participants'] as List<dynamic>?) ?? [];
        
        for (final participant in participants) {
          final userId = participant['user_id'] as String;
          final amountOwed = (participant['amount_owed'] as num).toDouble();
          final isSettled = participant['is_settled'] as bool? ?? false;
          
          if (!isSettled) {
            if (payerId == user.id && userId == otherUserId) {
              // They owe you
              totalBalance += amountOwed;
            } else if (payerId == otherUserId && userId == user.id) {
              // You owe them
              totalBalance -= amountOwed;
            }
          }
        }
      }

      return {
        'person': profile,
        'balance': totalBalance, // Positive = they owe you, Negative = you owe them
        'transactions': relevantSplits,
      };
    } catch (e) {
      print('❌ Error getting person split history: $e');
      rethrow;
    }
  }
}
