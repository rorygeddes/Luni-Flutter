import 'package:flutter/material.dart';
import '../services/backend_service.dart';

class TransactionQueueScreen extends StatefulWidget {
  const TransactionQueueScreen({Key? key}) : super(key: key);

  @override
  _TransactionQueueScreenState createState() => _TransactionQueueScreenState();
}

class _TransactionQueueScreenState extends State<TransactionQueueScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  int _remainingCount = 0;

  // Category mappings from workflow.md
  final Map<String, List<String>> _categoryMap = {
    'LIVING ESSENTIALS': ['Rent', 'Wifi', 'Utilities', 'Phone'],
    'EDUCATION': ['Tuition', 'Supplies', 'Books'],
    'FOOD': ['Groceries', 'Coffee & Lunch', 'Restaurants & Dinner'],
    'TRANSPORTATION': ['Bus Pass', 'Gas', 'Rideshare'],
    'HEALTHCARE': ['Gym', 'Medication', 'Haircuts', 'Toiletries'],
    'ENTERTAINMENT': ['Events', 'Night Out', 'Shopping', 'Substances', 'Subscriptions'],
    'VACATION': ['Travel', 'Accommodation', 'Activities'],
    'INCOME': ['Job Income', 'Family Support', 'Savings/Investments', 'Bonus', 'E-Transfer In'],
  };

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    
    try {
      final transactions = await BackendService.getTransactionQueue();
      final count = await BackendService.getUncategorizedCount();
      
      setState(() {
        _transactions = transactions;
        _remainingCount = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading queue: $e')),
        );
      }
    }
  }

  Future<void> _submitTransactions() async {
    if (_transactions.isEmpty) return;

    final success = await BackendService.submitCategorizedTransactions(_transactions);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_transactions.length} transactions categorized!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadQueue(); // Load next batch
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error submitting transactions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction Queue'),
            if (_remainingCount > 0)
              Text(
                '$_remainingCount transactions remaining',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: const Color(0xFFD4AF37), // Gold
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildQueueInfo(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          return _TransactionQueueCard(
                            transaction: _transactions[index],
                            categoryMap: _categoryMap,
                            onUpdate: (updated) {
                              setState(() {
                                _transactions[index] = updated;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _buildSubmitButton(),
                  ],
                ),
    );
  }

  Widget _buildQueueInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Review ${_transactions.length} transactions. Edit descriptions and categories as needed.',
              style: const TextStyle(color: Colors.blue),
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
          Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No transactions to categorize',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _transactions.isEmpty ? null : _submitTransactions,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37), // Gold color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Submit ${_transactions.length} Transaction${_transactions.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _TransactionQueueCard extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Map<String, List<String>> categoryMap;
  final Function(Map<String, dynamic>) onUpdate;

  const _TransactionQueueCard({
    required this.transaction,
    required this.categoryMap,
    required this.onUpdate,
  });

  @override
  __TransactionQueueCardState createState() => __TransactionQueueCardState();
}

class __TransactionQueueCardState extends State<_TransactionQueueCard> {
  late TextEditingController _descriptionController;
  late String _selectedParent;
  late String _selectedSub;
  late bool _isSplit;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.transaction['ai_description'] ?? widget.transaction['description'],
    );
    _selectedParent = widget.transaction['category'] ?? 'ENTERTAINMENT';
    _selectedSub = widget.transaction['subcategory'] ?? 'Shopping';
    _isSplit = widget.transaction['is_split'] ?? false;

    // Validate sub-category exists in selected parent
    if (!widget.categoryMap[_selectedParent]!.contains(_selectedSub)) {
      _selectedSub = widget.categoryMap[_selectedParent]!.first;
    }

    _descriptionController.addListener(_updateTransaction);
  }

  void _updateTransaction() {
    widget.transaction['ai_description'] = _descriptionController.text;
    widget.transaction['category'] = _selectedParent;
    widget.transaction['subcategory'] = _selectedSub;
    widget.transaction['is_split'] = _isSplit;
    widget.onUpdate(widget.transaction);
  }

  @override
  Widget build(BuildContext context) {
    final amount = (widget.transaction['amount'] ?? 0.0).toDouble();
    final date = widget.transaction['date']?.toString() ?? '';
    final rawDescription = widget.transaction['description'] ?? 'Unknown';
    final isPotentialDuplicate = widget.transaction['is_potential_duplicate'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isPotentialDuplicate ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPotentialDuplicate ? Colors.orange : Colors.grey[300]!,
          width: isPotentialDuplicate ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duplicate warning
            if (isPotentialDuplicate) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'POTENTIAL DUPLICATE',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Date and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date.split('T')[0],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: amount < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // AI Description (editable)
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.edit, size: 20),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            
            // Raw description (small grey text)
            Text(
              'Raw: $rawDescription',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Category dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedParent,
                    decoration: const InputDecoration(
                      labelText: 'Parent Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    items: widget.categoryMap.keys.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedParent = value!;
                        _selectedSub = widget.categoryMap[value]!.first;
                        _updateTransaction();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSub,
                    decoration: const InputDecoration(
                      labelText: 'Sub-Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    items: widget.categoryMap[_selectedParent]!.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Text(
                          sub,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSub = value!;
                        _updateTransaction();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Split checkbox
            CheckboxListTile(
              title: const Text(
                'Mark for Split',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Send to split queue after submission',
                style: TextStyle(fontSize: 12),
              ),
              value: _isSplit,
              onChanged: (value) {
                setState(() {
                  _isSplit = value ?? false;
                  _updateTransaction();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFD4AF37),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
