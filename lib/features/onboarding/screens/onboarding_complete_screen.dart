import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                Center(
                child: SizedBox(
                  height: 300,
                  child: SvgPicture.asset(
                    'assets/illustrations/undraw_easter-bunny.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
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
