import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Lazy getter — always called after Supabase.initialize() completes
SupabaseClient get _supabase => Supabase.instance.client;

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String? senderUsername;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.senderUsername,
  });
}

// ─────────────────────────────────────────────
// Real-time StreamProvider
// ─────────────────────────────────────────────

final friendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final myId = _supabase.auth.currentUser?.id;
  if (myId == null) return Stream.value([]);

  // .stream() delivers real-time updates whenever friend_requests changes.
  // RLS ensures only the receiver sees their own rows.
  return _supabase
      .from('friend_requests')
      .stream(primaryKey: ['id'])
      .eq('receiver_id', myId)
      .asyncMap((data) async {
        if (data.isEmpty) return <FriendRequest>[];

        // Single batch query for all sender usernames — no N+1
        final senderIds = data.map((r) => r['sender_id'] as String).toSet().toList();
        final usersData = await _supabase
            .from('users')
            .select('id, username')
            .inFilter('id', senderIds);

        final usernameMap = {
          for (final u in usersData) u['id'] as String: u['username'] as String?,
        };

        return data.map((item) {
          return FriendRequest(
            id: item['id'] as String,
            senderId: item['sender_id'] as String,
            receiverId: item['receiver_id'] as String,
            createdAt: DateTime.parse(item['created_at'] as String),
            senderUsername: usernameMap[item['sender_id'] as String],
          );
        }).toList();
      });
});

// ─────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────

class SocialService {
  /// Sends a friend request.
  /// Throws [PostgrestException] with code '23505' on duplicate.
  static Future<void> sendFriendRequest(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _supabase.from('friend_requests').insert({
      'sender_id': myId,
      'receiver_id': targetUserId,
    });
  }

  /// Accepts a friend request via a SECURITY DEFINER RPC.
  ///
  /// The server-side function atomically:
  ///  1. Creates the friendship record
  ///  2. Assigns both users to the same party (creating one if needed)
  ///  3. Deletes the friend_request row
  ///
  /// This avoids the RLS restriction that prevents the receiver
  /// from updating the sender's `party_id` directly.
  static Future<void> acceptFriendRequest(FriendRequest request) async {
    await _supabase.rpc('accept_friend_request', params: {
      'p_request_id': request.id,
      'p_sender_id': request.senderId,
    });
  }

  /// Declines a friend request — simply deletes it.
  static Future<void> declineFriendRequest(String requestId) async {
    await _supabase.from('friend_requests').delete().eq('id', requestId);
  }
}
