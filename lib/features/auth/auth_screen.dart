import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme.dart';
import '../../core/widgets/pixel_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String _userEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:3000',
        );
      } else {
        final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

        if (webClientId == null || webClientId.isEmpty) {
          throw 'GOOGLE_WEB_CLIENT_ID not found in .env file.';
        }

        await GoogleSignIn.instance.initialize(
          serverClientId: webClientId,
        );

        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) throw 'No ID Token found.';

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.questlings://login-callback/',
      );
      setState(() {
        _otpSent = true;
        _userEmail = email;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your email for the OTP code!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: _userEmail,
        token: otp,
        type: OtpType.magiclink,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
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
              const Icon(Icons.egg, size: 80, color: QuestlingsTheme.primaryAction),
              const SizedBox(height: 24),
              const Text(
                'QUESTLINGS',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4.0),
              ),
              const SizedBox(height: 8),
              const Text(
                'ENTER THE REALM',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 48),

              if (!_otpSent) ...[
                PixelButton(
                  icon: const Icon(Icons.login, color: Colors.white),
                  text: 'Sign in with Google',
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  backgroundColor: QuestlingsTheme.primaryAction,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: QuestlingsTheme.shadow, thickness: 2)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: QuestlingsTheme.shadow, thickness: 2)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                    boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Icon(Icons.email, color: QuestlingsTheme.shadow),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 24),
                PixelButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  text: _isLoading ? 'SENDING...' : 'Send Magic Link',
                ),
              ] else ...[
                Text(
                  'Enter the code sent to $_userEmail',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                    boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: QuestlingsTheme.shadow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Icon(Icons.password, color: QuestlingsTheme.shadow),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 24),
                PixelButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  text: _isLoading ? 'VERIFYING...' : 'Verify Login',
                  backgroundColor: QuestlingsTheme.primaryAction,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Use a different email', style: TextStyle(color: QuestlingsTheme.shadow, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}