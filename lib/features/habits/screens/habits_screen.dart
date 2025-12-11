import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/storage_service.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../core/widgets/counseling_floating_button.dart';
import '../../../services/habits_service.dart';
import '../../../services/user_service.dart';

final _habitsProvider = StateProvider<Map<String, bool>>((ref) => {});

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final ConfettiController _confettiController = ConfettiController();
  int _streak = 0;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadHabitDefs();
    _loadHabits();
    _loadStreak();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  String _formatDateTime(DateTime dt) {
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${days[dt.weekday-1]}, ${months[dt.month-1]} ${dt.day} • $h:$m:$s';
  }

  Future<void> _loadHabitDefs() async {
    List<Map<String, dynamic>> defs = [];
    try {
      final service = HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance);
      defs = await service.listHabitDefs();
    } catch (_) {
      defs = await StorageService.getHabitDefs();
    }
    if (defs.isEmpty) {
      final defaults = [
        {'id': 'water', 'label': AppStrings.habitsDrinkWater, 'icon': Icons.water_drop_outlined.codePoint},
        {'id': 'meditate', 'label': AppStrings.habitsMeditate, 'icon': Icons.self_improvement_outlined.codePoint},
        {'id': 'journal', 'label': AppStrings.habitsJournal, 'icon': Icons.edit_note_outlined.codePoint},
        {'id': 'stretch', 'label': AppStrings.habitsStretching, 'icon': Icons.fitness_center_outlined.codePoint},
        {'id': 'walk', 'label': AppStrings.habitsWalk, 'icon': Icons.directions_walk_outlined.codePoint},
      ];
      _habits = defaults.map((d) => Habit(id: d['id'] as String, label: d['label'] as String, icon: IconData(d['icon'] as int, fontFamily: 'MaterialIcons'))).toList();
      for (final d in defaults) {
        try {
          await StorageService.saveHabitDef(d);
          await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).addHabitDef(
            id: d['id'] as String,
            label: d['label'] as String,
            iconCodePoint: d['icon'] as int,
          );
        } catch (_) {}
      }
    } else {
      _habits = defs.map((d) => Habit(
        id: d['id'] as String,
        label: (d['label'] as String?) ?? d['id'] as String,
        icon: IconData((d['icon'] as int?) ?? Icons.check_circle_outline.codePoint, fontFamily: 'MaterialIcons'),
      )).toList();
    }
    setState(() {});
  }

  Future<void> _loadHabits() async {
    try {
      final service = HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance);
      final fetched = await service.getHabits();
      final Map<String, bool> completed = {
        for (final h in _habits) h.id: fetched[h.id] ?? false,
      };
      final lastResetIso = await StorageService.getHabitsLastReset();
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);
      if ((lastResetIso ?? '') != todayKey) {
        for (final id in completed.keys.toList()) {
          completed[id] = false;
          try {
            await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).setHabit(id, false);
          } catch (_) {}
          try {
            await StorageService.updateHabit(id, false);
          } catch (_) {}
        }
        await StorageService.setHabitsLastReset(todayKey);
      }
      ref.read(_habitsProvider.notifier).state = completed;
    } catch (_) {
      final local = await StorageService.getHabits();
      final Map<String, bool> completed = {
        for (final h in _habits) h.id: (local[h.id]?['completed'] as bool?) ?? false,
      };
      final lastResetIso = await StorageService.getHabitsLastReset();
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);
      if ((lastResetIso ?? '') != todayKey) {
        for (final id in completed.keys.toList()) {
          completed[id] = false;
          await StorageService.updateHabit(id, false);
        }
        await StorageService.setHabitsLastReset(todayKey);
      }
      ref.read(_habitsProvider.notifier).state = completed;
    }
  }

  Future<void> _loadStreak() async {
    try {
      final data = await UserService(FirebaseFirestore.instance, FirebaseAuth.instance).getUserData();
      setState(() {
        _streak = (data?['habitStreak'] as int?) ?? 0;
      });
    } catch (_) {
      final streak = await StorageService.getHabitStreak();
      setState(() {
        _streak = streak;
      });
    }
  }

  Future<void> _toggleHabit(String habitId, bool completed) async {
    try {
      await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).setHabit(habitId, completed);
      ref.read(_habitsProvider.notifier).state = {
        ...ref.read(_habitsProvider),
        habitId: completed,
      };
    } catch (e) {
      // Fallback to local storage
      await StorageService.updateHabit(habitId, completed);
      ref.read(_habitsProvider.notifier).state = {
        ...ref.read(_habitsProvider),
        habitId: completed,
      };
    }

    // Check if all habits completed
    final allCompleted = ref.read(_habitsProvider).values.every((v) => v || ref.read(_habitsProvider)[habitId] == true);
    if (completed && allCompleted) {
      _confettiController.play();
      final newStreak = _streak + 1;
      try {
        await UserService(FirebaseFirestore.instance, FirebaseAuth.instance).updateHabitStreak(newStreak);
      } catch (_) {}
      setState(() {
        _streak = newStreak;
      });
      try {
        final badges = await StorageService.getBadges();
        if (newStreak >= 7 && !badges.contains('streak_7')) {
          await StorageService.addBadge('streak_7');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge earned: 7-Day Streak'), backgroundColor: AppColors.accent),
          );
        }
        if (newStreak >= 30 && !badges.contains('streak_30')) {
          await StorageService.addBadge('streak_30');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge earned: 30-Day Streak'), backgroundColor: AppColors.secondary),
          );
        }
      } catch (_) {}
    }

    if (completed) {
      try {
        await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).logHabitCompletion(habitId);
      } catch (_) {}
      await StorageService.addHabitLogEntry(habitId: habitId, date: DateTime.now().toIso8601String());
    }
  }

  Future<void> _addHabit() async {
    final TextEditingController controller = TextEditingController();
    IconData selectedIcon = Icons.check_circle_outline;
    final icons = [
      Icons.check_circle_outline,
      Icons.self_improvement_outlined,
      Icons.water_drop_outlined,
      Icons.edit_note_outlined,
      Icons.directions_walk_outlined,
      Icons.fitness_center_outlined,
      Icons.nightlight_round,
      Icons.auto_awesome,
    ];
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Habit name'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: icons.map((ic) {
                  final isSel = ic == selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      selectedIcon = ic;
                      (ctx as Element).markNeedsBuild();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.lightGray200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(ic, color: isSel ? AppColors.primary : AppColors.dark900),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) {
                Navigator.of(ctx).pop();
              } else {
                Navigator.of(ctx).pop({'label': name, 'icon': selectedIcon.codePoint});
              }
            }, child: const Text('Add')),
          ],
        );
      },
    );
    if (result != null) {
      final id = '${result['label'].toString().toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_')}_${DateTime.now().millisecondsSinceEpoch}';
      final habit = Habit(id: id, label: result['label'] as String, icon: IconData(result['icon'] as int, fontFamily: 'MaterialIcons'));
      setState(() {
        _habits.add(habit);
      });
      try {
        await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).addHabitDef(id: id, label: habit.label, iconCodePoint: habit.icon.codePoint);
      } catch (_) {}
      await StorageService.saveHabitDef({'id': id, 'label': habit.label, 'icon': habit.icon.codePoint});
      try {
        await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).setHabit(id, false);
      } catch (_) {}
      ref.read(_habitsProvider.notifier).state = {
        ...ref.read(_habitsProvider),
        id: false,
      };
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    setState(() {
      _habits.removeWhere((h) => h.id == habit.id);
    });
    try {
      await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).deleteHabitDef(habit.id);
      await HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance).removeHabitKey(habit.id);
    } catch (_) {}
    await StorageService.deleteHabitDef(habit.id);
    final map = {...ref.read(_habitsProvider)};
    map.remove(habit.id);
    ref.read(_habitsProvider.notifier).state = map;
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(_habitsProvider);

    return Stack(
      children: [
        Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.habitsTitle,
                              style: Theme.of(context).textTheme.displaySmall,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.2, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              _formatDateTime(_now),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGray),
                            )
                                .animate()
                                .fadeIn(delay: 50.ms, duration: 400.ms),
                            const SizedBox(height: 12),
                            Text(
                              '${AppStrings.habitsStreak}: $_streak 🔥',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.dark900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 400.ms),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _addHabit,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Habit'),
                        ),
                      ],
                    ),
                  ),

                  // Habits list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        final isCompleted = habits[habit.id] ?? false;

                        return _HabitCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          onToggle: (completed) =>
                              _toggleHabit(habit.id, completed),
                          onDelete: () => _deleteHabit(habit),
                        )
                            .animate(delay: (index * 50).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.2, end: 0);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AnimatedBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabit,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    ),
        // const CounselingFloatingButton(),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                habit.icon,
                color: isCompleted ? AppColors.success : AppColors.primary,
              ),
            )
                .animate(target: isCompleted ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 200.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                  duration: 200.ms,
                ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                habit.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted
                          ? AppColors.mediumGray
                          : AppColors.darkText,
                    ),
              ),
            ),
            Checkbox(
              value: isCompleted,
              onChanged: (value) => onToggle(value ?? false),
              activeColor: AppColors.success,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: AppColors.error,
            ),
          ],
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

class Habit {
  final String id;
  final String label;
  final IconData icon;

  const Habit({
    required this.id,
    required this.label,
    required this.icon,
  });
}
