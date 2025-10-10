import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'backend_service.dart';
import 'dart:async';
import '../models/category_model.dart';

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
          'description': 'Calculate total spending for each category with detailed breakdown. Returns categories with totals, transaction counts, and subcategories. Use when user asks about category breakdowns, spending patterns, where they spend most, or which category has the most transactions. Categories include: Food, Entertainment, Transportation, Living Essentials, Education, Healthcare, Vacation.',
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
          'description': 'Get current balance of all user accounts with dynamic calculation. Returns account names, types, balances (in CAD), and total balance. Use when user asks about their balance, how much money they have, net worth, or account status. Balances are automatically converted to CAD.',
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
      // === CATEGORIES ===
      {
        'type': 'function',
        'function': {
          'name': 'get_all_categories',
          'description': 'Get all available spending categories and subcategories. Use when user asks about categories, what categories exist, or wants to know categorization options.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_uncategorized_count',
          'description': 'Get count of uncategorized transactions that need review. Use when user asks about pending transactions or what needs to be categorized.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      // === SOCIAL & SPLITS ===
      {
        'type': 'function',
        'function': {
          'name': 'get_friends',
          'description': 'Get list of user\'s friends. Use when user asks about their friends, who they can split with, or social connections.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_groups',
          'description': 'Get list of user\'s groups. Use when user asks about their groups or who they split expenses with.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_group_details',
          'description': 'Get detailed information about a specific group including members and balances. Use when user asks about a specific group, who owes who, or group expenses.',
          'parameters': {
            'type': 'object',
            'properties': {
              'group_name': {
                'type': 'string',
                'description': 'Name of the group to get details for',
              },
            },
            'required': ['group_name'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_person_split_history',
          'description': 'Get split transaction history with a specific person. Use when user asks about what they owe someone or what someone owes them.',
          'parameters': {
            'type': 'object',
            'properties': {
              'person_name': {
                'type': 'string',
                'description': 'Name or username of the person',
              },
            },
            'required': ['person_name'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_split_queue',
          'description': 'Get pending split transactions that need to be assigned. Use when user asks about pending splits or what needs to be split.',
          'parameters': {
            'type': 'object',
            'properties': {},
          },
        },
      },
    ];
  }

  /// Execute agent tool functions
  /// 
  /// 🔒 SECURITY: All data access is automatically filtered by the current user.
  /// BackendService uses Supabase.instance.client which includes the user's JWT token.
  /// Supabase Row Level Security (RLS) policies enforce that users can ONLY access
  /// their own data (transactions, accounts, friends, groups, etc.).
  /// No user can access another user's data through the AI agent.
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
          final categoryDetails = <String, Map<String, dynamic>>{};
          int processedCount = 0;

          for (var t in transactions) {
            try {
              final date = DateTime.parse(t['date'] as String);
              if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  date.isBefore(endDate.add(const Duration(days: 1)))) {
                final category = t['category'] as String? ?? 'Uncategorized';
                final subcategory = t['subcategory'] as String?;
                final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                
                if (amount < 0) { // Only count expenses
                  categoryTotals[category] =
                      (categoryTotals[category] ?? 0) + amount.abs();
                  
                  // Track subcategories and transaction count
                  if (!categoryDetails.containsKey(category)) {
                    categoryDetails[category] = {
                      'transaction_count': 0,
                      'subcategories': <String>{},
                    };
                  }
                  categoryDetails[category]!['transaction_count'] = 
                      (categoryDetails[category]!['transaction_count'] as int) + 1;
                  
                  if (subcategory != null) {
                    (categoryDetails[category]!['subcategories'] as Set<String>).add(subcategory);
                  }
                  
                  processedCount++;
                }
              }
            } catch (e) {
              // Skip transactions with invalid dates
              continue;
            }
          }

          final sorted = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final totalSpending = sorted.fold(0.0, (sum, e) => sum + e.value);

          print('✅ Agent tool: Found ${sorted.length} categories from $processedCount transactions');
          print('   Top 3: ${sorted.take(3).map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}');

          return {
            'categories': sorted
                .map((e) => {
                      'category': e.key,
                      'total': e.value,
                      'transaction_count': categoryDetails[e.key]!['transaction_count'],
                      'subcategories': (categoryDetails[e.key]!['subcategories'] as Set<String>).toList(),
                    })
                .toList(),
            'total_spending': totalSpending,
            'transaction_count': processedCount,
          };

        case 'get_account_balances':
          final accounts = await BackendService.getAccounts();
          
          double totalBalance = 0.0;
          final accountList = <Map<String, dynamic>>[];
          
          for (var account in accounts) {
            // BackendService.getAccounts() returns 'balance' field (not 'current_balance')
            // Use safer null handling to avoid type cast errors
            final balanceValue = account['balance'];
            final balance = (balanceValue is num) ? balanceValue.toDouble() : 0.0;
            
            final name = account['name'] as String? ?? 'Unknown Account';
            final type = account['type'] as String? ?? 'Unknown Type';
            final currency = account['display_currency'] as String? ?? 'CAD';
            
            accountList.add({
              'name': name,
              'balance': balance,
              'type': type,
              'currency': currency,
            });
            
            totalBalance += balance;
          }
          
          print('✅ Agent tool: Found ${accountList.length} accounts, total: \$${totalBalance.toStringAsFixed(2)}');
          
          return {
            'accounts': accountList,
            'total_balance': totalBalance,
            'currency': 'CAD',
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

        case 'get_all_categories':
          final categories = await BackendService.getCategories();
          
          // Group categories by parent
          final Map<String, List<String>> grouped = {};
          for (var cat in categories) {
            if (!grouped.containsKey(cat.parentKey)) {
              grouped[cat.parentKey] = [];
            }
            grouped[cat.parentKey]!.add(cat.name);
          }
          
          final categoryList = grouped.entries.map((entry) => {
            'parent': entry.key,
            'parent_display': CategoryModel.getParentDisplayName(entry.key),
            'icon': CategoryModel.getParentIcon(entry.key),
            'subcategories': entry.value,
            'count': entry.value.length,
          }).toList();
          
          print('✅ Agent tool: Found ${categoryList.length} parent categories with ${categories.length} subcategories');
          
          return {
            'categories': categoryList,
            'parent_count': categoryList.length,
            'total_count': categories.length,
          };

        case 'get_uncategorized_count':
          final count = await BackendService.getUncategorizedCount();
          
          print('✅ Agent tool: Found $count uncategorized transactions');
          
          return {
            'count': count,
            'message': count > 0 
                ? '$count transactions need to be categorized'
                : 'All transactions are categorized',
          };

        case 'get_friends':
          final friends = await BackendService.getFriends();
          
          final friendList = friends.map((f) => {
            'username': f['username'] as String? ?? 'Unknown',
            'full_name': f['full_name'] as String? ?? '',
            'profile_image': f['profile_image_url'] as String?,
          }).toList();
          
          print('✅ Agent tool: Found ${friendList.length} friends');
          
          return {
            'friends': friendList,
            'count': friendList.length,
          };

        case 'get_groups':
          final groups = await BackendService.getUserGroups();
          
          final groupList = groups.map((g) => {
            'name': g['name'] as String? ?? 'Unknown',
            'created_at': g['created_at'] as String?,
          }).toList();
          
          print('✅ Agent tool: Found ${groupList.length} groups');
          
          return {
            'groups': groupList,
            'count': groupList.length,
          };

        case 'get_group_details':
          final groupName = arguments['group_name'] as String;
          final groups = await BackendService.getUserGroups();
          
          // Find the group by name
          final group = groups.firstWhere(
            (g) => (g['name'] as String).toLowerCase() == groupName.toLowerCase(),
            orElse: () => <String, dynamic>{},
          );
          
          if (group.isEmpty) {
            return {
              'error': 'Group "$groupName" not found',
              'available_groups': groups.map((g) => g['name']).toList(),
            };
          }
          
          final groupId = group['id'] as String;
          final details = await BackendService.getGroupDetails(groupId);
          
          print('✅ Agent tool: Got details for group "$groupName"');
          
          return {
            'group_name': details['group_name'],
            'member_count': details['member_count'],
            'members': details['members'],
            'balances': details['balances'],
            'transactions': details['transactions'],
          };

        case 'get_person_split_history':
          final personName = arguments['person_name'] as String;
          final friends = await BackendService.getFriends();
          
          // Find the person by username or full name
          final person = friends.firstWhere(
            (f) {
              final username = (f['username'] as String? ?? '').toLowerCase();
              final fullName = (f['full_name'] as String? ?? '').toLowerCase();
              final search = personName.toLowerCase();
              return username.contains(search) || fullName.contains(search);
            },
            orElse: () => <String, dynamic>{},
          );
          
          if (person.isEmpty) {
            return {
              'error': 'Person "$personName" not found',
              'available_people': friends.map((f) => f['username']).toList(),
            };
          }
          
          final userId = person['id'] as String;
          final history = await BackendService.getPersonSplitHistory(userId);
          
          print('✅ Agent tool: Got split history with "${person['username']}"');
          
          return {
            'person': person['username'],
            'full_name': person['full_name'],
            'you_owe': history['you_owe'],
            'they_owe': history['they_owe'],
            'net_balance': history['net_balance'],
            'recent_transactions': history['transactions'],
          };

        case 'get_split_queue':
          final queue = await BackendService.getSplitQueue();
          
          final queueList = queue.map((t) => {
            'description': t.aiDescription ?? t.description,
            'amount': t.amount,
            'date': t.date.toString().split(' ')[0],
          }).toList();
          
          print('✅ Agent tool: Found ${queueList.length} items in split queue');
          
          return {
            'count': queueList.length,
            'transactions': queueList,
            'message': queueList.isEmpty 
                ? 'No pending split transactions'
                : '${queueList.length} transactions waiting to be split',
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

