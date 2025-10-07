import 'package:supabase_flutter/supabase_flutter.dart';

class OpenAIService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Normalize merchant name
  static Future<String> normalizeMerchant(String rawDescription, String merchantRaw) async {
    try {
      // Call backend API to normalize merchant name
      final response = await _supabase.functions.invoke(
        'normalize-merchant',
        body: {
          'raw_description': rawDescription,
          'merchant_raw': merchantRaw,
        },
      );
      
      return response.data['normalized_merchant'] as String? ?? merchantRaw;
    } catch (e) {
      // Fallback to simple normalization
      String normalized = merchantRaw;
      normalized = normalized.replaceAll(RegExp(r'_[A-Z0-9]+$'), '');
      normalized = normalized.replaceAll(RegExp(r'^[A-Z]+_'), '');
      normalized = normalized.replaceAll('_', ' ');
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
      
      normalized = normalized.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
      
      return normalized.isNotEmpty ? normalized : merchantRaw;
    }
  }
  
  // Categorize transaction
  static Future<TransactionCategorization> categorizeTransaction({
    required String description,
    required String merchantNorm,
    required double amount,
    required DateTime date,
    List<String> userFavorites = const [],
    Map<String, String> userRules = const {},
  }) async {
    try {
      // Call backend API to categorize transaction
      final response = await _supabase.functions.invoke(
        'categorize-transaction',
        body: {
          'description': description,
          'merchant_norm': merchantNorm,
          'amount': amount,
          'date': date.toIso8601String(),
          'user_favorites': userFavorites,
          'user_rules': userRules,
        },
      );
      
      return TransactionCategorization.fromJson(response.data);
    } catch (e) {
      // Fallback to simple categorization logic
      String category = 'personal_social';
      String subcategory = 'Misc (Unassigned)';
      double confidence = 0.5;
      
      final merchant = merchantNorm.toLowerCase();
      
      if (merchant.contains('starbucks') || merchant.contains('coffee') || 
          merchant.contains('mcdonalds') || merchant.contains('pizza') ||
          merchant.contains('restaurant') || merchant.contains('food')) {
        category = 'food_drink';
        subcategory = merchant.contains('coffee') ? 'Coffee Shop' : 'Snacks & Fast food';
        confidence = 0.8;
      }
      else if (merchant.contains('uber') || merchant.contains('lyft') || 
               merchant.contains('transit') || merchant.contains('gas')) {
        category = 'transportation';
        subcategory = merchant.contains('uber') || merchant.contains('lyft') ? 'Rideshare' : 'Gas';
        confidence = 0.8;
      }
      else if (merchant.contains('netflix') || merchant.contains('spotify') || 
               merchant.contains('amazon') || merchant.contains('subscription')) {
        category = 'personal_social';
        subcategory = 'Subscriptions';
        confidence = 0.8;
      }
      else if (merchant.contains('grocery') || merchant.contains('supermarket') || 
               merchant.contains('walmart') || merchant.contains('target')) {
        category = 'food_drink';
        subcategory = 'Groceries';
        confidence = 0.8;
      }
      
      return TransactionCategorization(
        category: category,
        subcategory: subcategory,
        confidence: confidence,
        alternates: [],
        justification: 'Fallback categorization based on merchant name',
      );
    }
  }
  
  // Parse JSON from AI response
  static Map<String, dynamic> _parseJsonFromResponse(String content) {
    // Try to extract JSON from the response
    final jsonStart = content.indexOf('{');
    final jsonEnd = content.lastIndexOf('}');
    
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      final jsonString = content.substring(jsonStart, jsonEnd + 1);
      // Simple JSON parsing - in production, use proper JSON parsing
      return _parseSimpleJson(jsonString);
    }
    
    throw Exception('No JSON found in response');
  }
  
  // Simple JSON parser for AI responses
  static Map<String, dynamic> _parseSimpleJson(String jsonString) {
    // This is a simplified parser - in production, use dart:convert
    final result = <String, dynamic>{};
    
    // Extract category
    final categoryMatch = RegExp(r'"category":\s*"([^"]+)"').firstMatch(jsonString);
    if (categoryMatch != null) {
      result['category'] = categoryMatch.group(1);
    }
    
    // Extract subcategory
    final subcategoryMatch = RegExp(r'"subcategory":\s*"([^"]+)"').firstMatch(jsonString);
    if (subcategoryMatch != null) {
      result['subcategory'] = subcategoryMatch.group(1);
    }
    
    // Extract confidence
    final confidenceMatch = RegExp(r'"confidence":\s*([0-9.]+)').firstMatch(jsonString);
    if (confidenceMatch != null) {
      result['confidence'] = double.tryParse(confidenceMatch.group(1)!) ?? 0.0;
    }
    
    // Extract justification
    final justificationMatch = RegExp(r'"justification":\s*"([^"]+)"').firstMatch(jsonString);
    if (justificationMatch != null) {
      result['justification'] = justificationMatch.group(1);
    }
    
    // Default values
    result['category'] ??= 'personal_social';
    result['subcategory'] ??= 'Misc (Unassigned)';
    result['confidence'] ??= 0.0;
    result['alternates'] ??= [];
    result['justification'] ??= 'AI categorization';
    
    return result;
  }
}

class TransactionCategorization {
  final String category;
  final String subcategory;
  final double confidence;
  final List<Map<String, String>> alternates;
  final String justification;
  
  const TransactionCategorization({
    required this.category,
    required this.subcategory,
    required this.confidence,
    required this.alternates,
    required this.justification,
  });
  
  factory TransactionCategorization.fromJson(Map<String, dynamic> json) {
    return TransactionCategorization(
      category: json['category'] as String? ?? 'personal_social',
      subcategory: json['subcategory'] as String? ?? 'Misc (Unassigned)',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      alternates: List<Map<String, String>>.from(
        (json['alternates'] as List?)?.map((e) => Map<String, String>.from(e)) ?? [],
      ),
      justification: json['justification'] as String? ?? 'AI categorization',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'subcategory': subcategory,
      'confidence': confidence,
      'alternates': alternates,
      'justification': justification,
    };
  }
}
