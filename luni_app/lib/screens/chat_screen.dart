import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import 'package:intl/intl.dart';
import '../widgets/luni_button.dart';
import '../services/messaging_service.dart';
import '../widgets/luni_button.dart';
import '../services/auth_service.dart';
import '../widgets/luni_button.dart';
import '../models/message_model.dart';
import '../widgets/luni_button.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    try {
      final messages = await MessagingService.getMessages(widget.conversationId);
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // Scroll to bottom
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
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await MessagingService.markMessagesAsRead(widget.conversationId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final message = await MessagingService.sendMessage(
        conversationId: widget.conversationId,
        messageText: messageText,
      );

      if (mounted) {
        setState(() {
          _messages.add(message);
          _isSending = false;
        });

        // Scroll to bottom
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
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Active now',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEAB308),
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64.w,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Send a message to start the conversation',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == AuthService.currentUser?.id;
                          
                          // Show date separator if this is a new day
                          final showDate = index == 0 ||
                              !_isSameDay(_messages[index - 1].createdAt, message.createdAt);
                          
                          return Column(
                            children: [
                              if (showDate) _buildDateSeparator(message.createdAt),
                              _buildMessageBubble(message, isMe),
                            ],
                          );
                        },
                      ),
          ),
          
          // Input Field
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.otherUserAvatar != null && widget.otherUserAvatar!.isNotEmpty) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(widget.otherUserAvatar!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback to initials
    final initials = widget.otherUserName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEAB308).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEAB308),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    String dateText;
    if (_isSameDay(date, now)) {
      dateText = 'Today';
    } else if (difference.inDays == 1) {
      dateText = 'Yesterday';
    } else if (difference.inDays < 7) {
      dateText = DateFormat('EEEE').format(date);
    } else {
      dateText = DateFormat('MMM d, yyyy').format(date);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFEAB308) : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.messageText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.createdAt.toLocal()),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14.w,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          LuniGestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _isSending 
                    ? Colors.grey.shade300 
                    : const Color(0xFFEAB308),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20.w,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

