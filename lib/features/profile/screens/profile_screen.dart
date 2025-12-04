import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';
import '../../../services/journal_service.dart';
import '../../../services/mood_service.dart';
import '../../../services/habits_service.dart';
import '../../../services/meditation_service.dart';
import '../../../services/auth_service.dart';
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
  List<int> _moodLast7 = List.filled(7, 0);
  double _habitsCompletion = 0.0;
  double _meditationCompletion = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    Map<String, dynamic>? userData;
    List<Map<String, dynamic>> journals = [];
    List<Map<String, dynamic>> moods = [];
    Map<String, bool> habits = {};
    Map<String, bool> meditations = {};
    try {
      userData = await UserService(FirebaseFirestore.instance, FirebaseAuth.instance).getUserData();
    } catch (_) {}
    try {
      journals = await JournalService(FirebaseFirestore.instance, FirebaseAuth.instance).listEntries();
    } catch (_) {
      final local = await StorageService.getJournalEntries();
      journals = local;
    }
    try {
      moods = await MoodService(FirebaseFirestore.instance, FirebaseAuth.instance).getMoodHistory();
    } catch (_) {
      final local = await StorageService.getMoodHistory();
      moods = local;
    }
    try {
      habits = await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).getHabits();
    } catch (_) {
      final localHabits = await StorageService.getHabits();
      habits = {
        for (final e in localHabits.entries)
          e.key: (e.value is Map<String, dynamic>) ? ((e.value['completed'] as bool?) ?? false) : false,
      };
    }
    try {
      meditations = await MeditationService(FirebaseFirestore.instance, FirebaseAuth.instance).listCompletions();
    } catch (_) {
      meditations = {};
    }

    final fallbackName = await StorageService.getUserName();
    final fallbackStreak = await StorageService.getHabitStreak();

    final now = DateTime.now();
    final buckets = List<int>.filled(7, 0);
    for (final m in moods) {
      final s = m['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try { dt = DateTime.parse(s); } catch (_) { dt = null; }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = now.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        buckets[6 - diff] += 1;
      }
    }

    int habitsTotal = habits.length;
    int habitsDone = habits.values.where((v) => v).length;
    double habitsPct = habitsTotal == 0 ? 0.0 : habitsDone / habitsTotal;

    int medTotal = meditations.length;
    int medDone = meditations.values.where((v) => v).length;
    double medPct = medTotal == 0 ? 0.0 : medDone / medTotal;

    setState(() {
      _userName = (userData?['name'] as String?) ?? fallbackName ?? 'User';
      _streak = (userData?['habitStreak'] as int?) ?? fallbackStreak;
      _journalCount = journals.length;
      _moodCount = moods.length;
      _moodLast7 = buckets;
      _habitsCompletion = habitsPct;
      _meditationCompletion = medPct;
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

                Text(
                  'Graphs & Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 12),
                _AnalyticsSection(
                  moodLast7: _moodLast7,
                  habitsCompletion: _habitsCompletion,
                  meditationCompletion: _meditationCompletion,
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
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
                _MenuItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () async {
                        try {
                          await AuthService(FirebaseAuth.instance).signOut();
                        } catch (_) {}
                        if (mounted) {
                          context.go('/auth/signin');
                        }
                      },
                    )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 400.ms)
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

class _AnalyticsSection extends StatelessWidget {
  final List<int> moodLast7;
  final double habitsCompletion;
  final double meditationCompletion;

  const _AnalyticsSection({
    required this.moodLast7,
    required this.habitsCompletion,
    required this.meditationCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = moodLast7.isEmpty ? 0 : (moodLast7.reduce((a, b) => a > b ? a : b));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood trend (last 7 days)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < moodLast7.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: maxVal == 0 ? 4 : (moodLast7[i] / maxVal) * 100 + 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Activity completion', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ProgressRow(label: 'Habits', value: habitsCompletion),
            const SizedBox(height: 8),
            _ProgressRow(label: 'Meditation', value: meditationCompletion),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
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
