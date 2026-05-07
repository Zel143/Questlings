import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _questling;
  bool _isLoading = true;
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;

  int _hp = 45;
  int _maxHp = 50;
  int _exp = 120;
  int _maxExp = 200;

  List<Map<String, dynamic>> _activeQuests = [];
  List<Map<String, dynamic>> _completedQuests = [];

  // ----------------------------------------------------------------------
  // Database operations
  // ----------------------------------------------------------------------

  Future<void> _fetchQuests() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Fetch active quests
      final activeResponse = await Supabase.instance.client
          .from('user_quests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: true);

      // Fetch last 10 completed quests (most recent first)
      final completedResponse = await Supabase.instance.client
          .from('user_quests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false)
          .limit(10);

      setState(() {
        _activeQuests = List<Map<String, dynamic>>.from(activeResponse);
        _completedQuests = List<Map<String, dynamic>>.from(completedResponse);
      });
      debugPrint('✅ Quests loaded from DB: ${_activeQuests.length} active, ${_completedQuests.length} completed');
    } catch (e) {
      debugPrint('❌ Error loading quests from DB: $e');
    }
  }

  Future<void> _addQuestToDB(Map<String, dynamic> questData) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final newQuest = {
        'user_id': userId,
        'title': questData['title'],
        'description': questData['description'],
        'exp_reward': questData['expReward'],
        'progress': 0,
        'max_progress': questData['maxProgress'],
        'category': questData['category'],
        'status': 'active',
      };
      final response = await Supabase.instance.client
          .from('user_quests')
          .insert(newQuest)
          .select()
          .single();
      setState(() {
        _activeQuests.add(response);
      });
      debugPrint('✅ Quest added to DB: ${response['title']}');
    } catch (e) {
      debugPrint('❌ Error adding quest to DB: $e');
    }
  }

  Future<void> _updateQuestProgress(String questId, int newProgress, int maxProgress) async {
    try {
      await Supabase.instance.client
          .from('user_quests')
          .update({'progress': newProgress})
          .eq('id', questId);
      debugPrint('✅ Progress updated for quest $questId: $newProgress/$maxProgress');
    } catch (e) {
      debugPrint('❌ Error updating progress: $e');
    }
  }

  Future<void> _completeQuestInDB(String questId, int finalExp, int questIndex, int maxProgress) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Mark as completed in DB, setting progress to maxProgress (non-null)
      await Supabase.instance.client
          .from('user_quests')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
            'progress': maxProgress, // ensure non-null
          })
          .eq('id', questId);

      // Fetch latest 10 completed quests
      final completedResponse = await Supabase.instance.client
          .from('user_quests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false)
          .limit(10);

      setState(() {
        // Remove from active list
        if (questIndex < _activeQuests.length) {
          _activeQuests.removeAt(questIndex);
        }
        // Update completed list
        _completedQuests = List<Map<String, dynamic>>.from(completedResponse);
      });
      debugPrint('✅ Quest completed and archived');
    } catch (e) {
      debugPrint('❌ Error completing quest: $e');
    }
  }

  // ----------------------------------------------------------------------
  // Quest logic (adapted for DB)
  // ----------------------------------------------------------------------

  void _completeQuestStep(int index, String? currentQuestlingType) {
    final quest = _activeQuests[index];
    if (quest['status'] != 'active') return; // safety

    final isTypeMatch = quest['category'] != null && quest['category'] == currentQuestlingType;
    final baseExp = quest['exp_reward'] as int;
    final finalExp = isTypeMatch ? (baseExp * 1.1).round() : baseExp;
    final currentProgress = quest['progress'] as int;
    final maxProgress = quest['max_progress'] as int;

    if (maxProgress > 1) {
      // Multi-step quest
      final newProgress = currentProgress + 1;
      setState(() {
        quest['progress'] = newProgress;
      });
      _updateQuestProgress(quest['id'], newProgress, maxProgress);

      if (newProgress >= maxProgress) {
        // Quest finished – show dialog, completion will be handled after rewards
        _showCompletionDialog(quest, finalExp, isTypeMatch, index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress updated: $newProgress/$maxProgress'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: QuestlingsTheme.primaryAction,
          ),
        );
      }
    } else {
      // Single-step quest – complete immediately
      _showCompletionDialog(quest, finalExp, isTypeMatch, index);
    }
  }

  void _showCompletionDialog(Map<String, dynamic> quest, int exp, bool bonusActive, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: QuestlingsTheme.primaryAction),
            const SizedBox(width: 8),
            const Text('Quest Complete!', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${quest['title']}" completed!'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20, color: Color(0xFFFFD54F)),
                const SizedBox(width: 8),
                Text('+$exp EXP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (bonusActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: const Color(0xFFFFF9C4),
                    child: const Text('TYPE BONUS!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final maxProgress = quest['max_progress'] as int; // get from quest
              _awardRewardsAndArchiveQuest(exp, index, quest['id'], maxProgress);
            },
            child: const Text('CLAIM REWARDS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _awardRewardsAndArchiveQuest(int finalExp, int questIndex, String questId, int maxProgress) {
    setState(() {
      _exp += finalExp;
      if (_exp >= _maxExp) {
        _exp -= _maxExp;
        _maxExp = (_maxExp * 1.2).round();
        _hp = _maxHp;
      } else {
        _hp += 2;
        if (_hp > _maxHp) _hp = _maxHp;
      }
    });
    // Archive in DB with maxProgress
    _completeQuestInDB(questId, finalExp, questIndex, maxProgress);
  }

  void _showAddQuestDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedExp = 10;
    int progressSteps = 1;
    String selectedCategory = 'Sports';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Quest', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quest Title',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('EXP Reward: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    _buildExpOption(10, 'Easy', selectedExp, (v) => setDialogState(() => selectedExp = v)),
                    const SizedBox(width: 4),
                    _buildExpOption(25, 'Medium', selectedExp, (v) => setDialogState(() => selectedExp = v)),
                    const SizedBox(width: 4),
                    _buildExpOption(50, 'Hard', selectedExp, (v) => setDialogState(() => selectedExp = v)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progress Steps: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (progressSteps > 1) setDialogState(() => progressSteps--);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: QuestlingsTheme.shadow,
                                border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                              ),
                              child: const Icon(Icons.remove, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$progressSteps',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (progressSteps < 10) setDialogState(() => progressSteps++);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: QuestlingsTheme.primaryAction,
                                border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            progressSteps == 1 ? '(one tap)' : '(tap $progressSteps times)',
                            style: const TextStyle(fontSize: 10, color: QuestlingsTheme.shadow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                        DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                        DropdownMenuItem(value: 'Art', child: Text('Art')),
                        DropdownMenuItem(value: 'School', child: Text('School')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedCategory = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty || desc.isEmpty) return;
                // Add to DB
                _addQuestToDB({
                  'title': title,
                  'description': desc,
                  'expReward': selectedExp,
                  'maxProgress': progressSteps,
                  'category': selectedCategory,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Quest', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpOption(int exp, String label, int current, void Function(int) onSelected) {
    final isSelected = current == exp;
    return GestureDetector(
      onTap: () => onSelected(exp),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? QuestlingsTheme.lightGreen : Colors.white,
          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        ),
        child: Column(
          children: [
            Text('+$exp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? QuestlingsTheme.primaryAction : QuestlingsTheme.shadow)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // Lifecycle & profile loading
  // ----------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _idleAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _loadProfileAndQuests();
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndQuests() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final profileResponse = await Supabase.instance.client
          .from('users')
          .select('''
            *,
            user_questlings:equipped_questling_id (
              *,
              questling_dictionary:questling_id (
                name,
                elemental_type,
                sprite_path
              )
            )
          ''')
          .eq('id', user.id)
          .maybeSingle();

      if (profileResponse == null) {
        if (mounted) context.go('/username');
        return;
      }

      setState(() {
        _userProfile = profileResponse;
        if (profileResponse['user_questlings'] != null) {
          _questling = profileResponse['user_questlings'];
        }
      });

      // Load quests from database
      await _fetchQuests();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSpritePath() {
    final questlingData = _questling?['questling_dictionary'];
    final spritePath = questlingData?['sprite_path'];
    if (spritePath != null && spritePath.toString().isNotEmpty) {
      return spritePath;
    }
    final type = questlingData?['elemental_type'] ?? '';
    switch (type) {
      case 'Sports':
        return 'assets/sprites/Sports-ling/Starter1.jpg';
      case 'Tech':
        return 'assets/sprites/Tech-ling/Starter2.jpg';
      case 'Art':
        return 'assets/sprites/Art-ling/Starter3.png';
      case 'School':
        return 'assets/sprites/Skool-ling/Starter4.jpg';
      default:
        return 'assets/sprites/Sports-ling/Starter1.jpg';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Sports':
        return const Color(0xFFD32F2F);
      case 'Tech':
        return const Color(0xFF7B1FA2);
      case 'Art':
        return const Color(0xFF2E7D32);
      case 'School':
        return const Color(0xFF795548);
      default:
        return QuestlingsTheme.shadow;
    }
  }

  // ----------------------------------------------------------------------
  // UI Building (unchanged except quest fields mapping)
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(child: Text('Error loading profile.'));
    }

    final userLevel = _userProfile!['level'] ?? 1;
    final questlingData = _questling?['questling_dictionary'];
    final questlingNickname = _questling?['nickname'] ?? questlingData?['name'] ?? 'Unknown Egg';
    final questlingType = questlingData?['elemental_type'] ?? 'Unknown';
    final spritePath = _getSpritePath();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card (unchanged)
          PixelContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: QuestlingsTheme.background,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        ),
                        child: AnimatedBuilder(
                          animation: _idleAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _idleAnimation.value),
                              child: child,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              spritePath,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: QuestlingsTheme.brownAction,
                        child: Text(
                          'LVL $userLevel',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(questlingNickname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTypeColor(questlingType).withValues(alpha: 0.15),
                        border: Border.all(color: _getTypeColor(questlingType), width: 1.5),
                      ),
                      child: Text(
                        '$questlingType Type',
                        style: TextStyle(
                          color: _getTypeColor(questlingType),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: QuestlingsTheme.shadow, thickness: 2),
                const SizedBox(height: 8),
                _buildStatBar('HP', '$_hp/$_maxHp', QuestlingsTheme.primaryAction, _hp / _maxHp),
                const SizedBox(height: 8),
                _buildStatBar('EXP', '$_exp/$_maxExp', QuestlingsTheme.surface, _exp / _maxExp),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active Quests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sports_martial_arts, color: QuestlingsTheme.primaryAction, size: 32),
                  SizedBox(width: 8),
                  Text('Active Quests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              GestureDetector(
                onTap: _showAddQuestDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: QuestlingsTheme.primaryAction,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('Add Quest', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._activeQuests.asMap().entries.map((entry) {
            final index = entry.key;
            final quest = entry.value;
            return _buildQuestItem(
              title: quest['title'],
              description: quest['description'],
              expAmount: quest['exp_reward'],
              progress: quest['progress'],
              maxProgress: quest['max_progress'],
              isDone: false, // active quests are never "done" in UI sense, but we use status
              expColor: null, // not used
              category: quest['category'],
              currentQuestlingType: questlingType,
              onTap: () => _completeQuestStep(index, questlingType),
            );
          }),
          if (_activeQuests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No active quests.\nTap + to add a quest!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: QuestlingsTheme.shadow),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Completed Quests
          if (_completedQuests.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.history, color: QuestlingsTheme.shadow, size: 28),
                SizedBox(width: 8),
                Text('Recently Completed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            ..._completedQuests.map((quest) => _buildCompletedQuestItem(quest)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, String value, Color color, double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: QuestlingsTheme.shadow, width: 2),
            color: QuestlingsTheme.shadow,
          ),
          child: Row(
            children: [
              Expanded(
                flex: (percentage * 100).toInt(),
                child: Container(color: color),
              ),
              Expanded(
                flex: ((1 - percentage) * 100).toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestItem({
    required String title,
    required String description,
    required int expAmount,
    bool isDone = false,
    int? progress,
    int? maxProgress,
    Color? expColor,
    String? category,
    String? currentQuestlingType,
    VoidCallback? onTap,
  }) {
    final isTypeMatch = category != null && category == currentQuestlingType;
    final displayExp = isTypeMatch ? '+$expAmount EXP (+10%)' : '+$expAmount EXP';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: PixelContainer(
          backgroundColor: Colors.white,
          padding: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                ),
                child: null, // checkbox not checked until completed, but we don't show check for active
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTypeMatch) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Color(0xFFE6C200), size: 18),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isTypeMatch ? const Color(0xFFFFF9C4) : QuestlingsTheme.surface,
                            border: Border.all(
                              color: isTypeMatch ? const Color(0xFFE6C200) : QuestlingsTheme.shadow,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            displayExp,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isTypeMatch ? const Color(0xFFB89B00) : QuestlingsTheme.shadow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: QuestlingsTheme.shadow,
                      ),
                    ),
                    if (progress != null && maxProgress != null && maxProgress > 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PROGRESS', style: TextStyle(fontSize: 10, letterSpacing: 1)),
                          Text('$progress/$maxProgress', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          border: Border.all(color: QuestlingsTheme.shadow, width: 1.5),
                        ),
                        child: Row(
                          children: List.generate(maxProgress, (index) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: index < progress ? const Color(0xFF2B5B84) : Colors.white,
                                  border: index < maxProgress - 1
                                      ? const Border(right: BorderSide(color: QuestlingsTheme.shadow, width: 1.5))
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedQuestItem(Map<String, dynamic> quest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PixelContainer(
        backgroundColor: QuestlingsTheme.lightGreen.withValues(alpha: 0.5),
        padding: 12,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: QuestlingsTheme.primaryAction, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    quest['description'],
                    style: TextStyle(fontSize: 12, color: QuestlingsTheme.shadow),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '+${quest['exp_reward']} EXP',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}