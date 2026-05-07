import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/pixel_button.dart';
import '../../core/widgets/pixel_container.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with SingleTickerProviderStateMixin {
  final _questlingNameController = TextEditingController();
  
  bool _isLoading = false;
  int _selectedStarterIndex = 0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Starter questlings mapped to the actual sprites in assets/sprites/
  final List<Map<String, String>> _starters = [
    {
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Sports-ling',
      'type': 'Sports',
      'description': 'A fiery red bird that loves athletics!',
      'sprite': 'assets/sprites/Sports-ling/Starter1.jpg',
    },
    {
      'id': '22222222-2222-2222-2222-222222222222',
      'name': 'Tech-ling',
      'type': 'Tech',
      'description': 'A brainy capybara, always debugging!',
      'sprite': 'assets/sprites/Tech-ling/Starter2.jpg',
    },
    {
      'id': '33333333-3333-3333-3333-333333333333',
      'name': 'Art-ling',
      'type': 'Art',
      'description': 'A creative chameleon full of color!',
      'sprite': 'assets/sprites/Art-ling/Starter3.png',
    },
    {
      'id': '44444444-4444-4444-4444-444444444444',
      'name': 'Skool-ling',
      'type': 'School',
      'description': 'A wise owl scholar with knowledge!',
      'sprite': 'assets/sprites/Skool-ling/Starter4.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _questlingNameController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    final questlingName = _questlingNameController.text.trim();

    if (questlingName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your companion a name.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in.';

      final selectedStarter = _starters[_selectedStarterIndex];

      // 1. Create User Questling (links to the dictionary entry)
      final questlingResponse = await Supabase.instance.client.from('user_questlings').insert({
        'user_id': user.id,
        'questling_id': selectedStarter['id'],
        'nickname': questlingName,
        'status': 'Healthy',
        'level': 1,
      }).select().single();

      final userQuestlingId = questlingResponse['id'];

      // 2. Equip the Questling on the user profile
      await Supabase.instance.client.from('users').update({
        'equipped_questling_id': userQuestlingId,
      }).eq('id', user.id);

      if (mounted) {
        context.go('/');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _starters[_selectedStarterIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNT SETUP', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to Questlings!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your username and choose your first companion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
              ),
              const SizedBox(height: 32),
              
              // --- Starter Selection ---
              const Text(
                'Choose Your Starter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Selected Questling Preview (large, bouncing)
              PixelContainer(
                backgroundColor: QuestlingsTheme.background,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          selected['sprite']!,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none, // Keep pixel art crisp
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selected['name']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTypeColor(selected['type']!).withValues(alpha: 0.15),
                        border: Border.all(color: _getTypeColor(selected['type']!), width: 1.5),
                      ),
                      child: Text(
                        selected['type']!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _getTypeColor(selected['type']!),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selected['description']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: QuestlingsTheme.shadow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sprite Selection Grid (4 thumbnails)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_starters.length, (index) {
                  final isSelected = index == _selectedStarterIndex;
                  final starter = _starters[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStarterIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isSelected ? _getTypeColor(starter['type']!).withValues(alpha: 0.12) : Colors.white,
                        border: Border.all(
                          color: isSelected ? _getTypeColor(starter['type']!) : QuestlingsTheme.shadow,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: _getTypeColor(starter['type']!).withValues(alpha: 0.3),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              )]
                            : const [BoxShadow(
                                color: QuestlingsTheme.shadow,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              )],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          starter['sprite']!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Questling Nickname Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                ),
                child: TextField(
                  controller: _questlingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Companion Nickname',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              PixelButton(
                onPressed: _isLoading ? null : _submitSetup,
                text: _isLoading ? 'SAVING...' : 'BEGIN JOURNEY',
                backgroundColor: QuestlingsTheme.primaryAction,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a color associated with each questling type for visual theming.
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Sports':
        return const Color(0xFFD32F2F); // Red
      case 'Tech':
        return const Color(0xFF7B1FA2); // Purple
      case 'Art':
        return const Color(0xFF2E7D32); // Green
      case 'School':
        return const Color(0xFF795548); // Brown
      default:
        return QuestlingsTheme.shadow;
    }
  }
}
