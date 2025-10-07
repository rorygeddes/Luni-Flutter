import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/queue_item_model.dart';
import '../models/transaction_model.dart';

class TransactionQueueScreen extends StatefulWidget {
  const TransactionQueueScreen({super.key});

  @override
  State<TransactionQueueScreen> createState() => _TransactionQueueScreenState();
}

class _TransactionQueueScreenState extends State<TransactionQueueScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<QueueItemModel> _queueItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueueItems();
  }

  Future<void> _loadQueueItems() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('transaction_queue')
          .select('''
            *,
            transactions!inner(
              id,
              amount,
              description,
              merchant_name,
              date
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .limit(5);

      setState(() {
        _queueItems = response.map<QueueItemModel>((json) => QueueItemModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading queue items: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveTransaction(QueueItemModel queueItem) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Update transaction with AI categorization
      await _supabase
          .from('transactions')
          .update({
            'category': queueItem.aiCategory,
            'subcategory': queueItem.aiSubcategory,
            'is_categorized': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', queueItem.transactionId);

      // Update queue item status
      await _supabase
          .from('transaction_queue')
          .update({'status': 'approved'})
          .eq('id', queueItem.id);

      // Reload queue
      await _loadQueueItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction approved and categorized!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectTransaction(QueueItemModel queueItem) async {
    try {
      // Update queue item status
      await _supabase
          .from('transaction_queue')
          .update({'status': 'rejected'})
          .eq('id', queueItem.id);

      // Reload queue
      await _loadQueueItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error rejecting transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Queue'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _queueItems.isEmpty
              ? _buildEmptyState()
              : _buildQueueList(),
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
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAB308),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            ),
            child: Text(
              'Back to Home',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Review and approve AI-categorized transactions (${_queueItems.length}/5)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _queueItems.length,
            itemBuilder: (context, index) {
              final queueItem = _queueItems[index];
              return _buildQueueItem(queueItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(QueueItemModel queueItem) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queueItem.aiDescription ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Original: ${queueItem.transactionId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    '${(queueItem.confidenceScore * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // AI categorization
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Suggestion:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildCategoryChip(queueItem.aiCategory ?? 'Unknown', Colors.blue),
                      SizedBox(width: 8.w),
                      _buildCategoryChip(queueItem.aiSubcategory ?? 'Other', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectTransaction(queueItem),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                      foregroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveTransaction(queueItem),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
}