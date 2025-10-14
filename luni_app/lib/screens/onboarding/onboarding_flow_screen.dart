import 'package:flutter/material.dart';
import '../../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/luni_button.dart';
import 'package:provider/provider.dart';
import '../../widgets/luni_button.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/luni_button.dart';
import 'personal_info_screen.dart';
import '../../widgets/luni_button.dart';
import 'motivations_screen.dart';
import '../../widgets/luni_button.dart';
import 'income_screen.dart';
import '../../widgets/luni_button.dart';
import 'expenses_screen.dart';
import '../../widgets/luni_button.dart';
import 'frequent_merchants_screen.dart';
import '../../widgets/luni_button.dart';
import 'categories_setup_screen.dart';
import '../../widgets/luni_button.dart';
import '../main_layout.dart';
import '../../widgets/luni_button.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // New sequence based on onboarding.md:
    // 0) What is Luni? (3 cards)
    // 1) Life stage selection
    // 2) "Here’s how I’ll help" explainer with CTA to connect Plaid or Demo Mode
    // 3) Optional quick survey (kept minimal): motivations
    // 4) Done → saves + go to dashboard (provider handles persistence)
    _pages = [
      _WhatIsLuniIntro(onNext: _nextPage),
      _LifeStageScreen(onSelected: (stage) {
        context.read<OnboardingProvider>().setLifeStage(stage);
        _nextPage();
      }),
      _ConnectOrDemoScreen(
        onConnect: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const _PlaidConnectScreen(),
            ),
          );
        },
        onUseDemo: () async {
          context.read<OnboardingProvider>().setDemoMode(true);
          _nextPage();
        },
      ),
      const MotivationsScreen(),
      _FinishScreen(onFinish: _completeOnboarding),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      await context.read<OnboardingProvider>().saveOnboardingData();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainLayout(currentRoute: '/'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuniGestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8D777),
                Color(0xFFFFFFFF),
              ],
              stops: [0.0, 0.15],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _pages.length,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEAB308)),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87, // Darker text for better contrast
                      ),
                    ),
                  ],
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: _pages[index],
                    );
                  },
                ),
              ),
              
              // Navigation buttons
              Container(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEAB308)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEAB308),
                            ),
                          ),
                        ),
                      ),
                    
                    if (_currentPage > 0) SizedBox(width: 16.w),
                    
                    Expanded(
                      child: LuniElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Finish' : 'Next',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 0) What is Luni? three simple cards with Next CTA
class _WhatIsLuniIntro extends StatelessWidget {
  final VoidCallback onNext;
  const _WhatIsLuniIntro({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is Luni?', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          _bullet('TRACK: Real-time accounts, spending, and goals in one place.'),
          _bullet('SPLIT: Instantly split expenses and track who owes who.'),
          _bullet('PLAN: Set goals and let AI create a simple, actionable plan.'),
          const Spacer(),
          LuniElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308), foregroundColor: Colors.white),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: const Color(0xFFEAB308), size: 20.w),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
        ],
      ),
    );
  }
}

// 1) Life stage selection
class _LifeStageScreen extends StatelessWidget {
  final void Function(String stage) onSelected;
  const _LifeStageScreen({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final stages = [
      'Student',
      'Young Professional',
      'Settling In',
      'Parent',
      'Retiring/Retired',
    ];
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where are you at in life?', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          ...stages.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: LuniElevatedButton(
                  onPressed: () => onSelected(s),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Color(0xFFEAB308), width: 2),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              )),
        ],
      ),
    );
  }
}

// 2) Connect Plaid or Demo mode
class _ConnectOrDemoScreen extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onUseDemo;
  const _ConnectOrDemoScreen({required this.onConnect, required this.onUseDemo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Here's how I'll help", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text('To give accurate insights, Luni securely connects to your bank accounts via Plaid. Or try Demo Mode to see the experience instantly.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
          SizedBox(height: 20.h),
          LuniElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308), foregroundColor: Colors.white),
            child: const Text('🔒 Connect My Bank'),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onUseDemo,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEAB308), width: 2)),
            child: const Text('Skip for now → Demo Mode'),
          )
        ],
      ),
    );
  }
}

// 2a) Plaid connect placeholder screen (uses existing flow via PlaidService on Home)
class _PlaidConnectScreen extends StatelessWidget {
  const _PlaidConnectScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Bank')),
      body: Center(
        child: Text('Use Home → Connect Bank section to link accounts. Coming soon to onboarding.'),
      ),
    );
  }
}

// 4) Finish step
class _FinishScreen extends StatelessWidget {
  final VoidCallback onFinish;
  const _FinishScreen({required this.onFinish});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You’re all set', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text('We’ll tailor your experience based on what you shared. You can update this anytime in Settings.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
          const Spacer(),
          LuniElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308), foregroundColor: Colors.white),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}
