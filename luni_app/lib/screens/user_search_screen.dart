import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import '../services/messaging_service.dart';
import '../widgets/luni_button.dart';
import '../services/auth_service.dart';
import '../widgets/luni_button.dart';
import '../models/user_model.dart';
import '../widgets/luni_button.dart';
import 'user_profile_screen.dart';
import '../widgets/luni_button.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<UserModel> _searchResults = [];
  List<UserModel> _recentUsers = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentUsers();
    // Auto-focus search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await MessagingService.getAllUsers();
      print('📋 Loaded ${users.length} users for suggestions');
      for (var user in users) {
        print('   - ${user.username} (${user.fullName})');
      }
      if (mounted) {
        setState(() {
          _recentUsers = users.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recent users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await MessagingService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  Future<void> _selectUser(UserModel user) async {
    // Navigate to user profile screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
    
    // After profile closes, pop the search screen to return to Social
    if (mounted) {
      Navigator.of(context).pop();
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
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _searchUsers,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'Search by username...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20.w),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEAB308),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isSearching && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.w,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try searching with a different username',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final usersToShow = _isSearching ? _searchResults : _recentUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isSearching) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 12.h),
            child: Text(
              'Suggested',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: usersToShow.length,
            itemBuilder: (context, index) {
              return _buildUserTile(usersToShow[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(UserModel user) {
    return LuniGestureDetector(
      onTap: () => _selectUser(user),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(user.avatarUrl, user.fullName),
            
            SizedBox(width: 12.w),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? 'User',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
          ],
        ),
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
}

