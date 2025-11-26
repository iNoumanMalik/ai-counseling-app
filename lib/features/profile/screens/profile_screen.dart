import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../core/utils/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  int _streak = 0;
  int _journalCount = 0;
  int _moodCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await StorageService.getUserName();
    final streak = await StorageService.getHabitStreak();
    final journals = await StorageService.getJournalEntries();
    final moods = await StorageService.getMoodHistory();

    setState(() {
      _userName = name ?? 'User';
      _streak = streak;
      _journalCount = journals.length;
      _moodCount = moods.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Profile header
                Center(
                  child: Column(
                    children: [
                      Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 50,
                              color: AppColors.white,
                            ),
                          )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 300.ms),
                      const SizedBox(height: 16),
                      Text(
                        _userName ?? 'User',
                        style: Theme.of(context).textTheme.displaySmall,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child:
                          _StatCard(
                                label: 'Day Streak',
                                value: '$_streak',
                                icon: Icons.local_fire_department,
                                color: AppColors.accent,
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _StatCard(
                                label: 'Journal Entries',
                                value: '$_journalCount',
                                icon: Icons.edit_note_outlined,
                                color: AppColors.secondary,
                              )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms)
                              .slideX(begin: 0.2, end: 0),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child:
                          _StatCard(
                                label: 'Mood Entries',
                                value: '$_moodCount',
                                icon: Icons.mood_outlined,
                                color: AppColors.primary,
                              )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms)
                              .slideX(begin: 0.2, end: 0),
                    ),
                  ],
                ),
                // const SizedBox(height: 16),
                // _StatCard(
                //       label: 'Mood Entries',
                //       value: '$_moodCount',
                //       icon: Icons.mood_outlined,
                //       color: AppColors.primary,
                //     )
                //     .animate()
                //     .fadeIn(delay: 500.ms, duration: 400.ms)
                //     .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),

                // Menu items
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 16),

                _MenuItem(
                      icon: Icons.history_outlined,
                      label: AppStrings.profileMoodHistory,
                      onTap: () {
                        // TODO: Navigate to mood history
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mood history coming soon'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
                _MenuItem(
                      icon: Icons.edit_note_outlined,
                      label: AppStrings.profileJournalHistory,
                      onTap: () => context.push('/journal'),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
                _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Reminders',
                      onTap: () {
                        // TODO: Navigate to reminders
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reminders coming soon'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
                _MenuItem(
                      icon: Icons.emergency_outlined,
                      label: 'Crisis Support',
                      onTap: () => context.push('/sos'),
                    )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AnimatedBottomNav(currentIndex: 3),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mediumGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.mediumGray,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}
