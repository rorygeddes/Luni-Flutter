import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../models/user_model.dart';
import '../widgets/luni_button.dart';
import 'budget_modal.dart';
import 'wallet_modal.dart';
import 'daily_report_modal.dart';
import 'bank_connection_screen.dart';
import 'transaction_queue_screen.dart';
import 'categories_screen.dart';
import '../services/plaid_service.dart';
import 'onboarding/onboarding_flow_screen.dart';
import 'main_layout.dart';

class LuniHomeScreen extends StatefulWidget {
  const LuniHomeScreen({super.key});

  @override
  State<LuniHomeScreen> createState() => _LuniHomeScreenState();
}

class _LuniHomeScreenState extends State<LuniHomeScreen> with AutomaticKeepAliveClientMixin {
  UserModel? _userProfile;
  Map<String, double> _categorySpending = {};
  int _queueCount = 0;
  bool _hasLoadedOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_hasLoadedOnce) return; // Only load once on initial mount
    
    try {
      final user = await AuthService.getCurrentUserProfile();
      final spending = await BackendService.getCategorySpending();
      final queue = await BackendService.getUncategorizedTransactions();
      
      if (mounted) {
        setState(() {
          _userProfile = user;
          _categorySpending = spending;
          _queueCount = queue.length;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      print('Error loading home screen data: $e');
    }
  }

  Future<void> _refreshData() async {
    try {
      final user = await AuthService.getCurrentUserProfile();
      final spending = await BackendService.getCategorySpending();
      final queue = await BackendService.getUncategorizedTransactions();
      
      if (mounted) {
        setState(() {
          _userProfile = user;
          _categorySpending = spending;
          _queueCount = queue.length;
        });
      }
    } catch (e) {
      print('Error refreshing home screen data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      color: Colors.white, // White background for seamless scrolling
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFFEAB308),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(context),
            SizedBox(height: 16.h),

            // Survey Section
            _buildSurveySection(context),
            SizedBox(height: 16.h),

            // Bank Connection Section
            _buildBankConnectionSection(context),
            SizedBox(height: 16.h),

            // Transaction Queue Section
            _buildTransactionQueueSection(context),
            SizedBox(height: 16.h),

            // Category Spending Section
            _buildCategorySpendingSection(context),
            SizedBox(height: 16.h),

            // Daily Report Button
            _buildDailyReportButton(context),
            SizedBox(height: 16.h),

            // Current Budget Overview (Clickable)
            LuniGestureDetector(
              onTap: () => NavigationService.navigateToModal(const BudgetModal()),
              child: _buildBudgetOverview(),
            ),
            SizedBox(height: 16.h),

            // Current Wallet & Accounts (Clickable)
            LuniGestureDetector(
              onTap: () => NavigationService.navigateToModal(const WalletModal()),
              child: _buildWalletSection(),
            ),
            SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    String userName = _userProfile?.fullName ?? 'Student';
    String userEmail = _userProfile?.email ?? '';
    
    return Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$userName!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (userEmail.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildStatCard('0', Icons.local_fire_department, () => _showPointsModal(context, 'Streak', '0', Icons.local_fire_department)),
              SizedBox(width: 8.w),
              _buildStatCard('0', Icons.star, () => _showPointsModal(context, 'LoonScore', '0', Icons.star)),
            ],
          ),
        );
  }

  Widget _buildSurveySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: const Color(0xFFEAB308),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Help us personalize your experience by completing a quick survey about your financial goals and preferences.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingFlowScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.quiz),
              label: const Text('Complete Survey!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, IconData icon, VoidCallback onTap) {
    return LuniGestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8D777),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPointsModal(BuildContext context, String title, String value, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5, // Reduced height to prevent overflow
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
                    title,
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
            
            SizedBox(height: 20.h), // Reduced spacing
            
            // Content - Made scrollable to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Icon(
                      icon,
                      size: 60.w, // Reduced icon size
                      color: const Color(0xFFEAB308),
                    ),
                    SizedBox(height: 16.h), // Reduced spacing
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 36.sp, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h), // Reduced spacing
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16.h), // Reduced spacing
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Detailed view coming soon!',
                        style: TextStyle(
                          fontSize: 12.sp, // Reduced font size
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankConnectionSection(BuildContext context) {
    // Check if user has connected accounts using FutureBuilder
    // For now, we'll show the connect button (real check would be async)
        
    return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: const Color(0xFFEAB308),
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Bank Connection',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Connect your bank accounts to automatically track transactions and categorize your spending.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BankConnectionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.link),
                  label: const Text('Connect Bank Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  void _connectBankAccount(BuildContext context) {
    PlaidService.launchPlaidLink(
      onSuccess: (publicToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the page to update the UI
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainLayout(currentRoute: '/'),
          ),
        );
      },
      onExit: (error) {
        if (error.contains('User cancelled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank connection cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onEvent: (event) {
        print('Plaid event: $event');
      },
    );
  }

  Widget _buildTransactionQueueSection(BuildContext context) {
    // Transaction queue will be shown based on real data from provider
    // This section should use Consumer<TransactionProvider> for real-time updates
    // For now, we'll show it if the user navigates to the queue screen

    return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.queue,
                    color: Colors.orange.shade600,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Transaction Queue',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '$_queueCount',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Review and categorize your recent transactions with AI assistance.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TransactionQueueScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Review Transactions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildDailyReportButton(BuildContext context) {
    return LuniGestureDetector(
      onTap: () => NavigationService.navigateToModal(const DailyReportModal()),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'View Daily Report',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 48.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Connect your bank account to see your budget insights',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String amount, String label, String subtitle, double progress, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, String amount, double progress, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 3.h,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(1.5.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(1.5.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Balances',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 48.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Connect your bank account to see your balances',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBubble(String amount, String account, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _getTextColorForBackground(backgroundColor),
            ),
          ),
          Text(
            account,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    if (backgroundColor == Colors.blue.shade100) return Colors.blue.shade800;
    if (backgroundColor == Colors.red.shade100) return Colors.red.shade800;
    if (backgroundColor == Colors.green.shade100) return Colors.green.shade800;
    if (backgroundColor == Colors.purple.shade100) return Colors.purple.shade800;
    if (backgroundColor == Colors.orange.shade100) return Colors.orange.shade800;
    return Colors.black;
  }

  Widget _buildCategorySpendingSection(BuildContext context) {
    if (_categorySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpending = _categorySpending.values.fold(0.0, (a, b) => a + b);

    return LuniGestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategoriesScreen(),
              ),
            );
          },
          child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart,
                    color: const Color(0xFFEAB308),
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Category Spending',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Last 30 days • \$${totalSpending.toStringAsFixed(2)} total',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              ..._categorySpending.entries.map((entry) {
                final percentage = (entry.value / totalSpending * 100).toStringAsFixed(1);
                return _buildCategoryRow(
                  entry.key,
                  entry.value,
                  percentage,
                );
              }).toList(),
            ],
          ),
          ),
        );
  }

  Widget _buildCategoryRow(String category, double amount, String percentage) {
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryDisplayName(category),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food_drink':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
      case 'utilities':
        return Icons.receipt;
      case 'health':
      case 'healthcare':
        return Icons.favorite;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food_drink':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
      case 'utilities':
        return Colors.red;
      case 'health':
      case 'healthcare':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      case 'travel':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'food_drink':
        return 'Food & Drink';
      case 'transportation':
        return 'Transportation';
      case 'shopping':
        return 'Shopping';
      case 'entertainment':
        return 'Entertainment';
      case 'bills':
        return 'Bills & Utilities';
      case 'utilities':
        return 'Utilities';
      case 'health':
      case 'healthcare':
        return 'Healthcare';
      case 'education':
        return 'Education';
      case 'travel':
        return 'Travel';
      default:
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }
}