import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with AutomaticKeepAliveClientMixin {
  List<ConversationModel> _conversations = [];
  List<UserModel> _allUsers = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  int _selectedTab = 0; // 0 = Messages, 1 = Friends, 2 = Discover

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        MessagingService.getConversations(),
        BackendService.getFriends(),
        MessagingService.getAllUsers(),
      ]);

      if (mounted) {
        setState(() {
          _conversations = results[0] as List<ConversationModel>;
          _friends = results[1] as List<Map<String, dynamic>>;
          _allUsers = results[2] as List<UserModel>;
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      print('Error loading social data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  void _openSearch() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    );
    
    // Reload conversations when returning from search
    _loadData();
  }

  void _showPublicProfile(String userId, String userName, String? avatarUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text(
                        'Public Profile',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          // Avatar
                          _buildAvatar(avatarUrl, userName),
                          SizedBox(height: 16.h),
                          // Name
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Categories Section
                          Text(
                            'Spending Categories',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'User categories will appear here',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading && !_hasLoadedOnce) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEAB308),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            _buildHeader(),
            
            // Search bar button (only show in Discover tab)
            if (_selectedTab == 2) _buildSearchButton(),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _selectedTab == 0 
                    ? _buildMessagesTab() 
                    : _selectedTab == 1
                        ? _buildFriendsTab()
                        : _buildDiscoverTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          // Tab selector
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 
                            ? const Color(0xFFEAB308) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Messages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 0 
                              ? Colors.white 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 
                            ? const Color(0xFFEAB308) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Friends',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 1 
                              ? Colors.white 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 2),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedTab == 2 
                            ? const Color(0xFFEAB308) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Discover',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 2 
                              ? Colors.white 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _openSearch,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade400, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              'Search by username...',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (_conversations.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Go to Discover to find people to chat with',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationCard(_conversations[index]);
      },
    );
  }

  Widget _buildFriendsTab() {
    if (_friends.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No friends yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Go to Discover to find and add friends',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildDiscoverTab() {
    if (_allUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No users available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_allUsers[index]);
      },
    );
  }

  Widget _buildConversationCard(ConversationModel conversation) {
    final hasUnread = conversation.unreadCount > 0;
    
    return GestureDetector(
      onTap: () async {
        // Navigate to chat
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              otherUserId: conversation.user1Id == AuthService.currentUser?.id 
                  ? conversation.user2Id 
                  : conversation.user1Id,
              otherUserName: conversation.otherUserName ?? 'User',
              otherUserAvatar: conversation.otherUserAvatarUrl,
            ),
          ),
        );
        
        // Reload conversations after returning from chat
        _loadData();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFFEAB308).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasUnread ? const Color(0xFFEAB308).withOpacity(0.3) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                _buildAvatar(conversation.otherUserAvatarUrl, conversation.otherUserName),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          conversation.unreadCount > 9 ? '9+' : '${conversation.unreadCount}',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(width: 12.w),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName ?? 'User',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          _formatTime(conversation.lastMessageTime!),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastMessage ?? 'Start a conversation',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: hasUnread ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final username = friend['username'] as String? ?? 'Unknown';
    final email = friend['email'] as String? ?? '';
    final fullName = friend['full_name'] as String?;
    final avatarUrl = friend['avatar_url'] as String?;
    final friendUserId = friend['friend_user_id'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar - Click to view profile
          GestureDetector(
            onTap: () => _showPublicProfile(friendUserId, fullName ?? username, avatarUrl),
            child: _buildAvatar(avatarUrl, fullName ?? username),
          ),
          
          SizedBox(width: 12.w),
          
          // Content - Click name to view profile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showPublicProfile(friendUserId, fullName ?? username, avatarUrl),
                  child: Text(
                    fullName ?? username,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Message button
          GestureDetector(
            onTap: () async {
              // Open chat with this friend
              try {
                final conversationId = await MessagingService.getOrCreateConversation(friendUserId);
                
                if (mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversationId: conversationId,
                        otherUserId: friendUserId,
                        otherUserName: fullName ?? username,
                        otherUserAvatar: avatarUrl,
                      ),
                    ),
                  );
                  
                  // Reload data
                  _loadData();
                }
              } catch (e) {
                print('Error opening chat: $e');
              }
            },
            child: Icon(
              Icons.chat_bubble_outline,
              color: const Color(0xFFEAB308),
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(user.avatarUrl, user.fullName),
            
            SizedBox(width: 12.w),
            
            // Content - Click to view profile
            Expanded(
              child: GestureDetector(
                onTap: () => _showPublicProfile(user.id, user.fullName ?? user.username ?? 'User', user.avatarUrl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'User',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '@${user.username ?? 'user'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Add Friend button
                GestureDetector(
                  onTap: () async {
                    // Send friend request
                    try {
                      final success = await BackendService.sendFriendRequest(user.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                                ? '✅ Friend request sent!' 
                                : '❌ Failed to send friend request'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                        if (success) {
                          // Reload data to update friends list
                          _loadData();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add, size: 14.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          'Add Friend',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                // Message button
                GestureDetector(
                  onTap: () async {
                    // Get or create conversation and navigate to chat
                    try {
                      final conversationId = await MessagingService.getOrCreateConversation(user.id);
                      
                      if (mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: conversationId,
                              otherUserId: user.id,
                              otherUserName: user.fullName ?? user.username ?? 'User',
                              otherUserAvatar: user.avatarUrl,
                            ),
                          ),
                        );
                        
                        // Reload data and switch to messages tab
                        await _loadData();
                        setState(() => _selectedTab = 0);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error starting conversation: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.message, size: 14.sp, color: const Color(0xFFD4AF37)),
                        SizedBox(width: 4.w),
                        Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String? name) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback to initials
    final initials = (name ?? 'U')
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEAB308).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEAB308),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

// Chat Screen (continued in next part...)
