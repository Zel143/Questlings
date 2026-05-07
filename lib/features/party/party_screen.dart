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

class _PartyScreenState extends ConsumerState<PartyScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _partyMembers = [];
  Map<String, dynamic>? _party;
  bool _isSearching = false;
  bool _isLoadingParty = true;
  String? _currentUserId;
  late TabController _tabController;

  final Set<String> _pendingRequestsSent = {};
  String? _sendingRequestTo;
  final Set<String> _processingRequests = {};
  final Set<String> _invitingFriends = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _loadParty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParty() async {
    if (_currentUserId == null) return;
    if (mounted) setState(() { _isLoadingParty = true; _party = null; _partyMembers = []; });
    try {
      final userData = await Supabase.instance.client
          .from('users').select('party_id').eq('id', _currentUserId!).maybeSingle();
      
      if (userData == null || userData['party_id'] == null) {
        if (mounted) setState(() => _isLoadingParty = false);
        return;
      }

      final partyId = userData['party_id'];
      
      // Fetch party details and members with their profiles
      final partyFuture = Supabase.instance.client
          .from('parties').select('*').eq('id', partyId).maybeSingle();
      final membersFuture = Supabase.instance.client
          .from('party_members')
          .select('user:users(id, username, level)')
          .eq('party_id', partyId);

      final partyData = await partyFuture;
      final membersData = await membersFuture;

      if (partyData != null) {
        final List<Map<String, dynamic>> memberDetails = membersData
            .map((m) => m['user'] as Map<String, dynamic>)
            .toList();
            
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
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await Supabase.instance.client
          .from('users').select('id, username, level').ilike('username', '%$query%').limit(10);
      setState(() { _searchResults = List<Map<String, dynamic>>.from(results); _isSearching = false; });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    if (_pendingRequestsSent.contains(targetUserId) || _sendingRequestTo == targetUserId) return;
    setState(() => _sendingRequestTo = targetUserId);
    try {
      await SocialService.sendFriendRequest(targetUserId);
      if (mounted) {
        setState(() { _pendingRequestsSent.add(targetUserId); _sendingRequestTo = null; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() => _sendingRequestTo = null);
        final message = e.code == '23505' ? 'You already sent a request to this user.' : 'Failed: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (e.code == '23505') setState(() => _pendingRequestsSent.add(targetUserId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sendingRequestTo = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _inviteFriendToParty(String friendId) async {
    if (_invitingFriends.contains(friendId)) return;
    setState(() => _invitingFriends.add(friendId));
    try {
      await SocialService.inviteToParty(friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added to your party! 🎉')),
        );
        // Refresh friends list so their party_id updates (shows "In Party" badge)
        ref.invalidate(friendsListProvider);
        // Reload party data — the RPC may have created a new party
        await _loadParty();
        // Switch to Party tab so the user sees the updated roster
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to invite: $e')));
      }
    } finally {
      if (mounted) setState(() => _invitingFriends.remove(friendId));
    }
  }

  void _showCreateGoalDialog() {
    if (_party == null) return;
    final nameCtrl = TextEditingController();
    final energyCtrl = TextEditingController(text: '100');
    int days = 7;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Party Goal', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal Name', hintText: 'e.g. Weekly Workout Challenge')),
            const SizedBox(height: 12),
            TextField(controller: energyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Energy')),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Duration: ', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<int>(value: days, items: [3,5,7,14,30].map((d) => DropdownMenuItem(value: d, child: Text('$d days'))).toList(),
                onChanged: (v) => setDialogState(() => days = v!)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await SocialService.createPartyGoal(
                    partyId: _party!['id'], name: nameCtrl.text.trim(),
                    targetEnergy: int.tryParse(energyCtrl.text) ?? 100, durationDays: days,
                  );
                  if (mounted) {
                    ref.invalidate(partyGoalsProvider(_party!['id']));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal created! 🎯')));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.primaryAction)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendButton(String userId) {
    final isSending = _sendingRequestTo == userId;
    final isPending = _pendingRequestsSent.contains(userId);
    final label = isSending ? 'Sending...' : isPending ? 'Pending ✓' : '+ Friend';
    final bgColor = (isSending || isPending) ? QuestlingsTheme.shadow.withValues(alpha: 0.3) : QuestlingsTheme.primaryAction;
    return GestureDetector(
      onTap: (isSending || isPending) ? null : () => _sendFriendRequest(userId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bgColor, border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: (isSending || isPending) ? QuestlingsTheme.shadow : Colors.white, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(friendRequestsProvider);

    return Column(children: [
      // Tab bar
      Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: QuestlingsTheme.shadow, width: 2))),
        child: TabBar(
          controller: _tabController,
          labelColor: QuestlingsTheme.shadow, unselectedLabelColor: QuestlingsTheme.shadow.withValues(alpha: 0.5),
          indicatorColor: QuestlingsTheme.primaryAction, indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.group, size: 18), const SizedBox(width: 4), const Text('Party'),
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.people, size: 18), const SizedBox(width: 4), const Text('Friends'),
              // Badge for pending requests
              ...requestsAsync.when(
                data: (r) => r.isEmpty ? <Widget>[] : [const SizedBox(width: 4), Container(
                  padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: QuestlingsTheme.warning, shape: BoxShape.circle),
                  child: Text('${r.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )],
                loading: () => <Widget>[], error: (_, __) => <Widget>[],
              ),
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.person_add, size: 18), const SizedBox(width: 4), const Text('Search'),
            ])),
          ],
        ),
      ),
      // Tab content
      Expanded(child: TabBarView(controller: _tabController, children: [
        _buildPartyTab(),
        _buildFriendsTab(requestsAsync),
        _buildSearchTab(),
      ])),
    ]);
  }

  // ── PARTY TAB ──
  Widget _buildPartyTab() {
    if (_isLoadingParty) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Party Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: QuestlingsTheme.shadow, width: 4))),
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(_party != null ? _party!['name'] ?? 'Your Party' : 'Party',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ),
          if (_party != null)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
              child: Text('${_partyMembers.length} / 50', style: const TextStyle(fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 16),

        // Party Members
        if (_partyMembers.isEmpty)
          PixelContainer(padding: 24, child: const Center(
            child: Text('No party yet.\nAccept a friend request or invite friends to start!',
              textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ))
        else
          ..._partyMembers.map((member) {
            final isSelf = member['id'] == _currentUserId;
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: PixelContainer(padding: 12,
              child: Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: isSelf ? QuestlingsTheme.primaryAction : QuestlingsTheme.surface,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
                  child: Center(child: Text((member['username'] as String)[0].toUpperCase(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isSelf ? Colors.white : QuestlingsTheme.shadow))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(member['username'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (isSelf) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: QuestlingsTheme.lightGreen, child: const Text('YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)))],
                  ]),
                  Text('Lv. ${member['level'] ?? 1}', style: const TextStyle(fontSize: 12, color: QuestlingsTheme.shadow)),
                ])),
              ]),
            ));
          }),

        // Party Goals section
        if (_party != null) ...[
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Party Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            GestureDetector(onTap: _showCreateGoalDialog, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: QuestlingsTheme.primaryAction, border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
              child: const Text('+ New Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            )),
          ]),
          const SizedBox(height: 12),
          _buildGoalsList(),
        ],
      ],
    ));
  }

  Widget _buildGoalsList() {
    if (_party == null) return const SizedBox.shrink();
    final goalsAsync = ref.watch(partyGoalsProvider(_party!['id']));
    return goalsAsync.when(
      data: (goals) {
        if (goals.isEmpty) return PixelContainer(padding: 16, child: const Center(
          child: Text('No goals yet. Create one to challenge your party!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
        return Column(children: goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PixelContainer(padding: 12, backgroundColor: goal.isCompleted ? QuestlingsTheme.lightGreen : Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(goal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: goal.isCompleted ? QuestlingsTheme.primaryAction : QuestlingsTheme.surface,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 1.5)),
                  child: Text(goal.isCompleted ? 'DONE' : '${goal.currentEnergy}/${goal.targetEnergy}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: goal.isCompleted ? Colors.white : QuestlingsTheme.shadow))),
              ]),
              const SizedBox(height: 8),
              Container(height: 12, decoration: BoxDecoration(border: Border.all(color: QuestlingsTheme.shadow, width: 1.5)),
                child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: goal.progress.clamp(0, 1),
                  child: Container(color: goal.isCompleted ? QuestlingsTheme.primaryAction : QuestlingsTheme.blueAction))),
              const SizedBox(height: 6),
              Text('Ends ${_formatDate(goal.endDate)}', style: const TextStyle(fontSize: 11, color: QuestlingsTheme.shadow)),
            ]),
          ),
        )).toList());
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
      error: (e, _) => Text('Error loading goals: $e'),
    );
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  // ── FRIENDS TAB ──
  Widget _buildFriendsTab(AsyncValue<List<FriendRequest>> requestsAsync) {
    final friendsAsync = ref.watch(friendsListProvider);

    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pending requests
        requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) return const SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pending Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: QuestlingsTheme.primaryAction)),
              const SizedBox(height: 8),
              ...requests.map((req) {
                final isProcessing = _processingRequests.contains(req.id);
                return Padding(padding: const EdgeInsets.only(bottom: 8), child: PixelContainer(padding: 12,
                  child: Row(children: [
                    Expanded(child: Text('${req.senderUsername ?? 'Someone'} wants to be your friend!', style: const TextStyle(fontWeight: FontWeight.bold))),
                    if (isProcessing)
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    else ...[
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), tooltip: 'Accept',
                        onPressed: () => _handleAccept(req)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), tooltip: 'Decline',
                        onPressed: () => _handleDecline(req.id)),
                    ],
                  ]),
                ));
              }),
              const SizedBox(height: 16),
            ]);
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) { debugPrint('[FriendRequests] Stream error: $e'); return const SizedBox.shrink(); },
        ),

        // Friends list
        const Text('My Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        friendsAsync.when(
          data: (friends) {
            if (friends.isEmpty) return PixelContainer(padding: 20, child: const Center(
              child: Text('No friends yet.\nSearch for users and send requests!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
            return Column(children: friends.map((friend) {
              final isInMyParty = _party != null && friend.partyId != null && friend.partyId == _party!['id'];
              final isInviting = _invitingFriends.contains(friend.id);
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: PixelContainer(padding: 12,
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isInMyParty ? QuestlingsTheme.lightGreen : QuestlingsTheme.surface,
                      border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
                    child: Center(child: Text(friend.username[0].toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Lv. ${friend.level}', style: const TextStyle(fontSize: 12, color: QuestlingsTheme.shadow)),
                  ])),
                  // Show "Add to Party" for friends NOT in your party
                  if (!isInMyParty)
                    GestureDetector(
                      onTap: isInviting ? null : () => _inviteFriendToParty(friend.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: isInviting ? QuestlingsTheme.shadow.withValues(alpha: 0.3) : QuestlingsTheme.blueAction,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
                        child: Text(isInviting ? '...' : '+ Party', style: TextStyle(color: isInviting ? QuestlingsTheme.shadow : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    )
                  // Show "In Party ✓" badge for friends already in your party
                  else
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(color: QuestlingsTheme.lightGreen, border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
                      child: const Text('In Party ✓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ));
            }).toList());
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    ));
  }

  Future<void> _handleAccept(FriendRequest req) async {
    setState(() => _processingRequests.add(req.id));
    try {
      await SocialService.acceptFriendRequest(req);
      if (mounted) {
        // Force refresh both providers so UI updates immediately
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(friendsListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend accepted! You are now in the same party. 🎉')));
        await _loadParty();
        // Switch to Party tab so the user sees the new party
        _tabController.animateTo(0);
      }
    } catch (e) {
      debugPrint('[Accept] Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
    } finally {
      if (mounted) setState(() => _processingRequests.remove(req.id));
    }
  }

  Future<void> _handleDecline(String requestId) async {
    setState(() => _processingRequests.add(requestId));
    try {
      await SocialService.declineFriendRequest(requestId);
      if (mounted) {
        // Force refresh so the notification disappears immediately
        ref.invalidate(friendRequestsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request declined.')));
      }
    } catch (e) {
      debugPrint('[Decline] Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to decline: $e')));
    } finally {
      if (mounted) setState(() => _processingRequests.remove(requestId));
    }
  }

  // ── SEARCH TAB ──
  Widget _buildSearchTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        PixelContainer(padding: 0, child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users by username...', hintStyle: TextStyle(color: QuestlingsTheme.shadow.withValues(alpha: 0.5)),
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.search, color: QuestlingsTheme.shadow),
            suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: QuestlingsTheme.shadow),
              onPressed: () { _searchController.clear(); _searchUsers(''); }) : null,
          ),
          onChanged: _searchUsers,
        )),
        if (_isSearching)
          const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        if (!_isSearching && _searchResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Search Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ..._searchResults.map((user) {
            final isSelf = user['id'] == _currentUserId;
            return Padding(padding: const EdgeInsets.only(bottom: 8), child: PixelContainer(padding: 12,
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: QuestlingsTheme.surface, border: Border.all(color: QuestlingsTheme.shadow, width: 2)),
                  child: Center(child: Text((user['username'] as String)[0].toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Lv. ${user['level'] ?? 1}', style: const TextStyle(fontSize: 12, color: QuestlingsTheme.shadow)),
                ])),
                if (!isSelf) _buildFriendButton(user['id'] as String),
              ]),
            ));
          }),
        ],
      ],
    ));
  }
}