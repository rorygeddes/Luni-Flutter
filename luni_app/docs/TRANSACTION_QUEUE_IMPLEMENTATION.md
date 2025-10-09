# 🎯 Transaction Queue Implementation Guide

## ✅ What's Already Built

### Backend Complete ✅
1. **OpenAI Service** (`lib/services/openai_service.dart`)
   - `cleanDescription()` - Cleans up raw bank descriptions
   - `categorizeTransaction()` - AI categorizes into parent/sub categories
   - `processTransaction()` - Combined description + categorization
   - Fallback logic for when API fails

2. **Backend Service Updates** (`lib/services/backend_service.dart`)
   - `getTransactionQueue()` - Gets 5 uncategorized transactions with AI processing
   - `submitCategorizedTransactions()` - Submits user-confirmed categories
   - `getUncategorizedCount()` - Shows remaining transactions count
   - Duplicate detection integrated

3. **Transaction Model** (`lib/models/transaction_model.dart`)
   - Added `aiDescription` field (AI-cleaned, user-editable)
   - Added `isPotentialDuplicate` for duplicate detection
   - Raw `description` preserved (never changes)

4. **Database** (`docs/sql/ADD_AI_DESCRIPTION_COLUMN.sql`)
   - Added `ai_description` column to transactions table

---

## 🚀 What Needs to Be Built (UI)

### 1. Transaction Queue Screen
Location: `lib/screens/transaction_queue_screen.dart`

**Features:**
- Shows 5 transactions at a time
- Each transaction has:
  - AI-cleaned description (editable text field)
  - Raw description (small grey text below)
  - Parent category dropdown
  - Sub-category dropdown (filtered by parent)
  - Split checkbox
  - Amount & date (read-only)
- Submit button at bottom
- Counter showing remaining uncategorized transactions

### 2. Category Dropdowns
- Parent categories filter sub-categories
- User can edit AI suggestions
- Default to AI suggestions

### 3. Split Queue Screen (Future)
- Similar to transaction queue
- Additional fields for group/person selection
- Covered in workflow.md

---

## 📋 Step-by-Step Implementation

### Step 1: Run SQL Setup (5 minutes)

In Supabase SQL Editor:
```sql
-- File: docs/sql/ADD_AI_DESCRIPTION_COLUMN.sql
```

This adds the `ai_description` column to your transactions table.

### Step 2: Update .env File (2 minutes)

Add your OpenAI API key:
```env
OPENAI_API_KEY=sk-your-api-key-here
```

Get your API key from: https://platform.openai.com/api-keys

### Step 3: Regenerate Transaction Model (2 minutes)

```bash
cd "Luni Flutter/luni_app"
flutter pub run build_runner build --delete-conflicting-outputs
```

This updates `transaction_model.g.dart` with the new fields.

### Step 4: Create Transaction Queue Screen (60-90 minutes)

Create `lib/screens/transaction_queue_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/backend_service.dart';

class TransactionQueueScreen extends StatefulWidget {
  @override
  _TransactionQueueScreenState createState() => _TransactionQueueScreenState();
}

class _TransactionQueueScreenState extends State<TransactionQueueScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  int _remainingCount = 0;

  // Category mappings (from workflow.md)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading queue: $e')),
      );
    }
  }

  Future<void> _submitTransactions() async {
    final success = await BackendService.submitCategorizedTransactions(_transactions);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${_transactions.length} transactions categorized!')),
      );
      _loadQueue(); // Load next batch
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error submitting transactions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Queue'),
        subtitle: _remainingCount > 0
            ? Text('$_remainingCount transactions remaining')
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'All caught up!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('No transactions to categorize'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
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

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _transactions.isEmpty ? null : _submitTransactions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD4AF37), // Gold color
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Submit ${_transactions.length} Transaction${_transactions.length != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final amount = widget.transaction['amount'] ?? 0.0;
    final date = widget.transaction['date'] ?? '';
    final rawDescription = widget.transaction['description'] ?? 'Unknown';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date.split('T')[0],
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: amount < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // AI Description (editable)
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            
            // Raw description (small grey text)
            Text(
              'Raw: $rawDescription',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            
            // Category dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedParent,
                    decoration: InputDecoration(
                      labelText: 'Parent Category',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.categoryMap.keys.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 14)),
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
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSub,
                    decoration: InputDecoration(
                      labelText: 'Sub-Category',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.categoryMap[_selectedParent]!.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Text(sub, style: TextStyle(fontSize: 14)),
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
            SizedBox(height: 12),
            
            // Split checkbox
            CheckboxListTile(
              title: Text('Mark for Split'),
              subtitle: Text('Send to split queue after submission'),
              value: _isSplit,
              onChanged: (value) {
                setState(() {
                  _isSplit = value ?? false;
                  _updateTransaction();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
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
```

