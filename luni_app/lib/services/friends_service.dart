import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get friendship status with another user
  // Returns: 'none', 'sent', 'pending', 'accepted'
  static Future<String> getFriendshipStatus(String otherUserId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return 'none';

      // Check if current user sent a request
      final sentRequest = await _supabase
          .from('friends')
          .select()
          .eq('user_id', currentUser.id)
          .eq('friend_id', otherUserId)
          .maybeSingle();

      if (sentRequest != null) {
        return sentRequest['status'] as String;
      }

      // Check if other user sent a request
      final receivedRequest = await _supabase
          .from('friends')
          .select()
          .eq('user_id', otherUserId)
          .eq('friend_id', currentUser.id)
          .maybeSingle();

      if (receivedRequest != null) {
        final status = receivedRequest['status'] as String;
        return status == 'pending' ? 'pending' : status;
      }

      return 'none';
    } catch (e) {
      print('Error getting friendship status: $e');
      return 'none';
    }
  }

  // Send friend request
  static Future<void> sendFriendRequest(String friendId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      await _supabase.from('friends').insert({
        'user_id': currentUser.id,
        'friend_id': friendId,
        'status': 'sent',
      });
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  // Accept friend request
  static Future<void> acceptFriendRequest(String friendId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      await _supabase
          .from('friends')
          .update({'status': 'accepted', 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', friendId)
          .eq('friend_id', currentUser.id);
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  // Get all friends
  static Future<List<String>> getFriendIds() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      final friendships = await _supabase
          .from('friends')
          .select()
          .or('user_id.eq.${currentUser.id},friend_id.eq.${currentUser.id}')
          .eq('status', 'accepted');

      List<String> friendIds = [];
      for (var friendship in friendships) {
        final userId = friendship['user_id'] as String;
        final friendId = friendship['friend_id'] as String;
        friendIds.add(userId == currentUser.id ? friendId : userId);
      }

      return friendIds;
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }
}

