import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'main_layout.dart';
import 'auth/sign_in_screen.dart';
import '../main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<double> _screenFadeOut;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Play soft jingle if audio file exists
    _playJingle();

    // Logo animation - appears immediately (no fade)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );

    // Logo appears at full scale immediately
    _logoScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // No rotation - just clean
    _logoRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // Text animation - 1s fade duration
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Start animations with exact timing:
    // 1) Logo visible immediately
    _logoController.forward();

    // 2) After 0.5s, start text fade (1s long)
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // 3) Navigate at 1.5s total
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _navigateToApp();
      }
    });
  }

  Future<void> _playJingle() async {
    try {
      // Try to play jingle if it exists
      await _audioPlayer.play(AssetSource('sounds/luni_jingle.mp3'));
      await _audioPlayer.setVolume(0.5); // Moderate volume
    } catch (e) {
      // Silently fail if audio file doesn't exist
      print('Splash audio not found (optional): $e');
    }
  }

  void _navigateToApp() {
    // Check auth state and navigate accordingly
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // Preload profile to avoid flicker
        AuthService.getCurrentUserProfile().then((UserModel? profile) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MainLayout(currentRoute: '/', initialUserProfile: profile),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        });
        return;
      }

      // If no user, go to sign in
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      // If Supabase not initialized, go to sign in
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo - Full screen feel
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value,
                      child: Image.asset(
                        'assets/images/ChatGPT Image Oct 10 2025.png',
                        width: 280.w,
                        height: 280.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 40.h),
              
              // Animated Text - Fade in
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      children: [
                        Text(
                          'Luni',
                          style: TextStyle(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37), // Gold color
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Smart Budgeting for Students',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black54,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

