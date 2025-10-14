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
          Text('What is Luni?', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 12.h),
          Text('Luni is your personal financial system that connects your real financial data with AI insights to make money tracking simple and stress-free.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800)),
          SizedBox(height: 18.h),
          _card('TRACK', 'View your accounts, spending, and goals update in real time all in one central place.', Icons.insights),
          SizedBox(height: 12.h),
          _card('SPLIT', 'Split expenses instantly and track who owes who, without the awkward math.', Icons.group),
          SizedBox(height: 12.h),
          _card('PLAN', 'Set clear goals and let Luni’s AI build a simple, actionable plan to reach them.', Icons.flag),
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

  Widget _card(String title, String body, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(color: Color(0xFFEAB308), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                SizedBox(height: 6.h),
                Text(body, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800)),
              ],
            ),
          ),
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
    final provider = context.read<OnboardingProvider>();
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Here's how I’ll help", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 12.h),
          Text('To give accurate insights, Luni securely connects to your bank accounts. Used by 12,000+ institutions. Bank‑level encryption. Live updates. You stay in control.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800)),
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
      body: _PlaidConnectBody(),
    );
  }
}

class _PlaidConnectBody extends StatefulWidget {
  @override
  State<_PlaidConnectBody> createState() => _PlaidConnectBodyState();
}

class _PlaidConnectBodyState extends State<_PlaidConnectBody> {
  bool _isConnecting = false;
  String? _status;

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _status = 'Loading Plaid…';
    });
    try {
      PlaidService.launchPlaidLink(
        onSuccess: (publicToken) async {
          setState(() => _status = 'Exchanging token…');
          try {
            await PlaidService.exchangePublicToken(publicToken);
            if (!mounted) return;
            setState(() => _status = 'Accounts linked!');
            await Future.delayed(const Duration(milliseconds: 600));
            if (!mounted) return;
            Navigator.of(context).pop(); // back to onboarding flow
          } catch (e) {
            setState(() => _status = 'Exchange failed: $e');
          }
        },
        onExit: (reason) {
          setState(() {
            _isConnecting = false;
            _status = reason;
          });
        },
        onEvent: (event) {
          setState(() => _status = event);
        },
      );
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Securely connect via Plaid', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text('We never see your credentials. You can remove access anytime.', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
          SizedBox(height: 24.h),
          LuniElevatedButton(
            onPressed: _isConnecting ? null : _connect,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308), foregroundColor: Colors.white),
            child: _isConnecting ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Connect with Plaid'),
          ),
          if (_status != null) ...[
            SizedBox(height: 16.h),
            Text(_status!, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800)),
          ]
        ],
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
