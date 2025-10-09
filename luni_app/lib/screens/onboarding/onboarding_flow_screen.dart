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

  final List<Widget> _pages = [
    const PersonalInfoScreen(),
    const MotivationsScreen(),
    const IncomeScreen(),
    const ExpensesScreen(),
    const FrequentMerchantsScreen(),
    const CategoriesSetupScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
                          _currentPage == _pages.length - 1 ? 'Complete' : 'Next',
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
