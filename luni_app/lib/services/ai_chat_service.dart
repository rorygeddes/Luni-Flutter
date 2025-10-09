import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'backend_service.dart';
import 'dart:async';

class AIChatService {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _assistantsUrl = 'https://api.openai.com/v1/assistants';
  static const String _threadsUrl = 'https://api.openai.com/v1/threads';
  
  // Store assistant ID (create once, reuse)
  static String? _assistantId;

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

  // ============================================================================
  // AGENT MODE - OpenAI Assistants API
  // ============================================================================

  /// Initialize or get the Luni financial agent assistant
  static Future<String> _getOrCreateAssistant() async {
    if (_assistantId != null) return _assistantId!;

    try {
      final response = await http.post(
        Uri.parse(_assistantsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2',
        },
        body: json.encode({
          'name': 'Luni Financial Agent',
          'instructions': '''You are Luni Agent, an advanced AI financial assistant with access to the user's complete financial data.

Your personality:
- Friendly, supportive, and data-driven
- Analytical but easy to understand
- Encouraging (never judgmental)
- Specific with numbers and insights

When to use tools:
- ALWAYS use tools when user asks about their spending, transactions, balances, or categories
- Use get_transactions for detailed transaction analysis
- Use get_spending_by_category for category breakdowns
- Use get_account_balances for balance checks
- Use find_transactions to search for specific purchases

Communication style:
- Start by explaining what you're looking at
- Present findings with specific numbers
- Offer actionable insights
- Keep responses concise but informative''',
          'model': 'gpt-4o',
          'tools': _getAgentTools(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _assistantId = data['id'] as String;
        print('✅ Created Luni Agent: $_assistantId');
        return _assistantId!;
      } else {
        print('❌ Error creating assistant: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create assistant');
      }
    } catch (e) {
      print('❌ Error in _getOrCreateAssistant: $e');
      rethrow;
    }
  }

  /// Send message with agent mode (uses Assistants API)
  static Future<void> sendMessageWithAgent({
    required String userMessage,
    required String threadId,
    required Function(String action, String status, Map<String, dynamic>? data) onAgentAction,
    required Function(String response) onResponse,
    required Function(String error) onError,
  }) async {
    try {
      print('🤖 Agent mode: Sending message...');
      
      // Get or create assistant
      final assistantId = await _getOrCreateAssistant();

      // Add message to thread
      await http.post(
        Uri.parse('$_threadsUrl/$threadId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2',
        },
        body: json.encode({
          'role': 'user',
          'content': userMessage,
        }),
      );

      // Create and run
      final runResponse = await http.post(
        Uri.parse('$_threadsUrl/$threadId/runs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2',
        },
        body: json.encode({
          'assistant_id': assistantId,
        }),
      );

      if (runResponse.statusCode != 200) {
        throw Exception('Failed to create run: ${runResponse.body}');
      }

      final runData = json.decode(runResponse.body);
      final runId = runData['id'] as String;

      // Poll for completion
      await _pollRunStatus(
        threadId: threadId,
        runId: runId,
        onAgentAction: onAgentAction,
        onResponse: onResponse,
        onError: onError,
      );
    } catch (e) {
      print('❌ Error in sendMessageWithAgent: $e');
      onError('Sorry, I encountered an error. Please try again.');
    }
  }

  /// Poll run status and handle tool calls
  static Future<void> _pollRunStatus({
    required String threadId,
    required String runId,
    required Function(String action, String status, Map<String, dynamic>? data) onAgentAction,
    required Function(String response) onResponse,
    required Function(String error) onError,
  }) async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await http.get(
        Uri.parse('$_threadsUrl/$threadId/runs/$runId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2',
        },
      );

      if (response.statusCode != 200) {
        onError('Failed to check run status');
        return;
      }

      final data = json.decode(response.body);
      final status = data['status'] as String;

      print('🔄 Run status: $status');

      switch (status) {
        case 'completed':
          // Get the assistant's response
          final messagesResponse = await http.get(
            Uri.parse('$_threadsUrl/$threadId/messages?limit=1'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'OpenAI-Beta': 'assistants=v2',
            },
          );

          if (messagesResponse.statusCode == 200) {
            final messagesData = json.decode(messagesResponse.body);
            final messages = messagesData['data'] as List;
            if (messages.isNotEmpty) {
              final content = messages[0]['content'] as List;
              if (content.isNotEmpty) {
                final text = content[0]['text']['value'] as String;
                onResponse(text);
              }
            }
          }
          return;

        case 'requires_action':
          // Handle tool calls
          final requiredAction = data['required_action'];
          if (requiredAction != null) {
            final toolCalls = requiredAction['submit_tool_outputs']['tool_calls'] as List;
            final toolOutputs = <Map<String, dynamic>>[];

            for (var toolCall in toolCalls) {
              final toolCallId = toolCall['id'] as String;
              final functionName = toolCall['function']['name'] as String;
              final arguments = json.decode(toolCall['function']['arguments'] as String);

              // Notify UI of agent action
              onAgentAction(functionName, 'running', arguments);

              // Execute the tool
              final result = await _executeAgentTool(functionName, arguments);

              // Notify completion
              onAgentAction(functionName, 'complete', result);

              toolOutputs.add({
                'tool_call_id': toolCallId,
                'output': json.encode(result),
              });
            }

            // Submit tool outputs
            await http.post(
              Uri.parse('$_threadsUrl/$threadId/runs/$runId/submit_tool_outputs'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
                'OpenAI-Beta': 'assistants=v2',
              },
              body: json.encode({
                'tool_outputs': toolOutputs,
              }),
            );
          }
          break;

        case 'failed':
        case 'cancelled':
        case 'expired':
          onError('The request $status. Please try again.');
          return;
      }
    }
  }

  /// Create a new thread for agent conversation
  static Future<String?> createAgentThread() async {
    try {
      final response = await http.post(
        Uri.parse(_threadsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2',
        },
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final threadId = data['id'] as String;
        print('✅ Created agent thread: $threadId');
        return threadId;
      }
    } catch (e) {
      print('❌ Error creating thread: $e');
    }
    return null;
  }

  /// Define agent tools for OpenAI Assistants
  static List<Map<String, dynamic>> _getAgentTools() {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'get_transactions',
          'description': 'Get user transactions for analysis. Use when user asks about spending, transactions, or where money went. Returns up to 20 most relevant transactions.',
          'parameters': {
            'type': 'object',
            'properties': {
              'start_date': {
                'type': 'string',
                'description': 'Start date in YYYY-MM-DD format',
              },
              'end_date': {
                'type': 'string',
                'description': 'End date in YYYY-MM-DD format',
              },
              'category': {
                'type': 'string',
                'description': 'Optional: filter by category (e.g., "Food", "Entertainment")',
              },
            },
            'required': ['start_date', 'end_date'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_spending_by_category',
          'description': 'Calculate total spending for each category. Use when user asks about category breakdowns or which category they spend most on.',
          'parameters': {
            'type': 'object',
            'properties': {
              'start_date': {
                'type': 'string',
                'description': 'Start date in YYYY-MM-DD format',
              },
              'end_date': {
                'type': 'string',
                'description': 'End date in YYYY-MM-DD format',
              },
            },
            'required': ['start_date', 'end_date'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_account_balances',
          'description': 'Get current balance of all user accounts. Use when user asks about their balance, how much money they have, or account status.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'find_transactions',
          'description': 'Search for specific transactions by keyword or merchant name. Use when user asks about specific purchases, stores, or merchants.',
          'parameters': {
            'type': 'object',
            'properties': {
              'keyword': {
                'type': 'string',
                'description': 'Search term to find in transaction descriptions',
              },
            },
            'required': ['keyword'],
          },
        },
      },
    ];
  }

  /// Execute agent tool functions
  static Future<Map<String, dynamic>> _executeAgentTool(
    String functionName,
    Map<String, dynamic> arguments,
  ) async {
    print('🤖 Executing: $functionName with args: $arguments');

    try {
      switch (functionName) {
        case 'get_transactions':
          final transactions = await BackendService.getTransactions(limit: 500);
          final startDate = DateTime.parse(arguments['start_date']);
          final endDate = DateTime.parse(arguments['end_date']);

          final filtered = transactions.where((t) {
            try {
              final date = DateTime.parse(t['date'] as String);
              return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
                     date.isBefore(endDate.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          }).toList();

          // Filter by category if provided
          if (arguments['category'] != null) {
            final category = arguments['category'] as String;
            filtered.removeWhere((t) =>
                (t['category'] as String?)?.toLowerCase() !=
                category.toLowerCase());
          }

          final total = filtered.fold(0.0, (sum, t) {
            final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
            return sum + amount.abs();
          });

          return {
            'count': filtered.length,
            'total_amount': total,
            'transactions': filtered.take(20).map((t) => {
                  'description': t['ai_description'] ?? t['description'] ?? 'Unknown',
                  'amount': (t['amount'] as num?)?.toDouble() ?? 0.0,
                  'category': t['category'] ?? 'Uncategorized',
                  'date': t['date'] ?? '',
                }).toList(),
          };

        case 'get_spending_by_category':
          final transactions = await BackendService.getTransactions(limit: 500);
          final startDate = DateTime.parse(arguments['start_date']);
          final endDate = DateTime.parse(arguments['end_date']);

          final categoryTotals = <String, double>{};

          for (var t in transactions) {
            try {
              final date = DateTime.parse(t['date'] as String);
              if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  date.isBefore(endDate.add(const Duration(days: 1)))) {
                final category = t['category'] as String? ?? 'Uncategorized';
                final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                if (amount < 0) {
                  categoryTotals[category] =
                      (categoryTotals[category] ?? 0) + amount.abs();
                }
              }
            } catch (e) {
              // Skip transactions with invalid dates
              continue;
            }
          }

          final sorted = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return {
            'categories': sorted
                .map((e) => {
                      'category': e.key,
                      'total': e.value,
                    })
                .toList(),
            'total_spending': sorted.fold(0.0, (sum, e) => sum + e.value),
          };

        case 'get_account_balances':
          final accounts = await BackendService.getAccounts();
          
          double totalBalance = 0.0;
          final accountList = <Map<String, dynamic>>[];
          
          for (var account in accounts) {
            final balance = (account['current_balance'] as num?)?.toDouble() ?? 0.0;
            final name = account['name'] as String? ?? 'Unknown Account';
            final type = account['type'] as String? ?? 'Unknown Type';
            
            accountList.add({
              'name': name,
              'balance': balance,
              'type': type,
            });
            
            totalBalance += balance;
          }
          
          return {
            'accounts': accountList,
            'total_balance': totalBalance,
          };

        case 'find_transactions':
          final keyword = arguments['keyword'] as String;
          final transactions = await BackendService.getTransactions(limit: 500);

          final matches = transactions.where((t) {
            try {
              final desc = ((t['ai_description'] ?? t['description']) as String?) ?? '';
              return desc.toLowerCase().contains(keyword.toLowerCase());
            } catch (e) {
              return false;
            }
          }).toList();

          return {
            'count': matches.length,
            'transactions': matches
                .take(10)
                .map((t) => {
                      'description': t['ai_description'] ?? t['description'] ?? 'Unknown',
                      'amount': (t['amount'] as num?)?.toDouble() ?? 0.0,
                      'category': t['category'] ?? 'Uncategorized',
                      'date': t['date'] ?? '',
                    })
                .toList(),
          };

        default:
          return {'error': 'Unknown function: $functionName'};
      }
    } catch (e) {
      print('❌ Error executing $functionName: $e');
      return {'error': e.toString()};
    }
  }
}

