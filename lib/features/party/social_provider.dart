import 'package:flutter/foundation.dart';
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

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    // sender is joined as a nested object: { username: '...' }
    final senderMap = json['sender'] as Map<String, dynamic>?;
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: senderMap?['username'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Real-time StreamProvider
// ─────────────────────────────────────────────

final friendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final myId = _supabase.auth.currentUser?.id;
  if (myId == null) return Stream.value([]);

  // Use .stream() to get real-time updates.
  // The .eq() filter is applied client-side after Supabase Realtime delivers
  // the event, and RLS ensures only rows the user has access to are broadcast.
  return _supabase
      .from('friend_requests')
      .stream(primaryKey: ['id'])
      .eq('receiver_id', myId)
      .asyncMap((data) async {
        if (data.isEmpty) return <FriendRequest>[];

        // Collect all unique sender IDs in one pass
        final senderIds = data.map((r) => r['sender_id'] as String).toSet().toList();

        // Single batch query for all sender usernames — eliminates N+1
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
  /// Sends a friend request. Throws [PostgrestException] on DB errors
  /// (e.g., duplicate request — caught gracefully in the UI).
  static Future<void> sendFriendRequest(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _supabase.from('friend_requests').insert({
      'sender_id': myId,
      'receiver_id': targetUserId,
    });
  }

  /// Accepts a friend request. Both the friendship insert and request delete
  /// are attempted. If the friendship already exists (duplicate accept), it
  /// is silently ignored. The request is always cleaned up.
  static Future<void> acceptFriendRequest(FriendRequest request) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    // Normalize order to prevent (A,B) vs (B,A) duplicates in friendships table
    final id1 = myId.compareTo(request.senderId) < 0 ? myId : request.senderId;
    final id2 = myId.compareTo(request.senderId) < 0 ? request.senderId : myId;

    try {
      await _supabase.from('friendships').insert({
        'user_id_1': id1,
        'user_id_2': id2,
      });
    } on PostgrestException catch (e) {
      // Code 23505 = unique_violation — friendship already exists, safe to ignore
      if (e.code != '23505') {
        debugPrint('Unexpected error inserting friendship: ${e.message}');
        rethrow;
      }
    }

    // Always clean up the request, even if friendship already existed
    try {
      await _supabase.from('friend_requests').delete().eq('id', request.id);
    } on PostgrestException catch (e) {
      debugPrint('Error deleting friend request: ${e.message}');
      // Don't rethrow — the friendship was created successfully
    }
  }

  /// Declines (deletes) a pending friend request.
  static Future<void> declineFriendRequest(String requestId) async {
    try {
      await _supabase.from('friend_requests').delete().eq('id', requestId);
    } on PostgrestException catch (e) {
      debugPrint('Error declining friend request: ${e.message}');
      rethrow;
    }
  }
}
