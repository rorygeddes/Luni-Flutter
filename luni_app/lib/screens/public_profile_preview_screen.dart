import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Preview of what other users see when they view your public profile
class PublicProfilePreviewScreen extends StatefulWidget {
  const PublicProfilePreviewScreen({super.key});

  @override
  State<PublicProfilePreviewScreen> createState() => _PublicProfilePreviewScreenState();
}

class _PublicProfilePreviewScreenState extends State<PublicProfilePreviewScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Public Profile Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:       _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _currentUser == null
              ? const Center(
                  child: Text(
                    'Unable to load profile',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Info banner
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is what other users see when they view your profile',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Profile picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
                          ),
                        ),
                        child: _currentUser!.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  _currentUser!.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
                                ),
                              )
                            : _buildInitialsAvatar(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Full name
                      Text(
                        _currentUser!.fullName ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Username
                      Text(
                        '@${_currentUser!.username ?? 'unknown'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // E-Transfer ID (if available)
                      if (_currentUser!.etransferId != null && _currentUser!.etransferId!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'E-Transfer ID',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _currentUser!.etransferId!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Public info section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visible Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.person_outline, 'Full Name', _currentUser!.fullName ?? 'Not set'),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.alternate_email, 'Username', '@${_currentUser!.username ?? 'unknown'}'),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.image_outlined, 'Profile Picture', _currentUser!.avatarUrl != null ? 'Visible' : 'Default'),
                            if (_currentUser!.etransferId != null && _currentUser!.etransferId!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.account_balance_wallet_outlined, 'E-Transfer ID', 'Visible'),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Hidden info section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.red.shade400,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hidden from Others',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.email_outlined, 'Email Address', 'Hidden', isHidden: true),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.calendar_today_outlined, 'Join Date', 'Hidden', isHidden: true),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.lock, 'Account Details', 'Hidden', isHidden: true),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(_currentUser!.fullName ?? _currentUser!.username ?? '?');
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isHidden = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isHidden ? Colors.white30 : AppTheme.primaryColor.withOpacity(0.7),
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isHidden ? Colors.white30 : Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isHidden ? Colors.white30 : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: isHidden ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
        if (isHidden)
          Icon(
            Icons.visibility_off,
            color: Colors.white30,
            size: 16,
          ),
      ],
    );
  }
}

