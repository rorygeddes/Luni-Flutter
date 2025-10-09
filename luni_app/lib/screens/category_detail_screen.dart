import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import '../models/category_model.dart';
import '../widgets/luni_button.dart';
import '../models/transaction_model.dart';
import '../widgets/luni_button.dart';
import '../services/backend_service.dart';
import '../widgets/luni_button.dart';

/// Detail screen showing subcategories and transactions for a parent category
class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel parentCategory;
  final String filter; // 'all', 'month', '3months'

  const CategoryDetailScreen({
    super.key,
    required this.parentCategory,
    this.filter = 'month',
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<CategoryModel> _subcategories = [];
  Map<String, double> _subcategoryTotals = {};
  Map<String, List<TransactionModel>> _subcategoryTransactions = {};
  bool _isLoading = true;
  String _selectedFilter = 'month';
  
  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filter;
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all categories and filter subcategories
      final allCategories = await BackendService.getCategories();
      final subcategories = allCategories
          .where((cat) => 
            cat.parentKey == widget.parentCategory.parentKey && 
            cat.name != widget.parentCategory.name
          )
          .toList();

      // Calculate date range based on filter
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedFilter) {
        case 'all':
          startDate = DateTime(2000);
          break;
        case '3months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'month':
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Load transactions for each subcategory
      Map<String, double> totals = {};
      Map<String, List<TransactionModel>> transactions = {};

      for (var subcategory in subcategories) {
        final categoryTransactions = await BackendService.getTransactionsByCategory(
          subcategory.name,
          startDate: startDate,
        );
        
        transactions[subcategory.name] = categoryTransactions;
        totals[subcategory.name] = categoryTransactions.fold(
          0.0,
          (sum, txn) => sum + txn.amount.abs(),
        );
      }

      if (mounted) {
        setState(() {
          _subcategories = subcategories;
          _subcategoryTotals = totals;
          _subcategoryTransactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading category data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeFilter(String newFilter) {
    setState(() => _selectedFilter = newFilter);
    _loadCategoryData();
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'all':
        return 'All Time';
      case '3months':
        return 'Last 3 Months';
      case 'month':
      default:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = _subcategoryTotals.values.fold(0.0, (a, b) => a + b);

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
          widget.parentCategory.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: '3months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'all', child: Text('All Time')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _getFilterLabel(),
                    style: TextStyle(
                      color: const Color(0xFFEAB308),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFFEAB308)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategoryData,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Total Spent Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFEAB308),
                            const Color(0xFFEAB308).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.parentCategory.icon ?? '📊',
                                style: TextStyle(fontSize: 32.sp),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${_subcategories.length} categories',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Total Spent',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '\$${totalSpent.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Subcategories Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Breakdown',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddSubcategoryDialog(),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Category'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEAB308),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Subcategories List
                    if (_subcategories.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32.w),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No subcategories yet',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Add a category to get started',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._subcategories.map((subcategory) {
                        final spent = _subcategoryTotals[subcategory.name] ?? 0.0;
                        final percentage = totalSpent > 0
                            ? (spent / totalSpent * 100).toStringAsFixed(1)
                            : '0.0';
                        final txnCount = _subcategoryTransactions[subcategory.name]?.length ?? 0;

                        return _buildSubcategoryCard(
                          subcategory,
                          spent,
                          percentage,
                          txnCount,
                        );
                      }).toList(),
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubcategoryCard(
    CategoryModel subcategory,
    double spent,
    String percentage,
    int transactionCount,
  ) {
    return LuniGestureDetector(
      onTap: () {
        if (transactionCount > 0) {
          _showTransactionsBottomSheet(subcategory);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  subcategory.icon ?? '📁',
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Name and transactions count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategory.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEAB308),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              '\$${spent.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionsBottomSheet(CategoryModel subcategory) {
    final transactions = _subcategoryTransactions[subcategory.name] ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                children: [
                  Text(
                    subcategory.name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Transactions list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  return _buildTransactionItem(txn);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Unknown Transaction',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(transaction.date),
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: transaction.amount < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddSubcategoryDialog() {
    final nameController = TextEditingController();
    String selectedIcon = '📁';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subcategory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Icon selector (simplified for now)
            DropdownButtonFormField<String>(
              value: selectedIcon,
              onChanged: (value) => selectedIcon = value ?? '📁',
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '📁', child: Text('📁 Folder')),
                DropdownMenuItem(value: '🍔', child: Text('🍔 Food')),
                DropdownMenuItem(value: '🎬', child: Text('🎬 Entertainment')),
                DropdownMenuItem(value: '🚗', child: Text('🚗 Transport')),
                DropdownMenuItem(value: '🏠', child: Text('🏠 Home')),
                DropdownMenuItem(value: '💊', child: Text('💊 Health')),
                DropdownMenuItem(value: '📚', child: Text('📚 Education')),
                DropdownMenuItem(value: '💳', child: Text('💳 Other')),
              ],
            ),
          ],
        ),
        actions: [
          LuniTextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          LuniElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await BackendService.createCategory(
                    name: nameController.text,
                    parentKey: widget.parentCategory.parentKey,
                    icon: selectedIcon,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadCategoryData(); // Reload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAB308),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

