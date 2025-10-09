import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import '../models/user_model.dart';
import '../widgets/luni_button.dart';
import '../services/messaging_service.dart';
import '../widgets/luni_button.dart';
import '../services/friends_service.dart';
import '../widgets/luni_button.dart';
import 'chat_screen.dart';
import '../widgets/luni_button.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _friendStatus = 'none'; // 'none', 'pending', 'accepted', 'sent'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendStatus();
  }

  Future<void> _loadFriendStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await FriendsService.getFriendshipStatus(widget.user.id);
      if (mounted) {
        setState(() {
          _friendStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading friend status: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await FriendsService.sendFriendRequest(widget.user.id);
      
      if (mounted) {
        setState(() => _friendStatus = 'sent');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to ${widget.user.fullName}'),
            backgroundColor: const Color(0xFFEAB308),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending friend request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openChat() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEAB308),
          ),
        ),
      );

      // Get or create conversation
      final conversationId = await MessagingService.getOrCreateConversation(widget.user.id);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to chat
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              otherUserId: widget.user.id,
              otherUserName: widget.user.fullName ?? widget.user.username ?? 'User',
              otherUserAvatar: widget.user.avatarUrl,
            ),
          ),
        );

        // After chat, go back to social screen
        if (mounted) {
          Navigator.of(context).pop(); // Pop profile screen
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: $e'),
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
        title: Text(
          '@${widget.user.username ?? 'user'}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Profile Picture
                  _buildAvatar(),
                  
                  SizedBox(height: 16.h),
                  
                  // Full Name
                  Text(
                    widget.user.fullName ?? 'User',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Username
                  Text(
                    '@${widget.user.username ?? 'user'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  SizedBox(height: 24.h),
                  
                  // Stats or Bio (placeholder)
                  _buildStatsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty) {
      return Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFEAB308),
            width: 3,
          ),
          image: DecorationImage(
            image: NetworkImage(widget.user.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback to initials
    final initials = (widget.user.fullName ?? 'U')
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEAB308).withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFEAB308),
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEAB308),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEAB308),
        ),
      );
    }

    return Row(
      children: [
        // Add Friend Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _friendStatus == 'none' ? _sendFriendRequest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _friendStatus == 'none'
                  ? const Color(0xFFEAB308)
                  : Colors.grey.shade300,
              foregroundColor: _friendStatus == 'none'
                  ? Colors.white
                  : Colors.grey.shade600,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(
              _friendStatus == 'accepted'
                  ? Icons.check_circle
                  : _friendStatus == 'sent'
                      ? Icons.schedule
                      : Icons.person_add,
              size: 20.w,
            ),
            label: Text(
              _friendStatus == 'accepted'
                  ? 'Friends'
                  : _friendStatus == 'sent'
                      ? 'Request Sent'
                      : _friendStatus == 'pending'
                          ? 'Accept Request'
                          : 'Add Friend',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // Message Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFEAB308),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(
                  color: Color(0xFFEAB308),
                  width: 2,
                ),
              ),
            ),
            icon: Icon(Icons.message, size: 20.w),
            label: Text(
              'Message',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Friends', '0'),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.grey.shade300,
              ),
              _buildStatItem('LunScore', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

