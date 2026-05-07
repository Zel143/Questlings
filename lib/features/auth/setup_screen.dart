import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/pixel_button.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _usernameController = TextEditingController();
  final _questlingNameController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedStarterId = '11111111-1111-1111-1111-111111111111'; // Default Seedling

  final List<Map<String, String>> _starters = [
    {
      'id': '11111111-1111-1111-1111-111111111111',
      'name': 'Seedling (Grass)',
    },
    {
      'id': '22222222-2222-2222-2222-222222222222',
      'name': 'Ember (Fire)',
    },
    {
      'id': '33333333-3333-3333-3333-333333333333',
      'name': 'Droplet (Water)',
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _questlingNameController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    final username = _usernameController.text.trim();
    final questlingName = _questlingNameController.text.trim();

    if (username.isEmpty || questlingName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in.';

      // 1. Create User Profile
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'username': username,
        'level': 1,
        'xp': 0,
        'stardust': 0,
      });

      // 2. Create User Questling
      final questlingResponse = await Supabase.instance.client.from('user_questlings').insert({
        'user_id': user.id,
        'questling_id': _selectedStarterId,
        'nickname': questlingName,
        'status': 'Healthy',
        'level': 1,
      }).select().single();

      final userQuestlingId = questlingResponse['id'];

      // 3. Equip the Questling
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
              
              // Username Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Questling Type Selection
              const Text('Choose Your Starter', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStarterId,
                    isExpanded: true,
                    items: _starters.map((starter) {
                      return DropdownMenuItem<String>(
                        value: starter['id'],
                        child: Text(
                          starter['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStarterId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Questling Name Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                ),
                child: TextField(
                  controller: _questlingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Companion Name',
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
}
