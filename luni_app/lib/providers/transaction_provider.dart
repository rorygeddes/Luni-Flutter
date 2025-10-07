import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/plaid_service.dart';
import '../services/openai_service.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _queuedTransactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get queuedTransactions => _queuedTransactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // Load queued transactions
  Future<void> loadQueuedTransactions() async {
    _setLoading(true);
    
    try {
      // Load categories first
      await _loadCategories();
      
      // Load queued transactions
      final queueItems = await PlaidService.getQueuedTransactions(limit: 5);
      
      // Process each transaction with AI categorization
      final processedTransactions = <Map<String, dynamic>>[];
      
      for (final queueItem in queueItems) {
        final transaction = queueItem['transactions'] as Map<String, dynamic>;
        
        // Get AI categorization if not already done
        if (transaction['ai_category_id'] == null) {
          final categorization = await OpenAIService.categorizeTransaction(
            description: transaction['raw_description'] as String,
            merchantNorm: transaction['merchant_norm'] as String,
            amount: (transaction['amount_cents'] as int) / 100.0,
            date: DateTime.parse(transaction['posted_at'] as String),
          );
          
          // Update transaction with AI categorization
          await _updateTransactionWithAI(
            transaction['id'] as String,
            categorization,
          );
          
          transaction['ai_category_id'] = _findCategoryId(categorization.category, categorization.subcategory);
          transaction['ai_category_name'] = categorization.subcategory;
          transaction['ai_confidence'] = categorization.confidence;
        }
        
        // Add to processed list
        processedTransactions.add({
          ...queueItem,
          'transactions': transaction,
        });
      }
      
      _queuedTransactions = processedTransactions;
    } catch (e) {
      // Handle error
      _queuedTransactions = [];
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('categories')
          .select('*')
          .or('user_id.is.null,user_id.eq.${user.id}')
          .order('parent_key')
          .order('name');

      _categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      _categories = [];
    }
  }

  // Update transaction with AI categorization
  Future<void> _updateTransactionWithAI(String transactionId, TransactionCategorization categorization) async {
    try {
      final categoryId = _findCategoryId(categorization.category, categorization.subcategory);
      
      await _supabase
          .from('transactions')
          .update({
            'ai_category_id': categoryId,
            'ai_confidence': categorization.confidence,
          })
          .eq('id', transactionId);
    } catch (e) {
      // Handle error
    }
  }

  // Find category ID by parent and subcategory
  String? _findCategoryId(String parentKey, String subcategoryName) {
    try {
      final category = _categories.firstWhere(
        (cat) => cat.parentKey == parentKey && cat.name == subcategoryName,
      );
      return category.id;
    } catch (e) {
      // Return first category in the parent group as fallback
      try {
        final fallbackCategory = _categories.firstWhere(
          (cat) => cat.parentKey == parentKey,
        );
        return fallbackCategory.id;
      } catch (e) {
        return null;
      }
    }
  }

  // Update transaction category selection
  void updateTransactionCategory(String transactionId, String? categoryId) {
    final index = _queuedTransactions.indexWhere(
      (item) => item['transactions']['id'] == transactionId,
    );
    
    if (index != -1) {
      _queuedTransactions[index]['transactions']['selected_category_id'] = categoryId;
      notifyListeners();
    }
  }

  // Categorize a single transaction
  Future<void> categorizeTransaction(String transactionId, String? categoryId) async {
    if (categoryId == null) return;

    try {
      // Update transaction in database
      await _supabase
          .from('transactions')
          .update({
            'ai_category_id': categoryId,
          })
          .eq('id', transactionId);

      // Remove from queue
      await _supabase
          .from('queue_items')
          .update({'state': 'done'})
          .eq('transaction_id', transactionId);

      // Remove from local list
      _queuedTransactions.removeWhere(
        (item) => item['transactions']['id'] == transactionId,
      );

      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  // Submit all categorized transactions
  Future<void> submitCategorizedTransactions() async {
    try {
      final transactionsToUpdate = <String, String>{};
      
      // Collect all transactions with selected categories
      for (final queueItem in _queuedTransactions) {
        final transaction = queueItem['transactions'] as Map<String, dynamic>;
        final transactionId = transaction['id'] as String;
        final selectedCategoryId = transaction['selected_category_id'] as String?;
        
        if (selectedCategoryId != null) {
          transactionsToUpdate[transactionId] = selectedCategoryId;
        }
      }

      // Update all transactions in batch
      for (final entry in transactionsToUpdate.entries) {
        await _supabase
            .from('transactions')
            .update({'ai_category_id': entry.value})
            .eq('id', entry.key);
      }

      // Mark queue items as done
      final transactionIds = transactionsToUpdate.keys.toList();
      if (transactionIds.isNotEmpty) {
        await _supabase
            .from('queue_items')
            .update({'state': 'done'})
            .inFilter('transaction_id', transactionIds);
      }

      // Clear local queue
      _queuedTransactions.clear();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get transactions by category
  Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', user.id)
          .eq('ai_category_id', categoryId)
          .order('posted_at', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get monthly spending by category
  Future<Map<String, double>> getMonthlySpendingByCategory(int year, int month) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final response = await _supabase
          .from('transactions')
          .select('ai_category_id, amount_cents')
          .eq('user_id', user.id)
          .gte('posted_at', startDate.toIso8601String())
          .lte('posted_at', endDate.toIso8601String())
          .not('ai_category_id', 'is', null);

      final spending = <String, double>{};
      
      for (final transaction in response as List) {
        final categoryId = transaction['ai_category_id'] as String;
        final amount = (transaction['amount_cents'] as int) / 100.0;
        
        spending[categoryId] = (spending[categoryId] ?? 0) + amount.abs();
      }

      return spending;
    } catch (e) {
      return {};
    }
  }
}
