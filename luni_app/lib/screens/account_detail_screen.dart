import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../services/backend_service.dart';

class AccountDetailScreen extends StatefulWidget {
  final AccountModel account;

  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> transactionsData;
      
      // Handle "All" account specially
      if (widget.account.id == 'all_accounts') {
        transactionsData = await BackendService.getAllAccountTransactions();
      } else {
        transactionsData = await BackendService.getTransactionsByAccount(widget.account.id);
      }
      
      if (mounted) {
        setState(() {
          _transactions = transactionsData.map((e) => TransactionModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          widget.account.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Account Balance Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: widget.account.type == 'credit' 
                  ? Colors.red.shade50 
                  : Colors.green.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                // Primary balance (CAD)
                Text(
                  _formatBalanceForDisplay(widget.account),
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: _getBalanceColor(widget.account),
                  ),
                ),
                Text(
                  'CAD',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                // Show original currency balance if different from CAD
                if (_shouldShowOriginalBalance(widget.account)) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _formatOriginalBalanceForDisplay(widget.account),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    widget.account.currency,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: widget.account.type == 'credit' 
                        ? Colors.red.shade100 
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${widget.account.type} • ${widget.account.subtype}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.account.type == 'credit' 
                          ? Colors.red.shade700 
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Transactions Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Text(
                  'Transactions (Last 90 Days)',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_transactions.length}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEAB308),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Transactions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Transactions will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final amount = transaction.amount;
    final isCategorized = transaction.category != null && transaction.subcategory != null;
    final description = transaction.description;
    final date = transaction.date;
    final category = transaction.category;
    final subcategory = transaction.subcategory;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCategorized 
              ? const Color(0xFFEAB308) 
              : Colors.grey.shade300,
          width: isCategorized ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: amount < 0 ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  amount < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amount < 0 ? Colors.red.shade600 : Colors.green.shade600,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: amount < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  if (isCategorized)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 14.w,
                        color: const Color(0xFFEAB308),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (isCategorized && category != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16.w,
                    color: const Color(0xFFEAB308),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$category ${subcategory != null ? '• $subcategory' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Format balance for display - show credit card debt as positive numbers
  String _formatBalanceForDisplay(AccountModel account) {
    final isCreditCard = account.type == 'credit' || account.subtype == 'credit card';
    
    if (isCreditCard && account.balance < 0) {
      // For credit cards, show debt as positive number
      return '\$${(-account.balance).toStringAsFixed(2)}';
    } else {
      // For other accounts, show balance as-is
      return '\$${account.balance.toStringAsFixed(2)}';
    }
  }

  // Get color for balance display
  Color _getBalanceColor(AccountModel account) {
    final isCreditCard = account.type == 'credit' || account.subtype == 'credit card';
    
    if (isCreditCard) {
      // Credit cards always show in red (debt)
      return Colors.red;
    } else {
      // Checking/savings accounts: green for positive, red for negative
      return account.balance >= 0 ? Colors.green.shade700 : Colors.red;
    }
  }

  // Check if we should show the original balance (for non-CAD accounts)
  bool _shouldShowOriginalBalance(AccountModel account) {
    return account.currency != 'CAD' && 
           account.originalBalance != null && 
           account.originalBalance != account.balance;
  }

  // Format the original balance for display
  String _formatOriginalBalanceForDisplay(AccountModel account) {
    if (account.originalBalance == null) return '';
    
    final isCreditCard = account.type == 'credit' || account.subtype == 'credit card';
    
    if (isCreditCard && account.originalBalance! < 0) {
      // For credit cards, show debt as positive number
      return '\$${(-account.originalBalance!).toStringAsFixed(2)}';
    } else {
      // For other accounts, show balance as-is
      return '\$${account.originalBalance!.toStringAsFixed(2)}';
    }
  }
}

