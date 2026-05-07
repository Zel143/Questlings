import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  final List<Map<String, dynamic>> _quests = [
    {
      'title': 'Hydration Potion',
      'description': 'Drink 8 glasses of water today to restore vitality.',
      'expReward': 15,
      'progress': 3,
      'maxProgress': 8,
      'isDone': false,
      'expColor': const Color(0xFF6EABDE),
      'category': 'Sports',
    },
    {
      'title': 'Morning Patrol',
      'description': 'Complete a 20-minute walk outside.',
      'expReward': 20,
      'progress': 1,
      'maxProgress': 1,
      'isDone': true,
      'expColor': null,
      'category': 'Sports',
    },
    {
      'title': 'Study Grimoire',
      'description': 'Read 15 pages of any non-fiction book.',
      'expReward': 25,
      'progress': 0,
      'maxProgress': 1,
      'isDone': false,
      'expColor': QuestlingsTheme.surface,
      'category': 'School',
    },
    {
      'title': 'Save Data',
      'description': 'Write one sentence in your daily journal.',
      'expReward': 10,
      'progress': 0,
      'maxProgress': 1,
      'isDone': false,
      'expColor': QuestlingsTheme.surface,
      'category': 'Tech',
    },
    {
      'title': 'Sketch Practice',
      'description': 'Draw for 15 minutes.',
      'expReward': 15,
      'progress': 0,
      'maxProgress': 1,
      'isDone': false,
      'expColor': QuestlingsTheme.surface,
      'category': 'Art',
    },
  ];

  void _completeQuestStep(int index, String? currentQuestlingType) {
    if (_quests[index]['isDone']) return;

    setState(() {
      final quest = _quests[index];
      
      if (quest['maxProgress'] != null && quest['maxProgress'] > 1) {
        quest['progress'] = (quest['progress'] as int) + 1;
        if (quest['progress'] >= quest['maxProgress']) {
          _markQuestDone(quest, currentQuestlingType);
        } else {
          _saveLocalState();
        }
      } else {
        quest['progress'] = 1;
        _markQuestDone(quest, currentQuestlingType);
      }
    });
  }

  void _markQuestDone(Map<String, dynamic> quest, String? currentQuestlingType) {
    quest['isDone'] = true;
    _awardRewards(quest['expReward'], quest['category'], currentQuestlingType);
    _saveLocalState();
    
    // Refresh automatically by removing it from view after a brief delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          quest['isHidden'] = true;
        });
      }
    });
  }

  void _awardRewards(int baseExp, String? category, String? currentQuestlingType) {
    final isTypeMatch = category != null && category == currentQuestlingType;
    final finalExp = isTypeMatch ? (baseExp * 1.1).round() : baseExp;

    _exp += finalExp;
    
    if (_exp >= _maxExp) {
      _exp = _exp - _maxExp;
      _maxExp = (_maxExp * 1.2).round();
      _hp = _maxHp;
      if (_userProfile != null) {
        _userProfile!['level'] = (_userProfile!['level'] ?? 1) + 1;
      }
    } else {
      _hp += 2;
      if (_hp > _maxHp) _hp = _maxHp;
    }
    
    _saveLocalState();
    _updateStatsInDb();
  }

  Future<void> _updateStatsInDb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && _userProfile != null) {
      final userLevel = _userProfile!['level'] ?? 1;
      try {
        await Supabase.instance.client
            .from('users')
            .update({'xp': _exp, 'level': userLevel})
            .eq('id', user.id);
      } catch (e) {
        debugPrint('Error updating stats in DB: $e');
      }
    }
  }

  Future<void> _saveLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hp', _hp);
    await prefs.setInt('maxHp', _maxHp);
    await prefs.setInt('exp', _exp);
    await prefs.setInt('maxExp', _maxExp);
    
    List<Map<String, dynamic>> simpleQuests = _quests.map((q) => {
       'title': q['title'],
       'progress': q['progress'],
       'isDone': q['isDone'],
    }).toList();
    await prefs.setString('quests_state', jsonEncode(simpleQuests));
  }

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastResetDate = prefs.getString('last_reset_date');
    final shouldReset = lastResetDate != today;
    
    if (shouldReset) {
      await prefs.setString('last_reset_date', today);
    }
    
    setState(() {
      _hp = prefs.getInt('hp') ?? 45;
      _maxHp = prefs.getInt('maxHp') ?? 50;
      _exp = prefs.getInt('exp') ?? 120;
      _maxExp = prefs.getInt('maxExp') ?? 200;
      
      if (!shouldReset) {
        final questsJson = prefs.getString('quests_state');
        if (questsJson != null) {
          try {
            final List<dynamic> decoded = jsonDecode(questsJson);
            for (var savedQuest in decoded) {
              final title = savedQuest['title'];
              final index = _quests.indexWhere((q) => q['title'] == title);
              if (index != -1) {
                 _quests[index]['progress'] = savedQuest['progress'];
                 _quests[index]['isDone'] = savedQuest['isDone'];
              }
            }
          } catch (e) {
            debugPrint('Error loading quests state: $e');
          }
        }
      } else {
        // Reset all quests for the new day
        for (var quest in _quests) {
          quest['progress'] = 0;
          quest['isDone'] = false;
        }
        _saveLocalState();
      }
      
      // Initialize UI visibility state
      for (var quest in _quests) {
        quest['isHidden'] = quest['isDone'] == true;
      }
    });
  }

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
    
    _loadLocalState();
    _loadProfile();
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
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
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Returns the local asset path for the equipped questling's sprite.
  /// Falls back to a mapping by elemental_type if sprite_path is null in the DB.
  String _getSpritePath() {
    final questlingData = _questling?['questling_dictionary'];
    final spritePath = questlingData?['sprite_path'];
    if (spritePath != null && spritePath.toString().isNotEmpty) {
      return spritePath;
    }
    // Fallback mapping by elemental_type
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

  /// Returns a color associated with each questling type for visual theming.
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(child: Text('Error loading profile.'));
    }

    final username = _userProfile!['username'] ?? 'Unknown';
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
          // Profile Card
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
                              filterQuality: FilterQuality.none, // Keep pixel art crisp
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
          const Row(
            children: [
              Icon(Icons.sports_martial_arts, color: QuestlingsTheme.primaryAction, size: 32),
              SizedBox(width: 8),
              Text('Active Quests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          ..._quests.asMap().entries.where((entry) => entry.value['isHidden'] != true).map((entry) {
            final index = entry.key;
            final quest = entry.value;
            return _buildQuestItem(
              title: quest['title'],
              description: quest['description'],
              expAmount: quest['expReward'],
              progress: quest['progress'],
              maxProgress: quest['maxProgress'],
              isDone: quest['isDone'],
              expColor: quest['expColor'],
              category: quest['category'],
              currentQuestlingType: questlingType,
              onTap: () => _completeQuestStep(index, questlingType),
            );
          }),
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
    final displayExp = isTypeMatch && !isDone ? '+$expAmount EXP (+10%)' : (isDone ? 'DONE' : '+$expAmount EXP');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: PixelContainer(
          backgroundColor: isDone ? QuestlingsTheme.lightGreen : Colors.white,
          padding: 12,
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isDone ? QuestlingsTheme.primaryAction : Colors.white,
                border: Border.all(color: QuestlingsTheme.shadow, width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
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
                          color: isTypeMatch && !isDone ? const Color(0xFFFFF9C4) : (expColor ?? QuestlingsTheme.surface),
                          border: Border.all(
                            color: isTypeMatch && !isDone ? const Color(0xFFE6C200) : QuestlingsTheme.shadow, 
                            width: 1.5
                          ),
                        ),
                        child: Text(
                          displayExp,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isTypeMatch && !isDone ? const Color(0xFFB89B00) : (isDone ? Colors.white : QuestlingsTheme.shadow),
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
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (progress != null && maxProgress != null) ...[
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
}