import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';
import 'social_provider.dart';

class PartyScreen extends ConsumerStatefulWidget {
  const PartyScreen({super.key});

  @override
  ConsumerState<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends ConsumerState<PartyScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _partyMembers = [];
  Map<String, dynamic>? _party;
  bool _isSearching = false;
  bool _isLoadingParty = true;
  String? _currentUserId;

  // Spam-guard: tracks user IDs that already have a pending request sent
  final Set<String> _pendingRequestsSent = {};
  // Tracks which user ID is currently being sent (in-flight)
  String? _sendingRequestTo;
  // Tracks request IDs that are currently being accepted/declined
  final Set<String> _processingRequests = {};

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _loadParty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParty() async {
    if (_currentUserId == null) return;

    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('party_id')
          .eq('id', _currentUserId!)
          .maybeSingle();

      if (userData == null || userData['party_id'] == null) {
        setState(() => _isLoadingParty = false);
        return;
      }

      final partyId = userData['party_id'];

      // Load party info and members
      final partyData = await Supabase.instance.client
          .from('parties')
          .select('*, party_members(*)')
          .eq('id', partyId)
          .maybeSingle();

      if (partyData != null) {
        final members = await Supabase.instance.client
            .from('party_members')
            .select('user_id')
            .eq('party_id', partyId);

        // Fetch user details for each member
        List<Map<String, dynamic>> memberDetails = [];
        for (final member in members) {
          final userProfile = await Supabase.instance.client
              .from('users')
              .select('id, username, level')
              .eq('id', member['user_id'])
              .maybeSingle();
          if (userProfile != null) {
            memberDetails.add(userProfile);
          }
        }

        setState(() {
          _party = partyData;
          _partyMembers = memberDetails;
          _isLoadingParty = false;
        });
      } else {
        setState(() => _isLoadingParty = false);
      }
    } catch (e) {
      debugPrint('Error loading party: $e');
      setState(() => _isLoadingParty = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await Supabase.instance.client
          .from('users')
          .select('id, username, level')
          .ilike('username', '%$query%')
          .limit(10);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(results);
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    // Guard: already sent or currently in-flight
    if (_pendingRequestsSent.contains(targetUserId) || _sendingRequestTo == targetUserId) return;

    setState(() => _sendingRequestTo = targetUserId);

    try {
      await SocialService.sendFriendRequest(targetUserId);
      if (mounted) {
        setState(() {
          _pendingRequestsSent.add(targetUserId);
          _sendingRequestTo = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() => _sendingRequestTo = null);
        // Code 23505 = unique_violation: request already exists
        final message = e.code == '23505'
            ? 'You already sent a request to this user.'
            : 'Failed to send request: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        // Mark as pending so the button reflects reality
        if (e.code == '23505') setState(() => _pendingRequestsSent.add(targetUserId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sendingRequestTo = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }

  Widget _buildFriendButton(String userId) {
    final isSending = _sendingRequestTo == userId;
    final isPending = _pendingRequestsSent.contains(userId);

    final label = isSending ? 'Sending...' : isPending ? 'Pending ✓' : '+ Friend';
    final bgColor = (isSending || isPending)
        ? QuestlingsTheme.shadow.withValues(alpha: 0.3)
        : QuestlingsTheme.primaryAction;

    return GestureDetector(
      onTap: (isSending || isPending) ? null : () => _sendFriendRequest(userId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (isSending || isPending) ? QuestlingsTheme.shadow : Colors.white,
                fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(friendRequestsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Friend Requests (Real-time) ──
          requestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending Requests', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: QuestlingsTheme.primaryAction)),
                  const SizedBox(height: 8),
                  ...requests.map((req) {
                    final isProcessing = _processingRequests.contains(req.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PixelContainer(
                        padding: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${req.senderUsername ?? 'Someone'} wants to be your friend!',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isProcessing)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            else ...[  
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                tooltip: 'Accept',
                                onPressed: () async {
                                  setState(() => _processingRequests.add(req.id));
                                  try {
                                    await SocialService.acceptFriendRequest(req);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Friend accepted! You are now in the same party. 🎉'),
                                        ),
                                      );
                                      // Reload party so new member appears immediately
                                      _loadParty();
                                    }
                                  } catch (e) {
                                    debugPrint('[Accept] Error: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to accept: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _processingRequests.remove(req.id));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Decline',
                                onPressed: () async {
                                  setState(() => _processingRequests.add(req.id));
                                  try {
                                    await SocialService.declineFriendRequest(req.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Friend request declined.')),
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('[Decline] Error: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to decline: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _processingRequests.remove(req.id));
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) {
              debugPrint('[FriendRequests] Stream error: $e');
              return const SizedBox.shrink();
            },
          ),

          // ── Search Bar ──
          PixelContainer(
            padding: 0,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by username...',
                hintStyle: TextStyle(color: QuestlingsTheme.shadow.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(Icons.search, color: QuestlingsTheme.shadow),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: QuestlingsTheme.shadow),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchUsers,
            ),
          ),

          // ── Search Results ──
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_isSearching && _searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Search Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ..._searchResults.map((user) {
              final isSelf = user['id'] == _currentUserId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PixelContainer(
                  padding: 12,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: QuestlingsTheme.surface,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (user['username'] as String)[0].toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['username'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Lv. ${user['level'] ?? 1}',
                                style: const TextStyle(fontSize: 12, color: QuestlingsTheme.shadow)),
                          ],
                        ),
                      ),
                      if (!isSelf)
                        _buildFriendButton(user['id'] as String),
                    ],
                  ),
                ),
              );
            }),
          ],

          // ── Party Header ──
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: QuestlingsTheme.shadow, width: 4)),
                ),
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _party != null ? _party!['name'] ?? 'Your Party' : 'Party',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                ),
                child: Text('${_partyMembers.length} / 50',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Party Members ──
          if (_isLoadingParty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_partyMembers.isEmpty)
            PixelContainer(
              padding: 24,
              child: const Center(
                child: Text('No party members yet. Search for users to invite!',
                    textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            ..._partyMembers.map((member) {
              final isSelf = member['id'] == _currentUserId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PixelContainer(
                  padding: 12,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelf ? QuestlingsTheme.primaryAction : QuestlingsTheme.surface,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (member['username'] as String)[0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isSelf ? Colors.white : QuestlingsTheme.shadow),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(member['username'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (isSelf) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: QuestlingsTheme.lightGreen,
                                    child: const Text('YOU',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ],
                            ),
                            Text('Lv. ${member['level'] ?? 1}',
                                style: const TextStyle(fontSize: 12, color: QuestlingsTheme.shadow)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}