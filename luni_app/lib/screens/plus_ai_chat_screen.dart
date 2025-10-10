import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/ai_chat_service.dart';
import '../services/backend_service.dart';
import '../widgets/luni_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlusAIChatScreen extends StatefulWidget {
  const PlusAIChatScreen({super.key});

  @override
  State<PlusAIChatScreen> createState() => _PlusAIChatScreenState();
}

class _PlusAIChatScreenState extends State<PlusAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasLoadedContext = false;
  Map<String, dynamic>? _financialContext;
  
  // Chat history
  String? _currentConversationId;
  List<Map<String, dynamic>> _conversations = [];
  bool _showSidebar = false;
  
  // Agent Mode (Auto)
  String? _agentThreadId; // OpenAI thread ID for agent conversations
  final List<AgentAction> _agentActions = [];
  String _currentMode = 'Chat Mode'; // Displays which mode was used: 'Chat Mode' or 'Agent Mode'

  @override
  void initState() {
    super.initState();
    _loadFinancialContext();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialContext() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get user's financial overview
      final accounts = await BackendService.getAccounts();
      final recentTransactions = await BackendService.getTransactions(limit: 100);

      double totalBalance = 0;
      for (var account in accounts) {
        totalBalance += (account['current_balance'] as num?)?.toDouble() ?? 0.0;
      }

      // Calculate this month's spending
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      double monthlySpending = 0;
      String? topCategory;
      final categoryTotals = <String, double>{};

      for (var transaction in recentTransactions) {
        final date = DateTime.parse(transaction['date'] as String);
        final amount = (transaction['amount'] as num).toDouble();
        
        if (date.isAfter(monthStart) && amount < 0) {
          monthlySpending += amount.abs();
          
          final category = transaction['category'] as String? ?? 'Other';
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount.abs();
        }
      }

      // Find top category
      if (categoryTotals.isNotEmpty) {
        topCategory = categoryTotals.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      setState(() {
        _financialContext = {
          'total_balance': totalBalance,
          'monthly_spending': monthlySpending,
          'top_category': topCategory,
          'recent_transactions': recentTransactions.length,
        };
        _hasLoadedContext = true;
      });

      print('💰 Financial context loaded: Balance=\$${totalBalance.toStringAsFixed(2)}, Monthly=\$${monthlySpending.toStringAsFixed(2)}');
    } catch (e) {
      print('⚠️  Could not load financial context: $e');
      setState(() => _hasLoadedContext = true);
    }
  }

  Future<void> _initializeChat() async {
    // Load all conversations
    final conversations = await BackendService.getAIConversations();
    
    if (mounted) {
      setState(() {
        _conversations = conversations;
      });

      // If there are existing conversations, load the most recent one
      if (conversations.isNotEmpty) {
        await _loadConversation(conversations.first['id'] as String);
      } else {
        // Create a new conversation
        await _createNewChat();
      }
    }
  }

  Future<void> _createNewChat() async {
    final conversationId = await BackendService.createAIConversation();
    
    if (conversationId != null && mounted) {
      setState(() {
        _currentConversationId = conversationId;
        _messages.clear();
        _agentActions.clear();
        _currentMode = 'Chat Mode'; // Reset to chat mode for new conversation
      });

      // Always create OpenAI agent thread (for auto mode)
      _agentThreadId = await AIChatService.createAgentThread();
      print('🤖 Agent thread created: $_agentThreadId');

      // Add welcome message and save it
      const welcomeText = 'Hey! 👋 I\'m Luni, your AI financial assistant. I can help with budgeting advice and analyze your spending data when needed.\n\nAsk me anything!';
      
      setState(() {
        _messages.add(ChatMessage(
          text: welcomeText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      // Save welcome message to database
      await BackendService.saveAIMessage(
        conversationId: conversationId,
        role: 'assistant',
        content: welcomeText,
      );

      // Reload conversations list
      await _reloadConversations();
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    final messages = await BackendService.getAIMessages(conversationId);
    
    if (mounted) {
      setState(() {
        _currentConversationId = conversationId;
        _messages.clear();
        _agentActions.clear();
        _currentMode = 'Chat Mode'; // Reset to chat mode
        for (var msg in messages) {
          _messages.add(ChatMessage(
            text: msg['content'] as String,
            isUser: msg['role'] == 'user',
            timestamp: DateTime.parse(msg['created_at'] as String),
          ));
        }
      });

      // Create a new agent thread for this conversation (for auto mode)
      _agentThreadId = await AIChatService.createAgentThread();
      print('🤖 Agent thread created for loaded conversation: $_agentThreadId');

      _scrollToBottom();
    }
  }

  Future<void> _reloadConversations() async {
    final conversations = await BackendService.getAIConversations();
    if (mounted) {
      setState(() {
        _conversations = conversations;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _currentConversationId == null) return;

    final userMessage = text.trim();
    _messageController.clear();

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _agentActions.clear(); // Clear previous agent actions
    });

    _scrollToBottom();

    // Save user message to database
    await BackendService.saveAIMessage(
      conversationId: _currentConversationId!,
      role: 'user',
      content: userMessage,
    );

    // Auto-generate title from first user message
    if (_messages.where((m) => m.isUser).length == 1) {
      final title = userMessage.length > 50 
          ? '${userMessage.substring(0, 50)}...' 
          : userMessage;
      await BackendService.updateAIConversationTitle(
        conversationId: _currentConversationId!,
        title: title,
      );
      await _reloadConversations();
    }

    try {
      // ======== AUTO MODE (AI decides whether to use tools) ========
      bool usedTools = false;
      
      if (_agentThreadId != null) {
        await AIChatService.sendMessageWithAgent(
          userMessage: userMessage,
          threadId: _agentThreadId!,
          onAgentAction: (action, status, data) {
            if (!mounted) return;
            
            setState(() {
              if (status == 'running') {
                usedTools = true; // Mark that tools are being used
                _currentMode = 'Agent Mode'; // Switch to Agent Mode display
                _agentActions.add(AgentAction(
                  name: action,
                  status: 'running',
                  description: _getActionDescription(action),
                  data: data,
                ));
                print('🔄 Agent action: $action (running) - Auto mode activated');
              } else if (status == 'complete') {
                final index = _agentActions.indexWhere(
                  (a) => a.name == action && a.status == 'running'
                );
                if (index != -1) {
                  _agentActions[index] = _agentActions[index].copyWith(
                    status: 'complete',
                    data: data,
                  );
                  print('✅ Agent action: $action (complete)');
                }
              }
            });
            _scrollToBottom();
          },
          onResponse: (aiResponse) async {
            if (!mounted) return;
            
            // If no tools were used, this was just a chat response
            if (!usedTools) {
              setState(() {
                _currentMode = 'Chat Mode';
              });
              print('💬 No tools used - stayed in Chat Mode');
            }
            
            setState(() {
              _messages.add(ChatMessage(
                text: aiResponse,
                isUser: false,
                timestamp: DateTime.now(),
              ));
              _isLoading = false;
            });

            await BackendService.saveAIMessage(
              conversationId: _currentConversationId!,
              role: 'assistant',
              content: aiResponse,
            );

            _scrollToBottom();
          },
          onError: (error) async {
            if (!mounted) return;
            
            setState(() {
              _messages.add(ChatMessage(
                text: error,
                isUser: false,
                timestamp: DateTime.now(),
              ));
              _isLoading = false;
            });
            _scrollToBottom();
          },
        );
      } else {
        // Fallback if no agent thread (shouldn't happen)
        print('⚠️ No agent thread available');
        setState(() {
          _messages.add(ChatMessage(
            text: 'Sorry, I\'m having trouble connecting. Please try creating a new chat.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error in _sendMessage: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again! 🔄',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }
  
  String _getActionDescription(String action) {
    switch (action) {
      case 'get_transactions':
        return 'Reading your transactions...';
      case 'get_spending_by_category':
        return 'Analyzing spending by category...';
      case 'get_account_balances':
        return 'Checking account balances...';
      case 'find_transactions':
        return 'Searching transactions...';
      case 'get_all_categories':
        return 'Loading spending categories...';
      case 'get_uncategorized_count':
        return 'Checking uncategorized transactions...';
      case 'get_friends':
        return 'Looking up your friends...';
      case 'get_groups':
        return 'Loading your groups...';
      case 'get_group_details':
        return 'Getting group details...';
      case 'get_person_split_history':
        return 'Checking split history...';
      case 'get_split_queue':
        return 'Loading pending splits...';
      default:
        return 'Processing...';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Header (extends into status bar)
              _buildHeader(),
              
              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
              ),
              
              // Suggested questions (only show at start)
              if (_messages.length <= 1 && _hasLoadedContext)
                _buildSuggestedQuestions(),
              
              // Input field
              _buildInputField(),
            ],
          ),
          
          // Sidebar overlay
          if (_showSidebar) _buildSidebar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isAgentMode = _currentMode == 'Agent Mode';
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 12.h, // Status bar height + extra padding
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFfdf3c6), // #fdf3c6 - Light warm cream/gold from Figma
            const Color(0xFFfefbf0), // Subtle intermediate warm tone
            const Color(0xFFffffff), // Pure white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 1.0], // Steeper transition from gold to white
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFfdf3c6).withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          LuniIconButton(
            icon: Icons.menu,
            onPressed: () => setState(() => _showSidebar = !_showSidebar),
            color: Colors.black87,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAgentMode 
                    ? [const Color(0xFFEAB308), const Color(0xFFD4AF37)]
                    : [const Color(0xFFf8d777), const Color(0xFFfdf0b6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isAgentMode ? Icons.psychology_rounded : Icons.chat_bubble_outline,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Luni AI',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isAgentMode 
                            ? const Color(0xFFEAB308) 
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _currentMode, // Shows 'Chat Mode' or 'Agent Mode'
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          LuniIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
            color: Colors.black87,
            size: 24.w,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80.w,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a conversation with Luni!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: _messages.length + _agentActions.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show messages first
        if (index < _messages.length) {
          return _buildMessageBubble(_messages[index]);
        }
        
        // Show agent actions after messages
        final actionIndex = index - _messages.length;
        if (actionIndex < _agentActions.length) {
          return _buildAgentAction(_agentActions[actionIndex]);
        }
        
        // Show loading indicator last
        return _buildLoadingIndicator();
      },
    );
  }
  
  Widget _buildAgentAction(AgentAction action) {
    final isComplete = action.status == 'complete';
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isComplete 
              ? Colors.green.shade50 
              : const Color(0xFFEAB308).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isComplete ? Colors.green : const Color(0xFFEAB308),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isComplete ? Colors.green : const Color(0xFFEAB308),
                shape: BoxShape.circle,
              ),
              child: isComplete 
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20.w,
                    )
                  : SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 Agent Action',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    action.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (isComplete && action.data != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _getActionSummary(action),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getActionSummary(AgentAction action) {
    if (action.data == null) return '';
    
    try {
      switch (action.name) {
        case 'get_transactions':
          final count = action.data!['count'] ?? 0;
          final total = action.data!['total_amount'] ?? 0.0;
          return 'Found $count transactions totaling \$${total.toStringAsFixed(2)}';
          
        case 'get_spending_by_category':
          final total = action.data!['total_spending'] ?? 0.0;
          final categories = action.data!['categories'] as List? ?? [];
          final transactionCount = action.data!['transaction_count'] ?? 0;
          
          if (categories.isNotEmpty) {
            final topCategory = categories.first as Map<String, dynamic>;
            final topName = topCategory['category'] as String;
            final topAmount = topCategory['total'] as double;
            return 'Found ${categories.length} categories ($transactionCount transactions). Top: $topName (\$${topAmount.toStringAsFixed(2)})';
          }
          return 'Analyzed ${categories.length} categories, \$${total.toStringAsFixed(2)} total';
          
        case 'get_account_balances':
          final total = action.data!['total_balance'] ?? 0.0;
          final accounts = action.data!['accounts'] as List? ?? [];
          return '${accounts.length} accounts, \$${total.toStringAsFixed(2)} total balance';
          
        case 'find_transactions':
          final count = action.data!['count'] ?? 0;
          return 'Found $count matching transactions';
          
        case 'get_all_categories':
          final count = action.data!['count'] ?? 0;
          return 'Found $count spending categories';
          
        case 'get_uncategorized_count':
          final count = action.data!['count'] ?? 0;
          return count > 0 
              ? '$count transactions need categorization'
              : 'All transactions categorized';
          
        case 'get_friends':
          final count = action.data!['count'] ?? 0;
          return 'You have $count friend${count == 1 ? '' : 's'}';
          
        case 'get_groups':
          final count = action.data!['count'] ?? 0;
          return 'You have $count group${count == 1 ? '' : 's'}';
          
        case 'get_group_details':
          final groupName = action.data!['group_name'] ?? 'Unknown';
          final memberCount = action.data!['member_count'] ?? 0;
          return 'Group "$groupName" has $memberCount member${memberCount == 1 ? '' : 's'}';
          
        case 'get_person_split_history':
          final person = action.data!['person'] ?? 'Unknown';
          final netBalance = action.data!['net_balance'] ?? 0.0;
          if (netBalance > 0) {
            return '$person owes you \$${netBalance.toStringAsFixed(2)}';
          } else if (netBalance < 0) {
            return 'You owe $person \$${(-netBalance).toStringAsFixed(2)}';
          } else {
            return 'You and $person are settled up';
          }
          
        case 'get_split_queue':
          final count = action.data!['count'] ?? 0;
          return count > 0 
              ? '$count transaction${count == 1 ? '' : 's'} waiting to be split'
              : 'No pending splits';
          
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAB308), Color(0xFFD4AF37)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 18.w,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFFEAB308)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: message.isUser ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: message.isUser ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8.w),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey.shade700,
                size: 18.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAB308), Color(0xFFD4AF37)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 18.w,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4.w),
                _buildDot(1),
                SizedBox(width: 4.w),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      onEnd: () {
        if (mounted && _isLoading) {
          setState(() {}); // Restart animation
        }
      },
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final scale = 0.5 + (animValue * 0.5);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = AIChatService.getSuggestedQuestions(
      financialContext: _financialContext,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Suggested questions:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: suggestions.map((question) {
              return LuniGestureDetector(
                onTap: () => _sendMessage(question),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFFEAB308),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            SizedBox(width: 8.w),
            LuniGestureDetector(
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(_messageController.text),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFEAB308), Color(0xFFD4AF37)],
                        ),
                  color: _isLoading ? Colors.grey.shade300 : null,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return LuniGestureDetector(
      onTap: () => setState(() => _showSidebar = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Row(
          children: [
            LuniGestureDetector(
              onTap: () {}, // Prevent tap-through
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                color: Colors.white,
                child: Column(
                  children: [
                    // Sidebar header
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEAB308), Color(0xFFD4AF37)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Chat History',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          LuniIconButton(
                            icon: Icons.add,
                            onPressed: () {
                              _createNewChat();
                              setState(() => _showSidebar = false);
                            },
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ],
                      ),
                    ),
                    
                    // Conversations list
                    Expanded(
                      child: _conversations.isEmpty
                          ? Center(
                              child: Text(
                                'No conversations yet',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              itemCount: _conversations.length,
                              itemBuilder: (context, index) {
                                final conversation = _conversations[index];
                                final isActive = conversation['id'] == _currentConversationId;
                                
                                return LuniGestureDetector(
                                  onTap: () {
                                    _loadConversation(conversation['id'] as String);
                                    setState(() => _showSidebar = false);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFFEAB308).withOpacity(0.1) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isActive ? const Color(0xFFEAB308) : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 20.w,
                                          color: isActive ? const Color(0xFFEAB308) : Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                conversation['title'] as String,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                _formatDate(DateTime.parse(conversation['updated_at'] as String)),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isActive)
                                          LuniIconButton(
                                            icon: Icons.delete_outline,
                                            onPressed: () async {
                                              await BackendService.deleteAIConversation(conversation['id'] as String);
                                              await _reloadConversations();
                                            },
                                            color: Colors.red,
                                            size: 20.w,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AgentAction {
  final String name;
  final String status;
  final String description;
  final Map<String, dynamic>? data;

  AgentAction({
    required this.name,
    required this.status,
    required this.description,
    this.data,
  });

  AgentAction copyWith({
    String? status,
    Map<String, dynamic>? data,
  }) {
    return AgentAction(
      name: name,
      status: status ?? this.status,
      description: description,
      data: data ?? this.data,
    );
  }
}

