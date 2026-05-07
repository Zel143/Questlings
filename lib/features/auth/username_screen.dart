import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/router.dart' show needsUsernameSetup;
import '../../core/widgets/pixel_container.dart';
import '../../core/widgets/pixel_button.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _questlingNameController = TextEditingController();

  bool _isLoading = true; // starts loading to check existing user
  bool _isSubmitting = false;
  String? _errorMessage;

  // 0 = username step, 1 = sprite selection step
  int _currentStep = 0;

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
    _checkExistingUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _questlingNameController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) GoRouter.of(context).go('/login');
        return;
      }

      final response = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (response != null) {
        // User already exists - skip to home
        needsUsernameSetup = false;
        GoRouter.of(context).go('/');
        return;
      }

      // New user - show the form
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Advance from Step 0 (username) → Step 1 (sprite pick)
  void _goToSpriteStep() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Please enter a username');
      return;
    }
    if (username.length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters');
      return;
    }

    setState(() {
      _errorMessage = null;
      _currentStep = 1;
    });
  }

  /// Go back to Step 0
  void _goBackToUsername() {
    setState(() {
      _errorMessage = null;
      _currentStep = 0;
    });
  }

  /// Final submit: create user profile + questling + equip
  Future<void> _submitSetup() async {
    final username = _usernameController.text.trim();
    final questlingName = _questlingNameController.text.trim();

    if (questlingName.isEmpty) {
      setState(() => _errorMessage = 'Give your companion a nickname!');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in.';

      final selectedStarter = _starters[_selectedStarterIndex];

      // 1. Create User Profile
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'username': username,
        'level': 1,
        'xp': 0,
        'stardust': 0,
      });

      // 2. Create User Questling (links to the dictionary entry)
      final questlingResponse =
          await Supabase.instance.client.from('user_questlings').insert({
        'user_id': user.id,
        'questling_id': selectedStarter['id'],
        'nickname': questlingName,
        'status': 'Healthy',
        'level': 1,
      }).select().single();

      final userQuestlingId = questlingResponse['id'];

      // 3. Equip the Questling on the user profile
      await Supabase.instance.client.from('users').update({
        'equipped_questling_id': userQuestlingId,
      }).eq('id', user.id);

      if (!mounted) return;

      // Mark setup as complete
      needsUsernameSetup = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome, adventurer! Your journey begins!'),
          backgroundColor: QuestlingsTheme.primaryAction,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      GoRouter.of(context).go('/');
    } catch (error) {
      if (!mounted) return;

      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('duplicate') ||
          errorStr.contains('unique') ||
          errorStr.contains('already exists')) {
        setState(() {
          _errorMessage = 'That username is already taken. Try another!';
          _currentStep = 0; // go back to username step
        });
      } else {
        setState(() => _errorMessage = 'Setup failed: $error');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _currentStep == 0
                  ? _buildUsernameStep()
                  : _buildSpriteStep(),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // STEP 0: Username
  // ──────────────────────────────────────────
  Widget _buildUsernameStep() {
    return Column(
      key: const ValueKey('step_username'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_add, size: 64, color: QuestlingsTheme.primaryAction),
        const SizedBox(height: 24),
        const Text(
          'CHOOSE YOUR NAME',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3.0),
        ),
        const SizedBox(height: 8),
        const Text(
          'What shall we call you, adventurer?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        if (_errorMessage != null) _buildErrorBanner(),
        PixelContainer(
          padding: 0,
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.badge_outlined, color: QuestlingsTheme.shadow),
            ),
            maxLength: 20,
            textCapitalization: TextCapitalization.none,
            onSubmitted: (_) => _goToSpriteStep(),
          ),
        ),
        const SizedBox(height: 24),
        PixelButton(
          onPressed: _goToSpriteStep,
          text: 'NEXT',
          backgroundColor: QuestlingsTheme.primaryAction,
          textColor: Colors.white,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // STEP 1: Sprite Selection + Nickname
  // ──────────────────────────────────────────
  Widget _buildSpriteStep() {
    final selected = _starters[_selectedStarterIndex];

    return Column(
      key: const ValueKey('step_sprite'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _goBackToUsername,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2))],
                color: Colors.white,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 18, color: QuestlingsTheme.shadow),
                  SizedBox(width: 6),
                  Text('BACK', style: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'CHOOSE YOUR STARTER',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pick your first companion and give it a name!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) _buildErrorBanner(),

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
                  color: isSelected
                      ? _getTypeColor(starter['type']!).withValues(alpha: 0.12)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? _getTypeColor(starter['type']!)
                        : QuestlingsTheme.shadow,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getTypeColor(starter['type']!)
                                .withValues(alpha: 0.3),
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          )
                        ]
                      : const [
                          BoxShadow(
                            color: QuestlingsTheme.shadow,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          )
                        ],
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
            boxShadow: const [
              BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))
            ],
          ),
          child: TextField(
            controller: _questlingNameController,
            decoration: const InputDecoration(
              labelText: 'Companion Nickname',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon:
                  Icon(Icons.pets, color: QuestlingsTheme.shadow),
            ),
            onSubmitted: (_) => _submitSetup(),
          ),
        ),
        const SizedBox(height: 32),

        PixelButton(
          onPressed: _isSubmitting ? null : _submitSetup,
          text: _isSubmitting ? 'SAVING...' : 'BEGIN JOURNEY',
          backgroundColor: QuestlingsTheme.primaryAction,
          textColor: Colors.white,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Shared widgets
  // ──────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border.all(color: const Color(0xFFE65100), width: 2),
          boxShadow: const [
            BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(3, 3)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE65100), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}