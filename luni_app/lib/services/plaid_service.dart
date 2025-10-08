import 'package:flutter/foundation.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/queue_item_model.dart';
import 'backend_service.dart';

class PlaidService {
  // Create link token for Plaid Link
  static Future<String> createLinkToken() async {
    // Get actual user ID from Supabase auth
    // This is critical - Plaid requires a unique user identifier
    String userId;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        userId = user.id;
      } else {
        // Fallback to a unique identifier if not logged in
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('Error getting user ID: $e');
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return await BackendService.createLinkToken(userId);
  }

  // Launch Plaid Link with real integration
  static Future<void> launchPlaidLink({
    required Function(String) onSuccess,
    required Function(String) onExit,
    required Function(String) onEvent,
  }) async {
    try {
      final linkToken = await createLinkToken();
      
      // Store link token for OAuth redirect (both web and mobile)
      await _storeOAuthState(linkToken);
      
      if (kIsWeb) {
        // Web implementation - show a dialog with Plaid Link
        // For now, we'll simulate the web flow as plaid_flutter doesn't fully support web
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

  // Store OAuth state for redirect handling
  static Future<void> _storeOAuthState(String linkToken) async {
    if (kIsWeb) {
      // For web, store in browser localStorage
      // This will be available to the OAuth redirect page
      print('Storing link token for web OAuth redirect');
      // Note: In Flutter web, you'd use dart:html or js package to access localStorage
      // For now, the OAuth page will handle token storage
    } else {
      // For mobile, we need to ensure the token is available to the redirect page
      // The token should be stored in a way that the redirect page can access it
      print('Link token ready for mobile OAuth redirect: ${linkToken.substring(0, 20)}...');
      
      // Store token in shared preferences for the redirect page to access
      // This is a workaround since mobile can't directly access localStorage
      // The redirect page will need to get the token from your backend
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

  // Web Plaid Link implementation (still uses mock flow as plaid_flutter doesn't fully support web)
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

  // Exchange public token for access token (via backend)
  static Future<void> exchangePublicToken(String publicToken) async {
    try {
      print('Exchanging public token via backend');
      
      // Call backend to exchange public token
      final data = await BackendService.exchangePublicToken(publicToken);
      
      print('Successfully exchanged public token and received data');
      print('Received ${data['accounts']?.length ?? 0} accounts');
      print('Received ${data['transactions']?.length ?? 0} transactions');
      
      // Save Plaid data to Supabase
      await BackendService.savePlaidData(
        accessToken: data['access_token'] as String,
        itemId: data['item_id'] as String,
        accounts: data['accounts'] as List<dynamic>,
        transactions: data['transactions'] as List<dynamic>,
      );
      
      print('✅ Plaid data successfully saved to database');
      
    } catch (e) {
      print('Error exchanging public token: $e');
      throw e;
    }
  }

  // Get user's accounts from database
  static Future<List<AccountModel>> getAccounts() async {
    try {
      final accountsData = await BackendService.getAccounts();
      return accountsData.map((data) => AccountModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Get user's transactions from database
  static Future<List<TransactionModel>> getTransactions({int limit = 50}) async {
    try {
      final transactionsData = await BackendService.getTransactions(limit: limit);
      return transactionsData.map((data) => TransactionModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Get uncategorized transactions for the queue
  static Future<List<Map<String, dynamic>>> getQueuedTransactions({int limit = 5}) async {
    try {
      final queueData = await BackendService.getUncategorizedTransactions(limit: limit);
      return queueData;
    } catch (e) {
      print('Error getting transaction queue: $e');
      return [];
    }
  }

  // Check if user has connected accounts
  static Future<bool> hasConnectedAccounts() async {
    try {
      final accounts = await getAccounts();
      return accounts.isNotEmpty;
    } catch (e) {
      print('Error checking connected accounts: $e');
      return false;
    }
  }
}