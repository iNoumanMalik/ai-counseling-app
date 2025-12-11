import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../core/utils/storage_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithEmail(email, password);
      try {
        final data = await ref.read(userServiceProvider).getUserData();
        String? existingName = (data?['name'] as String?);
        if (existingName == null || existingName.trim().isEmpty) {
          final derived = user.displayName ?? (user.email?.split('@').first ?? 'User');
          await ref.read(userServiceProvider).createOrUpdateProfile(name: derived);
          await StorageService.setUserName(derived);
        } else {
          await StorageService.setUserName(existingName);
        }
      } catch (_) {}
      if (mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign in failed';
      switch (e.code) {
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
        case 'user-not-found':
          msg = 'No user found for this email';
          break;
        case 'wrong-password':
          msg = 'Wrong password';
          break;
        case 'network-request-failed':
          msg = 'Network error';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts, try later';
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign In'),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/auth/signup'),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