### Step 5: Add Navigation (5 minutes)

In your main navigation (probably `add_screen.dart` or navigation drawer):

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionQueueScreen()),
    );
  },
  child: Text('Transaction Queue'),
)
```

### Step 6: Update Track Screen for Gold Border (30 minutes)

In your account detail or transaction list widgets, add conditional styling:

```dart
Widget _buildTransactionCard(Map<String, dynamic> transaction) {
  final isCategorized = transaction['is_categorized'] == true;
  
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: isCategorized ? Color(0xFFD4AF37) : Colors.grey[300]!,
        width: isCategorized ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      title: Text(transaction['ai_description'] ?? transaction['description']),
      subtitle: isCategorized
          ? Text('${transaction['category']} > ${transaction['subcategory']}')
          : Text('Uncategorized'),
      trailing: Text('\$${transaction['amount'].abs().toStringAsFixed(2)}'),
    ),
  );
}
```

---

## 🎨 Design Specifications

### Colors
- **Gold Border**: `Color(0xFFD4AF37)` - For categorized transactions
- **Primary Button**: Gold/Yellow
- **Income**: Green
- **Expense**: Red

### Typography
- **Description**: 16pt, medium weight
- **Raw Description**: 12pt, grey
- **Amount**: 18pt, bold

### Spacing
- Card padding: 16px
- Card margin: 16px bottom
- Element spacing: 12px

---

## 🧪 Testing Checklist

- [ ] Run SQL script to add ai_description column
- [ ] Regenerate transaction model with build_runner
- [ ] Add OPENAI_API_KEY to .env
- [ ] Test transaction queue loads 5 transactions
- [ ] Verify AI descriptions are generated
- [ ] Test editing AI description
- [ ] Test parent category changes sub-category options
- [ ] Test split checkbox
- [ ] Test submit button
- [ ] Verify gold border appears on categorized transactions
- [ ] Check remaining count updates
- [ ] Test with no uncategorized transactions (shows "All caught up!")

---

## 📊 How It Works

```
1. User opens Transaction Queue
   ↓
2. Backend gets 5 uncategorized transactions
   ↓
3. For each transaction:
   - Calls OpenAI to clean description
   - Calls OpenAI to categorize
   - Updates database with AI suggestions
   ↓
4. UI displays transactions with:
   - AI description (editable)
   - AI category suggestions (editable dropdowns)
   - Split checkbox
   ↓
5. User reviews and edits if needed
   ↓
6. User clicks Submit
   ↓
7. Backend marks all as is_categorized = true
   ↓
8. Transactions get gold border in Track screen
   ↓
9. Next 5 transactions load
```

---

## 🚀 Future Enhancements

1. **AI Learning**
   - Store user corrections
   - Improve AI suggestions based on history

2. **Split Queue**
   - Separate screen for split transactions
   - Group and person selection
   - Follows workflow.md specifications

3. **Batch Actions**
   - "Accept All" button
   - Bulk edit categories

4. **Smart Categories**
   - Merchant-based rules
   - Time-based categorization

---

## 🐛 Troubleshooting

### "OpenAI API Error"
- Check OPENAI_API_KEY in .env
- Verify API key has credits
- Check fallback logic is working

### "No transactions in queue"
- Verify transactions exist in database
- Check is_categorized = false or null
- Run: `SELECT COUNT(*) FROM transactions WHERE is_categorized = false;`

### "Gold border not showing"
- Check is_categorized is set to true
- Verify UI conditional logic
- Check transaction model has latest changes

---

**Total Implementation Time**: 2-3 hours  
**Difficulty**: Medium  
**Priority**: High - Core feature

---

## 📝 Next Steps

1. Run SQL setup
2. Add OpenAI API key
3. Regenerate models
4. Implement UI components
5. Test thoroughly
6. Deploy!

Good luck! 🚀

