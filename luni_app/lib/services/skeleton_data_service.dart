import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/queue_item_model.dart';

class SkeletonDataService {
  // Mock accounts data
  static List<AccountModel> getMockAccounts() {
    return [
      AccountModel(
        id: 'acc_checking_001',
        userId: 'user_001',
        institutionId: 'ins_td_001',
        name: 'TD Checking Account',
        type: 'depository',
        subtype: 'checking',
        balance: 1250.75,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AccountModel(
        id: 'acc_savings_001',
        userId: 'user_001',
        institutionId: 'ins_td_001',
        name: 'TD Savings Account',
        type: 'depository',
        subtype: 'savings',
        balance: 3500.00,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AccountModel(
        id: 'acc_credit_001',
        userId: 'user_001',
        institutionId: 'ins_rbc_001',
        name: 'RBC Credit Card',
        type: 'credit',
        subtype: 'credit_card',
        balance: -450.25,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  // Mock transactions data
  static List<TransactionModel> getMockTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'txn_001',
        userId: 'user_001',
        accountId: 'acc_checking_001',
        amount: -25.50,
        description: 'STARBUCKS COFFEE',
        merchantName: 'Starbucks',
        date: now.subtract(const Duration(days: 1)),
        category: 'food_drink',
        subcategory: 'Coffee',
        isCategorized: true,
        isSplit: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'txn_002',
        userId: 'user_001',
        accountId: 'acc_checking_001',
        amount: -150.00,
        description: 'UBER TRIP',
        merchantName: 'Uber',
        date: now.subtract(const Duration(days: 2)),
        category: 'transportation',
        subcategory: 'Rideshare',
        isCategorized: true,
        isSplit: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: 'txn_003',
        userId: 'user_001',
        accountId: 'acc_checking_001',
        amount: -89.99,
        description: 'NETFLIX SUBSCRIPTION',
        merchantName: 'Netflix',
        date: now.subtract(const Duration(days: 3)),
        category: 'entertainment',
        subcategory: 'Subscriptions',
        isCategorized: true,
        isSplit: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'txn_004',
        userId: 'user_001',
        accountId: 'acc_checking_001',
        amount: -45.00,
        description: 'MCDONALDS',
        merchantName: 'McDonald\'s',
        date: now.subtract(const Duration(days: 4)),
        category: null,
        subcategory: null,
        isCategorized: false,
        isSplit: false,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: 'txn_005',
        userId: 'user_001',
        accountId: 'acc_checking_001',
        amount: -120.00,
        description: 'AMAZON PURCHASE',
        merchantName: 'Amazon',
        date: now.subtract(const Duration(days: 5)),
        category: null,
        subcategory: null,
        isCategorized: false,
        isSplit: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Mock queue items data
  static List<Map<String, dynamic>> getMockQueueItems() {
    return [
      {
        'id': 1,
        'transaction_id': 'txn_004',
        'ai_description': 'McDonald\'s',
        'ai_category': 'food_drink',
        'ai_subcategory': 'Fast Food',
        'confidence_score': 0.9,
        'status': 'pending',
        'amount': -45.00,
        'description': 'MCDONALDS',
        'merchant_name': 'McDonald\'s',
        'date': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'id': 2,
        'transaction_id': 'txn_005',
        'ai_description': 'Amazon Purchase',
        'ai_category': 'shopping',
        'ai_subcategory': 'Online Shopping',
        'confidence_score': 0.8,
        'status': 'pending',
        'amount': -120.00,
        'description': 'AMAZON PURCHASE',
        'merchant_name': 'Amazon',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
  }

  // Check if user has connected accounts (always true for skeleton)
  static bool hasConnectedAccounts() {
    return true;
  }

  // Get queued transactions count
  static int getQueuedTransactionsCount() {
    return getMockQueueItems().length;
  }

  // Mock groups data
  static List<Map<String, dynamic>> getMockGroups() {
    return [
      {
        'id': 'group_1',
        'name': 'Roommates',
        'description': 'House sharing expenses',
        'member_count': 3,
        'total_owed': 450.00,
        'icon': '🏠',
      },
      {
        'id': 'group_2',
        'name': 'Trip to Vancouver',
        'description': 'Weekend getaway costs',
        'member_count': 4,
        'total_owed': 280.50,
        'icon': '✈️',
      },
      {
        'id': 'group_3',
        'name': 'Study Group',
        'description': 'Books and supplies',
        'member_count': 5,
        'total_owed': 125.00,
        'icon': '📚',
      },
    ];
  }

  // Mock people data
  static List<Map<String, dynamic>> getMockPeople() {
    return [
      {
        'id': 'person_1',
        'name': 'Alex Johnson',
        'email': 'alex@example.com',
        'avatar': '👤',
        'total_owed': 85.00,
      },
      {
        'id': 'person_2',
        'name': 'Sarah Chen',
        'email': 'sarah@example.com',
        'avatar': '👤',
        'total_owed': -45.00, // They owe you
      },
      {
        'id': 'person_3',
        'name': 'Mike Davis',
        'email': 'mike@example.com',
        'avatar': '👤',
        'total_owed': 120.00,
      },
      {
        'id': 'person_4',
        'name': 'Emma Wilson',
        'email': 'emma@example.com',
        'avatar': '👤',
        'total_owed': -30.00,
      },
    ];
  }

  // Mock split queue items
  static List<Map<String, dynamic>> getMockSplitQueue() {
    return [
      {
        'id': 'split_1',
        'transaction_description': 'Dinner at Italian Restaurant',
        'amount': 120.00,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'suggested_split': 'Equal split among 4 people',
        'people_count': 4,
        'per_person': 30.00,
      },
      {
        'id': 'split_2',
        'transaction_description': 'Grocery Shopping',
        'amount': 85.50,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'suggested_split': 'Roommates group',
        'people_count': 3,
        'per_person': 28.50,
      },
    ];
  }

  // Mock conversations with messages
  static List<Map<String, dynamic>> getMockConversations() {
    return [
      {
        'id': 'conv_1',
        'person_id': 'person_1',
        'person_name': 'Alex Johnson',
        'person_avatar': '👤',
        'balance': 85.00, // Positive means they owe you
        'last_message': 'Sure, I\'ll send it today!',
        'last_message_time': DateTime.now().subtract(const Duration(minutes: 15)),
        'unread_count': 1,
      },
      {
        'id': 'conv_2',
        'person_id': 'person_2',
        'person_name': 'Sarah Chen',
        'person_avatar': '👤',
        'balance': -45.00, // Negative means you owe them
        'last_message': 'No worries, whenever you can',
        'last_message_time': DateTime.now().subtract(const Duration(hours: 2)),
        'unread_count': 0,
      },
      {
        'id': 'conv_3',
        'person_id': 'person_3',
        'person_name': 'Mike Davis',
        'person_avatar': '👤',
        'balance': 0.00, // Even
        'last_message': 'Thanks for dinner yesterday!',
        'last_message_time': DateTime.now().subtract(const Duration(days: 1)),
        'unread_count': 0,
      },
    ];
  }

  // Mock messages for a specific conversation
  static List<Map<String, dynamic>> getMockMessages(String personId) {
    if (personId == 'person_1') {
      return [
        {
          'id': 'msg_1',
          'text': 'Hey! Do you have a moment?',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          'id': 'msg_2',
          'text': 'Yeah, what\'s up?',
          'is_me': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3, minutes: -2)),
        },
        {
          'id': 'msg_3',
          'text': 'Can I pay you back for the concert tickets tomorrow?',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': 'msg_4',
          'text': 'Of course! No rush',
          'is_me': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: -5)),
        },
        {
          'id': 'msg_5',
          'text': 'Sure, I\'ll send it today!',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        },
      ];
    } else if (personId == 'person_2') {
      return [
        {
          'id': 'msg_6',
          'text': 'I owe you for the groceries, right?',
          'is_me': true,
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': 'msg_7',
          'text': 'Yeah, it was \$45 total',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 22)),
        },
        {
          'id': 'msg_8',
          'text': 'I\'ll transfer it by the weekend',
          'is_me': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          'id': 'msg_9',
          'text': 'No worries, whenever you can',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
      ];
    } else {
      return [
        {
          'id': 'msg_10',
          'text': 'Thanks for dinner yesterday!',
          'is_me': false,
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': 'msg_11',
          'text': 'Anytime! It was fun 😊',
          'is_me': true,
          'timestamp': DateTime.now().subtract(const Duration(days: 1, minutes: -10)),
        },
      ];
    }
  }
}
