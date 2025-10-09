import 'package:flutter/material.dart';
import '../../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/luni_button.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/luni_button.dart';
import 'dart:io';
import '../../widgets/luni_button.dart';
import '../../services/auth_service.dart';
import '../../widgets/luni_button.dart';
import '../../models/user_model.dart';
import '../../widgets/luni_button.dart';
import '../onboarding/onboarding_flow_screen.dart';
import '../../widgets/luni_button.dart';
import '../main_layout.dart';
import '../../widgets/luni_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

        try {
          // Sign up user (username availability is checked inside AuthService)
          final response = await AuthService.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
          );

          if (response.user != null) {
            // Navigate directly to main app
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainLayout(currentRoute: '/'),
                ),
              );
            }
          }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              Color(0xFFF8D777),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  
                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Luni',
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Smart money management for students',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 48.h),
                  
                  // Profile image picker
                  Center(
                    child: LuniGestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFEAB308),
                            width: 3,
                          ),
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 32.w,
                                      color: const Color(0xFFEAB308),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFFEAB308),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Form fields
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    validator: (value) => value?.isEmpty == true ? 'Full name is required' : null,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: '@username',
                    prefixText: '@',
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Username is required';
                      if (value!.length < 3) return 'Username must be at least 3 characters';
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Username can only contain letters, numbers, and underscores';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Password is required';
                      if (value!.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: LuniElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Sign in link
                  Center(
                    child: LuniGestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFEAB308),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefixText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
        ),
      ),
    );
  }
}
