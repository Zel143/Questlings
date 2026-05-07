import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
<<<<<<< Updated upstream
=======
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _questling;
  bool _isLoading = true;
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;

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
>>>>>>> Stashed changes
  Widget build(BuildContext context) {
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
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: QuestlingsTheme.background,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        ),
                        // Image placeholder
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: QuestlingsTheme.brownAction,
                        child: const Text(
                          'LVL 5',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bulba', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text('Grass Type', style: TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: QuestlingsTheme.shadow, thickness: 2),
                const SizedBox(height: 8),
                _buildStatBar('HP', '45/50', QuestlingsTheme.primaryAction, 0.9),
                const SizedBox(height: 8),
                _buildStatBar('EXP', '120/200', QuestlingsTheme.surface, 0.6),
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
          _buildQuestItem(
            title: 'Hydration Potion',
            description: 'Drink 8 glasses of water today to restore vitality.',
            exp: '+15 EXP',
            progress: 3,
            maxProgress: 8,
            expColor: const Color(0xFF6EABDE),
          ),
          _buildQuestItem(
            title: 'Morning Patrol',
            description: 'Complete a 20-minute walk outside.',
            exp: 'DONE',
            isDone: true,
          ),
          _buildQuestItem(
            title: 'Study Grimoire',
            description: 'Read 15 pages of any non-fiction book.',
            exp: '+25 EXP',
            expColor: QuestlingsTheme.surface,
          ),
          _buildQuestItem(
            title: 'Save Data',
            description: 'Write one sentence in your daily journal.',
            exp: '+10 EXP',
            expColor: QuestlingsTheme.surface,
          ),
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
    required String exp,
    bool isDone = false,
    int? progress,
    int? maxProgress,
    Color? expColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: expColor ?? QuestlingsTheme.surface,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 1.5),
                        ),
                        child: Text(
                          exp,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: QuestlingsTheme.shadow,
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
    );
  }
}