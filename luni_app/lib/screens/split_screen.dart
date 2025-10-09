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
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  
  // Temporarily keep these for display
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
      final results = await Future.wait([
        BackendService.getSplitQueue(),
        BackendService.getUserGroups(),
      ]);
      
      if (mounted) {
        setState(() {
          _splitQueue = results[0] as List<TransactionModel>;
          _groups = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
        print('📋 Split queue loaded: ${_splitQueue.length} transactions, ${_groups.length} groups');
      }
    } catch (e) {
      print('❌ Error loading split queue: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Removed old _confirmSplit and _modifySplit - functionality now in _SplitQueueCard widget

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
              if (!_isLoading) ...[
                _buildSectionHeader('Groups', _groups.length),
                _buildGroupsList(_groups),
              ],
              
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
      children: queue.map((transaction) => _SplitQueueCard(
        transaction: transaction,
        groups: _groups,
        onSplitSubmitted: () {
          // Reload queue after split is submitted
          _loadSplitQueue();
        },
      )).toList(),
    );
  }

  // Removed old _buildSplitQueueItem - now using _SplitQueueCard widget below

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

// Split Queue Card Widget with Group/Person Selection
class _SplitQueueCard extends StatefulWidget {
  final TransactionModel transaction;
  final List<Map<String, dynamic>> groups;
  final VoidCallback onSplitSubmitted;

  const _SplitQueueCard({
    required this.transaction,
    required this.groups,
    required this.onSplitSubmitted,
  });

  @override
  State<_SplitQueueCard> createState() => __SplitQueueCardState();
}

class __SplitQueueCardState extends State<_SplitQueueCard> {
  String? _selectedGroupId;
  List<Map<String, dynamic>> _groupMembers = [];
  List<String> _selectedPeopleIds = [];
  bool _isGroupVisible = false;
  bool _isLoadingMembers = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // If only one group exists, auto-select it
    if (widget.groups.length == 1) {
      _selectedGroupId = widget.groups.first['id'];
      _loadGroupMembers(_selectedGroupId!);
    }
  }

  Future<void> _loadGroupMembers(String groupId) async {
    setState(() => _isLoadingMembers = true);
    
    try {
      final members = await BackendService.getGroupMembers(groupId);
      if (mounted) {
        setState(() {
          _groupMembers = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  Future<void> _submitSplit() async {
    if (_selectedPeopleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one person to split with')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await BackendService.submitSplitTransaction(
      transactionId: widget.transaction.id,
      participantUserIds: _selectedPeopleIds,
      groupId: _selectedGroupId,
      isGroupVisible: _isGroupVisible,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Split \$${widget.transaction.amount.abs().toStringAsFixed(2)} among ${_selectedPeopleIds.length} people',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSplitSubmitted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error creating split'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.transaction.aiDescription ?? widget.transaction.description ?? 'Unknown';
    final amount = widget.transaction.amount.abs();
    final date = widget.transaction.date;
    final amountPerPerson = _selectedPeopleIds.isNotEmpty 
        ? amount / _selectedPeopleIds.length 
        : amount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
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
          // Header
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
                      '${date.month}/${date.day}/${date.year}',
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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Group Selection
          DropdownButtonFormField<String>(
            value: _selectedGroupId,
            decoration: InputDecoration(
              labelText: 'Select Group',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            items: widget.groups.map((group) {
              return DropdownMenuItem<String>(
                value: group['id'],
                child: Row(
                  children: [
                    Text(group['icon'] ?? '👥'),
                    SizedBox(width: 8.w),
                    Text(group['name']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGroupId = value;
                  _selectedPeopleIds.clear();
                });
                _loadGroupMembers(value);
              }
            },
          ),
          SizedBox(height: 12.h),

          // Members Selection
          if (_selectedGroupId != null) ...[
            Text(
              'Select People to Split With:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            
            if (_isLoadingMembers)
              const Center(child: CircularProgressIndicator())
            else if (_groupMembers.isEmpty)
              Text(
                'No members in this group',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _groupMembers.map((member) {
                  final userId = member['user_id'];
                  final isSelected = _selectedPeopleIds.contains(userId);
                  final displayName = member['nickname'] ?? 
                                     member['profiles']?['username'] ?? 
                                     member['profiles']?['email'] ?? 
                                     'Unknown';

                  return FilterChip(
                    label: Text(displayName),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4AF37).withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPeopleIds.add(userId);
                        } else {
                          _selectedPeopleIds.remove(userId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: 12.h),

            // Group Visibility Toggle
            CheckboxListTile(
              title: Text(
                'Make visible to group chat',
                style: TextStyle(fontSize: 13.sp),
              ),
              value: _isGroupVisible,
              onChanged: (value) {
                setState(() => _isGroupVisible = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFD4AF37),
            ),
          ],

          // Split Preview
          if (_selectedPeopleIds.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount per person:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${amountPerPerson.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitSplit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm Split'),
            ),
          ),
        ],
      ),
    );
  }
}

