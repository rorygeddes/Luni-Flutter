import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/skeleton_data_service.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = SkeletonDataService.getMockAccounts();
    final transactions = SkeletonDataService.getMockTransactions();
    
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.filter_list,
                    color: Colors.grey.shade600,
                    size: 24.w,
                  ),
                ],
              ),
            ),
            
            // Accounts Overview
            _buildAccountsOverview(accounts),
            SizedBox(height: 24.h),
            
            // Recent Transactions
            _buildRecentTransactions(transactions),
            SizedBox(height: 24.h),
            
            // Categories Overview
            _buildCategoriesOverview(transactions),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsOverview(List<AccountModel> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accounts',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        ...accounts.map((account) => _buildAccountCard(account)).toList(),
      ],
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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

  Widget _buildRecentTransactions(List<TransactionModel> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        ...transactions.take(5).map((transaction) => _buildTransactionCard(transaction)).toList(),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: transaction.isCategorized 
            ? Border.all(color: const Color(0xFFEAB308), width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: transaction.amount < 0 ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              transaction.amount < 0 ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.amount < 0 ? Colors.red.shade600 : Colors.green.shade600,
              size: 16.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (transaction.category != null)
                  Text(
                    '${transaction.category} • ${transaction.subcategory}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: transaction.amount < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesOverview(List<TransactionModel> transactions) {
    final categorizedTransactions = transactions.where((t) => t.isCategorized).toList();
    final categoryTotals = <String, double>{};
    
    for (final transaction in categorizedTransactions) {
      if (transaction.category != null) {
        categoryTotals[transaction.category!] = (categoryTotals[transaction.category!] ?? 0) + transaction.amount.abs();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        ...categoryTotals.entries.map((entry) => _buildCategoryCard(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildCategoryCard(String category, double amount) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.category,
              color: const Color(0xFFEAB308),
              size: 12.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

