import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import '../services/backend_service.dart';
import '../widgets/luni_button.dart';
import '../models/transaction_model.dart';
import '../widgets/luni_button.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> with AutomaticKeepAliveClientMixin {
  List<TransactionModel> _splitQueue = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;
  bool _showSplitQueue = false; // Controls split queue modal visibility

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
        BackendService.getFriends(),
      ]);
      
      if (mounted) {
        setState(() {
          _splitQueue = results[0] as List<TransactionModel>;
          _groups = results[1] as List<Map<String, dynamic>>;
          _friends = results[2] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
        print('📋 Loaded: ${_splitQueue.length} transactions, ${_groups.length} groups, ${_friends.length} friends');
      }
    } catch (e) {
      print('❌ Error loading split data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Removed old _confirmSplit and _modifySplit - functionality now in _SplitQueueCard widget

  void _showSplitQueueModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text(
                        'Split Queue',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_splitQueue.length} transaction${_splitQueue.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                // Split Queue List
                Expanded(
                  child: _splitQueue.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 48.sp, color: Colors.grey.shade400),
                              SizedBox(height: 12.h),
                              Text(
                                'No transactions to split',
                                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(16.w),
                          itemCount: _splitQueue.length,
                          itemBuilder: (context, index) {
                            return _SplitQueueCard(
                              transaction: _splitQueue[index],
                              groups: _groups,
                              onSplitSubmitted: () {
                                _loadSplitQueue();
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
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
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // PINNED: Groups Section
                    _buildPinnedGroupsSection(),
                    
                    SizedBox(height: 8.h),
                    
                    // PINNED: People Section (Friends)
                    _buildPinnedPeopleSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // Split Queue Button (Modal Trigger)
                    _buildSplitQueueButton(),
                    
                    // Expandable content area
                    Expanded(child: Container()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedGroupsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Groups',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Show create group dialog
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _groups.isEmpty
              ? Text('No groups yet', style: TextStyle(color: Colors.grey.shade600))
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _groups.map((group) {
                    return Chip(
                      avatar: Text(group['icon'] ?? '👥'),
                      label: Text(group['name']),
                      backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildPinnedPeopleSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          _friends.isEmpty
              ? Text('No friends yet - add friends in Social tab', style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp))
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _friends.map((friend) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: const Color(0xFFD4AF37),
                        child: Text(
                          (friend['username'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      label: Text(friend['username'] as String? ?? 'Unknown'),
                      backgroundColor: Colors.white,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSplitQueueButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: LuniElevatedButton(
        onPressed: _showSplitQueueModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long),
            SizedBox(width: 8.w),
            Text(
              'Split Queue (${_splitQueue.length})',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
  String? _selectedPersonId;
  List<Map<String, dynamic>> _groupMembers = [];
  List<Map<String, dynamic>> _allFriends = [];
  List<String> _selectedPeopleIds = [];
  bool _isGroupVisible = false;
  bool _isLoadingMembers = false;
  bool _isLoadingFriends = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    // If only one group exists, auto-select it
    if (widget.groups.length == 1) {
      _selectedGroupId = widget.groups.first['id'];
      _loadGroupMembers(_selectedGroupId!);
    }
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    
    try {
      final friends = await BackendService.getFriends();
      if (mounted) {
        setState(() {
          _allFriends = friends;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      print('❌ Error loading friends for split: $e');
      if (mounted) {
        setState(() => _isLoadingFriends = false);
      }
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
    // Validate: at least group OR person must be selected
    if (_selectedGroupId == null && _selectedPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a group or person to split with')),
      );
      return;
    }

    // If person selected directly, use that; otherwise use group members
    final participantIds = _selectedPersonId != null 
        ? [_selectedPersonId!] 
        : _selectedPeopleIds;

    if (participantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one person')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await BackendService.submitSplitTransaction(
      transactionId: widget.transaction.id,
      participantUserIds: participantIds,
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
    
    // Calculate split count: direct person (1), or group members count
    final splitCount = _selectedPersonId != null 
        ? 1 
        : _selectedPeopleIds.length;
    final amountPerPerson = splitCount > 0 
        ? amount / splitCount 
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

          // Group Selection (Optional)
          DropdownButtonFormField<String>(
            value: _selectedGroupId,
            decoration: InputDecoration(
              labelText: 'Select Group (Optional)',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              suffixIcon: _selectedGroupId != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedGroupId = null;
                          _selectedPeopleIds.clear();
                          _groupMembers.clear();
                        });
                      },
                    )
                  : null,
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
                  _selectedPersonId = null; // Clear person selection
                  _selectedPeopleIds.clear();
                });
                _loadGroupMembers(value);
              }
            },
          ),
          SizedBox(height: 12.h),

          // Person Selection (Optional - direct selection without group)
          DropdownButtonFormField<String>(
            value: _selectedPersonId,
            decoration: InputDecoration(
              labelText: 'Or Select Person Directly (Optional)',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              suffixIcon: _selectedPersonId != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedPersonId = null;
                        });
                      },
                    )
                  : null,
            ),
            items: () {
              // Remove duplicates based on friend_user_id
              final seenIds = <String>{};
              final uniqueFriends = <DropdownMenuItem<String>>[];
              
              for (final friend in _allFriends) {
                final friendUserId = friend['friend_user_id'] as String?;
                if (friendUserId == null || seenIds.contains(friendUserId)) continue;
                
                seenIds.add(friendUserId);
                final username = friend['username'] as String? ?? 'Unknown';
                
                uniqueFriends.add(
                  DropdownMenuItem<String>(
                    value: friendUserId,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12.r,
                          backgroundColor: const Color(0xFFD4AF37),
                          child: Text(
                            username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(fontSize: 10.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(username),
                      ],
                    ),
                  ),
                );
              }
              
              return uniqueFriends;
            }(),
            onChanged: (value) {
              setState(() {
                _selectedPersonId = value;
                if (value != null) {
                  _selectedGroupId = null; // Clear group selection
                  _selectedPeopleIds.clear();
                  _groupMembers.clear();
                }
              });
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
          if (_selectedPersonId != null || _selectedPeopleIds.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedPersonId != null 
                            ? 'Splitting with 1 person:' 
                            : 'Amount per person (${_selectedPeopleIds.length}):',
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
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: LuniElevatedButton(
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

