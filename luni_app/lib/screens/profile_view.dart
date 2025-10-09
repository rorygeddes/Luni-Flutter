import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/luni_button.dart';
import 'auth/sign_in_screen.dart';
import 'public_profile_preview_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with AutomaticKeepAliveClientMixin {
  UserModel? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _hasLoadedOnce = false;
  
  // User stats (set to 0 for now)
  int _lunis = 0;
  int _lunScore = 0;
  int _streak = 0;
  
  // Editable fields
  final _schoolController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
          _hasLoadedOnce = true;
          
          // Initialize controllers with profile data
          if (profile != null) {
            _usernameController.text = profile.username ?? '';
            // For now, set default values for school and age
            _schoolController.text = '';
            _ageController.text = '';
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    
    try {
      // Update the profile with new data
      final updatedProfile = _userProfile!.copyWith(
        username: _usernameController.text.trim(),
        // Add school and age to UserModel if needed
      );
      
      await AuthService.updateUserProfile(updatedProfile);
      
      setState(() {
        _isEditing = false;
        _userProfile = updatedProfile;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFFEAB308),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values if cancelled
        _usernameController.text = _userProfile?.username ?? '';
        _schoolController.text = '';
        _ageController.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (_isLoading && !_hasLoadedOnce) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEAB308),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and settings
            _buildHeader(context),
            
                  // Profile content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          
                          // Profile section
                          _buildProfileSection(),
                          SizedBox(height: 32.h),
                          
                          // Stats section
                          _buildStatsSection(),
                          SizedBox(height: 32.h),
                          
                          // Editable profile fields
                          _buildEditableProfileSection(),
                          SizedBox(height: 32.h),
                          
                          // Member since info
                          _buildMemberInfo(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          LuniGestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20.w,
              ),
            ),
          ),
          
          // Title
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          // Profile image button (clickable for settings)
          LuniGestureDetector(
            onTap: () => _showSettings(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEAB308),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundImage: _userProfile?.avatarUrl != null
                    ? NetworkImage(_userProfile!.avatarUrl!)
                    : null,
                child: _userProfile?.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 20.w,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile image
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEAB308),
              width: 3.w,
            ),
          ),
          child: CircleAvatar(
            radius: 57.r,
            backgroundImage: _userProfile?.avatarUrl != null
                ? NetworkImage(_userProfile!.avatarUrl!)
                : const AssetImage('assets/images/770816ec0c486fcc4894b95a1b38b37d327f89e4.png') as ImageProvider,
            child: _userProfile?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 60.w,
                    color: Colors.grey.shade400,
                  )
                : null,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Name
        Text(
          _userProfile?.fullName ?? 'User',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        
        // Username
        Text(
          '@${_userProfile?.username ?? 'username'}',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Member Since
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.grey.shade600,
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                _userProfile?.createdAt != null
                    ? 'Member since ${_formatDate(_userProfile!.createdAt!)}'
                    : 'New member',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('$_lunis', 'Lunis', Icons.monetization_on),
          _buildStatDivider(),
          _buildStatItem('$_lunScore', 'LunScore', Icons.star),
          _buildStatDivider(),
          _buildStatItem('$_streak', 'Streak', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFEAB308),
          size: 24.w,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildEditableProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            LuniGestureDetector(
              onTap: _isEditing ? _saveProfile : _toggleEdit,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _isEditing ? const Color(0xFFEAB308) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _isEditing ? 'Save' : 'Edit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _isEditing ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Email (read-only)
        _buildInfoField(
          'Email',
          _userProfile?.email ?? 'No email',
          Icons.email,
          Colors.blue.shade100,
          isEditable: false,
        ),
        
        SizedBox(height: 12.h),
        
        // Username (editable)
        _buildEditableField(
          'Username',
          _usernameController,
          Icons.person,
          Colors.green.shade100,
          prefix: '@',
        ),
        
        SizedBox(height: 12.h),
        
        // School (editable)
        _buildEditableField(
          'School',
          _schoolController,
          Icons.school,
          Colors.purple.shade100,
          hintText: 'Enter your school',
        ),
        
        SizedBox(height: 12.h),
        
        // Age (editable)
        _buildEditableField(
          'Age',
          _ageController,
          Icons.cake,
          Colors.orange.shade100,
          hintText: 'Enter your age',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon, Color color, {bool isEditable = false}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, Color color, {String? prefix, String? hintText, TextInputType? keyboardType}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: _isEditing,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    prefixText: prefix,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return LuniGestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade700,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        _buildInfoItem(
          'Member Since',
          _userProfile?.createdAt != null
              ? _formatFullDate(_userProfile!.createdAt!)
              : 'Just joined',
          Icons.calendar_today,
          Colors.purple.shade100,
        ),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        _buildInfoItem(
          'Version',
          '1.0.0',
          Icons.info,
          Colors.orange.shade100,
        ),
        _buildInfoItem(
          'Last Updated',
          'Today',
          Icons.update,
          Colors.teal.shade100,
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  LuniGestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Settings content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        _buildSettingsSection('Appearance', [
                          _buildSettingsItem('Dark Mode', Icons.dark_mode, false, (value) {
                            _toggleTheme(value);
                          }),
                        ]),
                        SizedBox(height: 24.h),
                        
                        _buildSettingsSection('Profile', [
                          _buildSettingsItem('View Public Profile', Icons.visibility, null, null, onTap: _viewPublicProfile),
                        ]),
                        SizedBox(height: 24.h),
                        
                        _buildSettingsSection('Account', [
                          _buildSettingsItem('Change Password', Icons.lock, null, null, onTap: _changePassword),
                          _buildSettingsItem('Sign Out', Icons.logout, null, null, onTap: _signOut),
                          _buildSettingsItem('Delete Account', Icons.delete, null, null, onTap: _deleteAccount, isDestructive: true),
                        ]),
                        SizedBox(height: 40.h),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        ...items,
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, bool? value, Function(bool)? onChanged, {VoidCallback? onTap, bool isDestructive = false}) {
    return LuniGestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey.shade600,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black,
                ),
              ),
            ),
            if (value != null)
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFFEAB308),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16.w,
              ),
          ],
        ),
      ),
    );
  }

  void _viewPublicProfile() {
    Navigator.of(context).pop(); // Close settings modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PublicProfilePreviewScreen(),
      ),
    );
  }

  void _toggleTheme(bool isDark) {
    // TODO: Implement theme toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDark ? 'Dark mode enabled' : 'Light mode enabled'),
        backgroundColor: const Color(0xFFEAB308),
      ),
    );
  }

  void _changePassword() {
    Navigator.of(context).pop(); // Close settings modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality will be implemented soon.'),
        actions: [
          LuniTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    Navigator.of(context).pop(); // Close settings modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          LuniTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          LuniTextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion functionality will be implemented soon.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    Navigator.of(context).pop(); // Close settings modal
    
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? All your data will be saved automatically.'),
        actions: [
          LuniTextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          LuniTextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Note: All user data is automatically saved to Supabase as transactions occur
        // No additional save operations needed before sign out
        
        // Sign out from Supabase
        await AuthService.signOut();
        
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully. All your data has been saved.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate to sign in screen by replacing the entire navigation stack
          // This ensures the user is taken to the sign-in screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
