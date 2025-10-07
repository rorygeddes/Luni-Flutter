import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import 'backend_service.dart';

class PlaidService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // For development, we'll use a mock backend URL
  // In production, replace with your actual backend URL
  static const String _backendUrl = 'https://your-backend-url.com';
  
  // Create link token for Plaid Link
  static Future<String> createLinkToken() async {
    return await BackendService.createLinkToken();
  }

  // Launch Plaid Link with real integration
  static Future<void> launchPlaidLink({
    required Function(String) onSuccess,
    required Function(String) onExit,
    required Function(String) onEvent,
  }) async {
    try {
      final linkToken = await createLinkToken();
      
      if (kIsWeb) {
        // Web implementation - show a dialog with Plaid Link
        await _launchPlaidLinkWeb(linkToken, onSuccess, onExit, onEvent);
      } else {
        // Mobile implementation using plaid_flutter
        await _launchPlaidLinkMobile(linkToken, onSuccess, onExit, onEvent);
      }
    } catch (e) {
      print('Error launching Plaid Link: $e');
      onExit('Failed to launch Plaid Link: $e');
    }
  }

  // Mobile Plaid Link implementation using real plaid_flutter
  static Future<void> _launchPlaidLinkMobile(
    String linkToken,
    Function(String) onSuccess,
    Function(String) onExit,
    Function(String) onEvent,
  ) async {
    try {
      print('Launching Plaid Link Mobile with token: ${linkToken.substring(0, 10)}...');
      
      final linkConfiguration = LinkTokenConfiguration(
        token: linkToken,
      );

      // Create Plaid Link with configuration
      await PlaidLink.create(configuration: linkConfiguration);
      
      // Set up event listeners using Stream API
      PlaidLink.onSuccess.listen((LinkSuccess success) {
        print('Plaid Link Success: ${success.publicToken}');
        onSuccess(success.publicToken ?? '');
      });
      
      PlaidLink.onExit.listen((LinkExit exit) {
        print('Plaid Link Exit: ${exit.error?.displayMessage}');
        final reason = exit.error?.displayMessage ?? 'User cancelled';
        onExit(reason);
      });
      
      PlaidLink.onEvent.listen((LinkEvent event) {
        print('Plaid Link Event: ${event.toString()}');
        onEvent(event.toString());
      });
      
      // Open Plaid Link
      PlaidLink.open();
      
    } catch (e) {
      print('Error in mobile Plaid Link: $e');
      onExit('Mobile Plaid Link error: $e');
    }
  }

  // Web Plaid Link implementation
  static Future<void> _launchPlaidLinkWeb(
    String linkToken,
    Function(String) onSuccess,
    Function(String) onExit,
    Function(String) onEvent,
  ) async {
    try {
      // For web, we'll show a dialog that simulates the Plaid Link experience
      // In a real implementation, you would embed Plaid Link using their web SDK
      onEvent('OPENED');
      
      // Simulate the Plaid Link flow
      await Future.delayed(const Duration(seconds: 2));
      onEvent('CONNECTED');
      
      await Future.delayed(const Duration(seconds: 1));
      onEvent('HANDOFF');
      
      await Future.delayed(const Duration(seconds: 1));
      onEvent('SUCCESS');
      
      // For demo purposes, simulate a successful connection
      // In production, this would be the actual public token from Plaid Link web
      onSuccess('mock_public_token_web_$linkToken');
      
    } catch (e) {
      print('Error in web Plaid Link: $e');
      onExit('Web Plaid Link error: $e');
    }
  }

  // Exchange public token for access token
  static Future<void> exchangePublicToken(String publicToken) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Warning: User not authenticated, cannot save data without valid user');
        throw Exception('User must be authenticated to save bank data');
      }

      // Call backend to exchange public token
      final data = await BackendService.exchangePublicToken(publicToken);
      
      // Save the received data to Supabase
      await _saveInstitution(user.id, data);
      await _saveAccounts(user.id, data);
      await _saveTransactions(user.id, data);
      
    } catch (e) {
      print('Error exchanging public token: $e');
      throw e;
    }
  }

  // Save data received from backend
  static Future<void> _saveInstitution(String userId, Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    final userEmail = user?.email ?? 'unknown@example.com';
    
    await _supabase.from('institutions').upsert({
      'id': 'ins_${data['item_id']}',
      'user_id': userId,
      'user_email': userEmail,
      'access_token': data['access_token'],
      'item_id': data['item_id'],
      'name': 'Connected Bank',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'item_id');
    
    print('Saved institution for user: $userEmail');
  }

  static Future<void> _saveAccounts(String userId, Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    final userEmail = user?.email ?? 'unknown@example.com';
    final accounts = data['accounts'] as List<dynamic>;
    
    for (final accountData in accounts) {
      await _supabase.from('accounts').upsert({
        'id': accountData['account_id'],
        'user_id': userId,
        'user_email': userEmail,
        'institution_id': 'ins_${data['item_id']}',
        'name': accountData['name'],
        'type': accountData['type'],
        'subtype': accountData['subtype'],
        'balance': (accountData['balances']['current'] as num).toDouble(),
        'mask': accountData['mask'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    }
    
    print('Saved ${accounts.length} accounts for user: $userEmail');
  }

  static Future<void> _saveTransactions(String userId, Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    final userEmail = user?.email ?? 'unknown@example.com';
    final transactions = data['transactions'] as List<dynamic>;
    
    for (final transactionData in transactions) {
      await _supabase.from('transactions').upsert({
        'id': transactionData['transaction_id'],
        'user_id': userId,
        'user_email': userEmail,
        'account_id': transactionData['account_id'],
        'institution_id': 'ins_${data['item_id']}',
        'amount': (transactionData['amount'] as num).toDouble(),
        'description': transactionData['name'],
        'merchant_name': transactionData['merchant_name'] ?? transactionData['name'],
        'date': DateTime.parse(transactionData['date']).toIso8601String().split('T')[0],
        'category': transactionData['category']?.isNotEmpty == true ? transactionData['category'][0] : 'Other',
        'subcategory': transactionData['subcategory'] ?? 'Other',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      // Add to transaction queue for AI review
      await _supabase.from('transaction_queue').upsert({
        'user_id': userId,
        'user_email': userEmail,
        'transaction_id': transactionData['transaction_id'],
        'ai_description': transactionData['name'],
        'ai_category': transactionData['category']?.isNotEmpty == true ? transactionData['category'][0] : 'Other',
        'ai_subcategory': transactionData['subcategory'] ?? 'Other',
        'confidence_score': 0.8,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'transaction_id');
    }
    
    print('Saved ${transactions.length} transactions for user: $userEmail');
  }

  // Get user's accounts
  static Future<List<AccountModel>> getAccounts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User not authenticated, returning empty accounts list');
      return [];
    }

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
    if (user == null) {
      print('User not authenticated, returning empty transactions list');
      return [];
    }

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
    if (user == null) {
      print('User not authenticated, returning empty queue list');
      return [];
    }

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