import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';

class MessagingService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all users for search (excluding current user)
  // Prioritizes username search, but also searches full_name
  // Only returns PUBLIC profile fields: id, username, full_name, avatar_url, etransfer_id
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      print('🔍 Searching for: "$query"');
      print('🔍 Current user ID: ${currentUser.id}');

      final response = await _supabase
          .from('profiles')
          .select('id, username, full_name, avatar_url, etransfer_id')  // PUBLIC FIELDS ONLY
          .neq('id', currentUser.id)
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .order('username')
          .limit(20);

      print('🔍 Search results count: ${(response as List).length}');
      
      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
      
      for (var user in users) {
        print('🔍 Found user: ${user.username} (${user.fullName})');
      }

      return users;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // Get all users (for showing all profiles)
  // Only returns PUBLIC profile fields: id, username, full_name, avatar_url, etransfer_id
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      print('👤 Current user email: ${currentUser.email}');
      print('👤 Current user ID: ${currentUser.id}');

      final response = await _supabase
          .from('profiles')
          .select('id, username, full_name, avatar_url, etransfer_id')  // PUBLIC FIELDS ONLY
          .neq('id', currentUser.id)
          .order('full_name');

      print('👥 Found ${(response as List).length} other users');
      
      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
      
      for (var user in users) {
        print('   - ${user.username} (${user.fullName}) [${user.id}]');
      }

      return users;
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Get or create conversation between two users
  static Future<String> getOrCreateConversation(String otherUserId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Sort user IDs to ensure consistent ordering
      final user1Id = currentUser.id.compareTo(otherUserId) < 0 
          ? currentUser.id 
          : otherUserId;
      final user2Id = currentUser.id.compareTo(otherUserId) < 0 
          ? otherUserId 
          : currentUser.id;

      // Try to find existing conversation
      final existing = await _supabase
          .from('conversations')
          .select()
          .eq('user1_id', user1Id)
          .eq('user2_id', user2Id)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Create new conversation
      final response = await _supabase
          .from('conversations')
          .insert({
            'user1_id': user1Id,
            'user2_id': user2Id,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error getting/creating conversation: $e');
      rethrow;
    }
  }

  // Get all conversations for current user
  static Future<List<ConversationModel>> getConversations() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Get conversations where user is participant
      final conversationsResponse = await _supabase
          .from('conversations')
          .select()
          .or('user1_id.eq.${currentUser.id},user2_id.eq.${currentUser.id}')
          .order('updated_at', ascending: false);

      List<ConversationModel> conversations = [];

      for (var convJson in conversationsResponse) {
        final user1Id = convJson['user1_id'] as String;
        final user2Id = convJson['user2_id'] as String;
        final conversationId = convJson['id'] as String;
        final otherUserId = user1Id == currentUser.id ? user2Id : user1Id;

        // Get the last message for this conversation
        final lastMessageResponse = await _supabase
            .from('messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        // Get unread count
        final unreadMessages = await _supabase
            .from('messages')
            .select()
            .eq('conversation_id', conversationId)
            .neq('sender_id', currentUser.id)
            .eq('is_read', false);

        final unreadCount = (unreadMessages as List).length;

        // Fetch the other user's PUBLIC profile
        final userProfile = await _supabase
            .from('profiles')
            .select('id, username, full_name, avatar_url, etransfer_id')  // PUBLIC FIELDS ONLY
            .eq('id', otherUserId)
            .single();

        // Build conversation model
        final conversation = ConversationModel(
          id: conversationId,
          user1Id: user1Id,
          user2Id: user2Id,
          createdAt: DateTime.parse(convJson['created_at'] as String),
          updatedAt: DateTime.parse(convJson['updated_at'] as String),
          lastMessage: lastMessageResponse?['message_text'] as String?,
          lastMessageTime: lastMessageResponse != null
              ? DateTime.parse(lastMessageResponse['created_at'] as String)
              : null,
          lastMessageSenderId: lastMessageResponse?['sender_id'] as String?,
          unreadCount: unreadCount,
          otherUserName: userProfile['full_name'] as String?,
          otherUserUsername: userProfile['username'] as String?,
          otherUserAvatarUrl: userProfile['avatar_url'] as String?,
        );

        conversations.add(conversation);
      }

      return conversations;
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  // Get messages for a conversation
  static Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Send a message
  static Future<MessageModel> sendMessage({
    required String conversationId,
    required String messageText,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': currentUser.id,
            'message_text': messageText,
          })
          .select()
          .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUser.id);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Subscribe to new messages in a conversation
  static Stream<MessageModel> subscribeToMessages(String conversationId) {
    return _supabase
        .from('messages:conversation_id=eq.$conversationId')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList())
        .expand((messages) => messages);
  }

  // Subscribe to conversation updates
  static Stream<ConversationModel> subscribeToConversations() {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => ConversationModel.fromJson(json)).toList())
        .expand((conversations) => conversations);
  }
}

