import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/plaid_service.dart';
import '../services/skeleton_data_service.dart';
import '../models/account_model.dart';

class BankConnectionScreen extends StatefulWidget {
  const BankConnectionScreen({super.key});

  @override
  State<BankConnectionScreen> createState() => _BankConnectionScreenState();
}

class _BankConnectionScreenState extends State<BankConnectionScreen> {
  bool _isConnecting = false;
  List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      // First try to load real accounts from database
      final realAccounts = await PlaidService.getAccounts();
      if (!mounted) return;
      
      if (realAccounts.isNotEmpty) {
        setState(() {
          _accounts = realAccounts;
        });
      } else {
        // Only show mock data if no real accounts exist
        setState(() {
          _accounts = [];
        });
      }
    } catch (e) {
      print('Error loading accounts: $e');
      if (!mounted) return;
      
      setState(() {
        _accounts = [];
      });
    }
  }

  Future<void> _connectBank() async {
    setState(() => _isConnecting = true);

    try {
      await PlaidService.launchPlaidLink(
        onSuccess: (publicToken) async {
          try {
            // Exchange the public token for access token and save account data
            await PlaidService.exchangePublicToken(publicToken);
            
            if (!mounted) return;
            setState(() => _isConnecting = false);
            
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bank account connected successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Reload accounts to show the newly connected ones
            await _loadAccounts();
          } catch (e) {
            if (!mounted) return;
            setState(() => _isConnecting = false);
            
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing connection: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        onExit: (reason) {
          if (!mounted) return;
          setState(() => _isConnecting = false);
          
          if (!mounted) return;
          if (reason.toLowerCase().contains('cancelled') || reason.toLowerCase().contains('exit')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bank connection cancelled'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connection failed: $reason'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        onEvent: (event) {
          print('Plaid event: $event');
          if (!mounted) return;
          
          // Show progress to user
          if (event == 'OPENED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening bank connection...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (event == 'CONNECTED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected to bank...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.contains('Plaid credentials not configured') || 
          errorMessage.contains('INVALID_API_KEYS') ||
          errorMessage.contains('invalid client_id or secret')) {
        // Show a helpful dialog for invalid credentials
        _showInvalidCredentialsDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _connectDemoBank() async {
    setState(() => _isConnecting = true);

    try {
      // Simulate demo bank connection
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      setState(() => _isConnecting = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo bank account connected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Load demo accounts
      _loadAccounts();
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: Text(
          'Connect Bank',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Connect Your Bank',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Securely connect your bank account to automatically track transactions',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 32.h),
              
              // Connect Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isConnecting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Connecting...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance, size: 24.w),
                            SizedBox(width: 12.w),
                            Text(
                              'Connect Bank Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Demo Button (for testing)
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: _isConnecting ? null : _connectDemoBank,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEAB308),
                    side: BorderSide(color: const Color(0xFFEAB308)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Use Demo Account (for testing)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Connected Accounts Section
              if (_accounts.isNotEmpty) ...[
                Text(
                  'Connected Accounts',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                ..._accounts.map((account) => _buildAccountCard(account)).toList(),
              ] else ...[
                // Show empty state when no accounts are connected
                Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 64.w,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Bank Accounts Connected',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Connect your bank account to start tracking transactions automatically',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: account.type == 'credit' ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              account.type == 'credit' ? Icons.credit_card : Icons.account_balance,
              color: account.type == 'credit' ? Colors.red.shade600 : Colors.green.shade600,
              size: 20.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${account.type} • ${account.subtype}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${account.balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: account.balance < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccountCard(String name, String type, double balance) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: balance < 0 ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              balance < 0 ? Icons.credit_card : Icons.account_balance,
              color: balance < 0 ? Colors.red.shade600 : Colors.green.shade600,
              size: 20.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: balance < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8.w),
            Text('Plaid Setup Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To connect your bank account, you need to set up your Plaid credentials.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Please add your Plaid credentials to the .env file:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'PLAID_CLIENT_ID=your_client_id\nPLAID_SECRET=your_secret\nPLAID_ENVIRONMENT=sandbox',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.sp,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'See PLAID_ENV_SETUP.md for detailed instructions.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInvalidCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8.w),
            Text('Invalid Plaid Credentials'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Plaid credentials are invalid or not properly configured.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'URGENT: You need to get valid Plaid sandbox credentials:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.red),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Go to https://dashboard.plaid.com/',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '2. Sign up and get your SANDBOX credentials',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '3. Update assets/.env with real credentials',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'See PLAID_CREDENTIALS_SETUP.md for detailed instructions.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Use "Demo Account" button for testing without real credentials',
                      style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

