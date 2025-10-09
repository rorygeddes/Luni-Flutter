import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/backend_service.dart';
import '../models/transaction_model.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> with AutomaticKeepAliveClientMixin {
  List<TransactionModel> _splitQueue = [];
  bool _isLoading = true;
  
  // TODO: Load real groups and people from database
  final groups = <Map<String, dynamic>>[];
  final people = <Map<String, dynamic>>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSplitQueue();
  }

  Future<void> _loadSplitQueue() async {
    setState(() => _isLoading = true);
    
    try {
      final splitTransactions = await BackendService.getSplitQueue();
      
      if (mounted) {
        setState(() {
          _splitQueue = splitTransactions;
          _isLoading = false;
        });
        print('📋 Split queue loaded: ${splitTransactions.length} transactions');
      }
    } catch (e) {
      print('❌ Error loading split queue: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmSplit(TransactionModel transaction) async {
    // TODO: Implement split confirmation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Split feature coming soon!')),
    );
  }

  Future<void> _modifySplit(TransactionModel transaction) async {
    // TODO: Implement split modification dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modify split feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                child: Row(
                  children: [
                    Text(
                      'Split',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: const Color(0xFFEAB308)),
                      onPressed: () {
                        // Add new split
                      },
                    ),
                  ],
                ),
              ),

              // Loading state
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.h),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              
              // Split Queue Section
              if (!_isLoading && _splitQueue.isNotEmpty) ...[
                _buildSectionHeader('Split Queue', _splitQueue.length),
                _buildSplitQueue(_splitQueue),
                SizedBox(height: 24.h),
              ],
              
              // Empty state for split queue
              if (!_isLoading && _splitQueue.isEmpty)
                Padding(
                  padding: EdgeInsets.all(32.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No transactions to split',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Groups Section
              _buildSectionHeader('Groups', groups.length),
              _buildGroupsList(groups),
              
              SizedBox(height: 24.h),
              
              // People Section
              _buildSectionHeader('People', people.length),
              _buildPeopleList(people),
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEAB308),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitQueue(List<TransactionModel> queue) {
    return Column(
      children: queue.map((transaction) => _buildSplitQueueItem(transaction)).toList(),
    );
  }

  Widget _buildSplitQueueItem(TransactionModel transaction) {
    final description = transaction.aiDescription ?? transaction.description ?? 'Unknown';
    final amount = transaction.amount.abs();
    final date = transaction.date;
    final category = transaction.category ?? 'Uncategorized';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Gold border
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
          // Header: Description and Amount
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${date.month}/${date.day}/${date.year} • $category',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // AI Suggestion Banner
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: const Color(0xFFD4AF37), size: 18.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Ready to split among group or individuals',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _modifySplit(transaction),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                    foregroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('Modify'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmSplit(transaction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('Split Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<Map<String, dynamic>> groups) {
    return Column(
      children: groups.map((group) => _buildGroupCard(group)).toList(),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
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
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                group['icon'],
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${group['member_count']} members • ${group['description']}',
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
                '\$${group['total_owed'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: group['total_owed'] >= 0 ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                group['total_owed'] >= 0 ? 'you are owed' : 'you owe',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleList(List<Map<String, dynamic>> people) {
    return Column(
      children: people.map((person) => _buildPersonCard(person)).toList(),
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person) {
    final isOwed = person['total_owed'] >= 0;
    final amount = person['total_owed'].abs();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
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
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                person['avatar'],
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  person['email'],
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
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isOwed ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isOwed ? 'owes you' : 'you owe',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

