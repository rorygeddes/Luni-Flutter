import 'package:flutter/foundation.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/queue_item_model.dart';
import 'backend_service.dart';

class PlaidService {
  // Create link token for Plaid Link
  static Future<String> createLinkToken() async {
    // For now, use a mock user token
    // TODO: Get actual user token from backend auth
    const mockUserToken = 'mock-user-token';
    return await BackendService.createLinkToken(mockUserToken);
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
      
    } catch (e) {
      print('Error exchanging public token: $e');
      throw e;
    }
  }

  // Note: All data saving is now handled by the backend
  // The backend will save to Supabase using the SECRET key
  // Frontend only needs to exchange tokens and display data

  // Get user's accounts (mock data for now)
  static Future<List<AccountModel>> getAccounts() async {
    try {
      // TODO: Get accounts from backend API
      // For now, return mock data
      return [];
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Get user's transactions (mock data for now)
  static Future<List<TransactionModel>> getTransactions({int limit = 50}) async {
    try {
      // TODO: Get transactions from backend API
      // For now, return mock data
      return [];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Get pending transactions from queue (mock data for now)
  static Future<List<QueueItemModel>> getQueuedTransactions({int limit = 5}) async {
    try {
      // TODO: Get transaction queue from backend API
      // For now, return mock data
      return [];
    } catch (e) {
      print('Error getting transaction queue: $e');
      return [];
    }
  }
}