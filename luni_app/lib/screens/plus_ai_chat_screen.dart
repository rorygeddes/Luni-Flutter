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

  @override
  void initState() {
    super.initState();
    _loadFinancialContext();
    _addWelcomeMessage();
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

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: 'Hey! 👋 I\'m Luni, your personal finance assistant. I can help you understand your spending, create budgets, and answer any money questions you have!\n\nWhat would you like to know?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

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
    });

    _scrollToBottom();

    try {
      // Build conversation history (last 10 messages for context)
      final history = _messages
          .where((m) => m.text != 'Hey! 👋 I\'m Luni, your personal finance assistant. I can help you understand your spending, create budgets, and answer any money questions you have!\n\nWhat would you like to know?') // Exclude welcome
          .skip(_messages.length > 11 ? _messages.length - 11 : 0)
          .take(10)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      // Get AI response
      final aiResponse = await AIChatService.sendMessage(
        userMessage: userMessage,
        conversationHistory: history,
        financialContext: _financialContext,
      );

      // Add AI response
      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAB308), Color(0xFFD4AF37)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luni AI',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
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
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildLoadingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
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

