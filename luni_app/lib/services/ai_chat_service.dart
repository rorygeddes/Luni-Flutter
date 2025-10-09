import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIChatService {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // Send a chat message and get a response
  static Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    Map<String, dynamic>? financialContext,
  }) async {
    try {
      // Build system prompt with financial context
      String systemPrompt = '''You are Luni, a friendly and helpful AI financial assistant for students. 
You help students manage their money, understand their spending, and make better financial decisions.

Your personality:
- Friendly, supportive, and encouraging
- Use simple language (no jargon)
- Give practical, actionable advice
- Be brief and to the point (2-3 sentences usually)
- Use emojis sparingly but appropriately
- Never judge or shame for spending decisions

Your capabilities:
- Answer questions about budgeting and finances
- Analyze spending patterns
- Provide savings tips
- Help set financial goals
- Explain financial concepts simply

Guidelines:
- If asked about a specific transaction, refer to their spending history
- If asked about budgets, suggest realistic student-friendly amounts
- If unsure, be honest and suggest they consult a financial advisor for complex matters
- Always be encouraging and positive''';

      // Add financial context if available
      if (financialContext != null) {
        systemPrompt += '\n\nCurrent Financial Overview:';
        if (financialContext['total_balance'] != null) {
          systemPrompt += '\n- Total Balance: \$${financialContext['total_balance'].toStringAsFixed(2)}';
        }
        if (financialContext['monthly_spending'] != null) {
          systemPrompt += '\n- This Month\'s Spending: \$${financialContext['monthly_spending'].toStringAsFixed(2)}';
        }
        if (financialContext['top_category'] != null) {
          systemPrompt += '\n- Top Spending Category: ${financialContext['top_category']}';
        }
        if (financialContext['recent_transactions'] != null) {
          final recentCount = financialContext['recent_transactions'] as int;
          systemPrompt += '\n- Recent Transactions: $recentCount in the last 7 days';
        }
      }

      // Build messages array
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      print('🤖 Sending message to OpenAI...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'].trim();
        print('✅ AI response received: ${aiResponse.substring(0, 50)}...');
        return aiResponse;
      } else {
        print('❌ OpenAI API error: ${response.statusCode} - ${response.body}');
        return _getErrorResponse(response.statusCode);
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      return 'Sorry, I\'m having trouble connecting right now. Please try again in a moment. 🔄';
    }
  }

  static String _getErrorResponse(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Oops! I need to be configured properly. Please check that your OpenAI API key is set up correctly. 🔑';
      case 429:
        return 'I\'m getting a lot of requests right now! Please wait a moment and try again. ⏰';
      case 500:
      case 503:
        return 'OpenAI is having some issues right now. Please try again in a few minutes. 🛠️';
      default:
        return 'I encountered an error. Please try asking your question again. 🤔';
    }
  }

  // Get suggested starter questions based on financial context
  static List<String> getSuggestedQuestions({Map<String, dynamic>? financialContext}) {
    final suggestions = [
      'How can I save money as a student?',
      'What\'s a good monthly budget for groceries?',
      'How much should I keep in emergency savings?',
      'Tips for reducing my spending?',
    ];

    // Add context-specific suggestions
    if (financialContext != null) {
      if (financialContext['monthly_spending'] != null) {
        final spending = financialContext['monthly_spending'] as double;
        if (spending > 1000) {
          suggestions.insert(0, 'Is my spending too high this month?');
        }
      }
      if (financialContext['top_category'] != null) {
        final category = financialContext['top_category'] as String;
        suggestions.insert(1, 'How can I spend less on $category?');
      }
    }

    return suggestions.take(4).toList();
  }
}

