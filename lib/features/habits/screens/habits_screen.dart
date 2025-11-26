import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../core/utils/storage_service.dart';

final _habitsProvider = StateProvider<Map<String, bool>>((ref) => {});

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final ConfettiController _confettiController = ConfettiController();
  int _streak = 0;

  final List<Habit> _habits = const [
    Habit(id: 'water', label: AppStrings.habitsDrinkWater, icon: Icons.water_drop_outlined),
    Habit(id: 'meditate', label: AppStrings.habitsMeditate, icon: Icons.self_improvement_outlined),
    Habit(id: 'journal', label: AppStrings.habitsJournal, icon: Icons.edit_note_outlined),
    Habit(id: 'stretch', label: AppStrings.habitsStretching, icon: Icons.fitness_center_outlined),
    Habit(id: 'walk', label: AppStrings.habitsWalk, icon: Icons.directions_walk_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _loadStreak();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final habits = await StorageService.getHabits();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final Map<String, bool> completed = {};
    for (final habit in _habits) {
      final habitData = habits[habit.id];
      if (habitData != null && habitData['date']?.toString().startsWith(today) == true) {
        completed[habit.id] = habitData['completed'] ?? false;
      } else {
        completed[habit.id] = false;
      }
    }
    ref.read(_habitsProvider.notifier).state = completed;
  }

  Future<void> _loadStreak() async {
    final streak = await StorageService.getHabitStreak();
    setState(() {
      _streak = streak;
    });
  }

  Future<void> _toggleHabit(String habitId, bool completed) async {
    await StorageService.updateHabit(habitId, completed);
    ref.read(_habitsProvider.notifier).state = {
      ...ref.read(_habitsProvider),
      habitId: completed,
    };

    // Check if all habits completed
    final allCompleted = ref.read(_habitsProvider).values.every((v) => v || ref.read(_habitsProvider)[habitId] == true);
    if (completed && allCompleted) {
      _confettiController.play();
      // Increase streak
      final newStreak = _streak + 1;
      await StorageService.setHabitStreak(newStreak);
      setState(() {
        _streak = newStreak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(_habitsProvider);

    return Scaffold(
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
                            const SizedBox(height: 16),
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
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const _HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
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

