import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

// Google OAuth Sign In
  Future<void> _signInWithGoogle() async {
      setState(() => _isLoading = true);
      
      try {
        if (kIsWeb) {
          // ==========================================
          // 🌐 WEB (CHROME) IMPLEMENTATION
          // ==========================================
          // On the web, Supabase handles the Google redirect natively.
          // We completely bypass the google_sign_in package here.
          await Supabase.instance.client.auth.signInWithOAuth(
            OAuthProvider.google,
            // Replace this with your actual local testing URL if different
            redirectTo: 'http://localhost:3000', 
          );
          
        } else {
          // ==========================================
          // 📱 NATIVE (ANDROID/IOS) IMPLEMENTATION
          // ==========================================
          final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
          
          if (webClientId == null || webClientId.isEmpty) {
            throw 'GOOGLE_WEB_CLIENT_ID not found in .env file.';
          }

          await GoogleSignIn.instance.initialize(
            serverClientId: webClientId,
          );

          final googleUser = await GoogleSignIn.instance.authenticate();
          final googleAuth = await googleUser.authentication;
          final idToken = googleAuth.idToken;

          if (idToken == null) throw 'No ID Token found.';

          // In google_sign_in >= 7.0.0, access token is retrieved separately
          final clientAuth = await googleUser.authorizationClient.authorizationForScopes([]);
          final accessToken = clientAuth?.accessToken;

          await Supabase.instance.client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
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

  // Send OTP to Email
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

  // Verify OTP
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.egg, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Questlings',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              if (!_otpSent) ...[
                // Google Login Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Email OTP Request
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('Send Magic Link / OTP'),
                ),
              ] else ...[
                // OTP Verification Form
                Text(
                  'Enter the code sent to $_userEmail',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('Verify Login'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Use a different email'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
