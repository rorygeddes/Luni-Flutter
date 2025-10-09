import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import 'package:provider/provider.dart';
import '../widgets/luni_button.dart';
import '../providers/transaction_provider.dart';
import '../widgets/luni_button.dart';
import '../services/backend_service.dart';
import '../widgets/luni_button.dart';
import '../models/category_model.dart';
import '../widgets/luni_button.dart';
import '../models/transaction_model.dart';
import '../widgets/luni_button.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with AutomaticKeepAliveClientMixin {
  List<CategoryModel> _categories = [];
  List<TransactionModel> _batchTransactions = [];
  Map<String, Map<String, dynamic>> _editedData = {};
  bool _hasLoadedOnce = false;
  bool _isSubmitting = false;
  int _currentBatch = 0;
  static const int _batchSize = 5;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    if (!_hasLoadedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    try {
      // Load categories
      final categories = await BackendService.getCategories();
      
      setState(() {
        _categories = categories;
        _hasLoadedOnce = true;
      });
      
      // Load queue transactions
      if (mounted) {
        final provider = context.read<TransactionProvider>();
        await provider.loadQueuedTransactions();
        if (mounted) {
          _loadCurrentBatch(provider.queuedTransactions);
        }
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => _hasLoadedOnce = true);
    }
  }

  void _loadCurrentBatch(List<Map<String, dynamic>> allQueueItems) {
    final startIndex = _currentBatch * _batchSize;
    final endIndex = (startIndex + _batchSize).clamp(0, allQueueItems.length);
    
    // Get the batch subset
    final batchItems = allQueueItems.sublist(startIndex, endIndex);
    
    setState(() {
      _batchTransactions = batchItems
          .map((item) => TransactionModel.fromJson(item))
          .toList();
      
      // Initialize edited data for each transaction
      for (var transaction in _batchTransactions) {
        _editedData[transaction.id] = {
          'description': _cleanDescription(transaction.description ?? 'Unknown Transaction'),
          'category': transaction.category ?? 'other',
          'subcategory': transaction.subcategory ?? 'Uncategorized',
          'is_split': transaction.isSplit,
        };
      }
    });
  }

  String _cleanDescription(String? rawDescription) {
    // AI-style description cleaning
    if (rawDescription == null || rawDescription.isEmpty) {
      return 'Unknown Transaction';
    }
    
    String cleaned = rawDescription.trim();
    
    // Remove asterisks and numbers
    cleaned = cleaned.replaceAll(RegExp(r'\*+\d+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*+'), '');
    
    // Handle e-transfers
    if (cleaned.toUpperCase().contains('E-TRANS') || 
        cleaned.toUpperCase().contains('ETRANS')) {
      return 'E-Transfer';
    }
    
    // Remove extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Capitalize first letter of each word
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _submitBatch() async {
    if (_isSubmitting) return;
    
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<TransactionProvider>();
      
      // Submit each transaction in the batch
      for (var transaction in _batchTransactions) {
        final editedData = _editedData[transaction.id]!;
        
        await BackendService.updateTransactionCategory(
          transactionId: transaction.id,
          category: editedData['category'],
          subcategory: editedData['subcategory'],
          aiDescription: editedData['description'],
          isSplit: editedData['is_split'],
        );
      }
      
      // Reload queue
      await provider.loadQueuedTransactions();
      
      // Move to next batch or reset to first
      setState(() {
        _currentBatch = 0;
        _editedData.clear();
      });
      
      _loadCurrentBatch(provider.queuedTransactions);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_batchTransactions.length} transactions categorized!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !_hasLoadedOnce) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFFEAB308)),
            ),
          );
        }

        final totalQueue = provider.queuedTransactions.length;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: totalQueue == 0
              ? _buildEmptyState()
              : _buildBatchView(totalQueue),
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
            'No transactions need review.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchView(int totalQueue) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(totalQueue),
          
          // Batch indicator
          _buildBatchIndicator(totalQueue),
          
          // Transaction list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: _batchTransactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(_batchTransactions[index], index);
              },
            ),
          ),
          
          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalQueue) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Text(
            'Transaction Queue',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$totalQueue pending',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEAB308),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchIndicator(int totalQueue) {
    final totalBatches = (totalQueue / _batchSize).ceil();
    final currentBatchNum = _currentBatch + 1;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, size: 18.w, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Text(
            'Batch $currentBatchNum of $totalBatches',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${_batchTransactions.length} transactions',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, int index) {
    final editedData = _editedData[transaction.id]!;
    final parentCategories = _categories
        .where((cat) => cat.parentKey == cat.name.toLowerCase().replaceAll(' ', '_'))
        .toList();
    
    final selectedParent = parentCategories.firstWhere(
      (cat) => cat.name.toLowerCase() == editedData['category'].toLowerCase(),
      orElse: () => parentCategories.first,
    );
    
    final subcategories = _categories
        .where((cat) => cat.parentKey == selectedParent.parentKey && cat.name != selectedParent.name)
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction number and date
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAB308).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEAB308),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _formatDate(transaction.date),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${transaction.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount < 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Description (editable)
          _buildEditableField(
            'Description',
            editedData['description'],
            (value) {
              setState(() {
                _editedData[transaction.id]!['description'] = value;
              });
            },
          ),
          
          SizedBox(height: 12.h),
          
          // Original description (non-editable, smaller)
          Text(
            'Original: ${transaction.description ?? 'Unknown Transaction'}',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 16.h),
          
          // Category dropdown
          _buildDropdown(
            'Category',
            editedData['category'],
            parentCategories.map((cat) => cat.name).toList(),
            (value) {
              setState(() {
                _editedData[transaction.id]!['category'] = value;
                _editedData[transaction.id]!['subcategory'] = 'Uncategorized';
              });
            },
          ),
          
          SizedBox(height: 12.h),
          
          // Subcategory dropdown
          _buildDropdown(
            'Subcategory',
            editedData['subcategory'],
            subcategories.isNotEmpty
                ? subcategories.map((cat) => cat.name).toList()
                : ['Uncategorized'],
            (value) {
              setState(() {
                _editedData[transaction.id]!['subcategory'] = value;
              });
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Split checkbox
          Row(
            children: [
              Checkbox(
                value: editedData['is_split'],
                onChanged: (value) {
                  setState(() {
                    _editedData[transaction.id]!['is_split'] = value ?? false;
                  });
                },
                activeColor: const Color(0xFFEAB308),
              ),
              Text(
                'Assign to Split Queue',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LuniElevatedButton(
          onPressed: _isSubmitting ? null : _submitBatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEAB308),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Submit ${_batchTransactions.length} Transaction${_batchTransactions.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
