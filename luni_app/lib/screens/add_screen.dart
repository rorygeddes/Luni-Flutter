import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backend_service.dart';
import '../models/category_model.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<Map<String, dynamic>> _accounts = [];
  List<CategoryModel> _categories = [];
  Map<String, Map<String, dynamic>> _editedTransactions = {};
  
  @override
  void initState() {
    super.initState();
    // Load queue data and supporting data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // Load accounts and categories in parallel
      final results = await Future.wait([
        BackendService.getAccounts(),
        BackendService.getCategories(),
      ]);
      
      setState(() {
        _accounts = results[0] as List<Map<String, dynamic>>;
        _categories = results[1] as List<CategoryModel>;
      });
      
      // Load queue transactions
      context.read<TransactionProvider>().loadQueuedTransactions();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final queueItems = provider.queuedTransactions;
    
        return Scaffold(
          backgroundColor: Colors.white,
          body: queueItems.isEmpty
              ? _buildEmptyState()
              : _buildQueueList(queueItems),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
            Icons.check_circle_outline,
            size: 80.w,
            color: Colors.green,
          ),
          SizedBox(height: 24.h),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No transactions need review at the moment.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<Map<String, dynamic>> queueItems) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
            Text(
                  'Transaction Queue',
              style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  '${queueItems.length} pending',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Info banner
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Colors.grey.shade600, size: 20.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Edit descriptions, select accounts, and choose categories for your transactions',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: queueItems.length,
              itemBuilder: (context, index) {
                final queueItem = queueItems[index];
                return _buildQueueItem(queueItem, index);
              },
            ),
          ),
          
          // Batch save button
          if (queueItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _editedTransactions.isNotEmpty ? _handleBatchSave : null,
                    icon: const Icon(Icons.save, size: 20),
                    label: Text(
                      'Save All Transactions (${_editedTransactions.length})',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _editedTransactions.isNotEmpty 
                          ? const Color(0xFFEAB308) 
                          : Colors.grey.shade300,
                      foregroundColor: _editedTransactions.isNotEmpty 
                          ? Colors.white 
                          : Colors.grey.shade500,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> queueItem, int index) {
    final transactionId = queueItem['transaction_id'] ?? queueItem['id'];
    final editedData = _editedTransactions[transactionId] ?? {};
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount and confidence
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    '\$${(queueItem['amount'] ?? 0.0).abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'AI: ${((queueItem['confidence_score'] ?? 0.5) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // AI Description (non-editable)
            _buildAIDescription(queueItem, transactionId),
            
            SizedBox(height: 16.h),
            
            // Account Display (non-editable)
            _buildAccountDisplay(queueItem),
            
            SizedBox(height: 16.h),
            
            // Category Selection
            _buildCategorySelection(queueItem, transactionId),
            
            SizedBox(height: 16.h),
            
            // Split Toggle
            _buildSplitToggle(queueItem, transactionId),
          ],
        ),
      ),
    );
  }

  Widget _buildAIDescription(Map<String, dynamic> queueItem, String transactionId) {
    final editedData = _editedTransactions[transactionId] ?? {};
    final aiDescription = editedData['description'] ?? 
                         queueItem['ai_description'] ?? 
                         queueItem['description'] ?? 
                         'Transaction';
    final originalDescription = queueItem['description'] ?? 'Unknown';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _improveDescription(queueItem, transactionId),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Regenerate with AI',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
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
                aiDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Original: $originalDescription',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDisplay(Map<String, dynamic> queueItem) {
    final accountId = queueItem['account_id'];
    final account = _accounts.firstWhere(
      (acc) => acc['id'] == accountId,
      orElse: () => {'name': 'Unknown Account'},
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 16.w,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 8.w),
              Text(
                account['name'] ?? 'Unknown Account',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(Map<String, dynamic> queueItem, String transactionId) {
    final editedData = _editedTransactions[transactionId] ?? {};
    final currentCategory = editedData['category'] ?? queueItem['ai_category'] ?? 'other';
    final currentSubcategory = editedData['subcategory'] ?? queueItem['ai_subcategory'] ?? 'Other';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: currentCategory,
                onChanged: (value) {
                  setState(() {
                    _editedTransactions[transactionId] = {
                      ..._editedTransactions[transactionId] ?? {},
                      'category': value,
                      'subcategory': 'Other', // Reset subcategory when category changes
                    };
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
                items: _categories
                    .where((cat) => cat.parentKey == cat.name.toLowerCase().replaceAll(' ', '_'))
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category.parentKey,
                    child: Text(
                      '${category.icon ?? ''} ${category.name}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: currentSubcategory,
                onChanged: (value) {
                  setState(() {
                    _editedTransactions[transactionId] = {
                      ..._editedTransactions[transactionId] ?? {},
                      'subcategory': value,
                    };
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select subcategory',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
                items: _categories
                    .where((cat) => cat.parentKey == currentCategory && cat.name != cat.parentKey)
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(
                      category.name,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSplitToggle(Map<String, dynamic> queueItem, String transactionId) {
    final editedData = _editedTransactions[transactionId] ?? {};
    final isSplit = editedData['is_split'] ?? false;
    
    return Row(
      children: [
        Icon(
          Icons.splitscreen,
          size: 20.w,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Text(
          'Split Transaction',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Switch(
          value: isSplit,
          onChanged: (value) {
            setState(() {
              _editedTransactions[transactionId] = {
                ..._editedTransactions[transactionId] ?? {},
                'is_split': value,
              };
            });
          },
          activeColor: const Color(0xFFEAB308),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        ),
    );
  }

  void _improveDescription(Map<String, dynamic> queueItem, String transactionId) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Generating new description...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      // TODO: Implement real AI description improvement
      // For now, generate a better description based on merchant and amount
      final originalDescription = queueItem['description'] ?? 'Unknown Transaction';
      final merchantName = queueItem['merchant_name'] ?? '';
      final amount = (queueItem['amount'] ?? 0.0).abs();
      
      String improvedDescription = _generateImprovedDescription(
        originalDescription, 
        merchantName, 
        amount
      );
      
      setState(() {
        _editedTransactions[transactionId] = {
          ..._editedTransactions[transactionId] ?? {},
          'description': improvedDescription,
        };
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Description improved with AI!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error improving description: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _generateImprovedDescription(String original, String merchant, double amount) {
    // Ensure we never return empty
    if (original.isEmpty) original = 'Transaction';
    
    // Clean up the original description
    String cleaned = original
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    
    // If we have a merchant name, use it
    if (merchant.isNotEmpty && merchant != 'null') {
      return merchant.split(' ')
          .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }
    
    // Otherwise, clean up the original description
    if (cleaned.isNotEmpty) {
      return cleaned.split(' ')
          .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }
    
    // Fallback based on amount
    if (amount > 0) {
      return 'Deposit';
    } else {
      return 'Purchase';
    }
  }

  void _handleBatchSave() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Saving transactions...'),
            ],
          ),
        ),
      );

      // Save all edited transactions
      for (final entry in _editedTransactions.entries) {
        final transactionId = entry.key;
        final editedData = entry.value;
        
        await context.read<TransactionProvider>().submitTransaction(
          transactionId: transactionId,
          category: editedData['category'] ?? 'other',
          subcategory: editedData['subcategory'] ?? 'Other',
          aiDescription: editedData['description'] ?? 'Transaction',
          isSplit: editedData['is_split'] ?? false,
        );
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully saved ${_editedTransactions.length} transactions!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear edited transactions and reload queue
        setState(() {
          _editedTransactions.clear();
        });
        
        context.read<TransactionProvider>().loadQueuedTransactions();
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transactions: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

