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

class _UsernameScreenState extends State<UsernameScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = true; // start as loading to check existing user
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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

  Future<void> _createUser() async {
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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'No authenticated user found.';

      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'username': username,
      }).select();

      if (!mounted) return;

      // Mark setup as complete
      needsUsernameSetup = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome, adventurer!'),
          backgroundColor: QuestlingsTheme.primaryAction,
        ),
      );
      // Small delay so snackbar shows
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      GoRouter.of(context).go('/');
    } catch (error) {
      if (!mounted) return;

      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('duplicate') || errorStr.contains('unique') || errorStr.contains('already exists')) {
        setState(() => _errorMessage = 'That username is already taken. Try another!');
      } else {
        setState(() => _errorMessage = 'Error: $error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: QuestlingsTheme.lightGreen,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                    ),
                  ),
                ),
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
                  onSubmitted: (_) => _createUser(),
                ),
              ),
              const SizedBox(height: 24),
              PixelButton(
                onPressed: _isLoading ? null : _createUser,
                text: _isLoading ? 'CREATING...' : 'BEGIN ADVENTURE',
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