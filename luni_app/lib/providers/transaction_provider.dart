import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/plaid_service.dart';
import '../services/openai_service.dart';
import '../services/backend_service.dart';

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
      
      // Load uncategorized transactions directly from database
      final queueData = await PlaidService.getQueuedTransactions(limit: 5);
      
      // Process each transaction with AI categorization
      final processedTransactions = <Map<String, dynamic>>[];
      
      for (final transactionData in queueData) {
        // Get AI categorization using user's categories
        final description = transactionData['description'] ?? 'Unknown';
        final merchantName = transactionData['merchant_name'];
        final amount = (transactionData['amount'] ?? 0.0).toDouble();
        
        // Simple keyword-based categorization (following old_method.md approach)
        final aiResult = _categorizeWithKeywords(
          description: description,
          merchantName: merchantName,
          amount: amount,
          userCategories: _categories,
        );
        
        // Add AI categorization to transaction data
        final processedTransaction = {
          'id': transactionData['id'],
          'transaction_id': transactionData['id'],
          'amount': transactionData['amount'],
          'description': transactionData['description'],
          'merchant_name': transactionData['merchant_name'],
          'date': transactionData['date'],
          'ai_description': aiResult['cleaned_description'] ?? transactionData['description'],
          'ai_category': aiResult['category'] ?? 'other',
          'ai_subcategory': aiResult['subcategory'] ?? 'Other',
          'confidence_score': aiResult['confidence'] ?? 0.5,
          'status': 'pending',
        };
        
        processedTransactions.add(processedTransaction);
      }
      
      _queuedTransactions = processedTransactions;
    } catch (e) {
      print('Error loading queued transactions: $e');
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

  // Submit categorized transaction
  Future<void> submitTransaction({
    required String transactionId,
    required String category,
    required String subcategory,
    required String aiDescription,
    bool isSplit = false,
  }) async {
    try {
      // Update transaction using BackendService
      await BackendService.updateTransactionCategory(
        transactionId: transactionId,
        category: category,
        subcategory: subcategory,
        aiDescription: aiDescription,
        isSplit: isSplit,
      );

      // Remove from local queue
      _queuedTransactions.removeWhere(
        (item) => item['id'] == transactionId || item['transaction_id'] == transactionId,
      );

      notifyListeners();
      
      print('✅ Transaction submitted: $transactionId');
    } catch (e) {
      print('❌ Error submitting transaction: $e');
      throw e;
    }
  }

  // Submit all categorized transactions from current queue
  Future<void> submitCategorizedTransactions() async {
    try {
      // Update all transactions in the queue
      for (final queueItem in _queuedTransactions) {
        await BackendService.updateTransactionCategory(
          transactionId: queueItem['transaction_id'] ?? queueItem['id'],
          category: queueItem['ai_category'] ?? 'other',
          subcategory: queueItem['ai_subcategory'] ?? 'Other',
          aiDescription: queueItem['ai_description'] ?? queueItem['description'],
          isSplit: queueItem['is_split'] ?? false,
        );
      }

      // Clear local queue
      _queuedTransactions.clear();
      notifyListeners();
      
      print('✅ All transactions submitted');
    } catch (e) {
      print('❌ Error submitting transactions: $e');
      throw e;
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

  // Categorize transaction with keywords (following old_method.md approach)
  Map<String, dynamic> _categorizeWithKeywords({
    required String description,
    String? merchantName,
    required double amount,
    required List<CategoryModel> userCategories,
  }) {
    final text = '${description.toLowerCase()} ${merchantName?.toLowerCase() ?? ''}'.toLowerCase();
    
    // Keyword matching (similar to old_method.md _classify_transaction)
    String? matchedParent;
    String? matchedSubcategory;
    double confidence = 0.5;

    // Food keywords
    if (text.contains('starbucks') || text.contains('coffee') || text.contains('cafe')) {
      matchedParent = 'food';
      matchedSubcategory = 'Coffee & Lunch Out';
      confidence = 0.9;
    } else if (text.contains('grocery') || text.contains('loblaws') || text.contains('walmart') || 
               text.contains('supermarket') || text.contains('safeway')) {
      matchedParent = 'food';
      matchedSubcategory = 'Groceries';
      confidence = 0.9;
    } else if (text.contains('restaurant') || text.contains('pizza') || text.contains('burger') || 
               text.contains('mcdonalds') || text.contains('subway')) {
      matchedParent = 'food';
      matchedSubcategory = 'Restaurants & Dinner';
      confidence = 0.85;
    }
    // Transportation keywords
    else if (text.contains('uber') || text.contains('lyft') || text.contains('taxi')) {
      matchedParent = 'transportation';
      matchedSubcategory = 'Rideshare';
      confidence = 0.95;
    } else if (text.contains('gas') || text.contains('petro') || text.contains('shell') || text.contains('esso')) {
      matchedParent = 'transportation';
      matchedSubcategory = 'Gas';
      confidence = 0.9;
    } else if (text.contains('transit') || text.contains('bus') || text.contains('metro') || text.contains('ttc')) {
      matchedParent = 'transportation';
      matchedSubcategory = 'Bus Pass';
      confidence = 0.9;
    }
    // Entertainment keywords
    else if (text.contains('netflix') || text.contains('spotify') || text.contains('disney') || 
             text.contains('subscription')) {
      matchedParent = 'entertainment';
      matchedSubcategory = 'Subscriptions';
      confidence = 0.9;
    } else if (text.contains('movie') || text.contains('cinema') || text.contains('theatre')) {
      matchedParent = 'entertainment';
      matchedSubcategory = 'Events';
      confidence = 0.85;
    } else if (text.contains('amazon') || text.contains('shopping') || text.contains('zara') || 
               text.contains('h&m')) {
      matchedParent = 'entertainment';
      matchedSubcategory = 'Shopping';
      confidence = 0.8;
    }
    // Living Essentials keywords
    else if (text.contains('rent') || text.contains('lease')) {
      matchedParent = 'living_essentials';
      matchedSubcategory = 'Rent';
      confidence = 0.95;
    } else if (text.contains('internet') || text.contains('wifi') || text.contains('rogers') || 
               text.contains('bell')) {
      matchedParent = 'living_essentials';
      matchedSubcategory = 'Wifi';
      confidence = 0.85;
    } else if (text.contains('hydro') || text.contains('electric') || text.contains('utility')) {
      matchedParent = 'living_essentials';
      matchedSubcategory = 'Utilities';
      confidence = 0.85;
    }
    // Education keywords
    else if (text.contains('tuition') || text.contains('university') || text.contains('college')) {
      matchedParent = 'education';
      matchedSubcategory = 'Tuition';
      confidence = 0.95;
    } else if (text.contains('book') || text.contains('textbook')) {
      matchedParent = 'education';
      matchedSubcategory = 'Books';
      confidence = 0.9;
    }
    // Healthcare keywords
    else if (text.contains('gym') || text.contains('fitness') || text.contains('goodlife')) {
      matchedParent = 'healthcare';
      matchedSubcategory = 'Gym';
      confidence = 0.9;
    } else if (text.contains('pharmacy') || text.contains('drug') || text.contains('shoppers')) {
      matchedParent = 'healthcare';
      matchedSubcategory = 'Medication';
      confidence = 0.85;
    }
    // Income keywords (positive amounts)
    else if (amount > 0) {
      if (text.contains('payroll') || text.contains('salary') || text.contains('wage')) {
        matchedParent = 'income';
        matchedSubcategory = 'Job Income';
        confidence = 0.95;
      } else if (text.contains('transfer') || text.contains('deposit')) {
        matchedParent = 'income';
        matchedSubcategory = 'Family Support';
        confidence = 0.7;
      } else {
        matchedParent = 'income';
        matchedSubcategory = 'Bonus';
        confidence = 0.6;
      }
    }

    // If no match found, default to "other"
    if (matchedParent == null) {
      matchedParent = 'other';
      matchedSubcategory = 'Other';
      confidence = 0.3;
    }

    // Clean up merchant name for display
    String cleanedDescription = merchantName ?? description;
    cleanedDescription = cleanedDescription
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    
    // Capitalize first letter of each word
    cleanedDescription = cleanedDescription.split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    return {
      'cleaned_description': cleanedDescription,
      'category': matchedParent,
      'subcategory': matchedSubcategory,
      'confidence': confidence,
    };
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
