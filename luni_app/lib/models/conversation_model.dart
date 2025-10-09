class ConversationModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCount;

  // Computed fields (populated from profiles)
  final String? otherUserName;
  final String? otherUserUsername;
  final String? otherUserAvatarUrl;

  const ConversationModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.otherUserName,
    this.otherUserUsername,
    this.otherUserAvatarUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      otherUserName: json['other_user_name'] as String?,
      otherUserUsername: json['other_user_username'] as String?,
      otherUserAvatarUrl: json['other_user_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'last_message_sender_id': lastMessageSenderId,
      'unread_count': unreadCount,
      'other_user_name': otherUserName,
      'other_user_username': otherUserUsername,
      'other_user_avatar_url': otherUserAvatarUrl,
    };
  }

  ConversationModel copyWith({
    String? otherUserName,
    String? otherUserUsername,
    String? otherUserAvatarUrl,
  }) {
    return ConversationModel(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      unreadCount: unreadCount,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserUsername: otherUserUsername ?? this.otherUserUsername,
      otherUserAvatarUrl: otherUserAvatarUrl ?? this.otherUserAvatarUrl,
    );
  }
}

