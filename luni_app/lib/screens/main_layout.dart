import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import 'luni_home_screen.dart';
import 'track_screen.dart';
import 'split_screen.dart';
import 'social_screen.dart';
import 'plus_ai_chat_screen.dart';
import 'profile_view.dart';

class MainLayout extends StatefulWidget {
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8D777), // Light gold at top of status bar
              Color(0xFFFFFFFF), // White at bottom of header
            ],
            stops: [0.0, 0.15], // Very small gradient - only in header area
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with transparent background to let gradient show through
              _buildHeader(context),
              
              // Content area with PageView for smooth navigation
              Expanded(
                child: Container(
                  color: Colors.white, // White background for content
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      LuniHomeScreen(),
                      TrackScreen(),
                      SplitScreen(),
                      SocialScreen(),
                    ],
                  ),
                ),
              ),
              
              // Bottom Navigation - always visible
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      // Transparent background to let main gradient show through
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h), // Extra bottom padding for seamless transition
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const AssetImage('assets/images/Luni Logo.png'),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Luni',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Notification button
                LuniGestureDetector(
                  onTap: () => _showNotifications(context),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🔔',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                    // Profile button
                    LuniGestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProfileView()),
                      ),
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundImage: const AssetImage('assets/images/770816ec0c486fcc4894b95a1b38b37d327f89e4.png'),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home, 'Home', _currentIndex == 0, () => _navigateToPage(0)),
          _buildNavItem(Icons.attach_money, 'Track', _currentIndex == 1, () => _navigateToPage(1)),
          _buildNavItem(Icons.add, '', false, () => _openAIChat(context), isCenter: true),
          _buildNavItem(Icons.account_balance_wallet, 'Split', _currentIndex == 2, () => _navigateToPage(2)),
          _buildNavItem(Icons.people, 'Social', _currentIndex == 3, () => _navigateToPage(3)),
        ],
      ),
    );
  }

  void _openAIChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlusAIChatScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Center(
                child: Text(
                  'No new notifications',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, {bool isCenter = false}) {
    if (isCenter) {
      return LuniGestureDetector(
        onTap: onTap,
        child: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5E68A), Color(0xFFEAB308), Color(0xFFD69E2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.w,
          ),
        ),
      );
    }

    return LuniGestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFEAB308) : Colors.grey.shade400,
            size: 24.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isActive ? const Color(0xFFEAB308) : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}