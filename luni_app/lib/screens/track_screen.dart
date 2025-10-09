import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/plaid_service.dart';
import '../services/backend_service.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'account_detail_screen.dart';
import 'category_detail_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> with AutomaticKeepAliveClientMixin {
  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        PlaidService.getAccounts(),
        PlaidService.getTransactions(limit: 50),
        BackendService.getCategories(),
      ]);
      
      print('📂 TrackScreen: Loaded ${(results[2] as List<CategoryModel>).length} categories from database');
      
      if (mounted) {
        setState(() {
          _accounts = results[0] as List<AccountModel>;
          _transactions = results[1] as List<TransactionModel>;
          _categories = results[2] as List<CategoryModel>;
          _isLoading = false;
          _hasLoadedOnce = true;
        });
        
        print('📂 TrackScreen: Categories in state: ${_categories.length}');
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_hasLoadedOnce) _hasLoadedOnce = true;
        });
      }
    }
  }

  Future<void> _syncTransactions() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Syncing new transactions...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Sync transactions from Plaid
      await BackendService.syncTransactions();

      // Reload data
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transactions synced successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (_isLoading && !_hasLoadedOnce) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_accounts.isEmpty && _hasLoadedOnce) {
      return Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No accounts connected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connect your bank to see your transactions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
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
    
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: _loadData,
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
              IconButton(
                icon: Icon(
                  Icons.sync,
                  color: Colors.grey.shade600,
                  size: 24.w,
                ),
                onPressed: _syncTransactions,
              ),
              Icon(
                Icons.filter_list,
                color: Colors.grey.shade600,
                size: 24.w,
              ),
                  ],
                ),
              ),
              
              // Accounts Overview
              _buildAccountsOverview(_accounts),
              SizedBox(height: 24.h),
              
              // Recent Transactions
              _buildRecentTransactions(_transactions),
              SizedBox(height: 24.h),
              
              // Categories Overview
              _buildCategoriesOverview(_transactions),
              SizedBox(height: 24.h),
            ],
          ),
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
    // Special styling for "All" account
    final isAllAccount = account.id == 'all_accounts';
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AccountDetailScreen(account: account),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isAllAccount ? const Color(0xFFEAB308).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isAllAccount ? Border.all(color: const Color(0xFFEAB308), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: isAllAccount ? const Color(0xFFEAB308).withOpacity(0.2) : Colors.grey.shade200,
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
              color: isAllAccount 
                  ? const Color(0xFFEAB308).withOpacity(0.2)
                  : account.type == 'credit' ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              isAllAccount 
                  ? Icons.account_balance_wallet
                  : account.type == 'credit' ? Icons.credit_card : Icons.account_balance,
              color: isAllAccount 
                  ? const Color(0xFFEAB308)
                  : account.type == 'credit' ? Colors.red.shade600 : Colors.green.shade600,
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
                  isAllAccount 
                      ? 'Combined Balance'
                      : '${account.type} • ${account.subtype}',
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
                    // Primary balance (CAD)
                    Text(
                      _formatBalanceForDisplay(account),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: _getBalanceColor(account, isAllAccount),
                      ),
                    ),
                    Text(
                      'CAD',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Show original currency balance if different from CAD
                    if (_shouldShowOriginalBalance(account)) ...[
                      SizedBox(height: 4.h),
                      Text(
                        _formatOriginalBalanceForDisplay(account),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        account.currency,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
        ],
      ),
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
                  // Show AI description if categorized, otherwise raw description
                  transaction.isCategorized && transaction.aiDescription != null
                      ? transaction.aiDescription!
                      : transaction.description ?? 'Unknown Transaction',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (transaction.category != null)
                  GestureDetector(
                    onTap: () => _showCategoryEditDialog(transaction),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        '${transaction.category} • ${transaction.subcategory}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showCategoryEditDialog(transaction),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'Tap to categorize',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
    // Get parent categories only (where parent_key matches the category's own key)
    final parentCategories = _categories
        .where((cat) => cat.parentKey == cat.name.toLowerCase().replaceAll(' ', '_'))
        .toList();

    // Calculate totals for each subcategory
    final categorizedTransactions = transactions.where((t) => t.isCategorized && t.subcategory != null).toList();
    final subcategoryTotals = <String, double>{};
    
    for (final transaction in categorizedTransactions) {
      if (transaction.subcategory != null) {
        subcategoryTotals[transaction.subcategory!] = (subcategoryTotals[transaction.subcategory!] ?? 0) + transaction.amount.abs();
      }
    }

    // Show empty state if NO categories are loaded at all
    if (parentCategories.isEmpty) {
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
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade400),
                  SizedBox(height: 12.h),
                  Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Pull down to refresh and load categories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show ALL parent categories with their subcategories
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
        ...parentCategories.map((parentCategory) {
          // Get subcategories for this parent
          final subcategories = _categories
              .where((cat) => 
                cat.parentKey == parentCategory.parentKey && 
                cat.name != parentCategory.name
              )
              .toList();
          
          // Calculate total for parent (sum of all subcategories)
          double parentTotal = 0.0;
          for (final subcat in subcategories) {
            parentTotal += subcategoryTotals[subcat.name] ?? 0.0;
          }
          
          return _buildCategorySection(parentCategory, subcategories, subcategoryTotals, parentTotal);
        }).toList(),
      ],
    );
  }

  Widget _buildCategorySection(
    CategoryModel parentCategory,
    List<CategoryModel> subcategories,
    Map<String, double> subcategoryTotals,
    double parentTotal,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Parent Category Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Text(
                  parentCategory.icon ?? '📊',
                  style: TextStyle(fontSize: 28.sp),
                ),
                SizedBox(width: 12.w),
                // Name
                Expanded(
                  child: Text(
                    parentCategory.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Total
                Text(
                  '\$${parentTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEAB308),
                  ),
                ),
              ],
            ),
          ),
          
          // Subcategories List
          if (subcategories.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No subcategories',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...subcategories.map((subcategory) {
              final amount = subcategoryTotals[subcategory.name] ?? 0.0;
              return _buildSubcategoryRow(subcategory, amount);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubcategoryRow(CategoryModel subcategory, double amount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon (smaller for subcategories)
          Text(
            subcategory.icon ?? '•',
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          // Name
          Expanded(
            child: Text(
              subcategory.name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          // Amount
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: amount > 0 ? Colors.black : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryEditDialog(TransactionModel transaction) {
    String selectedCategory = transaction.category ?? 'other';
    String selectedSubcategory = transaction.subcategory ?? 'Other';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description (non-editable)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? 'Unknown Transaction',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${transaction.amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setDialogState(() {
                    selectedCategory = value!;
                    selectedSubcategory = 'Other'; // Reset subcategory
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .where((cat) => cat.parentKey == cat.name.toLowerCase().replaceAll(' ', '_'))
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category.parentKey,
                    child: Text('${category.icon ?? ''} ${category.name}'),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 12.h),
              
              // Subcategory Dropdown
              DropdownButtonFormField<String>(
                value: selectedSubcategory,
                onChanged: (value) {
                  setDialogState(() {
                    selectedSubcategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .where((cat) => cat.parentKey == selectedCategory && cat.name != cat.parentKey)
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveCategoryChange(transaction, selectedCategory, selectedSubcategory),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategoryChange(TransactionModel transaction, String category, String subcategory) async {
    try {
      Navigator.of(context).pop(); // Close dialog
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Updating category...'),
            ],
          ),
        ),
      );

      // Update the transaction category
      await BackendService.updateTransactionCategory(
        transactionId: transaction.id,
        category: category,
        subcategory: subcategory,
        aiDescription: transaction.description ?? 'Unknown Transaction',
      );

      // Reload data to show changes
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
  Color _getBalanceColor(AccountModel account, bool isAllAccount) {
    if (isAllAccount) {
      return const Color(0xFFEAB308);
    }
    
    final isCreditCard = account.type == 'credit' || account.subtype == 'credit card';
    
    if (isCreditCard) {
      // Credit cards always show in red (debt)
      return Colors.red;
    } else {
      // Checking/savings accounts: green for positive, red for negative
      return account.balance >= 0 ? Colors.green : Colors.red;
    }
  }

  // Get display currency - show CAD for converted accounts
  String _getDisplayCurrency(AccountModel account) {
    // All balances are now converted to CAD for display
    return 'CAD';
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

