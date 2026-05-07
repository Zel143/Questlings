import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Lazy getter — always called after Supabase.initialize() completes
SupabaseClient get _supabase => Supabase.instance.client;

// ─────────────────────────────────────────────
// Models
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

class Friend {
  final String id;
  final String username;
  final int level;
  final String? partyId;

  Friend({
    required this.id,
    required this.username,
    required this.level,
    this.partyId,
  });
}

class PartyGoal {
  final String id;
  final String partyId;
  final String name;
  final String type;
  final int targetEnergy;
  final int currentEnergy;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  PartyGoal({
    required this.id,
    required this.partyId,
    required this.name,
    required this.type,
    required this.targetEnergy,
    required this.currentEnergy,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
  });

  double get progress => targetEnergy > 0 ? currentEnergy / targetEnergy : 0;
}

// ─────────────────────────────────────────────
// Real-time StreamProvider — Friend Requests
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
// FutureProvider — Friends List
// ─────────────────────────────────────────────

final friendsListProvider = FutureProvider<List<Friend>>((ref) async {
  final myId = _supabase.auth.currentUser?.id;
  if (myId == null) return [];

  // Get all friendships where the current user is either user_id_1 or user_id_2
  final friendships1 = await _supabase
      .from('friendships')
      .select('user_id_2')
      .eq('user_id_1', myId);

  final friendships2 = await _supabase
      .from('friendships')
      .select('user_id_1')
      .eq('user_id_2', myId);

  final friendIds = <String>{
    ...friendships1.map((f) => f['user_id_2'] as String),
    ...friendships2.map((f) => f['user_id_1'] as String),
  }.toList();

  if (friendIds.isEmpty) return [];

  final usersData = await _supabase
      .from('users')
      .select('id, username, level, party_id')
      .inFilter('id', friendIds);

  return usersData.map((u) => Friend(
    id: u['id'] as String,
    username: u['username'] as String? ?? 'Unknown',
    level: u['level'] as int? ?? 1,
    partyId: u['party_id'] as String?,
  )).toList();
});

// ─────────────────────────────────────────────
// FutureProvider — Party Goals
// ─────────────────────────────────────────────

final partyGoalsProvider = FutureProvider.family<List<PartyGoal>, String>((ref, partyId) async {
  final goalsData = await _supabase
      .from('party_goals')
      .select()
      .eq('party_id', partyId)
      .order('created_at', ascending: false);

  // Handle the case where 'created_at' might not exist — fall back to start_date
  return goalsData.map((g) => PartyGoal(
    id: g['id'] as String,
    partyId: g['party_id'] as String,
    name: g['name'] as String? ?? 'Goal',
    type: g['type'] as String? ?? 'weekly',
    targetEnergy: g['target_energy'] as int? ?? 100,
    currentEnergy: g['current_energy'] as int? ?? 0,
    startDate: DateTime.parse(g['start_date'] as String),
    endDate: DateTime.parse(g['end_date'] as String),
    isCompleted: g['is_completed'] as bool? ?? false,
  )).toList();
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

  /// Invites a friend to the current user's party via a SECURITY DEFINER RPC.
  static Future<void> inviteToParty(String friendId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _supabase.rpc('invite_to_party', params: {
      'p_friend_id': friendId,
    });
  }

  /// Creates a new party goal.
  static Future<void> createPartyGoal({
    required String partyId,
    required String name,
    required int targetEnergy,
    required int durationDays,
  }) async {
    final now = DateTime.now();
    await _supabase.from('party_goals').insert({
      'party_id': partyId,
      'type': 'weekly',
      'name': name,
      'target_energy': targetEnergy,
      'current_energy': 0,
      'start_date': now.toIso8601String(),
      'end_date': now.add(Duration(days: durationDays)).toIso8601String(),
      'is_completed': false,
    });
  }

  /// Removes a friend (deletes the friendship record).
  static Future<void> removeFriend(String friendId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    // Delete where current user is either side
    await _supabase
        .from('friendships')
        .delete()
        .or('and(user_id_1.eq.$myId,user_id_2.eq.$friendId),and(user_id_1.eq.$friendId,user_id_2.eq.$myId)');
  }
}
