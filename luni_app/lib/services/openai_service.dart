import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // Clean up transaction description
  static Future<String> cleanDescription(String rawDescription) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a transaction description cleaner for a student budgeting app. 
Your job is to take raw bank transaction descriptions and make them clean, simple, and user-friendly.

Rules:
1. Remove bank codes, asterisks, numbers, and special characters
2. Keep merchant/company names clear and readable
3. For e-transfers, just say "E-Transfer" (not the full code)
4. For common places, use simple names (e.g., "CinePLEX***6777" → "Cineplex")
5. Keep it short (2-4 words max)
6. Capitalize properly (title case for businesses)

Examples:
- "CinePLEX***6777" → "Cineplex"
- "E-TRANS__667**7" → "E-Transfer"
- "AMZN Mktp CA*2X3Y4Z" → "Amazon"
- "TIM HORTONS #1234" → "Tim Hortons"
- "SPOTIFY *Premium" → "Spotify"
- "SQ *COFFEE SHOP" → "Coffee Shop"

Return ONLY the cleaned description, nothing else.'''
            },
            {
              'role': 'user',
              'content': 'Clean this transaction description: $rawDescription'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cleanedDescription = data['choices'][0]['message']['content'].trim();
        print('✅ OpenAI cleaned: "$rawDescription" → "$cleanedDescription"');
        return cleanedDescription;
      } else {
        print('❌ OpenAI API error: ${response.statusCode} - ${response.body}');
        return _fallbackCleanDescription(rawDescription);
      }
    } catch (e) {
      print('❌ Error cleaning description: $e');
      return _fallbackCleanDescription(rawDescription);
    }
  }
  
  // Categorize transaction
  static Future<Map<String, String>> categorizeTransaction({
    required String description,
    required double amount,
    String? merchantName,
    Map<String, dynamic>? userProfile,
  }) async {
    try {
      // Build context from user profile if available
      String userContext = '';
      if (userProfile != null) {
        final favorites = userProfile['favorites'] as List<dynamic>? ?? [];
        final purposes = userProfile['purposes'] as List<dynamic>? ?? [];
        
        if (favorites.isNotEmpty) {
          userContext += '\nUser favorites: ${favorites.join(', ')}';
        }
        if (purposes.isNotEmpty) {
          userContext += '\nUser purposes: ${purposes.join(', ')}';
        }
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a transaction categorizer for a student budgeting app called Luni.
Your job is to categorize transactions into parent and sub-categories based on the description and amount.

Parent Categories and their Sub-Categories:

LIVING ESSENTIALS:
- Rent
- Wifi
- Utilities
- Phone

EDUCATION:
- Tuition
- Supplies
- Books

FOOD:
- Groceries
- Coffee & Lunch
- Restaurants & Dinner

TRANSPORTATION:
- Bus Pass
- Gas
- Rideshare

HEALTHCARE:
- Gym
- Medication
- Haircuts
- Toiletries

ENTERTAINMENT:
- Events
- Night Out
- Shopping
- Substances
- Subscriptions

VACATION:
- Travel
- Accommodation
- Activities

INCOME:
- Job Income
- Family Support
- Savings/Investments
- Bonus
- E-Transfer In

Special Rules:
1. Positive amounts (+) are usually INCOME
2. Negative amounts (-) are usually EXPENSES
3. E-Transfers can be in or out depending on amount
4. Subscriptions (Netflix, Spotify, etc) → Entertainment > Subscriptions
5. Coffee shops (Starbucks, Tim Hortons) → Food > Coffee & Lunch
6. Restaurants (dinner time) → Food > Restaurants & Dinner
7. Grocery stores (Walmart, Sobeys, etc) → Food > Groceries
8. Rideshare (Uber, Lyft) → Transportation > Rideshare
9. Gym memberships → Healthcare > Gym
10. Online shopping (Amazon, etc) → Entertainment > Shopping$userContext

Respond in this EXACT format (one line, pipe-separated):
PARENT_CATEGORY|SUB_CATEGORY

Examples:
- "Starbucks" → FOOD|Coffee & Lunch
- "Netflix" → ENTERTAINMENT|Subscriptions
- "Uber" → TRANSPORTATION|Rideshare
- "Sobeys" → FOOD|Groceries
- "E-Transfer" (positive) → INCOME|E-Transfer In
- "Rent Payment" → LIVING ESSENTIALS|Rent'''
            },
            {
              'role': 'user',
              'content': 'Categorize this transaction:\nDescription: $description\nAmount: $amount${merchantName != null ? '\nMerchant: $merchantName' : ''}'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['choices'][0]['message']['content'].trim();
        
        final parts = result.split('|');
        if (parts.length == 2) {
          final parentCategory = parts[0].trim();
          final subCategory = parts[1].trim();
          
          print('✅ OpenAI categorized: "$description" → $parentCategory > $subCategory');
          
          return {
            'parent_category': parentCategory,
            'sub_category': subCategory,
          };
        } else {
          print('⚠️  Invalid OpenAI response format: $result');
          return _fallbackCategorize(description, amount);
        }
      } else {
        print('❌ OpenAI API error: ${response.statusCode} - ${response.body}');
        return _fallbackCategorize(description, amount);
      }
    } catch (e) {
      print('❌ Error categorizing transaction: $e');
      return _fallbackCategorize(description, amount);
    }
  }

  // Fallback: Simple rule-based description cleaning
  static String _fallbackCleanDescription(String raw) {
    String cleaned = raw;
    
    // Remove common bank codes
    cleaned = cleaned.replaceAll(RegExp(r'\*+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'#+\d+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'__\d+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\d{4,}'), '');
    
    // E-Transfer simplification
    if (cleaned.toUpperCase().contains('E-TRANS') || cleaned.toUpperCase().contains('ETRANSFER')) {
      return 'E-Transfer';
    }
    
    // Common merchants
    if (cleaned.toUpperCase().contains('CINEPLEX')) return 'Cineplex';
    if (cleaned.toUpperCase().contains('AMAZON') || cleaned.toUpperCase().contains('AMZN')) return 'Amazon';
    if (cleaned.toUpperCase().contains('TIM HORTON')) return 'Tim Hortons';
    if (cleaned.toUpperCase().contains('STARBUCKS')) return 'Starbucks';
    if (cleaned.toUpperCase().contains('SPOTIFY')) return 'Spotify';
    if (cleaned.toUpperCase().contains('NETFLIX')) return 'Netflix';
    if (cleaned.toUpperCase().contains('UBER')) return 'Uber';
    
    // Clean up remaining
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    
    // Title case
    cleaned = cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return cleaned.isEmpty ? raw : cleaned;
  }

  // Fallback: Simple rule-based categorization
  static Map<String, String> _fallbackCategorize(String description, double amount) {
    final desc = description.toLowerCase();
    
    // Income (positive amounts)
    if (amount > 0) {
      if (desc.contains('transfer') || desc.contains('e-transfer')) {
        return {'parent_category': 'INCOME', 'sub_category': 'E-Transfer In'};
      }
      return {'parent_category': 'INCOME', 'sub_category': 'Job Income'};
    }
    
    // Subscriptions
    if (desc.contains('spotify') || desc.contains('netflix') || desc.contains('subscription')) {
      return {'parent_category': 'ENTERTAINMENT', 'sub_category': 'Subscriptions'};
    }
    
    // Food
    if (desc.contains('starbucks') || desc.contains('tim horton') || desc.contains('coffee')) {
      return {'parent_category': 'FOOD', 'sub_category': 'Coffee & Lunch'};
    }
    if (desc.contains('restaurant') || desc.contains('pizza') || desc.contains('burger')) {
      return {'parent_category': 'FOOD', 'sub_category': 'Restaurants & Dinner'};
    }
    if (desc.contains('grocery') || desc.contains('sobeys') || desc.contains('walmart') || desc.contains('loblaws')) {
      return {'parent_category': 'FOOD', 'sub_category': 'Groceries'};
    }
    
    // Transportation
    if (desc.contains('uber') || desc.contains('lyft') || desc.contains('rideshare')) {
      return {'parent_category': 'TRANSPORTATION', 'sub_category': 'Rideshare'};
    }
    if (desc.contains('gas') || desc.contains('petro') || desc.contains('shell')) {
      return {'parent_category': 'TRANSPORTATION', 'sub_category': 'Gas'};
    }
    
    // Utilities
    if (desc.contains('rent')) {
      return {'parent_category': 'LIVING ESSENTIALS', 'sub_category': 'Rent'};
    }
    if (desc.contains('wifi') || desc.contains('internet')) {
      return {'parent_category': 'LIVING ESSENTIALS', 'sub_category': 'Wifi'};
    }
    if (desc.contains('phone') || desc.contains('rogers') || desc.contains('bell') || desc.contains('telus')) {
      return {'parent_category': 'LIVING ESSENTIALS', 'sub_category': 'Phone'};
    }
    
    // Default to Entertainment > Shopping for expenses
    return {'parent_category': 'ENTERTAINMENT', 'sub_category': 'Shopping'};
  }

  // Process transaction with AI (description + categorization in one call)
  static Future<Map<String, dynamic>> processTransaction({
    required String rawDescription,
    required double amount,
    String? merchantName,
    Map<String, dynamic>? userProfile,
  }) async {
    try {
      print('🤖 Processing transaction: $rawDescription (\$$amount)');
      
      // Clean description
      final cleanedDescription = await cleanDescription(rawDescription);
      
      // Categorize
      final categorization = await categorizeTransaction(
        description: cleanedDescription,
        amount: amount,
        merchantName: merchantName,
        userProfile: userProfile,
      );
      
      return {
        'ai_description': cleanedDescription,
        'category': categorization['parent_category'],
        'subcategory': categorization['sub_category'],
      };
    } catch (e) {
      print('❌ Error processing transaction: $e');
    return {
        'ai_description': _fallbackCleanDescription(rawDescription),
        'category': 'ENTERTAINMENT',
        'subcategory': 'Shopping',
      };
    }
  }
}
