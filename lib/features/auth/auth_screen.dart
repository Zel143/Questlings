import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String _userEmail = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _animController.dispose();
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

        final googleSignIn = GoogleSignIn(serverClientId: webClientId);
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw 'Google Sign In was canceled.';
        }

        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;

        if (idToken == null) throw 'No ID Token found.';

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: QuestlingsTheme.danger,
          ),
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
          const SnackBar(
            content: Text('Check your email for the OTP code!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: QuestlingsTheme.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: QuestlingsTheme.danger,
          ),
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
          SnackBar(
            content: Text('Error: $error'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: QuestlingsTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: QuestlingsTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // ── Logo / Icon ──────────────────────────────────────────
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: QuestlingsTheme.primaryGradient,
                          boxShadow: QuestlingsTheme.glowShadow,
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        size: 56,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Questlings',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          foreground: Paint()
                            ..shader = QuestlingsTheme.goldGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 40),
                            ),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level up your life, one quest at a time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: QuestlingsTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // ── Auth Form ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: QuestlingsTheme.cardGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: QuestlingsTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_otpSent) ...[
                          // Google Sign In
                          _SocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Continue with Google',
                            isLoading: _isLoading,
                            onTap: _signInWithGoogle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _DividerWithText(text: 'Or continue with email'),
                          const SizedBox(height: 20),
                          // Email Field
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: QuestlingsTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          // Send OTP Button
                          _GradientButton(
                            label: 'Send Magic Link',
                            isLoading: _isLoading,
                            onTap: _sendOtp,
                          ),
                        ] else ...[
                          // OTP Verification
                          Text(
                            'Check your email',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We sent a code to\n$_userEmail',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'OTP Code',
                              hintText: 'Enter the 6-digit code',
                              prefixIcon: Icon(Icons.password_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: QuestlingsTheme.textPrimary,
                              fontSize: 24,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GradientButton(
                            label: 'Verify & Login',
                            isLoading: _isLoading,
                            onTap: _verifyOtp,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                            child: Text(
                              'Use a different email',
                              style: TextStyle(
                                color: QuestlingsTheme.primaryLight.withValues(alpha: 0.8),
                              ),
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
        ),
      ),
    );
  }
}

// ── Social Button ───────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final Gradient gradient;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Gradient Button ─────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: QuestlingsTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: QuestlingsTheme.primaryLight.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Divider ─────────────────────────────────────────────────────────────
class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: QuestlingsTheme.surfaceOverlay)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: QuestlingsTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: QuestlingsTheme.surfaceOverlay)),
      ],
    );
  }
}