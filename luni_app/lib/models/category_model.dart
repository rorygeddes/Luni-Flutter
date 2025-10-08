class CategoryModel {
  final String id;
  final String? userId;
  final String parentKey; // e.g., "living_essentials", "food", "entertainment"
  final String name; // e.g., "Rent", "Groceries", "Movies"
  final String? icon; // emoji or icon name
  final String? emoji; // alias for icon (for backwards compatibility)
  final bool isDefault; // true for default categories, false for user-created
  final bool isLocked; // alias for isDefault (for backwards compatibility)
  final bool isActive; // user can deselect categories
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    this.userId,
    required this.parentKey,
    required this.name,
    String? icon,
    String? emoji,
    bool? isDefault,
    bool? isLocked,
    this.isActive = true,
    required this.createdAt,
  })  : icon = icon ?? emoji,
        emoji = emoji ?? icon,
        isDefault = isDefault ?? isLocked ?? false,
        isLocked = isLocked ?? isDefault ?? false;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      parentKey: json['parent_key'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? json['emoji'] as String?,
      emoji: json['emoji'] as String? ?? json['icon'] as String?,
      isDefault: json['is_default'] as bool? ?? json['is_locked'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parent_key': parentKey,
      'name': name,
      'icon': icon,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get display name for parent category
  static String getParentDisplayName(String parentKey) {
    switch (parentKey) {
      case 'living_essentials':
        return 'Living Essentials';
      case 'education':
        return 'Education';
      case 'food':
        return 'Food & Dining';
      case 'transportation':
        return 'Transportation';
      case 'healthcare':
        return 'Healthcare';
      case 'entertainment':
        return 'Entertainment';
      case 'vacation':
        return 'Vacation & Travel';
      case 'income':
        return 'Income';
      default:
        return parentKey.replaceAll('_', ' ').split(' ').map((word) => 
          word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
  }

  // Helper to get icon for parent category
  static String getParentIcon(String parentKey) {
    switch (parentKey) {
      case 'living_essentials':
        return '🏠';
      case 'education':
        return '📚';
      case 'food':
        return '🍽️';
      case 'transportation':
        return '🚗';
      case 'healthcare':
        return '💊';
      case 'entertainment':
        return '🎬';
      case 'vacation':
        return '✈️';
      case 'income':
        return '💰';
      default:
        return '📁';
    }
  }
}
