import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/storage_service.dart';
import '../../../services/user_service.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen> {
  void _goToSignUp() {
    context.go('/auth/signup');
  }

  void _goToSignIn() {
    context.go('/auth/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome illustration
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 80,
                    color: AppColors.white,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 48),

                // Title
                Text(
                  "Let's Get Started!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),

                // Description
                Text(
                  "Create an account or sign in to continue",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),

                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToSignUp,
                    child: const Text('Create Account'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToSignIn,
                    child: const Text('Sign In'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

