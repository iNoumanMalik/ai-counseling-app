import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../services/user_service.dart';
import '../../../services/journal_service.dart';
import '../../../services/mood_service.dart';
import '../../../services/habits_service.dart';
import '../../../services/meditation_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/widgets/counseling_floating_button.dart';

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
  List<Map<String, dynamic>> _checkinsLast7 = const [];
  List<int> _habitLast7 = List.filled(7, 0);
  List<int> _journalLast7 = List.filled(7, 0);
  int _meditationCountLast7 = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String? name;
    int streak = 0;
    try {
      final data = await UserService(db, auth).getUserData();
      name = (data?['name'] as String?);
      streak = (data?['habitStreak'] as int?) ?? 0;
    } catch (_) {}
    if (name == null) {
      try {
        name = await StorageService.getUserName();
      } catch (_) {}
    }
    if (streak == 0) {
      try {
        streak = await StorageService.getHabitStreak();
      } catch (_) {}
    }

    List<Map<String, dynamic>> journals = [];
    try {
      journals = await JournalService(db, auth).listEntries();
    } catch (_) {
      journals = await StorageService.getJournalEntries();
    }
    int journalCount = journals.length;
    final journalBuckets = List<int>.filled(7, 0);
    for (final j in journals) {
      final s = j['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s);
      } catch (_) {
        dt = null;
      }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        journalBuckets[6 - diff] += 1;
      }
    }

    List<Map<String, dynamic>> moods = [];
    try {
      moods = await MoodService(db, auth).getMoodHistory();
    } catch (_) {
      moods = await StorageService.getMoodHistory();
    }
    int moodCount = moods.length;
    final moodBuckets = List<int>.filled(7, 0);
    for (final m in moods) {
      final s = m['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s);
      } catch (_) {
        dt = null;
      }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        moodBuckets[6 - diff] += 1;
      }
    }

    List<Map<String, dynamic>> habitLogs = [];
    try {
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        final qs = await db
            .collection('users')
            .doc(uid)
            .collection('habitLog')
            .orderBy('date', descending: true)
            .get();
        habitLogs = qs.docs.map((d) {
          final data = d.data();
          final ts = data['date'] as Timestamp?;
          return {
            'habitId': data['habitId'],
            'date': ts?.toDate().toIso8601String(),
          };
        }).toList();
      }
    } catch (_) {}
    if (habitLogs.isEmpty) {
      try {
        habitLogs = await StorageService.getHabitLog();
      } catch (_) {}
    }
    final habitBuckets = List<int>.filled(7, 0);
    for (final h in habitLogs) {
      final s = h['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s);
      } catch (_) {
        dt = null;
      }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        habitBuckets[6 - diff] += 1;
      }
    }
    final daysWithHabits = habitBuckets.where((e) => e > 0).length;
    final habitsCompletion = daysWithHabits / 7.0;

    int meditationCount7 = 0;
    try {
      final sessions = await StorageService.getMeditationSessions();
      for (final s in sessions) {
        final t = s['date'] as String?;
        if (t == null) continue;
        DateTime? dt;
        try { dt = DateTime.parse(t); } catch (_) { dt = null; }
        if (dt == null) continue;
        final day = DateTime(dt.year, dt.month, dt.day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) {
          meditationCount7 += 1;
        }
      }
    } catch (_) {}

    List<Map<String, dynamic>> checkins = [];
    try {
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        final qs = await db
            .collection('checkins')
            .doc(uid)
            .collection('entries')
            .orderBy('timestamp', descending: true)
            .get();
        checkins = qs.docs.map((d) => d.data()).toList();
      }
    } catch (_) {}
    if (checkins.isEmpty) {
      try {
        checkins = await StorageService.getCheckins();
      } catch (_) {}
    }
    final last7Checkins = <Map<String, dynamic>>[];
    for (final c in checkins) {
      final s = (c['timestamp'] as String?) ?? (c['date'] as String?);
      if (s == null) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s);
      } catch (_) {
        dt = null;
      }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) {
        last7Checkins.add(c);
      }
    }

    if (!mounted) return;
    setState(() {
      _userName = name;
      _streak = streak;
      _journalCount = journalCount;
      _moodCount = moodCount;
      _journalLast7 = journalBuckets;
      _moodLast7 = moodBuckets;
      _habitLast7 = habitBuckets;
      _habitsCompletion = habitsCompletion;
      _meditationCountLast7 = meditationCount7;
      _checkinsLast7 = last7Checkins;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                                  color: AppColors.primary.withValues(alpha: 0.3),
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

                    // Activity Overview with improved graph
                    Text(
                      'Activity Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    _UnifiedStatsChart(
                      journals: _journalLast7.fold<int>(0, (a, b) => a + b),
                      moods: _moodLast7.fold<int>(0, (a, b) => a + b),
                      habits: _habitLast7.fold<int>(0, (a, b) => a + b),
                      checkins: _checkinsLast7.length,
                      meditationScore: _meditationCountLast7,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),

                    // Stats
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
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
                          child: _StatCard(
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
                          child: _StatCard(
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
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    const SizedBox(height: 32),

                    // Settings Menu
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    _MenuItem(
                      icon: Icons.history_outlined,
                      label: AppStrings.profileMoodHistory,
                      onTap: () => context.push('/mood/history'),
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
        ),
        const CounselingFloatingButton(),
      ],
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  final List<int> journalData;
  final List<int> moodData;
  final List<int> habitData;
  final int meditationScore;

  const _WeeklyActivityChart({
    required this.journalData,
    required this.moodData,
    required this.habitData,
    required this.meditationScore,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = [
      ...journalData,
      ...moodData,
      ...habitData,
      meditationScore,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '7 Days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal.toDouble() + 2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: AppColors.primary.withOpacity(0.9),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = rod.toY.toInt();
                        String label = '';
                        Color color = AppColors.primary;
                        
                        if (rodIndex == 0) {
                          label = 'Journals';
                          color = AppColors.secondary;
                        } else if (rodIndex == 1) {
                          label = 'Moods';
                          color = AppColors.primary;
                        } else if (rodIndex == 2) {
                          label = 'Habits';
                          color = AppColors.success;
                        }
                        
                        return BarTooltipItem(
                          '$label\n$value entries',
                          TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '\n${days[group.x]}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mediumGray,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.lightGray300,
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.lightGray300,
                      width: 0.5,
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      groupVertically: true,
                      barRods: [
                        // Journals
                        BarChartRodData(
                          toY: journalData[index].toDouble(),
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.9),
                              AppColors.secondary.withOpacity(0.6),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        // Moods
                        BarChartRodData(
                          toY: moodData[index].toDouble(),
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.9),
                              AppColors.primary.withOpacity(0.6),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        // Habits
                        BarChartRodData(
                          toY: habitData[index].toDouble(),
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withOpacity(0.9),
                              AppColors.success.withOpacity(0.6),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: AppColors.secondary, label: 'Journals'),
                _LegendItem(color: AppColors.primary, label: 'Moods'),
                _LegendItem(color: AppColors.success, label: 'Habits'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnifiedStatsChart extends StatelessWidget {
  final int journals;
  final int moods;
  final int habits;
  final int checkins;
  final int meditationScore;

  const _UnifiedStatsChart({
    required this.journals,
    required this.moods,
    required this.habits,
    required this.checkins,
    required this.meditationScore,
  });

  @override
  Widget build(BuildContext context) {
    final values = [
      journals.toDouble(),
      moods.toDouble(),
      habits.toDouble(),
      checkins.toDouble(),
      meditationScore.toDouble(),
    ];
    final total = values.fold<double>(0, (a, b) => a + b);
    final colors = [
      Colors.yellow[600]!,
      Colors.purple[500]!,
      Colors.green[500]!,
      Colors.orange[500]!,
      Colors.blue[500]!,
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly activity breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Totals',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 70,
                  sections: [
                    PieChartSectionData(
                      value: values[0],
                      color: colors[0],
                      title: values[0] > 0 ? values[0].toInt().toString() : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: values[1],
                      color: colors[1],
                      title: values[1] > 0 ? values[1].toInt().toString() : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: values[2],
                      color: colors[2],
                      title: values[2] > 0 ? values[2].toInt().toString() : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: values[3],
                      color: colors[3],
                      title: values[3] > 0 ? values[3].toInt().toString() : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: values[4],
                      color: colors[4],
                      title: values[4] > 0 ? values[4].toInt().toString() : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _legend(colors[0], 'Journals: $journals'),
                _legend(colors[1], 'Moods: $moods'),
                _legend(colors[2], 'Habits: $habits'),
                _legend(colors[3], 'Check-ins: $checkins'),
                _legend(colors[4], 'Meditation: $meditationScore'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _ProgressGauge extends StatelessWidget {
  final double habitsCompletion;
  final double meditationCompletion;

  const _ProgressGauge({
    required this.habitsCompletion,
    required this.meditationCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Rates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            _CircularProgressGauge(
              label: 'Habits',
              value: habitsCompletion,
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 16),
            _CircularProgressGauge(
              label: 'Meditation',
              value: meditationCompletion,
              color: AppColors.lavender,
              icon: Icons.self_improvement_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressGauge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _CircularProgressGauge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(color),
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage}% completed this week',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StressDistributionChart extends StatelessWidget {
  final List<Map<String, dynamic>> checkins;

  const _StressDistributionChart({required this.checkins});

  @override
  Widget build(BuildContext context) {
    int low = 0, moderate = 0, high = 0;
    
    for (final c in checkins) {
      final cat = (c['category'] as String?) ?? '';
      if (cat == 'low') {
        low++;
      } else if (cat == 'moderate') {
        moderate++;
      } else if (cat == 'high') {
        high++;
      }
    }

    final total = low + moderate + high;
    if (total == 0) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stress Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${checkins.length} check-ins',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: [
                          PieChartSectionData(
                            value: low.toDouble(),
                            color: Colors.green[400],
                            title: '${((low / total) * 100).round()}%',
                            radius: 30,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            badgeWidget: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green[400],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.thumb_up, size: 16, color: Colors.white),
                            ),
                            badgePositionPercentageOffset: 0.98,
                          ),
                          PieChartSectionData(
                            value: moderate.toDouble(),
                            color: Colors.orange[400],
                            title: '${((moderate / total) * 100).round()}%',
                            radius: 30,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            badgeWidget: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber, size: 16, color: Colors.white),
                            ),
                            badgePositionPercentageOffset: 0.98,
                          ),
                          PieChartSectionData(
                            value: high.toDouble(),
                            color: Colors.red[400],
                            title: '${((high / total) * 100).round()}%',
                            radius: 30,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            badgeWidget: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.emergency, size: 16, color: Colors.white),
                            ),
                            badgePositionPercentageOffset: 0.98,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StressLegend(color: Colors.green[400]!, label: 'Low Stress', count: low),
                        const SizedBox(height: 12),
                        _StressLegend(color: Colors.orange[400]!, label: 'Moderate', count: moderate),
                        const SizedBox(height: 12),
                        _StressLegend(color: Colors.red[400]!, label: 'High Stress', count: high),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StressLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _StressLegend({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count check-ins',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mediumGray,
            fontWeight: FontWeight.w500,
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
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightGray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.mediumGray,
                  size: 14,
                ),
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
