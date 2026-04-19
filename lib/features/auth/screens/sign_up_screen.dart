import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../core/utils/storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signUpWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Email already in use';
          break;
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
        case 'weak-password':
          msg = 'Weak password';
          break;
        case 'operation-not-allowed':
          msg = 'Email/Password sign-in not enabled';
          break;
        case 'network-request-failed':
          msg = 'Network error';
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    try {
      await ref.read(userServiceProvider).createOrUpdateProfile(name: name);
    } catch (_) {
      await StorageService.setUserName(name);
    }

    await StorageService.setOnboardingComplete(true);
    if (mounted) {
      context.go('/home');
    }

    try {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 250,
                  child: SvgPicture.asset(
                    'assets/illustrations/undraw_welcome-cats.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                obscureText: true,
              ),              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Account'),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/auth/signin'),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
