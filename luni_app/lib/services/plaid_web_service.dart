import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class PlaidWebService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create Plaid Link token (you'll need to implement this endpoint)
  static Future<String> createLinkToken() async {
    try {
      // For now, return a mock token for development
      // In production, you'd call your backend to create a real token
      return 'link-sandbox-${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to create link token: $e');
    }
  }

  // Exchange public token for access token
  static Future<void> exchangePublicToken(String publicToken) async {
    try {
      // For now, simulate successful exchange
      // In production, you'd call your backend to exchange the token
      print('Public token received: $publicToken');
      
      // Simulate saving institution and accounts
      await _saveMockInstitution();
      await _saveMockAccounts();
      await _saveMockTransactions();
      
    } catch (e) {
      throw Exception('Failed to exchange public token: $e');
    }
  }

  // Launch Plaid Link with web-based integration
  static Future<void> launchPlaidLink({
    required Function(String) onSuccess,
    required Function(String) onExit,
    required Function(String) onEvent,
  }) async {
    try {
      if (kIsWeb) {
        print('Using web-based Plaid Link integration');
        await _launchWebPlaidLink(onSuccess, onExit, onEvent);
      } else {
        // For mobile, use the mock flow for now
        print('Using mobile mock Plaid flow');
        await _mockPlaidFlow(onSuccess, onExit, onEvent);
      }
    } catch (e) {
      print('Error launching Plaid Link: $e');
      onExit('Error: $e');
    }
  }

  // Web-based Plaid Link implementation using JavaScript interop
  static Future<void> _launchWebPlaidLink(
    Function(String) onSuccess,
    Function(String) onExit,
    Function(String) onEvent,
  ) async {
    try {
      // For now, simulate the web Plaid flow
      // In production, you would integrate with Plaid's web SDK here
      onEvent('OPENED');
      await Future.delayed(const Duration(milliseconds: 500));
      
      onEvent('CONNECTED');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate bank selection and authentication
      onEvent('BANK_SELECTED');
      await Future.delayed(const Duration(milliseconds: 500));
      
      onEvent('ACCOUNT_SELECTED');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Save mock data
      await _saveMockInstitution();
      await _saveMockAccounts();
      await _saveMockTransactions();
      
      onEvent('SUCCESS');
      onSuccess('web_public_token_${DateTime.now().millisecondsSinceEpoch}');
      
    } catch (e) {
      onExit('Web Plaid error: $e');
    }
  }

  // Mock Plaid flow for mobile development
  static Future<void> _mockPlaidFlow(
    Function(String) onSuccess,
    Function(String) onExit,
    Function(String) onEvent,
  ) async {
    try {
      onEvent('OPENED');
      onEvent('CONNECTED');
      
      // Simulate bank connection process
      await Future.delayed(const Duration(seconds: 2));
      
      // Save mock data
      await _saveMockInstitution();
      await _saveMockAccounts();
      await _saveMockTransactions();
      
      onEvent('SUCCESS');
      onSuccess('mock_public_token_mobile');
      
    } catch (e) {
      onExit('Mock flow error: $e');
    }
  }

  // Mock methods for development (replace with real Plaid API calls)
  static Future<void> _saveMockInstitution() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('institutions').upsert({
      'id': 'ins_mock_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': user.id,
      'name': 'TD Bank',
      'logo_url': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _saveMockAccounts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final accounts = [
      {
        'id': 'acc_checking_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'institution_id': 'ins_mock_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'TD Checking Account',
        'type': 'depository',
        'subtype': 'checking',
        'balance': 1250.75,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'acc_savings_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'institution_id': 'ins_mock_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'TD Savings Account',
        'type': 'depository',
        'subtype': 'savings',
        'balance': 3500.00,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'acc_credit_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'institution_id': 'ins_mock_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'RBC Credit Card',
        'type': 'credit',
        'subtype': 'credit_card',
        'balance': -450.25,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final account in accounts) {
      await _supabase.from('accounts').upsert(account);
    }
  }

  static Future<void> _saveMockTransactions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final transactions = [
      {
        'id': 'txn_${now.millisecondsSinceEpoch}_1',
        'user_id': user.id,
        'account_id': 'acc_checking_${now.millisecondsSinceEpoch}',
        'amount': -25.50,
        'description': 'STARBUCKS COFFEE',
        'merchant_name': 'Starbucks',
        'date': now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        'category': null,
        'subcategory': null,
        'is_categorized': false,
        'is_split': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'txn_${now.millisecondsSinceEpoch}_2',
        'user_id': user.id,
        'account_id': 'acc_checking_${now.millisecondsSinceEpoch}',
        'amount': -150.00,
        'description': 'UBER TRIP',
        'merchant_name': 'Uber',
        'date': now.subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
        'category': null,
        'subcategory': null,
        'is_categorized': false,
        'is_split': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'id': 'txn_${now.millisecondsSinceEpoch}_3',
        'user_id': user.id,
        'account_id': 'acc_checking_${now.millisecondsSinceEpoch}',
        'amount': -89.99,
        'description': 'NETFLIX SUBSCRIPTION',
        'merchant_name': 'Netflix',
        'date': now.subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
        'category': null,
        'subcategory': null,
        'is_categorized': false,
        'is_split': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final transaction in transactions) {
      await _supabase.from('transactions').upsert(transaction);
      
      // Add to transaction queue for AI review
      await _supabase.from('transaction_queue').insert({
        'user_id': user.id,
        'transaction_id': transaction['id'],
        'ai_description': _cleanDescription(transaction['description'] as String),
        'ai_category': _categorizeTransaction(transaction['description'] as String),
        'ai_subcategory': _getSubcategory(transaction['description'] as String),
        'confidence_score': 0.8,
        'status': 'pending',
        'created_at': now.toIso8601String(),
      });
    }
  }

  // Simple AI categorization (replace with real AI service)
  static String _cleanDescription(String description) {
    return description
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'[0-9]+$'), '')
        .trim();
  }

  static String _categorizeTransaction(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('starbucks') || desc.contains('coffee')) {
      return 'food_drink';
    } else if (desc.contains('uber') || desc.contains('lyft')) {
      return 'transportation';
    } else if (desc.contains('netflix') || desc.contains('subscription')) {
      return 'entertainment';
    } else {
      return 'miscellaneous';
    }
  }

  static String _getSubcategory(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('starbucks') || desc.contains('coffee')) {
      return 'Coffee';
    } else if (desc.contains('uber') || desc.contains('lyft')) {
      return 'Rideshare';
    } else if (desc.contains('netflix')) {
      return 'Subscriptions';
    } else {
      return 'Other';
    }
  }

  // Get user's accounts
  static Future<List<AccountModel>> getAccounts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('accounts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<AccountModel>((json) => AccountModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Get user's transactions
  static Future<List<TransactionModel>> getTransactions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      return response.map<TransactionModel>((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Check if user has connected accounts
  static Future<bool> hasConnectedAccounts() async {
    final accounts = await getAccounts();
    return accounts.isNotEmpty;
  }

  // Get queued transactions for review
  static Future<List<Map<String, dynamic>>> getQueuedTransactions({int limit = 5}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('transaction_queue')
          .select('''
            *,
            transactions!inner(
              id,
              amount,
              description,
              merchant_name,
              date
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .limit(limit);

      return response.map<Map<String, dynamic>>((item) => {
        'id': item['id'],
        'transaction_id': item['transaction_id'],
        'ai_description': item['ai_description'],
        'ai_category': item['ai_category'],
        'ai_subcategory': item['ai_subcategory'],
        'confidence_score': item['confidence_score'],
        'status': item['status'],
        'amount': item['transactions']['amount'],
        'description': item['transactions']['description'],
        'merchant_name': item['transactions']['merchant_name'],
        'date': item['transactions']['date'],
      }).toList();
    } catch (e) {
      print('Error getting queued transactions: $e');
      return [];
    }
  }
}
