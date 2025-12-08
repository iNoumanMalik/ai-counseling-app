import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../core/utils/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  String? _lastMood;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final data = await UserService(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      ).getUserData();
      setState(() {
        _userName = (data?['name'] as String?) ?? 'Friend';
        _lastMood = (data?['lastMood'] as String?) ?? _lastMood;
      });
    } catch (_) {
      final local = await StorageService.getUserName();
      setState(() {
        _userName = local ?? 'Friend';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Greeting
                      Text(
                            AppStrings.homeGreeting.replaceAll(
                              '{name}',
                              _userName ?? 'Friend',
                            ),
                            style: Theme.of(context).textTheme.displaySmall,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 32),

                      if (_lastMood != null)
                        Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _SuggestionCard(
                                lastMood: _lastMood!,
                                onNavigate: (route) => context.push(route),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),

                      // Mood selector
                      Text(
                        AppStrings.homeMoodSelection,
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      const MoodSelector()
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 32),

                      // Quick actions
                      Text(
                        AppStrings.homeQuickActions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: 16),

                      // Quick action cards
                      GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              QuickActionCard(
                                title: AppStrings.homeBreathingExercise,
                                icon: Icons.air_outlined,
                                gradient: AppColors.primaryGradient,
                                onTap: () => context.push('/breathing'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeJournal,
                                icon: Icons.edit_note_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/journal'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeMeditation,
                                icon: Icons.self_improvement_outlined,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accent.withValues(alpha: 0.7),
                                  ],
                                ),
                                onTap: () => context.push('/meditation'),
                              ),
                              QuickActionCard(
                                title: 'Worksheets',
                                icon: Icons.menu_book_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/worksheets'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeExploreCounselors,
                                icon: Icons.people_outline,
                                gradient: AppColors.primaryGradient,
                                onTap: () => context.push('/discovery'),
                              ),
                              QuickActionCard(
                                title: 'MCQ Check-in',
                                icon: Icons.quiz_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/checkin'),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AnimatedBottomNav(currentIndex: 0),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String lastMood;
  final void Function(String) onNavigate;
  const _SuggestionCard({required this.lastMood, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    String title;
    String button;
    String route;
    if (lastMood == AppStrings.moodAnxious || lastMood == AppStrings.moodSad) {
      title = 'You might benefit from a short breath or meditation.';
      button = AppStrings.homeBreathingExercise;
      route = '/breathing';
    } else if (lastMood == AppStrings.moodOkay) {
      title = 'Keep momentum with a quick habit.';
      button = AppStrings.homeJournal;
      route = '/journal';
    } else {
      title = 'Explore a worksheet to deepen reflection.';
      button = 'CBT Worksheets';
      route = '/worksheets';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => onNavigate(route),
            child: Text(button),
          ),
        ],
      ),
    );
  }
}
