import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/utils/storage_service.dart';
import '../../../data/models/mood_entry.dart';
import 'package:uuid/uuid.dart';

final _selectedMoodProvider = StateProvider<String?>((ref) => null);

class MoodSelector extends ConsumerStatefulWidget {
  const MoodSelector({super.key});

  @override
  ConsumerState<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends ConsumerState<MoodSelector> {
  final List<MoodOption> _moods = const [
    MoodOption(emoji: '😊', label: AppStrings.moodHappy, color: AppColors.moodHappy),
    MoodOption(emoji: '😐', label: AppStrings.moodOkay, color: AppColors.moodNeutral),
    MoodOption(emoji: '😔', label: AppStrings.moodSad, color: AppColors.moodSad),
    MoodOption(emoji: '😰', label: AppStrings.moodAnxious, color: AppColors.moodAnxiety),
    MoodOption(emoji: '😌', label: AppStrings.moodCalm, color: AppColors.softAqua),
  ];

  Future<void> _selectMood(String mood) async {
    ref.read(_selectedMoodProvider.notifier).state = mood;
    
    // Save mood entry
    final entry = MoodEntry(
      id: const Uuid().v4(),
      mood: mood,
      date: DateTime.now(),
    );
    
    await StorageService.addMoodEntry(entry.toJson());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood recorded: $mood'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = ref.watch(_selectedMoodProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySkyBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _moods.map((mood) {
          final isSelected = selectedMood == mood.label;
          return GestureDetector(
            onTap: () => _selectMood(mood.label),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: mood.color.withOpacity(isSelected ? 1.0 : 0.2),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primarySkyBlue, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.primarySkyBlue : AppColors.lightGray300,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}
