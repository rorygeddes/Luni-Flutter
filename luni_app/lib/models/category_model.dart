import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String? userId; // null for global/locked categories
  final String parentKey;
  final String name;
  final String emoji;
  final bool isLocked;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    this.userId,
    required this.parentKey,
    required this.name,
    required this.emoji,
    required this.isLocked,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? parentKey,
    String? name,
    String? emoji,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentKey: parentKey ?? this.parentKey,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Predefined parent categories
class ParentCategories {
  static const Map<String, Map<String, String>> categories = {
    'housing_utilities': {
      'name': 'Housing & Utilities',
      'emoji': '🏠',
    },
    'food_drink': {
      'name': 'Food & Drink',
      'emoji': '🍽️',
    },
    'transportation': {
      'name': 'Transportation',
      'emoji': '🚗',
    },
    'education': {
      'name': 'Education',
      'emoji': '📚',
    },
    'personal_social': {
      'name': 'Personal & Social',
      'emoji': '👥',
    },
    'health_wellness': {
      'name': 'Health & Wellness',
      'emoji': '🏥',
    },
    'savings_debt': {
      'name': 'Savings & Debt',
      'emoji': '💰',
    },
    'student_income': {
      'name': 'Student Income',
      'emoji': '💼',
    },
  };

  static const Map<String, List<Map<String, String>>> subcategories = {
    'housing_utilities': [
      {'name': 'Rent', 'emoji': '🏠'},
      {'name': 'Utilities', 'emoji': '⚡'},
      {'name': 'Internet', 'emoji': '🌐'},
      {'name': 'Furniture/essentials', 'emoji': '🪑'},
    ],
    'food_drink': [
      {'name': 'Groceries', 'emoji': '🛒'},
      {'name': 'Coffee Shop', 'emoji': '☕'},
      {'name': 'Nicer Meals out', 'emoji': '🍽️'},
      {'name': 'Snacks & Fast food', 'emoji': '🍔'},
    ],
    'transportation': [
      {'name': 'Public transit pass', 'emoji': '🚌'},
      {'name': 'Gas', 'emoji': '⛽'},
      {'name': 'Car insurance & maintenance', 'emoji': '🔧'},
      {'name': 'Rideshare', 'emoji': '🚗'},
      {'name': 'Bike/scooter', 'emoji': '🚲'},
    ],
    'education': [
      {'name': 'Tuition & fees', 'emoji': '🎓'},
      {'name': 'Textbooks', 'emoji': '📖'},
      {'name': 'Supplies', 'emoji': '✏️'},
    ],
    'personal_social': [
      {'name': 'Clothing', 'emoji': '👕'},
      {'name': 'Entertainment', 'emoji': '🎬'},
      {'name': 'Nights out', 'emoji': '🌃'},
      {'name': 'Sports & Hobbies', 'emoji': '⚽'},
      {'name': 'Alcohol / substances', 'emoji': '🍺'},
      {'name': 'Subscriptions', 'emoji': '📱'},
    ],
    'health_wellness': [
      {'name': 'Health insurance / school plan', 'emoji': '🏥'},
      {'name': 'Medication / pharmacy', 'emoji': '💊'},
      {'name': 'Fitness / Gym', 'emoji': '💪'},
      {'name': 'Haircuts', 'emoji': '✂️'},
    ],
    'savings_debt': [
      {'name': 'Emergency fund', 'emoji': '🚨'},
      {'name': 'Credit card payments', 'emoji': '💳'},
      {'name': 'Student loans', 'emoji': '🎓'},
    ],
    'student_income': [
      {'name': 'Employment', 'emoji': '💼'},
      {'name': 'Family Support', 'emoji': '👨‍👩‍👧‍👦'},
      {'name': 'Loans & Aid', 'emoji': '📋'},
      {'name': 'Other/Bonus', 'emoji': '🎁'},
    ],
  };
}
